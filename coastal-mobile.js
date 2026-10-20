/* Progressive mobile controls. Existing desktop markup/handlers stay intact. */
(() => {
 'use strict';
 const dialog=document.getElementById('hg-coast');if(!dialog)return;
 const panel=dialog.querySelector('.coast-photo-panel'),counter=dialog.querySelector('.coast-counter'),button=dialog.querySelector('.coast-gallery-button');if(!panel||!counter||!button)return;
 const media=matchMedia('(max-width:620px)'),original=button.textContent;
 let dots=panel.querySelector('.coast-mobile-dots');if(!dots){dots=document.createElement('div');dots.className='coast-mobile-dots';dots.setAttribute('aria-hidden','true');panel.append(dots)}
 function update(){const [current,rawTotal]=counter.textContent.split('/').map(t=>Number.parseInt(t.trim(),10));const total=counter.hidden?0:rawTotal;if(!media.matches){button.textContent=original;dots.replaceChildren();return}if(total>0){button.textContent=`▧ ${current} / ${total} · Galerie foto`;dots.replaceChildren();if(total>1)for(let i=1;i<=Math.min(total,6);i++){const dot=document.createElement('span');dot.className=(i===current||i===6&&current>=6)?'active':'';dots.append(dot)}}else{button.textContent='Galerie foto';dots.replaceChildren()}}
 const observer=new MutationObserver(update);observer.observe(counter,{childList:true,characterData:true,subtree:true,attributes:true,attributeFilter:['hidden']});media.addEventListener('change',update);update();
})();
