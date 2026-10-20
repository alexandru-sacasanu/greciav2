/* Decorate existing cards without replacing click handlers or fetching data. */
(function(){'use strict';
function decorate(container,offers,selection){
 if(typeof container==='string')container=document.querySelector(container);if(!container)return;
 container.querySelectorAll('[data-view]').forEach(button=>{
 const offer=offers.find(o=>String(o.id)===button.dataset.view),body=button.closest('.card-body');if(!offer||!body)return;
 body.querySelector('.hg-offer-extra')?.remove();
 const extra=document.createElement('div');extra.className='hg-offer-extra';
 const rating=document.createElement('p');rating.className='hg-offer-rating';rating.textContent=HGBooking.rating(offer);extra.append(rating);
 const s=typeof selection==='function'?selection(offer):selection;
 if(s?.start_date){try{const v=HGBooking.quote(offer,s),duration=document.createElement('p'),total=document.createElement('p');duration.className='hg-offer-period';duration.textContent='▣ '+v.label+(offer.type==='rental'?' · '+s.quantity+' vehicule':'');total.className='hg-offer-total';total.textContent=v.total_amount==null?'Preț la cerere':'Total estimat: '+HGBooking.money(v.total_amount,v.currency);extra.append(duration,total)}catch(error){const note=document.createElement('p');note.className='hg-offer-period';note.textContent=error.message;extra.append(note)}}
 body.insertBefore(extra,body.querySelector('.price-row'));
 });
}
window.HGOfferCards={decorate};
})();
