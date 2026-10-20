/* UI estimates only. Supply authoritative totals separately when connecting payments. */
(function(root){
'use strict';
const DAY=86400000;
function date(s){if(!/^\d{4}-\d{2}-\d{2}$/.test(s||''))throw Error('Alege o dată validă.');const t=Date.parse(s+'T00:00:00Z');if(!Number.isFinite(t)||new Date(t).toISOString().slice(0,10)!==s)throw Error('Dată invalidă.');return t;}
function quote(o,s){
 const expected={accommodation:['night'],rental:['day'],excursion:['person','trip'],cruise:['person','trip']};if(o.price_unit&&!expected[o.type]?.includes(o.price_unit))throw Error('Unitatea de preț necesită un calcul personalizat.');
 const start=date(s.start_date),q=Number(s.quantity);if(!Number.isInteger(q)||q<1||q>100)throw Error('Cantitate invalidă.');
 if(o.available_from&&s.start_date<o.available_from)throw Error('Oferta este disponibilă începând cu '+o.available_from+'.');
 if(o.available_to&&((s.end_date&&s.end_date>o.available_to)||s.start_date>o.available_to))throw Error('Oferta este disponibilă până la '+o.available_to+'.');
 if(o.type==='accommodation'&&o.capacity&&q>o.capacity)throw Error('Numărul de oaspeți depășește capacitatea.');
 let duration=1,multiplier=1,label;
 if(['accommodation','rental'].includes(o.type)){duration=(date(s.end_date)-start)/DAY;if(duration<1||duration>365)throw Error('Alege o perioadă între 1 și 365 de zile.');multiplier=duration*(o.type==='rental'?q:1);label=duration+(o.type==='accommodation'?(duration===1?' noapte':' nopți'):(duration===1?' zi':' zile'));}
 else if(['excursion','cruise'].includes(o.type)){label=q+(q===1?' participant':' participanți');multiplier=o.price_unit==='trip'?1:q;}
 else throw Error('Tip de ofertă invalid.');
 const explicit=Number.isSafeInteger(o.price_minor)&&o.price_minor>=0;
 const cents=explicit?o.price_minor:(o.price_from==null?null:Math.round(Number(o.price_from)*100));
 const total=cents==null?null:cents*multiplier;if(total!=null&&(!Number.isSafeInteger(total)||total<0))throw Error('Preț invalid.');
 return {duration,multiplier,label,unit_amount:cents,total_amount:total,currency:o.currency||'EUR',is_final:false};
}
function money(cents,currency='EUR'){return new Intl.NumberFormat('ro-RO',{style:'currency',currency}).format(cents/100);}
function rating(r){const n=Number(r?.review_count),v=Number(r?.rating_average);return n>0&&Number.isInteger(n)&&v>=1&&v<=5?`★ ${v.toLocaleString('ro-RO',{maximumFractionDigits:1,minimumFractionDigits:1})} · ${n} ${n===1?'recenzie':'recenzii'}`:'Fără recenzii';}
const api={quote,money,rating,date};if(typeof module!=='undefined')module.exports=api;else root.HGBooking=api;
})(globalThis);
