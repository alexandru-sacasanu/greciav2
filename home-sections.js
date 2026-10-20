/* UI only: no backend, no automatic filtering and no external requests. */
(function(){
 'use strict';
 const instances=new WeakMap();
 function init(target='#hg-home-sections',initial={}){
  const root=typeof target==='string'?document.querySelector(target):target;
  if(!root)throw Error('Containerul secțiunilor nu există.');
  if(instances.has(root)){const existing=instances.get(root);existing.configure(initial);return existing;}
  let options={onCategory:null,onDestination:null,onContact:null},destroyed=false;
  const status=root.querySelector('.hgh-status');
  function setStatus(message){status.textContent=message||'';status.hidden=!message;}
  function imageUrl(value){try{if(typeof value!=='string'||!value.trim())return '';const url=new URL(value,document.baseURI);return ['https:','http:','file:'].includes(url.protocol)?url.href:''}catch{return ''}}
  function configure(config={}){
   options={...options,...config};
   for(const [key,image] of Object.entries(config.images||{})){
    const url=imageUrl(typeof image==='string'?image:image?.src);if(!url)continue;
    root.querySelectorAll('[data-image]').forEach(el=>{if(el.dataset.image!==key)return;el.hidden=false;el.src=url;if(image&&typeof image==='object'&&image.alt!=null)el.alt=String(image.alt)});
   }
   if(Array.isArray(config.faq)){
    const list=root.querySelector('.hgh-faq-list');list.replaceChildren();
    config.faq.forEach(item=>{const details=document.createElement('details'),summary=document.createElement('summary'),text=document.createElement('p');summary.textContent=String(item.question||'');text.textContent=String(item.answer||'');details.append(summary,text);list.append(details)});
   }
  }
  function onClick(event){
   const button=event.target.closest('[data-hgh-action]');if(!button||!root.contains(button))return;
   const action=button.dataset.hghAction,value=button.dataset.value||null;
   const callback={category:options.onCategory,destination:options.onDestination,contact:options.onContact}[action];
   setStatus('');
   if(typeof callback==='function'){
    try{Promise.resolve(callback(value,{root,action})).catch(()=>{if(!destroyed)setStatus('Această acțiune nu poate fi deschisă momentan.')});}
    catch{setStatus('Această acțiune nu poate fi deschisă momentan.');}
   }else root.dispatchEvent(new CustomEvent('hg:home-action',{bubbles:true,cancelable:true,detail:{action,value}}));
  }
  // Native details is fully usable without JS. No toggle coordination: avoids queued-toggle races.
  function onImageError(event){
   if(event.target.tagName!=='IMG')return;
   const image=event.target;
   image.hidden=true;
   if(image.dataset.image==='feature')setStatus('Fotografia croazierei nu s-a încărcat. Verifică fișierul sailing.webp și calea folderului home-premium-assets.');
  }
  root.addEventListener('click',onClick);root.addEventListener('error',onImageError,true);
  const api={configure,setStatus,destroy(){destroyed=true;root.removeEventListener('click',onClick);root.removeEventListener('error',onImageError,true);instances.delete(root)}};
  instances.set(root,api);configure(initial);return api;
 }
 window.HGHomeSections={init,configure(config){return init().configure(config)}};
 if(document.getElementById('hg-home-sections'))init();
})();
