/* UI only. No network requests, Stripe SDK, database code or payment simulation. */
(function(){
'use strict';
const root=document.getElementById('hg-checkout');if(!root)return;
const q=s=>root.querySelector(s),form=q('form');
let state=null,options={},paymentReady=false,busy=false,version=0,previousFocus=null;
function imageUrl(value){if(typeof value!=='string'||!value.trim())return '';try{const u=new URL(value,document.baseURI);return ['https:','http:','file:'].includes(u.protocol)?u.href:''}catch{return ''}}
function formatDate(s){return new Date(HGBooking.date(s)).toLocaleDateString('ro-RO',{day:'numeric',month:'short',year:'numeric',timeZone:'UTC'})}
function sync(){q('.hgc-pay').disabled=!state||!paymentReady||busy||typeof options.onPay!=='function'||!state.quote?.authoritative||state.quote.total_amount<=0;}
function paintQuote(){const v=state.quote;const el=q('.hgc-breakdown');el.replaceChildren();for(const item of v.items){const row=document.createElement('p'),name=document.createElement('span'),amount=document.createElement('span');name.textContent=item.label;amount.textContent=HGBooking.money(item.amount_minor,v.currency);row.append(name,amount);el.append(row)}q('.hgc-total-label').textContent=v.authoritative?'Total de plată':'Total estimat';q('.hgc-total-amount').textContent=v.total_amount==null?'—':HGBooking.money(v.total_amount,v.currency);q('.hgc-pay').textContent=v.total_amount==null?'Continuă către plată':'Plătește '+HGBooking.money(v.total_amount,v.currency)+' →';q('.hgc-price-note').textContent=v.authoritative?'Suma afișată va fi debitată la plată.':'Prețul final și disponibilitatea se verifică înainte de plată.';sync();}
function setQuote(quote){if(!state)throw Error('Deschide checkoutul înainte de setQuote.');if(busy)throw Error('Plata este în curs.');if(!Number.isSafeInteger(quote.total_amount)||quote.total_amount<=0||!Array.isArray(quote.items)||!quote.items.length||!quote.items.every(i=>typeof i.label==='string'&&Number.isSafeInteger(i.amount_minor))||quote.items.reduce((s,i)=>s+i.amount_minor,0)!==quote.total_amount)throw Error('Totalul trebuie să corespundă liniilor din sumar.');HGBooking.money(quote.total_amount,quote.currency);state.quote={total_amount:quote.total_amount,currency:quote.currency,items:quote.items.map(i=>({...i})),authoritative:true};paintQuote();}
function open(payload,config={}){
 if(busy)throw Error('Plata este în curs.');const {offer,selection}=payload;const estimate=HGBooking.quote(offer,selection);version++;previousFocus=root.hidden?document.activeElement:previousFocus;options=config;paymentReady=false;busy=false;
 state={offer:{...offer},selection:{...selection},quote:{...estimate,authoritative:false,items:estimate.total_amount==null?[]:[{label:HGBooking.money(estimate.unit_amount,estimate.currency)+' × '+estimate.multiplier,amount_minor:estimate.total_amount}]}};
 form.reset();q('.hgc-status').textContent='';q('.hgc-offer-title').textContent=offer.title;q('.hgc-location').textContent=[offer.locality,offer.destination_name].filter(Boolean).join(', ');q('.hgc-rating').textContent=HGBooking.rating(offer);
 q('.hgc-date-range').textContent=formatDate(selection.start_date)+(selection.end_date&&['accommodation','rental'].includes(offer.type)?' – '+formatDate(selection.end_date):'');
 q('.hgc-duration').textContent=estimate.label+(offer.type==='accommodation'?' · '+selection.quantity+' oaspeți':offer.type==='rental'?' · '+selection.quantity+' vehicule':'');
 const photo=offer.photos?.[0],url=imageUrl(typeof photo==='string'?photo:photo?.url||offer.cover_url);const img=q('.hgc-photo');img.hidden=!url;if(url){img.src=url;img.alt=(typeof photo==='object'?photo.alt:'')||offer.title}else img.removeAttribute('src');
 const bg=imageUrl(config.backgroundUrl);root.style.setProperty('--hgc-scene',bg?'url('+JSON.stringify(bg)+')':'none');
 [['.hgc-terms',config.termsUrl],['.hgc-cancellation',config.cancellationUrl]].forEach(([sel,value])=>root.querySelectorAll(sel).forEach(a=>{const href=imageUrl(value);if(href)a.href=href;else a.removeAttribute('href')}));
 for(const [key,value] of Object.entries(config.contact||{})){if(form.elements[key]&&key!=='terms')form.elements[key].value=String(value)}
 q('.hgc-express-wrap').hidden=true;q('.hgc-payment-placeholder').hidden=false;q('.hgc-payment-note').textContent='Metoda de plată nu este disponibilă momentan.';
 q('#hgc-payment-element').replaceChildren();q('#hgc-express-element').replaceChildren();
 paintQuote();root.hidden=false;q('#hgc-title').focus();return {paymentElement:q('#hgc-payment-element'),expressElement:q('#hgc-express-element')};
}
function close(){if(busy)return false;version++;root.hidden=true;paymentReady=false;sync();previousFocus?.isConnected&&previousFocus.focus();options.onClose?.();return true;}
function setPaymentReady(ready){paymentReady=!!ready;q('.hgc-payment-placeholder').hidden=paymentReady;q('.hgc-payment-note').textContent=paymentReady?'':'Metoda de plată nu este disponibilă momentan.';sync();}
function setExpressAvailable(available){q('.hgc-express-wrap').hidden=!available;}
function status(message){q('.hgc-status').textContent=message||'';}
async function pay(expressEvent){
 if(!state||busy)return;
 if(!form.reportValidity())return;
 if(!paymentReady||!state.quote.authoritative||typeof options.onPay!=='function'){status('Plata nu este disponibilă momentan.');return;}
 const token=version;busy=true;sync();q('.hgc-back').disabled=q('.hgc-edit').disabled=true;status('Procesăm plata…');
 const contact=Object.fromEntries(['first_name','last_name','email','phone'].map(k=>[k,form.elements[k].value.trim()]));
 try{await options.onPay({offer:{...state.offer},selection:{...state.selection},quote:{...state.quote,items:state.quote.items.map(x=>({...x}))},contact,termsAccepted:form.elements.terms.checked,expressEvent});if(token===version)status('Așteptăm confirmarea plății.');}
 catch(error){if(token===version)status(error.message||'Plata nu a putut fi finalizată.');}
 finally{if(token===version){busy=false;sync();q('.hgc-back').disabled=q('.hgc-edit').disabled=false;}}
}
form.addEventListener('submit',event=>{event.preventDefault();pay()});
function back(){if(busy)return;if(options.onBack)options.onBack();else close();}
q('.hgc-back').onclick=back;q('.hgc-edit').onclick=back;
q('.hgc-photo').addEventListener('error',()=>{q('.hgc-photo').hidden=true});
window.HGCheckout={open,close,setQuote,setPaymentReady,setExpressAvailable,setStatus:status,submit:pay,getMountPoints:()=>({paymentElement:q('#hgc-payment-element'),expressElement:q('#hgc-express-element')})};
})();
