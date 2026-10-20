/* Încarcă la sfârșitul paginii, după app.js, datele cardurilor și loader-manifest.js. */
(() => {
 'use strict';
 const el=document.getElementById('hg-loader'),safety=window.HGLoaderSafety;
 if(!el||!safety||window.HGLoader)return;
 const q=s=>el.querySelector(s),stats={total:0,settled:0,loaded:0,failed:0,errors:[],dataStatus:'pending'};
 const clamp=(value,min,max,fallback)=>Number.isFinite(Number(value))?Math.max(min,Math.min(max,Number(value))):fallback;
 let started=null;
 function normalize(src){if(typeof src!=='string'||!src.trim())return '';try{const u=new URL(src,document.baseURI);u.hash='';return ['https:','http:','file:'].includes(u.protocol)?u.href:'';}catch{return '';}}
 function unique(items){return [...new Set(items.map(normalize).filter(Boolean))];}
 function allPlaces(){return ['HG_PIN_PLACES','HG_VILLAGE_PLACES','HG_FOREST_PLACES','HG_HARBOR_PLACES','HG_ROAD_PLACES','HG_PENINSULA_PLACES'].map(key=>window[key]).filter(Boolean);}
 function photos(root){const found=[];function walk(value,depth){if(!value||depth>8)return;if(Array.isArray(value)){value.forEach(v=>walk(v,depth+1));return;}if(typeof value==='object'){if(Array.isArray(value.photos))value.photos.forEach(p=>found.push(typeof p==='string'?p:p?.url));Object.entries(value).forEach(([key,v])=>{if(key!=='photos')walk(v,depth+1);});}}walk(root,0);return found;}
 function slug(){try{const d=typeof currentDestination==='function'?currentDestination():null;return String(d?.slug||document.getElementById('scene')?.dataset.destination||'').toLocaleLowerCase('ro-RO');}catch{return '';}}
 function collect(mode='all',config={}){
  const manifest=window.HG_LOADER_ASSETS||{},declared=Array.isArray(manifest)?manifest:(manifest.all||[]),critical=Array.isArray(manifest)?[]:(manifest.critical||[]);
  const current=slug(),groups=allPlaces(),doc=[...document.images].map(img=>img.currentSrc||img.getAttribute('src'));
  const visible=[...document.querySelectorAll('#scene img,header img,[data-loader-critical],#hg-loader img')].map(img=>img.currentSrc||img.getAttribute('src'));
  const full=unique([...critical,...declared,...doc,...groups.flatMap(photos),...(config.extraAssets||[])]);
  const first=unique([...critical,...visible,...groups.flatMap(group=>photos(group[current])),...(config.extraCritical||[])]);
  return {required:mode==='current'?first:full,background:unique([...(mode==='current'?full:[]),...(manifest.background||[]),...(config.backgroundAssets||[])])};
 }
 function loadImage(src,timeoutMs){return new Promise(resolve=>{
  let done=false;const img=new Image();let timer;
  function finish(ok,reason){if(done)return;done=true;clearTimeout(timer);img.onload=img.onerror=null;resolve({src,ok,reason});}
  img.onload=()=>{if(typeof img.decode==='function')img.decode().then(()=>finish(true),()=>finish(false,'decode'));else finish(true);};
  img.onerror=()=>finish(false,'network');timer=setTimeout(()=>finish(false,'timeout'),timeoutMs);img.src=src;
  if(img.complete&&img.naturalWidth>0)img.onload();
 });}
 let shown=0,raf=null;
 function paint(){if(safety.done)return;const percent=stats.total?Math.round(stats.settled/stats.total*100):100;
  if(raf)cancelAnimationFrame(raf);
  const step=()=>{shown+=(percent-shown)*0.12;if(Math.abs(percent-shown)<0.5)shown=percent;
   q('.hg-loader-fill').style.transform=`scaleX(${shown/100})`;q('.hg-loader-percent').textContent=Math.round(shown)+'%';q('.hg-loader-track').setAttribute('aria-valuenow',String(Math.round(shown)));
   if(shown!==percent)raf=requestAnimationFrame(step);};
  step();
 }
 function indeterminate(){if(safety.done)return;el.classList.add('hg-loader-indeterminate');q('.hg-loader-track').removeAttribute('aria-valuenow');q('.hg-loader-percent').textContent='…';}
 function warm(urls,timeoutMs){if(!urls.length)return;const run=async()=>{let index=0;await Promise.all(Array.from({length:2},async()=>{while(index<urls.length){const src=urls[index++];await loadImage(src,timeoutMs);}}));};if(typeof requestIdleCallback==='function')requestIdleCallback(()=>run(),{timeout:4000});else setTimeout(()=>run(),1200);}
 function start(options={}){
  if(started)return started;
  const config={...(window.HG_LOADER_CONFIG||{}),...options},mode=config.mode==='current'?'current':'all';
  const maxWait=clamp(config.maxWaitMs,1000,16000,15000),imageTimeout=clamp(config.imageTimeoutMs,1000,12000,8000),dataWait=clamp(config.dataWaitMs,0,10000,7000),concurrency=Math.round(clamp(config.concurrency,1,8,4));
  const minWait=clamp(config.minWaitMs,0,10000,4000);
  started=safety.finished.then(result=>({...result,...stats,errors:[...stats.errors]}));
  if(safety.done)return started;
  const startTime=Date.now(),releaseRaw=safety.release;
  safety.release=reason=>{const wait=minWait-(Date.now()-startTime);if(wait>0)setTimeout(()=>releaseRaw(reason),wait);else releaseRaw(reason);};
  for(const child of document.body.children){if(child===el||['SCRIPT','STYLE','LINK'].includes(child.tagName))continue;safety.inert.push([child,!!child.inert]);child.inert=true;}
  const deadline=setTimeout(()=>safety.release('timeout'),maxWait);safety.finished.then(()=>clearTimeout(deadline));
  (async()=>{
   indeterminate();let dataTimer;
   const readiness=window.HG_READY;
   if(readiness&&typeof readiness.then==='function'){
    stats.dataStatus=await Promise.race([Promise.resolve(readiness).then(()=>'ready',()=>'error'),new Promise(resolve=>{dataTimer=setTimeout(()=>resolve('timeout'),dataWait);})]);clearTimeout(dataTimer);
   }else stats.dataStatus='not-provided';
   if(safety.done)return;
   const {required,background}=collect(mode,config);let next=0;
   const seen=new Set(),jobs=required.map(src=>({src}));
   if(document.fonts?.ready)jobs.push({font:true});
   stats.total=jobs.length;el.classList.remove('hg-loader-indeterminate');q('.hg-loader-status').textContent='Se încarcă imaginile destinației…';paint();
   async function worker(){while(next<jobs.length&&!safety.done){const job=jobs[next++];let result;
    if(job.font){let fontTimer;result=await Promise.race([Promise.resolve(document.fonts.ready).then(()=>({ok:true}),()=>({ok:false,reason:'font'})),new Promise(resolve=>{fontTimer=setTimeout(()=>resolve({ok:false,reason:'font-timeout'}),imageTimeout);})]);clearTimeout(fontTimer);}
    else{seen.add(job.src);result=await loadImage(job.src,imageTimeout);}
    stats.settled++;if(result.ok)stats.loaded++;else{stats.failed++;stats.errors.push({src:job.src||'fonts',reason:result.reason});}paint();
   }}
   await Promise.all(Array.from({length:Math.min(concurrency,Math.max(1,jobs.length))},worker));
   if(!safety.done){q('.hg-loader-status').textContent=stats.failed?'Pregătire încheiată. Unele imagini nu sunt disponibile.':'Site-ul este pregătit.';safety.release('ready');}
   // Resursele neîncepute pot continua fără să blocheze pagina.
   if(config.warmBackground!==false)warm(unique([...background,...required.filter(src=>!seen.has(src))]).filter(src=>!seen.has(src)),imageTimeout);
  })().catch(error=>{stats.errors.push({src:'loader',reason:String(error?.message||error)});safety.release('error');});
  return started;
 }
 window.HGLoader={start,collect,stats};
 if(window.HG_LOADER_CONFIG?.autoStart!==false){if(document.readyState==='loading')document.addEventListener('DOMContentLoaded',()=>start(),{once:true});else start();}
})();
