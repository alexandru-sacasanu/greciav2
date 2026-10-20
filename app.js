'use strict';
const $=s=>document.querySelector(s),$$=s=>[...document.querySelectorAll(s)],E=HG.escape;
const staticScenes={lefkada:{src:'assets/lefkada-animated-base.png',boat:[68,78,7],positions:[[35,60],[76,40],[44,37]],pins:['Porto Katsiki','Satul de pe coastă','Drumuri cu panoramă']},halkidiki:{src:'assets/halkidiki-animated-base.png',boat:[20,78,5],positions:[[48,53],[78,45],[26,38]],pins:['Golfuri din Sithonia','Sate de pe coastă','Peninsulele Halkidiki']},thasos:{src:'assets/thasos-animated-base.png',boat:[53,80,5.5],positions:[[34,57],[72,53],[53,35]],pins:['Golfuri de marmură','Portul insulei','Păduri și panorame']}};
let destinations=[],offers=[],settings={},current='',category='accommodation',onlyFavorites=false,guestFilter=null,loadError=false;
const favorites=new Set(),dialog=$('#details'),reduced=matchMedia('(prefers-reduced-motion: reduce)');let paused=reduced.matches;
const demoNames=['Ionian Blue Villas','Sunset Bay Apartments','Aegean View Suites'];
function demoData(){destinations=['Lefkada','Halkidiki','Thasos'].map((name,i)=>({id:name.toLowerCase(),slug:name.toLowerCase(),name,sort_order:i,show_yacht:true}));offers=destinations.flatMap(d=>demoNames.map((title,i)=>({id:d.id+i,destination_id:d.id,type:'accommodation',title,locality:['La malul mării','Golf liniștit','Sat de coastă'][i],price_from:[142,98,126][i],currency:'EUR',price_unit:'night',summary:'Exemplu de cazare pentru prezentarea designului.',description:'Conectează Supabase pentru a gestiona propriile oferte și fotografii.',amenities:[],demoPhoto:['photo-1613490493576-7fde63acd811','photo-1571896349842-33c89424de2d','photo-1566073771259-6a8506099945'][i]})))}
function show(title,content){$('#dialog-title').textContent=title;$('#dialog-body').replaceChildren();if(typeof content==='string')$('#dialog-body').textContent=content;else $('#dialog-body').append(content);dialog.showModal()}
function applySettings(){if(!settings.id)return;$$('[data-label]').forEach(el=>{const text=settings.ui_labels?.[el.dataset.label];if(typeof text==='string')el.textContent=text});$('.intro h1').textContent=settings.hero_title;$('.intro>p').textContent=settings.hero_subtitle;$('#search .primary').textContent=settings.search_label;$('.section-top h2').textContent=settings.section_title;$('#footer-text').textContent=settings.footer_text;$('footer small').textContent='© '+new Date().getFullYear()+' '+settings.brand_name;document.title=settings.brand_name+' — '+settings.hero_title;$$('.brand').forEach(a=>{a.replaceChildren();const img=document.createElement('img');img.src=settings.logo?HG.mediaUrl(settings.logo):'assets/logo.png';img.alt=settings.brand_name||'Hello Grecia';img.className='brand-logo'+(a.closest('footer')?' brand-logo-footer':'');a.append(img)});const contact=$('#contact-link');contact.href=settings.contact_email?'mailto:'+encodeURIComponent(settings.contact_email):'#about';const trusts=$$('.trust>div');trusts.forEach((d,i)=>{d.querySelector('b').textContent=settings['trust_title_'+(i+1)];d.querySelector('span').textContent=settings['trust_text_'+(i+1)]});['primary_color','background_color','text_color'].forEach((k,i)=>{if(/^#[0-9a-f]{6}$/i.test(settings[k]))document.documentElement.style.setProperty(['--blue','--cream','--ink'][i],settings[k])});if(settings.yacht)$('.yacht').src=HG.mediaUrl(settings.yacht);motion()}
function currentDestination(){return destinations.find(d=>d.id===current)}
function renderNavigation(){$('#destination').innerHTML=destinations.map(d=>`<option value="${E(d.id)}">${E(d.name)}</option>`).join('');$('#destinations').innerHTML=destinations.map(d=>`<button data-dest="${E(d.id)}" aria-pressed="false">${E(d.name)}</button>`).join('');$('#destination').disabled=!destinations.length;$('#search .primary').disabled=!destinations.length}
function select(id){const d=destinations.find(x=>x.id===id);if(!d)return;current=id;const scene=staticScenes[d.slug],sceneEl=$('#scene'),img=$('#scene > img'),yacht=$('.yacht-layer'),nextSrc=d.hero?HG.mediaUrl(d.hero):(d.hero_local_path||scene.src);
 function apply(){img.src=nextSrc;img.alt=d.hero_alt||d.hero?.alt_text||`Panoramă ilustrată ${d.name}`;applyScene()}
 if(img.src.endsWith(nextSrc)||matchMedia('(prefers-reduced-motion: reduce)').matches){apply()}
 else{const preload=new Image();preload.onload=preload.onerror=()=>{sceneEl.style.opacity='0';setTimeout(()=>{apply();sceneEl.style.opacity='1'},250)};preload.src=nextSrc}
 function applyScene(){yacht.style.left=(d.boat_x??scene.boat[0])+'%';yacht.style.top=(d.boat_y??scene.boat[1])+'%';yacht.style.width=(d.boat_width??scene.boat[2])+'%';yacht.hidden=d.show_yacht===false;$$('[data-place]').forEach((pin,i)=>{pin.hidden=d.show_pins===false;pin.dataset.place=scene.pins[i];pin.style.left=scene.positions[i][0]+'%';pin.style.top=scene.positions[i][1]+'%';pin.setAttribute('aria-label','Descoperă '+scene.pins[i]);const label=pin.querySelector('span');if(label)label.textContent=scene.pins[i]});$('#scene').dataset.destination=d.name;$('#destination').value=id;$$('[data-dest]').forEach(b=>{b.classList.toggle('active',b.dataset.dest===id);b.setAttribute('aria-pressed',String(b.dataset.dest===id))});render()}
}
function images(o){return(o.offer_images||[]).slice().sort((a,b)=>a.sort_order-b.sort_order).map(i=>i.media).filter(Boolean)}
function price(o){if(o.price_from==null)return 'Preț la cerere';try{return new Intl.NumberFormat('ro-RO',{style:'currency',currency:o.currency}).format(o.price_from)}catch{return o.price_from+' '+o.currency}}
function render(){const dest=currentDestination();let data=offers.filter(o=>o.destination_id===current);data=data.filter(o=>['car','atv'].includes(category)?o.type==='rental'&&o.rental_kind===category:o.type===category);if(onlyFavorites)data=data.filter(o=>favorites.has(o.id));if(guestFilter)data=data.filter(o=>!['accommodation','rental'].includes(o.type)||o.capacity==null||o.capacity>=guestFilter);
 $('#cards').innerHTML=data.map(o=>{const photo=images(o)[0],url=photo?HG.mediaUrl(photo):(o.photos?.[0]?.url||(o.demoPhoto?`https://images.unsplash.com/${o.demoPhoto}?auto=format&fit=crop&w=800&q=85`:''));return `<article class="card" data-view="${o.id}"><div class="photo">${url?`<img src="${E(url)}" alt="${E(photo?.alt_text||o.title)}" loading="lazy">`:'<span class="photo-empty">Fotografii în curând</span>'}${o.featured?'<span class="rating">Recomandată</span>':''}<button class="heart" aria-label="Salvează ${E(o.title)}" aria-pressed="${favorites.has(o.id)}" data-save="${o.id}">${favorites.has(o.id)?'♥':'♡'}</button></div><div class="card-body"><h3>${E(o.title)}</h3><p class="location">⌖ ${E(o.locality||dest?.name)}</p><div class="price-row"><div><b>${E(price(o))}</b><small>${o.price_from==null?'': '/ '+E(HG.units[o.price_unit]||'')}</small></div><button class="view" data-view="${o.id}">Vezi oferta ↗</button></div></div></article>`}).join('')||`<p class="empty-state">${loadError?'Conținutul nu a putut fi încărcat. Reîncarcă pagina sau încearcă mai târziu.':onlyFavorites?'Nu ai favorite în această categorie și destinație.':'Nu există oferte publicate pentru această selecție.'}</p>`;
 $('#count').textContent=favorites.size;$('#favorites').setAttribute('aria-pressed',String(onlyFavorites));$('#result').textContent=dest?`${data.length} oferte · ${dest.name}${guestFilter?' · '+guestFilter+' persoane':''}`:'Nicio destinație disponibilă';$$('[data-type]').forEach(b=>{b.classList.toggle('active',b.dataset.type===category);b.setAttribute('aria-pressed',String(b.dataset.type===category))});
 window.HGOfferCards?.decorate('#cards',data,o=>({start_date:$('#checkin')?.value||'',end_date:$('#checkout')?.value||'',quantity:o.type==='rental'?1:Number($('#guests')?.value||2)}))}
function openOffer(id) {
  const offer = offers.find(item => item.id === id);
  if (!offer) return;
  const destination = destinations.find(item => item.id === offer.destination_id);

  const offerPhotos = images(offer).length
    ? images(offer).map(media => ({
        url: HG.mediaUrl(media),
        alt: media.alt_text || offer.title
      }))
    : (Array.isArray(offer.photos) && offer.photos.length)
      ? offer.photos
      : (offer.demoPhoto
          ? [{ url: `https://images.unsplash.com/${offer.demoPhoto}?auto=format&fit=crop&w=1200&q=85`, alt: offer.title }]
          : []);

  window.HGOfferModal.open({
    ...offer,
    destination_name: destination?.name || '',
    photos: offerPhotos
  }, {
    contactEmail: settings.contact_email,
    isFavorite: offerId => favorites.has(offerId),
    onFavorite: offerId => {
      favorites.has(offerId)
        ? favorites.delete(offerId)
        : favorites.add(offerId);
      render();
    },
    onCheckout: ({ offer: checkoutOffer, selection }) => {
      window.HGOfferModal.close();
      window.HGCheckout.open({ offer: checkoutOffer, selection }, {
        backgroundUrl: destination?.hero ? HG.mediaUrl(destination.hero) : undefined,
        onBack: () => {
          window.HGCheckout.close();
          openOffer(id);
        },
        onPay: async () => {
          throw Error('Plata nu este configurată încă. Contactează-ne pentru rezervare.');
        }
      });
    }
  });
}
const sampleOffers = [
  {
    id: 'sample-atv-lefkada',
    destination_slug: 'lefkada',
    type: 'rental',
    rental_kind: 'atv',
    title: 'ATV 450cc 4x4 Off-Road Adventure',
    slug: 'atv-450cc-4x4-lefkada',
    locality: 'Vassiliki, Lefkada',
    price_from: 65,
    currency: 'EUR',
    price_unit: 'day',
    capacity: 2,
    transmission: 'Automată',
    engine_cc: 450,
    fuel: 'Benzină',
    featured: true,
    summary: 'Explorează plajele ascunse și traseele montane din Lefkada cu un ATV puternic și sigur.',
    description: 'Vehicul de teren 450cc 4x4, perfect pentru drumurile de munte spre plajele izolate precum Egremni și Porto Katsiki. Include căști de protecție pentru 2 persoane, cutie de depozitare sigilată și asistență rutieră 24/7 pe toată insula.',
    amenities: ['Căști incluse', 'Kilometri nelimitați', 'Asistență 24/7', 'Asigurare inclusă', 'Suport telefon USB'],
    includes_text: '2 căști de protecție omologate, suport telefon cu încărcare USB, plin de combustibil la preluare, hartă turistică a traseelor off-road.',
    contact_text: 'Preluare direct din portul Vassiliki sau livrare gratuită la cazarea ta.',
    photos: [
      { url: 'https://images.unsplash.com/photo-1558981403-c5f9899a28bc?auto=format&fit=crop&w=1200&q=85', alt: 'ATV pe drum panoramic de coastă' },
      { url: 'https://images.unsplash.com/photo-1509316975850-ff9c5deb0cd9?auto=format&fit=crop&w=1200&q=85', alt: 'Traseu montan off-road' },
      { url: 'https://images.unsplash.com/photo-1568772585407-9361f9bf3a87?auto=format&fit=crop&w=1200&q=85', alt: 'ATV pregătit de aventură' }
    ]
  },
  {
    id: 'sample-atv-thasos',
    destination_slug: 'thasos',
    type: 'rental',
    rental_kind: 'atv',
    title: 'Polaris 570cc Quad Safari Explorer',
    slug: 'polaris-570cc-thasos',
    locality: 'Limenas, Thasos',
    price_from: 75,
    currency: 'EUR',
    price_unit: 'day',
    capacity: 2,
    transmission: 'Automată',
    engine_cc: 570,
    fuel: 'Benzină',
    featured: true,
    summary: 'Confort maxim și tracțiune integrală pentru descoperirea cascadelor și vârfurilor din Thasos.',
    description: 'Modelul premium Polaris Sportsman 570 oferă suspensie independentă și servodirecție EPS, ideal pentru urcarea spre Vârful Ipsarion sau golfurile izolate de marmură.',
    amenities: ['Tracțiune 4x4 decuplabilă', 'Servodirecție EPS', 'Cutie depozitare spate', 'Asigurare completă'],
    includes_text: 'Echipament complet de protecție, instrucтаж tehnic detaliat, asistență non-stop pe insulă.',
    contact_text: 'Punct de preluare în Limenas sau livrare la hotel.',
    photos: [
      { url: 'https://images.unsplash.com/photo-1568772585407-9361f9bf3a87?auto=format&fit=crop&w=1200&q=85', alt: 'Polaris Quad Safari' },
      { url: 'https://images.unsplash.com/photo-1558981403-c5f9899a28bc?auto=format&fit=crop&w=1200&q=85', alt: 'Peisaj montan Thasos' }
    ]
  },
  {
    id: 'sample-atv-halkidiki',
    destination_slug: 'halkidiki',
    type: 'rental',
    rental_kind: 'atv',
    title: 'Yamaha Grizzly 700cc Coast & Hills',
    slug: 'yamaha-grizzly-halkidiki',
    locality: 'Sithonia, Halkidiki',
    price_from: 80,
    currency: 'EUR',
    price_unit: 'day',
    capacity: 2,
    transmission: 'Automată',
    engine_cc: 700,
    fuel: 'Benzină',
    featured: false,
    summary: 'Putere brută și manevrabilitate excelentă pentru plajele sălbatice din peninsula Sithonia.',
    description: 'Explorează peninsulele de smarald ale peninsulei Halkidiki cu cel mai robust ATV din flotă. Perfect pentru drumurile de pământ spre golfurile ascunse dintre Vourvourou și Sarti.',
    amenities: ['Motor 700cc injecție', 'Troliu frontal', 'Căști incluse', 'Asistență tehnică'],
    includes_text: '2 căști, plin de combustibil la ridicare, suport telefon cu GPS.',
    contact_text: 'Livrări disponibile în toată peninsula Sithonia.',
    photos: [
      { url: 'https://images.unsplash.com/photo-1509316975850-ff9c5deb0cd9?auto=format&fit=crop&w=1200&q=85', alt: 'Yamaha ATV în natură' },
      { url: 'https://images.unsplash.com/photo-1558981403-c5f9899a28bc?auto=format&fit=crop&w=1200&q=85', alt: 'Traseu de coastă Sithonia' }
    ]
  },
  {
    id: 'sample-cruise-lefkada',
    destination_slug: 'lefkada',
    type: 'cruise',
    title: 'Croazieră pe Arhipelagul Scorpios & Meganisi',
    slug: 'croaziera-scorpios-meganisi-lefkada',
    locality: 'Nydri, Lefkada',
    price_from: 45,
    currency: 'EUR',
    price_unit: 'person',
    capacity: 45,
    duration_minutes: 420,
    featured: true,
    summary: 'O zi de vis navigând prin cele mai frumoase ape turcoaz din Marea Ionică.',
    description: 'Plecare din portul Nydri la bordul unui vas panoramic confortabil. Opriri pentru înot la plaja Egremni, vizitarea celebrei peșteri maritime Papanikolis din Meganisi și înconjurul insulei legendare Scorpios. La bord se servește un prânz tradițional grecesc.',
    amenities: ['Prânz tradițional inclus', 'Băuturi răcoritoare și vin local', 'Echipament snorkeling', 'Punte de plajă cu șezlonguri', 'Ghid turistic'],
    includes_text: 'Prânz cu souvlaki sau opțiune vegetariană, salată grecească, vin local, fructe de sezon, veste de salvare și echipament de snorkeling.',
    contact_text: 'Îmbarcare la ora 09:30 din portul Nydri (digul central).',
    photos: [
      { url: 'https://images.unsplash.com/photo-1544551763-46a013bb70d5?auto=format&fit=crop&w=1200&q=85', alt: 'Yacht navigând ape turcoaz' },
      { url: 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=1200&q=85', alt: 'Plajă izolată din arhipelag' },
      { url: 'https://images.unsplash.com/photo-1510525009512-ad7fc0c0281b?auto=format&fit=crop&w=1200&q=85', alt: 'Puntea vasului la apus' }
    ]
  },
  {
    id: 'sample-cruise-halkidiki',
    destination_slug: 'halkidiki',
    type: 'cruise',
    title: 'Croazieră cu Catamaranul în Golful Toroneos',
    slug: 'croaziera-catamaran-toroneos-halkidiki',
    locality: 'Neos Marmaras, Sithonia',
    price_from: 85,
    currency: 'EUR',
    price_unit: 'person',
    capacity: 12,
    duration_minutes: 360,
    featured: true,
    summary: 'Eleganță, intimitate și ape de cristal pe un catamaran modern cu grup restrâns.',
    description: 'Croazieră exclusivistă de o zi între brațele Kassandra și Sithonia. Opriri în golfuri virgine inaccesibile de pe uscat, insula Kelifos (Insula Țestoasă) pentru snorkeling printre recife, paddleboarding și prânz mediteranean proaspăt preparat la bord.',
    amenities: ['Catamaran modern de lux', 'Open bar & gustări gourmet', 'Plăci SUP (Stand-Up Paddle)', 'Wi-Fi prin satelit la bord'],
    includes_text: 'Platouri mediteraneene cu fructe de mare, salate proaspete, vin alb grecesc, bere, băuturi răcoritoare și echipament complet de snorkeling.',
    contact_text: 'Plecare la 10:00 din Marina Neos Marmaras.',
    photos: [
      { url: 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=1200&q=85', alt: 'Ape limpezi în Golful Toroneos' },
      { url: 'https://images.unsplash.com/photo-1544551763-46a013bb70d5?auto=format&fit=crop&w=1200&q=85', alt: 'Catamaran pe mare' }
    ]
  },
  {
    id: 'sample-cruise-thasos',
    destination_slug: 'thasos',
    type: 'cruise',
    title: 'Turul Golfului de Marmură cu Velierul Tradițional',
    slug: 'tur-velier-marmura-thasos',
    locality: 'Limenas, Thasos',
    price_from: 55,
    currency: 'EUR',
    price_unit: 'person',
    capacity: 16,
    duration_minutes: 300,
    featured: false,
    summary: 'Navigație relaxantă spre Marble Beach, Porto Vathy și insula nelocuită Panagia.',
    description: 'Descoperă contrastul hipnotizant dintre marmura albă a falezelor și apa de un turcoaz intens. O croazieră autentică cu velier de lemn, pescuit la bord și prânz cu pește proaspăt la grătar.',
    amenities: ['Prânz cu pește la grătar', 'Echipament pescuit și snorkeling', 'Muzică tradițională', 'Grup restrâns'],
    includes_text: 'Prânz complet, băuturi, cafea grecească, fructe și echipament de baie.',
    contact_text: 'Portul vechi Limenas, pontonul de ambarcațiuni tradiționale.',
    photos: [
      { url: 'https://images.unsplash.com/photo-1510525009512-ad7fc0c0281b?auto=format&fit=crop&w=1200&q=85', alt: 'Velier tradițional în Thasos' },
      { url: 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=1200&q=85', alt: 'Marble Beach văzută de pe mare' }
    ]
  },
  {
    id: 'sample-acc-lefkada',
    destination_slug: 'lefkada',
    type: 'accommodation',
    title: 'Aura Marine Luxury Villa & Private Pool',
    slug: 'aura-marine-luxury-villa-lefkada',
    locality: 'Agios Nikitas, Lefkada',
    price_from: 240,
    currency: 'EUR',
    price_unit: 'night',
    capacity: 6,
    bedrooms: 3,
    bathrooms: 3,
    featured: true,
    summary: 'Vilă exclusivistă cocoțată pe stâncă, cu piscină infinită și apusuri spectaculoase.',
    description: 'Design contemporan mediteranean armonizat cu piatră naturală. Dormitoare elegante cu paturi king-size și băi ensuite, terasă panoramică generoasă cu șezlonguri, zonă de dining exterior și cărare privată spre plaja Mylos.',
    amenities: ['Piscină infinită privată', 'Vedere panoramică la mare', 'Parcare privată gratuită', 'Wi-Fi de mare viteză', 'Aer condiționat centralizat', 'Zonă grătar BBQ'],
    includes_text: 'Coș de bun venit cu produse locale (ulei de măsline, vin, miere), prosoape de plajă, curățenie zilnică.',
    contact_text: 'Check-in flexibil cu cutie de chei cu cod sau întâmpinare personală.',
    photos: [
      { url: 'https://images.unsplash.com/photo-1566073771259-6a8506099945?auto=format&fit=crop&w=1200&q=85', alt: 'Vilă de lux cu piscină infinită' },
      { url: 'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?auto=format&fit=crop&w=1200&q=85', alt: 'Dormitor elegant cu vedere la mare' },
      { url: 'https://images.unsplash.com/photo-1571896349842-33c89424de2d?auto=format&fit=crop&w=1200&q=85', alt: 'Terasă panoramică spre apus' }
    ]
  },
  {
    id: 'sample-acc-halkidiki',
    destination_slug: 'halkidiki',
    type: 'accommodation',
    title: 'Sani Horizon Beachfront Suites',
    slug: 'sani-horizon-suites-halkidiki',
    locality: 'Kassandra, Halkidiki',
    price_from: 175,
    currency: 'EUR',
    price_unit: 'night',
    capacity: 4,
    bedrooms: 2,
    bathrooms: 2,
    featured: true,
    summary: 'Suite premium la 50m de plajă, înconjurate de pini mediteraneeni aromați.',
    description: 'Situate în renumita zonă Sani, suitele combină confortul de 5 stele cu liniștea naturii. Grădină privată, acces direct pe alee spre nisipul auriu și terasă umbrită pentru relaxare la prânz.',
    amenities: ['La 50m de plajă', 'Grădină privată', 'Bucătărie complet utilată', 'Smart TV & Netflix', 'Parcare inclusă'],
    includes_text: 'Șezlonguri și umbrelă rezervate pe plajă, curățenie și lenjerii proaspete la 2 zile.',
    contact_text: 'Recepție deschisă 24/7 și asistență turistică dedicată.',
    photos: [
      { url: 'https://images.unsplash.com/photo-1571896349842-33c89424de2d?auto=format&fit=crop&w=1200&q=85', alt: 'Suită la malul mării' },
      { url: 'https://images.unsplash.com/photo-1613490493576-7fde63acd811?auto=format&fit=crop&w=1200&q=85', alt: 'Exterior și terasă privată' }
    ]
  },
  {
    id: 'sample-acc-thasos',
    destination_slug: 'thasos',
    type: 'accommodation',
    title: 'Olive Grove Boutique Villa & Spa',
    slug: 'olive-grove-villa-thasos',
    locality: 'Golden Beach, Thasos',
    price_from: 140,
    currency: 'EUR',
    price_unit: 'night',
    capacity: 5,
    bedrooms: 2,
    bathrooms: 1,
    featured: false,
    summary: 'Vila autentică din piatră înconjurată de măslini seculari, la 200m de Golden Beach.',
    description: 'O oază de liniște și tradiție. Tavane înalte cu grinzi de lemn, decor cald inspirat din insulele grecești, curte spațioasă cu foișor și zonă de grătar din piatră pentru serile calde de vară.',
    amenities: ['Curte mare cu măslini', 'Zonă grătar BBQ', 'Balcon cu vedere la Muntele Ipsarion', 'Wi-Fi gratuit', 'AC'],
    includes_text: 'Cafea grecească, ceai din plante montane din Thasos, prosoape și consumabile de baie.',
    contact_text: 'Gazdă locală prietenoasă, suport disponibil în limba română.',
    photos: [
      { url: 'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?auto=format&fit=crop&w=1200&q=85', alt: 'Vilă tradițională în livadă de măslini' },
      { url: 'https://images.unsplash.com/photo-1590490360182-c33d57733427?auto=format&fit=crop&w=1200&q=85', alt: 'Interior rustic mediteranean' }
    ]
  },
  {
    id: 'sample-exc-thasos',
    destination_slug: 'thasos',
    type: 'excursion',
    title: 'Turul Insulei & Laguna Naturală Giola',
    slug: 'turul-insulei-giola-thasos',
    locality: 'Potos, Thasos',
    price_from: 35,
    currency: 'EUR',
    price_unit: 'person',
    capacity: 25,
    duration_minutes: 360,
    featured: true,
    summary: 'O zi completă: celebra piscină naturală Giola, mănăstiri istorice și satul Theologos.',
    description: 'Excursie ghidată cu autocar climatizat. Vizită la celebra „Piscina Sirenelor” (Giola), oprire la Mănăstirea Arhanghelul Mihail suspendată pe stâncă și prânz opțional în satul Theologos renumit pentru friptura tradițională de ied.',
    amenities: ['Autocar climatizat', 'Ghid vorbitor de română', 'Degustare miere de pin și ulei extravirgin'],
    includes_text: 'Transport dus-întors de la hotel, ghid autorizat, vizite ghidate și degustare de produse locale.',
    contact_text: 'Preluare dimineața direct de la hotelul sau vila ta.',
    photos: [
      { url: 'https://images.unsplash.com/photo-1533105079780-92b9be482077?auto=format&fit=crop&w=1200&q=85', alt: 'Punct de belvedere panoramic Thasos' },
      { url: 'https://images.unsplash.com/photo-1469854523086-cc02fe5d8800?auto=format&fit=crop&w=1200&q=85', alt: 'Traseu spre laguna Giola' }
    ]
  },
  {
    id: 'sample-exc-lefkada',
    destination_slug: 'lefkada',
    type: 'excursion',
    title: 'Safari Montan & Cascadele Dimosari',
    slug: 'safari-montan-dimosari-lefkada',
    locality: 'Nydri, Lefkada',
    price_from: 40,
    currency: 'EUR',
    price_unit: 'person',
    capacity: 18,
    duration_minutes: 240,
    featured: false,
    summary: 'Drumeție prin defileul răcoros spre cascadele Dimosari și satele montane tradiționale.',
    description: 'Evadează de la căldura plajei într-o drumeție umbrită de-a lungul râului, printre stânci albe și bazine naturale cu apă cristalină de munte. Încheiem la o tavernă autentică din satul Karia.',
    amenities: ['Ghid montan', 'Băuturi răcoritoare incluse', 'Traseu accesibil familiilor'],
    includes_text: 'Transfer de la punctul de întâlnire, ghidaj profesionist, sticlă de apă reutilizabilă.',
    contact_text: 'Plecare din parcarea principală Nydri la ora 09:00.',
    photos: [
      { url: 'https://images.unsplash.com/photo-1469854523086-cc02fe5d8800?auto=format&fit=crop&w=1200&q=85', alt: 'Cascade și traseu montan' },
      { url: 'https://images.unsplash.com/photo-1533105079780-92b9be482077?auto=format&fit=crop&w=1200&q=85', alt: 'Sat montan tradițional' }
    ]
  },
  {
    id: 'sample-car-lefkada',
    destination_slug: 'lefkada',
    type: 'rental',
    rental_kind: 'car',
    title: 'Suzuki Jimny 4x4 Cabriolet',
    slug: 'suzuki-jimny-4x4-lefkada',
    locality: 'Lefkada Town',
    price_from: 55,
    currency: 'EUR',
    price_unit: 'day',
    capacity: 4,
    transmission: 'Manuală',
    engine_cc: 1500,
    fuel: 'Benzină',
    featured: true,
    summary: 'Cel mai apreciat vehicul 4x4 pentru explorarea plajelor vestice ale Lefkadei.',
    description: 'Compact, manevrabil și decapotabil. Gardă la sol ridicată pentru a coborî fără emoții spre plajele Porto Katsiki, Egremni sau Kathisma. Plafon pliabil pentru a te bucura din plin de briza mării.',
    amenities: ['Tracțiune 4x4 decuplabilă', 'Aer condiționat', 'Plafon decapotabil', 'Asigurare CASCO inclusă', 'Kilometri nelimitați'],
    includes_text: 'Asigurare completă CDW fără franșiză, al doilea șofer gratuit, asistență rutieră pe insulă.',
    contact_text: 'Predare gratuită la cazare sau în portul Lefkada.',
    photos: [
      { url: 'https://images.unsplash.com/photo-1533473359331-0135ef1b58bf?auto=format&fit=crop&w=1200&q=85', alt: 'Suzuki Jimny 4x4' }
    ]
  },
  {
    id: 'sample-car-halkidiki',
    destination_slug: 'halkidiki',
    type: 'rental',
    rental_kind: 'car',
    title: 'Fiat 500 Hybrid Dolce Vita Cabrio',
    slug: 'fiat-500-cabrio-halkidiki',
    locality: 'Kallithea, Kassandra',
    price_from: 42,
    currency: 'EUR',
    price_unit: 'day',
    capacity: 4,
    transmission: 'Manuală',
    engine_cc: 1000,
    fuel: 'Hibrid',
    featured: false,
    summary: 'Stil italian și consum redus pentru drumurile panoramice dintre golfurile din Halkidiki.',
    description: 'Ideal pentru cupluri. Ușor de parcat în satele aglomerate de coastă, decapotabil electric și foarte economic datorită motorizării Mild Hybrid.',
    amenities: ['Plafon textil electric', 'Apple CarPlay / Android Auto', 'Senzori parcare', 'Consum redus 4.5L/100km'],
    includes_text: 'Kilometri nelimitați, asigurare de bază, curățenie inclusă.',
    contact_text: 'Preluare din Kallithea sau livrare direct la aeroportul Salonic.',
    photos: [
      { url: 'https://images.unsplash.com/photo-1549399542-7e3f8b79c341?auto=format&fit=crop&w=1200&q=85', alt: 'Fiat 500 Cabriolet' }
    ]
  }
];
function getSampleOffers(destList) {
  return sampleOffers.map(o => {
    const d = destList.find(x => x.slug === o.destination_slug || x.id === o.destination_slug);
    return { ...o, destination_id: d?.id || o.destination_slug };
  });
}
$('#destinations').onclick=e=>{const b=e.target.closest('[data-dest]');if(b){guestFilter=null;select(b.dataset.dest)}};$('#destination').onchange=e=>{guestFilter=null;select(e.target.value)};
$('#offer-types').onclick=e=>{const b=e.target.closest('[data-type]');if(b){category=b.dataset.type;render()}};
$('#cards').onclick=e=>{const save=e.target.closest('[data-save]');if(save){const id=save.dataset.save;favorites.has(id)?favorites.delete(id):favorites.add(id);render();return}const view=e.target.closest('[data-view]');if(view)openOffer(view.dataset.view)};
$('#favorites').onclick=()=>{onlyFavorites=!onlyFavorites;render();$('#stays').scrollIntoView({behavior:'smooth'})};
function localDate(d){return `${d.getFullYear()}-${String(d.getMonth()+1).padStart(2,'0')}-${String(d.getDate()).padStart(2,'0')}`}
const today=new Date(),start=new Date(today);start.setDate(start.getDate()+7);const end=new Date(start);end.setDate(end.getDate()+7);$('#checkin').min=localDate(today);$('#checkin').value=localDate(start);$('#checkout').value=localDate(end);
function dates(){const d=new Date($('#checkin').value+'T12:00:00');d.setDate(d.getDate()+1);$('#checkout').min=localDate(d);if($('#checkout').value<$('#checkout').min)$('#checkout').value=$('#checkout').min}$('#checkin').onchange=dates;dates();
$('#search').onsubmit=e=>{e.preventDefault();dates();onlyFavorites=false;guestFilter=Number($('#guests').value);select($('#destination').value);$('#stays').scrollIntoView({behavior:'smooth'})};
$$('[data-place]').forEach(b=>b.onclick=()=>show(b.dataset.place,currentDestination()?.description||`Explorează ${currentDestination()?.name}. Punctele sunt ilustrative, nu coordonate exacte.`));
$$('.close,.close-dialog').forEach(b=>b.onclick=()=>dialog.close());dialog.onclick=e=>{if(e.target===dialog){const r=dialog.getBoundingClientRect();if(e.clientX<r.left||e.clientX>r.right||e.clientY<r.top||e.clientY>r.bottom)dialog.close()}};
function motion(){const disabled=paused||settings.show_animation===false;document.body.classList.toggle('paused',disabled)}reduced.addEventListener('change',e=>{paused=e.matches;motion()});motion();
$('#scene').onpointermove=e=>{if(paused||settings.show_animation===false||reduced.matches||e.pointerType==='touch')return;const r=e.currentTarget.getBoundingClientRect();e.currentTarget.style.setProperty('--ry',`${(e.clientX-r.left-r.width/2)/r.width*1.6}deg`);e.currentTarget.style.setProperty('--rx',`${-(e.clientY-r.top-r.height/2)/r.height*.8}deg`)};$('#scene').onpointerleave=e=>{e.currentTarget.style.setProperty('--ry','0deg');e.currentTarget.style.setProperty('--rx','0deg')};
async function init(){if(!HG.configured){demoData();$('#catalog-note').textContent='Mod demonstrativ. Completează config.js pentru a folosi propriul conținut din Supabase.'}else{try{const db=await HG.client();const result=await Promise.all([db.from('destinations').select('*,hero:media!hero_media_id(*)').eq('is_active',true).order('sort_order').order('id'),db.from('offers').select('*,offer_images(sort_order,media:media(*))').eq('status','published').order('sort_order').order('id'),db.from('site_settings').select('*,logo:media!logo_media_id(*),yacht:media!yacht_media_id(*)').single()]);[destinations,offers,settings]=result.map(HG.unwrap);const sampleList=getSampleOffers(destinations),existingIds=new Set(offers.map(o=>o.id));offers=[...offers,...sampleList.filter(s=>!existingIds.has(s.id))];$('#catalog-note').textContent='Prețurile sunt orientative. Confirmă disponibilitatea și condițiile prin contact. Datele selectate nu verifică disponibilitatea în timp real.';applySettings()}catch{loadError=true;destinations=[];offers=[];$('#catalog-note').textContent='Conexiunea la catalog nu este disponibilă. Nu se afișează date demonstrative.'}}
 renderNavigation();if(destinations.length)select(destinations[0].id);else{$('.scene-wrap').hidden=true;render()}}
window.HGHomeSections?.configure({
  onCategory: value => { category = value; render(); $('#stays').scrollIntoView({ behavior: 'smooth' }); },
  onDestination: value => { const d = destinations.find(x => x.slug === value); if (d) select(d.id); $('#stays').scrollIntoView({ behavior: 'smooth' }); },
  onContact: () => { $('#contact-link').click(); }
});
window.HG_READY=init();
