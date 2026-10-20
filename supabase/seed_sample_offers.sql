-- Script pentru inserarea ofertelor de probă direct în baza de date Supabase.
-- Rulează acest script în Supabase Dashboard -> SQL Editor ca postgres.

begin;

do $$
declare
  dest_lefkada uuid;
  dest_halkidiki uuid;
  dest_thasos uuid;
begin
  select id into dest_lefkada from public.destinations where slug = 'lefkada';
  select id into dest_halkidiki from public.destinations where slug = 'halkidiki';
  select id into dest_thasos from public.destinations where slug = 'thasos';

  -- 1. ATV Lefkada
  insert into public.offers (
    destination_id, type, rental_kind, slug, title, summary, description,
    locality, price_from, currency, price_unit, capacity,
    amenities, includes_text, contact_text, status, featured, sort_order
  ) values (
    dest_lefkada, 'rental', 'atv', 'atv-450cc-4x4-lefkada',
    'ATV 450cc 4x4 Off-Road Adventure',
    'Explorează plajele ascunse și traseele montane din Lefkada cu un ATV puternic și sigur.',
    'Vehicul de teren 450cc 4x4, perfect pentru drumurile de munte spre plajele izolate precum Egremni și Porto Katsiki. Include căști de protecție pentru 2 persoane, cutie de depozitare sigilată și asistență rutieră 24/7 pe toată insula.',
    'Vassiliki, Lefkada', 65, 'EUR', 'day', 2,
    array['Căști incluse', 'Kilometri nelimitați', 'Asistență 24/7', 'Asigurare inclusă', 'Suport telefon USB'],
    '2 căști de protecție omologate, suport telefon cu încărcare USB, plin de combustibil la preluare, hartă turistică a traseelor off-road.',
    'Preluare direct din portul Vassiliki sau livrare gratuită la cazarea ta.',
    'published', true, 1
  ) on conflict (destination_id, slug) do nothing;

  -- 2. ATV Thasos
  insert into public.offers (
    destination_id, type, rental_kind, slug, title, summary, description,
    locality, price_from, currency, price_unit, capacity,
    amenities, includes_text, contact_text, status, featured, sort_order
  ) values (
    dest_thasos, 'rental', 'atv', 'polaris-570cc-thasos',
    'Polaris 570cc Quad Safari Explorer',
    'Confort maxim și tracțiune integrală pentru descoperirea cascadelor și vârfurilor din Thasos.',
    'Modelul premium Polaris Sportsman 570 oferă suspensie independentă și servodirecție EPS, ideal pentru urcarea spre Vârful Ipsarion sau golfurile izolate de marmură.',
    'Limenas, Thasos', 75, 'EUR', 'day', 2,
    array['Tracțiune 4x4 decuplabilă', 'Servodirecție EPS', 'Cutie depozitare spate', 'Asigurare completă'],
    'Echipament complet de protecție, instrucтаж tehnic detaliat, asistență non-stop pe insulă.',
    'Punct de preluare în Limenas sau livrare la hotel.',
    'published', true, 1
  ) on conflict (destination_id, slug) do nothing;

  -- 3. Croazieră Lefkada
  insert into public.offers (
    destination_id, type, slug, title, summary, description,
    locality, price_from, currency, price_unit, capacity, duration_minutes,
    amenities, includes_text, contact_text, status, featured, sort_order
  ) values (
    dest_lefkada, 'cruise', 'croaziera-scorpios-meganisi-lefkada',
    'Croazieră pe Arhipelagul Scorpios & Meganisi',
    'O zi de vis navigând prin cele mai frumoase ape turcoaz din Marea Ionică.',
    'Plecare din portul Nydri la bordul unui vas panoramic confortabil. Opriri pentru înot la plaja Egremni, vizitarea celebrei peșteri maritime Papanikolis din Meganisi și înconjurul insulei legendare Scorpios. La bord se servește un prânz tradițional grecesc.',
    'Nydri, Lefkada', 45, 'EUR', 'person', 45, 420,
    array['Prânz tradițional inclus', 'Băuturi răcoritoare și vin local', 'Echipament snorkeling', 'Punte de plajă cu șezlonguri', 'Ghid turistic'],
    'Prânz cu souvlaki sau opțiune vegetariană, salată grecească, vin local, fructe de sezon, veste de salvare și echipament de snorkeling.',
    'Îmbarcare la ora 09:30 din portul Nydri (digul central).',
    'published', true, 1
  ) on conflict (destination_id, slug) do nothing;

  -- 4. Croazieră Halkidiki
  insert into public.offers (
    destination_id, type, slug, title, summary, description,
    locality, price_from, currency, price_unit, capacity, duration_minutes,
    amenities, includes_text, contact_text, status, featured, sort_order
  ) values (
    dest_halkidiki, 'cruise', 'croaziera-catamaran-toroneos-halkidiki',
    'Croazieră cu Catamaranul în Golful Toroneos',
    'Eleganță, intimitate și ape de cristal pe un catamaran modern cu grup restrâns.',
    'Croazieră exclusivistă de o zi între brațele Kassandra și Sithonia. Opriri în golfuri virgine inaccesibile de pe uscat, insula Kelifos (Insula Țestoasă) pentru snorkeling printre recife, paddleboarding și prânz mediteranean proaspăt preparat la bord.',
    'Neos Marmaras, Sithonia', 85, 'EUR', 'person', 12, 360,
    array['Catamaran modern de lux', 'Open bar & gustări gourmet', 'Plăci SUP (Stand-Up Paddle)', 'Wi-Fi prin satelit la bord'],
    'Platouri mediteraneene cu fructe de mare, salate proaspete, vin alb grecesc, bere, băuturi răcoritoare și echipament complet de snorkeling.',
    'Plecare la 10:00 din Marina Neos Marmaras.',
    'published', true, 1
  ) on conflict (destination_id, slug) do nothing;

  -- 5. Cazare Lefkada (Vila)
  insert into public.offers (
    destination_id, type, slug, title, summary, description,
    locality, price_from, currency, price_unit, capacity, bedrooms,
    amenities, includes_text, contact_text, status, featured, sort_order
  ) values (
    dest_lefkada, 'accommodation', 'aura-marine-luxury-villa-lefkada',
    'Aura Marine Luxury Villa & Private Pool',
    'Vilă exclusivistă cocoțată pe stâncă, cu piscină infinită și apusuri spectaculoase.',
    'Design contemporan mediteranean armonizat cu piatră naturală. Dormitoare elegante cu paturi king-size și băi ensuite, terasă panoramică generoasă cu șezlonguri, zonă de dining exterior și cărare privată spre plaja Mylos.',
    'Agios Nikitas, Lefkada', 240, 'EUR', 'night', 6, 3,
    array['Piscină infinită privată', 'Vedere panoramică la mare', 'Parcare privată gratuită', 'Wi-Fi de mare viteză', 'Aer condiționat centralizat', 'Zonă grătar BBQ'],
    'Coș de bun venit cu produse locale (ulei de măsline, vin, miere), prosoape de plajă, curățenie zilnică.',
    'Check-in flexibil cu cutie de chei cu cod sau întâmpinare personală.',
    'published', true, 1
  ) on conflict (destination_id, slug) do nothing;

  -- 6. Cazare Thasos
  insert into public.offers (
    destination_id, type, slug, title, summary, description,
    locality, price_from, currency, price_unit, capacity, bedrooms,
    amenities, includes_text, contact_text, status, featured, sort_order
  ) values (
    dest_thasos, 'accommodation', 'olive-grove-villa-thasos',
    'Olive Grove Boutique Villa & Spa',
    'Vila autentică din piatră înconjurată de măslini seculari, la 200m de Golden Beach.',
    'O oază de liniște și tradiție. Tavane înalte cu grinzi de lemn, decor cald inspirat din insulele grecești, curte spațioasă cu foișor și zonă de grătar din piatră pentru serile calde de vară.',
    'Golden Beach, Thasos', 140, 'EUR', 'night', 5, 2,
    array['Curte mare cu măslini', 'Zonă grătar BBQ', 'Balcon cu vedere la Muntele Ipsarion', 'Wi-Fi gratuit', 'AC'],
    'Cafea grecească, ceai din plante montane din Thasos, prosoape și consumabile de baie.',
    'Gazdă locală prietenoasă, suport disponibil în limba română.',
    'published', false, 2
  ) on conflict (destination_id, slug) do nothing;

  -- 7. Excursie Thasos
  insert into public.offers (
    destination_id, type, slug, title, summary, description,
    locality, price_from, currency, price_unit, capacity, duration_minutes,
    amenities, includes_text, contact_text, status, featured, sort_order
  ) values (
    dest_thasos, 'excursion', 'turul-insulei-giola-thasos',
    'Turul Insulei & Laguna Naturală Giola',
    'O zi completă: celebra piscină naturală Giola, mănăstiri istorice și satul Theologos.',
    'Excursie ghidată cu autocar climatizat. Vizită la celebra „Piscina Sirenelor” (Giola), oprire la Mănăstirea Arhanghelul Mihail suspendată pe stâncă și prânz opțional în satul Theologos renumit pentru friptura tradițională de ied.',
    'Potos, Thasos', 35, 'EUR', 'person', 25, 360,
    array['Autocar climatizat', 'Ghid vorbitor de română', 'Degustare miere de pin și ulei extravirgin'],
    'Transport dus-întors de la hotel, ghid autorizat, vizite ghidate și degustare de produse locale.',
    'Preluare dimineața direct de la hotelul sau vila ta.',
    'published', true, 1
  ) on conflict (destination_id, slug) do nothing;

  -- 8. Închiriere Mașină Lefkada
  insert into public.offers (
    destination_id, type, rental_kind, slug, title, summary, description,
    locality, price_from, currency, price_unit, capacity,
    amenities, includes_text, contact_text, status, featured, sort_order
  ) values (
    dest_lefkada, 'rental', 'car', 'suzuki-jimny-4x4-lefkada',
    'Suzuki Jimny 4x4 Cabriolet',
    'Cel mai apreciat vehicul 4x4 pentru explorarea plajelor vestice ale Lefkadei.',
    'Compact, manevrabil și decapotabil. Gardă la sol ridicată pentru a coborî fără emoții spre plajele Porto Katsiki, Egremni sau Kathisma. Plafon pliabil pentru a te bucura din plin de briza mării.',
    'Lefkada Town', 55, 'EUR', 'day', 4,
    array['Tracțiune 4x4 decuplabilă', 'Aer condiționat', 'Plafon decapotabil', 'Asigurare CASCO inclusă', 'Kilometri nelimitați'],
    'Asigurare completă CDW fără franșiză, al doilea șofer gratuit, asistență rutieră pe insulă.',
    'Predare gratuită la cazare sau în portul Lefkada.',
    'published', true, 1
  ) on conflict (destination_id, slug) do nothing;

end $$;

commit;
