/* Încarcă după app.js și după fragmentele compas/pini. Nu modifică routerul. */
(() => {
 'use strict';
 const scene=document.getElementById('scene'),host=scene?.closest('.scene-wrap');
 if(!scene||!host||window.HGMobileHome)return;
 document.documentElement.classList.add('hg-mobile-home');
 const viewport=document.createElement('div');viewport.className='hg-mobile-map-viewport';
 viewport.setAttribute('role','region');viewport.setAttribute('aria-label','Hartă ilustrată. Glisează lateral pentru a explora.');
 scene.parentNode.insertBefore(viewport,scene);viewport.appendChild(scene);
 const hint=document.createElement('p');hint.className='hg-mobile-map-hint';
 hint.innerHTML='<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M3 12h18M7 8l-4 4 4 4m10-8 4 4-4 4"/></svg><span>Glisează pentru a explora insula</span>';
 viewport.insertAdjacentElement('afterend',hint);
 const media=matchMedia('(max-width:800px)');let frame=0,lastDestination=scene.dataset.destination,keyboard=false;
 window.addEventListener('keydown',event=>{if(event.key==='Tab')keyboard=true;});
 window.addEventListener('pointerdown',()=>{keyboard=false;},{passive:true});
 function center(){cancelAnimationFrame(frame);frame=requestAnimationFrame(()=>{
  if(!media.matches){viewport.removeAttribute('tabindex');return;}
  viewport.tabIndex=0;viewport.scrollLeft=Math.max(0,(viewport.scrollWidth-viewport.clientWidth)/2);
  hint.hidden=viewport.scrollWidth<=viewport.clientWidth+1;
 });}
 viewport.addEventListener('focusin',event=>{
  if(!media.matches||!keyboard)return;const pin=event.target.closest('button[data-place]');if(!pin)return;
  viewport.scrollLeft=Math.max(0,Math.min(viewport.scrollWidth-viewport.clientWidth,pin.offsetLeft-viewport.clientWidth/2));
 });
 const observer=new MutationObserver(()=>{if(scene.dataset.destination!==lastDestination){lastDestination=scene.dataset.destination;center();}});
 observer.observe(scene,{attributes:true,attributeFilter:['data-destination']});
 media.addEventListener('change',center);window.addEventListener('resize',center,{passive:true});center();
 window.HGMobileHome={center};
})();
