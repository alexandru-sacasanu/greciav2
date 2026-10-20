/* Decorative surf renderer: shared geometric contour, no video/dependencies. */
(() => {
 'use strict';
 const scriptURL=document.currentScript?.src||document.baseURI;
 const dialog=document.getElementById('hg-coast'),box=dialog?.querySelector('.coast-shore'),canvas=box?.querySelector('canvas');
 if(!canvas)return;
 const ctx=canvas.getContext('2d',{alpha:true});if(!ctx)return;
 let width=0,height=0,raf=0,lastTimestamp=0,phaseTime=0,previousTime=null,disposed=false,particlesDrawn=0;
 const textures=(window.HG_WAVE_TEXTURES||[]).map(t=>({...t,ready:false,image:new Image()}));
 const TAU=Math.PI*2;const drySand=new Image();let sandPattern=null;drySand.onload=()=>{sandPattern=ctx.createPattern(drySand,'repeat');sync()};drySand.src=new URL('coast-assets/sand-dry.png',scriptURL).href;
 const particleSeeds=Array.from({length:8},(_,i)=>{const noise=n=>{const x=Math.sin((i+1)*n)*43758.5453;return x-Math.floor(x)};return{y:.025+noise(12.9898)*.95,birth:.385+noise(4.1414)*.11,life:.105+noise(7.173)*.095,travel:1+noise(5.817)*3,lift:.5+noise(2.331)*2,radius:.25+noise(8.197)*.25}});
 function profileAt(a,t){if(!a?.length)return .55;const f=Math.min(a.length-1,Math.max(0,t*(a.length-1))),i=Math.floor(f),j=Math.min(a.length-1,i+1);return a[i]+(a[j]-a[i])*(f-i)}
 // Always the same curve for every layer; never use an unrelated SVG outline.
 function boundary(t){return 72+14*Math.sin(TAU*t+.35)+7*Math.sin(TAU*2*t+1.3)}
 function isOpen(){return dialog.open||dialog.hasAttribute('open')}
 function isPaused(){return dialog.classList.contains('coast-paused')}
 function resize(){const w=box.clientWidth||150,h=box.clientHeight||660,dpr=Math.min(window.devicePixelRatio||1,2);if(w===width&&h===height&&canvas.width===Math.round(w*dpr))return;width=w;height=h;canvas.width=Math.round(w*dpr);canvas.height=Math.round(h*dpr);ctx.setTransform(dpr,0,0,dpr,0,0)}
 function sandPath(advance,scale){ctx.beginPath();ctx.moveTo(width+2,-2);for(let y=0;y<=height+3;y+=3){ctx.lineTo((boundary(Math.min(1,y/height))+advance)*scale,y)}ctx.lineTo(width+2,height+3);ctx.closePath()}
 function draw(){resize();const cycle=phaseTime/7800,theta=cycle*TAU,surge=(1-Math.cos(theta))*.5,advance=-5+surge*14;ctx.clearRect(0,0,width,height);const scale=width/150;
  // Dry grains and the sand boundary stay fixed. Only water advances.
  sandPath(0,scale);if(sandPattern){const size=320/drySand.naturalWidth;try{sandPattern.setTransform({a:size,b:0,c:0,d:size,e:-(box.offsetLeft??-110),f:-(box.offsetTop??-18)})}catch{}}ctx.fillStyle=sandPattern||'#fbf0da';ctx.fill();
  // Analytic wet edge stays coherent even before textures finish loading.
  for(let y=0;y<height;y+=4){const t=y/height,x=boundary(t)*scale;const moisture=.17+.11*(.5+.5*Math.sin(theta-1.15));const grad=ctx.createLinearGradient(x,y,x+26*scale,y);grad.addColorStop(0,`rgba(128,108,70,${moisture})`);grad.addColorStop(1,'rgba(128,108,70,0)');ctx.fillStyle=grad;ctx.fillRect(x,y,30*scale,4)}
  const roles={wet:{offset:13,alpha:.25+.23*(.5+.5*Math.sin(theta-1.25)),spread:84},wash:{offset:-8+surge*2,alpha:.23+.21*surge,spread:140},retreat:{offset:-15+5*Math.sin(theta-.8),alpha:.13+.36*(1-surge),spread:108},front:{offset:0,alpha:.68+.28*surge,spread:145},break:{offset:1,alpha:.045*Math.exp(-Math.pow(((cycle%1)-.49)/.045,2)),spread:140}};
  // Warp short source rows: each texture's measured foam ridge is anchored
  // to boundary(t), so its original silhouette cannot create a second border.
  for(const texture of textures){if(!texture.ready)continue;const role=roles[texture.role];if(!role)continue;const iw=texture.image.naturalWidth,ih=texture.image.naturalHeight;ctx.save();if(texture.role==='wet'){sandPath(0,scale);ctx.clip()}ctx.globalAlpha=role.alpha;for(let y=0;y<height;y+=2){const dh=Math.min(2,height-y),t=(y+dh*.5)/height,sy=y/height*ih,sh=Math.min(ih-sy,ih/height*dh),targetWidth=role.spread*scale,anchor=profileAt(texture.profile,t),x=(boundary(t)+(texture.role==='wet'?0:advance)+role.offset)*scale-anchor*targetWidth;ctx.drawImage(texture.image,0,Math.max(0,sy),iw,sh,x,y,targetWidth,dh)}ctx.restore()}ctx.globalAlpha=1;
  // A restrained contour at the same boundary integrates tiny gaps in the PNG.
  ctx.beginPath();for(let y=0;y<=height;y+=3){const x=(boundary(y/height)+advance)*scale;y?ctx.lineTo(x,y):ctx.moveTo(x,y)}ctx.strokeStyle=`rgba(249,255,250,${.32+.2*surge})`;ctx.lineWidth=2.3*scale;ctx.stroke();
  // Short, deterministic droplets are emitted only as the crest breaks.
  // Positions are confined to the shore canvas, never the text panel.
  particlesDrawn=0;const part=cycle%1;
  for(const p of particleSeeds){const age=(part-p.birth+1)%1;if(age>=p.life)continue;const t=age/p.life,fade=Math.sin(Math.PI*t),birthAdvance=-5+(1-Math.cos(p.birth*TAU))*.5*14,x=(boundary(p.y)+birthAdvance+p.travel*Math.sin(Math.PI*t))*scale,y=p.y*height-p.lift*Math.sin(Math.PI*t);ctx.globalAlpha=.1*fade;ctx.fillStyle='#f6ffff';ctx.beginPath();ctx.ellipse(x,y,p.radius*scale,p.radius*scale*(1.1+.7*fade),-.45,0,TAU);ctx.fill();if(p.radius>.95){ctx.globalAlpha=.25*fade;ctx.strokeStyle='#2cbed1';ctx.lineWidth=.5*scale;ctx.stroke()}particlesDrawn++}ctx.globalAlpha=1;
 }
 function shouldRun(){return !disposed&&isOpen()&&!isPaused()&&!document.hidden}
 function tick(timestamp){raf=0;if(!shouldRun()){previousTime=null;return}if(previousTime!==null)phaseTime+=Math.min(timestamp-previousTime,90);previousTime=timestamp;if(timestamp-lastTimestamp>=33){draw();lastTimestamp=timestamp}raf=requestAnimationFrame(tick)}
 function sync(){if(disposed)return;if(isOpen())draw();if(shouldRun()){if(!raf){previousTime=null;raf=requestAnimationFrame(tick)}}else{if(raf)cancelAnimationFrame(raf);raf=0;previousTime=null}}
 textures.forEach(t=>{t.image.onload=()=>{t.ready=true;sync()};t.image.onerror=()=>{console.warn('Coastal wave texture could not load:',t.src);sync()};t.image.src=new URL(t.src,scriptURL).href});
 const observer=new MutationObserver(sync);observer.observe(dialog,{attributes:true,attributeFilter:['open','class']});const sizeObserver=typeof ResizeObserver!=='undefined'?new ResizeObserver(sync):null;sizeObserver?.observe(box);window.addEventListener('resize',sync);document.addEventListener('visibilitychange',sync);dialog.addEventListener('close',sync);
 window.HGCoastWave={refresh:sync,diagnostics:()=>({loaded:textures.filter(t=>t.ready).length,total:textures.length,paused:isPaused(),running:!!raf,drySandLoaded:!!sandPattern,particles:particlesDrawn,width,height}),destroy(){disposed=true;if(raf)cancelAnimationFrame(raf);observer.disconnect();sizeObserver?.disconnect();window.removeEventListener('resize',sync);document.removeEventListener('visibilitychange',sync);dialog.removeEventListener('close',sync)}};sync();
})();
