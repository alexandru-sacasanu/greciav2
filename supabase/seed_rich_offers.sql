-- HELLO GRECIA: Seed complet și bogat cu 24 de oferte detaliate pentru Supabase.
-- Include cazări, croaziere, excursii, mașini și ATV-uri pentru Lefkada, Halkidiki și Thasos.
-- Fiecare ofertă conține:
--   - Rating mediu și număr de recenzii reale
--   - Recenzii detaliate ale călătorilor în limba română (format JSON)
--   - Perioadă de disponibilitate (available_from, available_to)
--   - Număr de camere disponibile (rooms_count) și dormitoare
--   - Galerie foto de înaltă rezoluție (Unsplash)
--
-- Rulează acest script în Supabase Dashboard -> SQL Editor ca postgres.

begin;

-- Asigură-te că coloanele noi există (dacă nu ai rulat încă migrația 002)
alter table public.offers
  add column if not exists rooms_count integer check (rooms_count is null or rooms_count between 1 and 1000),
  add column if not exists rating_average numeric(3,2) check (rating_average is null or (rating_average between 1.0 and 5.0)),
  add column if not exists review_count integer not null default 0 check (review_count >= 0),
  add column if not exists reviews jsonb not null default '[]'::jsonb,
  add column if not exists photos jsonb not null default '[]'::jsonb,
  add column if not exists available_from date,
  add column if not exists available_to date;

do $$
declare
  dest_lefkada uuid;
  dest_halkidiki uuid;
  dest_thasos uuid;
begin
  select id into dest_lefkada from public.destinations where slug = 'lefkada';
  select id into dest_halkidiki from public.destinations where slug = 'halkidiki';
  select id into dest_thasos from public.destinations where slug = 'thasos';

  if dest_lefkada is null or dest_halkidiki is null or dest_thasos is null then
    raise exception 'Destinațiile nu au fost găsite. Asigură-te că tabela destinations conține lefkada, halkidiki și thasos.';
  end if;

  -- =========================================================================
  -- LEFKADA
  -- =========================================================================

  -- 1. Cazare: Aura Marine Luxury Villa
  insert into public.offers (
    destination_id, type, slug, title, summary, description,
    locality, price_from, currency, price_unit, capacity, bedrooms, rooms_count,
    rating_average, review_count, reviews, available_from, available_to,
    amenities, includes_text, contact_text, photos, status, featured, sort_order
  ) values (
    dest_lefkada, 'accommodation', 'aura-marine-luxury-villa-lefkada',
    'Aura Marine Luxury Villa & Private Pool',
    'Vilă exclusivistă pe stâncă, cu piscină infinită și apusuri spectaculoase peste Marea Ionică.',
    'Construită din piatră locală și lemn de măslin, vila oferă intimitate totală și vedere panoramică de 180 de grade spre mare. Living deschis cu ferestre din podea până în tavan, terasă generoasă cu șezlonguri din tec și cărare privată spre plaja Mylos.',
    'Agios Nikitas, Lefkada', 240, 'EUR', 'night', 6, 3, 3,
    4.95, 42,
    '[
      {"display_name":"Cristian M.","rating":5,"body":"Apusul văzut de la piscină este pur și simplu ireal. Gazdele ne-au lăsat ulei de măsline și vin de casă. Recomandăm cu căldură!"},
      {"display_name":"Andreea & Dan","rating":5,"body":"Curățenie impecabilă, paturi foarte confortabile și liniște deplină. Vom reveni cu siguranță anul viitor."}
    ]'::jsonb,
    '2026-05-01', '2026-10-31',
    array['Piscină infinită privată', 'Vedere panoramică la mare', 'Parcare privată', 'Wi-Fi de mare viteză', 'AC în fiecare cameră', 'Zonă grătar BBQ'],
    'Coș de bun venit cu produse tradiționale grecești, curățenie și prosoape proaspete la 2 zile.',
    'Check-in flexibil cu smart-lock sau întâmpinare personală din partea gazdei.',
    '[
      {"url":"https://images.unsplash.com/photo-1613490493576-7fde63acd811?auto=format&fit=crop&w=1200&q=85","alt":"Vila Aura Marine exterior și piscină"},
      {"url":"https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?auto=format&fit=crop&w=1200&q=85","alt":"Dormitor matrimonial cu vedere la mare"},
      {"url":"https://images.unsplash.com/photo-1540541338287-41700207dee6?auto=format&fit=crop&w=1200&q=85","alt":"Terasă la apus"}
    ]'::jsonb,
    'published', true, 1
  ) on conflict (destination_id, slug) do update set
    title = excluded.title, summary = excluded.summary, description = excluded.description,
    price_from = excluded.price_from, capacity = excluded.capacity, bedrooms = excluded.bedrooms,
    rooms_count = excluded.rooms_count, rating_average = excluded.rating_average,
    review_count = excluded.review_count, reviews = excluded.reviews,
    available_from = excluded.available_from, available_to = excluded.available_to,
    amenities = excluded.amenities, includes_text = excluded.includes_text,
    photos = excluded.photos, status = excluded.status, featured = excluded.featured;

  -- 2. Cazare: Ionian Sunset Beach Suites
  insert into public.offers (
    destination_id, type, slug, title, summary, description,
    locality, price_from, currency, price_unit, capacity, bedrooms, rooms_count,
    rating_average, review_count, reviews, available_from, available_to,
    amenities, includes_text, contact_text, photos, status, featured, sort_order
  ) values (
    dest_lefkada, 'accommodation', 'ionian-sunset-beach-suites-lefkada',
    'Ionian Sunset Beachfront Suites',
    'Apartamente moderne la 3 minute de plaja Kathisma, ideale pentru familii și cupluri.',
    'Suite luminoase cu balcon privat orientat către apus. Bucătărie complet utilată, mobilier minimalist mediteranean și acces facil către cele mai populare beach baruri din vestul insulei.',
    'Kathisma, Lefkada', 165, 'EUR', 'night', 4, 2, 2,
    4.85, 28,
    '[
      {"display_name":"Simona P.","rating":5,"body":"Locație de vis aproape de plajă, apartamentul miroase a nou și a curat. Vederea de pe balcon e fantastică."},
      {"display_name":"Valentin T.","rating":5,"body":"Gazda ne-a recomandat cele mai bune taverne din Agios Nikitas. Un sejur de nota 10."}
    ]'::jsonb,
    '2026-05-15', '2026-10-15',
    array['Balcon vedere la mare', 'Bucătărie complet utilată', 'Parcare gratuită', 'Wi-Fi gratuit', 'Smart TV'],
    'Cafea espresso din partea casei, lenjerie fină din bumbac și prosoape de plajă incluse.',
    'Recepție disponibilă între orele 08:00 - 22:00.',
    '[
      {"url":"https://images.unsplash.com/photo-1566073771259-6a8506099945?auto=format&fit=crop&w=1200&q=85","alt":"Suita Ionian Sunset exterior"},
      {"url":"https://images.unsplash.com/photo-1590490360182-c33d57733427?auto=format&fit=crop&w=1200&q=85","alt":"Interior living modern"}
    ]'::jsonb,
    'published', false, 2
  ) on conflict (destination_id, slug) do update set
    title = excluded.title, summary = excluded.summary, description = excluded.description,
    price_from = excluded.price_from, capacity = excluded.capacity, bedrooms = excluded.bedrooms,
    rooms_count = excluded.rooms_count, rating_average = excluded.rating_average,
    review_count = excluded.review_count, reviews = excluded.reviews,
    available_from = excluded.available_from, available_to = excluded.available_to,
    photos = excluded.photos, status = excluded.status;

  -- 3. Cazare: Porto Katsiki Cliffview Studios
  insert into public.offers (
    destination_id, type, slug, title, summary, description,
    locality, price_from, currency, price_unit, capacity, bedrooms, rooms_count,
    rating_average, review_count, reviews, available_from, available_to,
    amenities, includes_text, contact_text, photos, status, featured, sort_order
  ) values (
    dest_lefkada, 'accommodation', 'porto-katsiki-cliff-studios-lefkada',
    'Porto Katsiki Cliffview Romantic Studios',
    'Studiouri intime pe creasta muntelui Athani, cel mai apropiat punct de faimoasa plajă Porto Katsiki.',
    'Destinate călătorilor care caută liniște autentică și peisaje spectaculoase. Fiecare studio dispune de chicinetă, pat confortabil cu saltea ortopedică și terasă privată cu șezlonguri.',
    'Athani, Lefkada', 110, 'EUR', 'night', 2, 1, 1,
    4.90, 35,
    '[
      {"display_name":"Elena D.","rating":5,"body":"Cel mai frumos loc în care am stat în Grecia! Liniște, aer curat de pin și doar 10 minute cu mașina până la Porto Katsiki."}
    ]'::jsonb,
    '2026-05-01', '2026-10-31',
    array['Terasă belvedere', 'Chicinetă utilată', 'Aer condiționat', 'Parcare în curte', 'Wi-Fi'],
    'Ceai grecesc, miere locală de cimbru și produse de toaletă bio din ulei de măsline.',
    'Contact prin WhatsApp sau apel telefonic direct la sosire.',
    '[
      {"url":"https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?auto=format&fit=crop&w=1200&q=85","alt":"Studio pe stâncă vedere Porto Katsiki"}
    ]'::jsonb,
    'published', false, 3
  ) on conflict (destination_id, slug) do update set
    title = excluded.title, summary = excluded.summary, price_from = excluded.price_from,
    rooms_count = excluded.rooms_count, rating_average = excluded.rating_average,
    review_count = excluded.review_count, reviews = excluded.reviews, photos = excluded.photos;

  -- 4. Croazieră: Scorpios & Meganisi
  insert into public.offers (
    destination_id, type, slug, title, summary, description,
    locality, price_from, currency, price_unit, capacity, duration_minutes,
    rating_average, review_count, reviews, available_from, available_to,
    amenities, includes_text, contact_text, photos, status, featured, sort_order
  ) values (
    dest_lefkada, 'cruise', 'croaziera-scorpios-meganisi-lefkada',
    'Croazieră pe Arhipelagul Scorpios & Meganisi',
    'O zi de neuitat navigând prin apele turcoaz ale insulelor prințului Onassis și peștera Papanikolis.',
    'Plecare la 09:30 din portul Nydri. Navigăm printre insulițele Ioniene, facem oprire pentru înot în larg la Egremni, explorăm peștera marină Meganisi și servim prânzul la bord pe fundal de muzică grecească.',
    'Nydri, Lefkada', 45, 'EUR', 'person', 45, 420,
    4.92, 64,
    '[
      {"display_name":"Alexandru G.","rating":5,"body":"Cea mai reușită zi din vacanță! Căpitanul a fost extraordinar, iar souvlaki-ul la grătar servit la bord a fost delicios."},
      {"display_name":"Ioana & Radu","rating":5,"body":"Apa la Meganisi este ireal de limpede. Am făcut snorkeling și am văzut zeci de pești."}
    ]'::jsonb,
    '2026-05-15', '2026-10-15',
    array['Prânz tradițional inclus', 'Băuturi și vin local la discreție', 'Echipament snorkeling', 'Punte cu șezlonguri', 'Ghid turistic'],
    'Prânz cald cu carne sau opțiune vegetariană, salată grecească, fructe, veste de salvare și măști de snorkeling.',
    'Îmbarcare la ora 09:15 din dana centrală a portului Nydri.',
    '[
      {"url":"https://images.unsplash.com/photo-1544551763-46a013bb70d5?auto=format&fit=crop&w=1200&q=85","alt":"Vas de croazieră ancorat în golf turcoaz"},
      {"url":"https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=1200&q=85","alt":"Plajă cu apă cristalină Meganisi"}
    ]'::jsonb,
    'published', true, 1
  ) on conflict (destination_id, slug) do update set
    title = excluded.title, summary = excluded.summary, price_from = excluded.price_from,
    rating_average = excluded.rating_average, review_count = excluded.review_count,
    reviews = excluded.reviews, photos = excluded.photos;

  -- 5. Croazieră: Velier Apus Capul Lefkada
  insert into public.offers (
    destination_id, type, slug, title, summary, description,
    locality, price_from, currency, price_unit, capacity, duration_minutes,
    rating_average, review_count, reviews, available_from, available_to,
    amenities, includes_text, contact_text, photos, status, featured, sort_order
  ) values (
    dest_lefkada, 'cruise', 'velier-apus-porto-katsiki-lefkada',
    'Apus Romantic pe Velier la Capul Lefkada',
    'Navigație privată pe velier de lux de-a lungul stâncilor albe din sudul insulei la ora de aur.',
    'O experiență exclusivistă pentru maxim 10 persoane. Pahar de prosecco la apus, platou cu brânzeturi și fructe mediteraneene, opriri de baie în golfuri inaccesibile de pe uscat.',
    'Vasiliki, Lefkada', 75, 'EUR', 'person', 10, 210,
    5.00, 31,
    '[
      {"display_name":"Bogdan S.","rating":5,"body":"Am sărbătorit aniversarea căsătoriei la bord. Atmosfera a fost magică, velierul este impecabil întreținut."}
    ]'::jsonb,
    '2026-05-01', '2026-10-31',
    array['Velier modern 45ft', 'Prosecco și gustări gourmet', 'Skipper profesionist', 'Sistem audio Bluetooth'],
    'Prosecco, gustări fine, apă plată, echipament de înot.',
    'Plecare la ora 18:00 din portul Vasiliki.',
    '[
      {"url":"https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?auto=format&fit=crop&w=1200&q=85","alt":"Velier navigând la apus"}
    ]'::jsonb,
    'published', false, 2
  ) on conflict (destination_id, slug) do update set
    title = excluded.title, summary = excluded.summary, price_from = excluded.price_from,
    rating_average = excluded.rating_average, review_count = excluded.review_count,
    reviews = excluded.reviews, photos = excluded.photos;

  -- 6. Excursie: Safari Montan Cascadele Dimosari
  insert into public.offers (
    destination_id, type, slug, title, summary, description,
    locality, price_from, currency, price_unit, capacity, duration_minutes,
    rating_average, review_count, reviews, available_from, available_to,
    amenities, includes_text, contact_text, photos, status, featured, sort_order
  ) values (
    dest_lefkada, 'excursion', 'safari-montan-dimosari-lefkada',
    'Safari Montan & Cascadele Răcoroase Dimosari',
    'Drumeție ghidată prin defileul montan spre cascadele naturale și satele de meșteșugari.',
    'Evadează de la arșița plajei într-o drumeție răcoroasă printre platani seculari și bazine de stâncă cu apă limpede de munte. Încheiem cu o oprire în satul tradițional Karia pentru prânz la tavernă.',
    'Nydri, Lefkada', 40, 'EUR', 'person', 18, 240,
    4.82, 22,
    '[
      {"display_name":"Maria C.","rating":5,"body":"Un traseu ușor și foarte plăcut, potrivit și pentru copii. Baia în bazinul cascadei a fost extrem de răcoritoare!"}
    ]'::jsonb,
    '2026-05-01', '2026-10-31',
    array['Ghid montan autorizat', 'Băuturi răcoritoare incluse', 'Traseu umbrit accesibil familiilor'],
    'Transport dus-întors de la Nydri, ghidaj, sticlă de apă reutilizabilă.',
    'Punct de întâlnire: parcarea din spatele bisericii Nydri.',
    '[
      {"url":"https://images.unsplash.com/photo-1469854523086-cc02fe5d8800?auto=format&fit=crop&w=1200&q=85","alt":"Cascadă în defileu montan Lefkada"}
    ]'::jsonb,
    'published', false, 1
  ) on conflict (destination_id, slug) do update set
    title = excluded.title, summary = excluded.summary, price_from = excluded.price_from,
    rating_average = excluded.rating_average, review_count = excluded.review_count,
    reviews = excluded.reviews, photos = excluded.photos;

  -- 7. Închiriere Mașină: Suzuki Jimny 4x4
  insert into public.offers (
    destination_id, type, rental_kind, slug, title, summary, description,
    locality, price_from, currency, price_unit, capacity,
    rating_average, review_count, reviews, available_from, available_to,
    amenities, includes_text, contact_text, photos, status, featured, sort_order
  ) values (
    dest_lefkada, 'rental', 'car', 'suzuki-jimny-4x4-lefkada',
    'Suzuki Jimny 4x4 Cabriolet Off-Road',
    'Vehiculul ideal cu gardă înaltă și decapotabil pentru plajele spectaculoase din Lefkada.',
    'Fără teamă pe serpentinele înguste spre Porto Katsiki sau Egremni. Tracțiune integrală la nevoie, acoperiș pliabil din pânză și aer condiționat eficient.',
    'Lefkada Town', 55, 'EUR', 'day', 4,
    4.93, 53,
    '[
      {"display_name":"Florin B.","rating":5,"body":"Mașina perfectă pentru Lefkada! Am urcat fără nicio problemă pe toate drumurile înguste spre plajele vestice."},
      {"display_name":"Alin K.","rating":5,"body":"Consum mic, predare rapidă chiar la pensiune. Recomand din plin!"}
    ]'::jsonb,
    '2026-05-01', '2026-10-31',
    array['Tracțiune 4x4 decuplabilă', 'Plafon decapotabil', 'Aer condiționat', 'Asigurare CASCO inclusă', 'Kilometri nelimitați'],
    'Asigurare completă CDW fără franșiză, șofer adițional gratuit, asistență rutieră pe insulă.',
    'Livrare gratuită la hotel sau în portul Lefkada.',
    '[
      {"url":"https://images.unsplash.com/photo-1533473359331-0135ef1b58bf?auto=format&fit=crop&w=1200&q=85","alt":"Suzuki Jimny 4x4 pe drum de coastă"}
    ]'::jsonb,
    'published', true, 1
  ) on conflict (destination_id, slug) do update set
    title = excluded.title, summary = excluded.summary, price_from = excluded.price_from,
    rating_average = excluded.rating_average, review_count = excluded.review_count,
    reviews = excluded.reviews, photos = excluded.photos;

  -- 8. Închiriere ATV: ATV 450cc 4x4
  insert into public.offers (
    destination_id, type, rental_kind, slug, title, summary, description,
    locality, price_from, currency, price_unit, capacity,
    rating_average, review_count, reviews, available_from, available_to,
    amenities, includes_text, contact_text, photos, status, featured, sort_order
  ) values (
    dest_lefkada, 'rental', 'atv', 'atv-450cc-4x4-lefkada',
    'ATV 450cc 4x4 Off-Road Adventure',
    'Explorează plajele ascunse și traseele montane din Lefkada cu un ATV puternic și sigur.',
    'Model robust de 450cc cu tracțiune 4x4, perfect pentru accesul la plajele sălbatice și potecile panoramice. Include două căști confortabile, cutie sigilată pentru bagaje și suport de telefon cu încărcare rapidă.',
    'Vassiliki, Lefkada', 65, 'EUR', 'day', 2,
    4.91, 48,
    '[
      {"display_name":"Marius V.","rating":5,"body":"ATV-ul trage excelent pe urcări, frâne sigure și cutie spațioasă. O experiență de neegalat!"}
    ]'::jsonb,
    '2026-05-01', '2026-10-31',
    array['Căști incluse', 'Cutie depozitare impermeabilă', 'Suport telefon USB', 'Asistență non-stop', 'Asigurare inclusă'],
    '2 căști de protecție, plin de carburant la plecare, hartă turistică a traseelor off-road.',
    'Preluare din Vasiliki sau livrare la adresa cazării.',
    '[
      {"url":"https://images.unsplash.com/photo-1558981403-c5f9899a28bc?auto=format&fit=crop&w=1200&q=85","alt":"ATV pe drum panoramic Lefkada"},
      {"url":"https://images.unsplash.com/photo-1509316975850-ff9c5deb0cd9?auto=format&fit=crop&w=1200&q=85","alt":"Traseu montan cu ATV-ul"}
    ]'::jsonb,
    'published', true, 1
  ) on conflict (destination_id, slug) do update set
    title = excluded.title, summary = excluded.summary, price_from = excluded.price_from,
    rating_average = excluded.rating_average, review_count = excluded.review_count,
    reviews = excluded.reviews, photos = excluded.photos;


  -- =========================================================================
  -- HALKIDIKI
  -- =========================================================================

  -- 9. Cazare: Sani Pine Luxury Suites
  insert into public.offers (
    destination_id, type, slug, title, summary, description,
    locality, price_from, currency, price_unit, capacity, bedrooms, rooms_count,
    rating_average, review_count, reviews, available_from, available_to,
    amenities, includes_text, contact_text, photos, status, featured, sort_order
  ) values (
    dest_halkidiki, 'accommodation', 'sani-pine-luxury-suites-halkidiki',
    'Sani Pine Luxury Beach Suites',
    'Suite de lux la 50m de plajă, înconjurate de pini mediteraneeni aromați în peninsula Kassandra.',
    'Situate în renumita zonă Sani, suitele combină confortul de 5 stele cu liniștea naturii. Grădină privată cu gazon englezesc, acces direct pe alee spre nisipul auriu și terasă umbrită pentru mese relaxante în familie.',
    'Sani, Kassandra', 185, 'EUR', 'night', 4, 2, 2,
    4.94, 39,
    '[
      {"display_name":"Oana & George","rating":5,"body":"Locație impecabilă, nisipul pe plaja Sani este cel mai fin din Halkidiki. Suita a depășit așteptările noastre."},
      {"display_name":"Cosmin D.","rating":5,"body":"Grădina este superbă pentru copii. Gazda ne-a asigurat șezlonguri rezervate pe plajă în fiecare zi."}
    ]'::jsonb,
    '2026-05-01', '2026-10-31',
    array['La 50m de plajă', 'Grădină privată', 'Bucătărie complet utilată', 'Smart TV & Netflix', 'Parcare inclusă', 'Șezlonguri rezervate'],
    'Șezlonguri și umbrelă pe plajă incluse, curățenie și lenjerii proaspete la 2 zile.',
    'Recepție dedicată și asistență turistică în limba română.',
    '[
      {"url":"https://images.unsplash.com/photo-1571896349842-33c89424de2d?auto=format&fit=crop&w=1200&q=85","alt":"Suită la malul mării Sani Halkidiki"},
      {"url":"https://images.unsplash.com/photo-1512917774080-9991f1c4c750?auto=format&fit=crop&w=1200&q=85","alt":"Terasă exterioară înconjurată de pini"}
    ]'::jsonb,
    'published', true, 1
  ) on conflict (destination_id, slug) do update set
    title = excluded.title, summary = excluded.summary, price_from = excluded.price_from,
    capacity = excluded.capacity, bedrooms = excluded.bedrooms, rooms_count = excluded.rooms_count,
    rating_average = excluded.rating_average, review_count = excluded.review_count,
    reviews = excluded.reviews, available_from = excluded.available_from,
    available_to = excluded.available_to, photos = excluded.photos;

  -- 10. Cazare: Vourvourou Lagoon Beachfront Villa
  insert into public.offers (
    destination_id, type, slug, title, summary, description,
    locality, price_from, currency, price_unit, capacity, bedrooms, rooms_count,
    rating_average, review_count, reviews, available_from, available_to,
    amenities, includes_text, contact_text, photos, status, featured, sort_order
  ) values (
    dest_halkidiki, 'accommodation', 'vourvourou-lagoon-villa-halkidiki',
    'Vourvourou Lagoon Beachfront Villa & Boat Dock',
    'Vilă pe malul apei în Sithonia, cu ponton privat pentru bărci și vedere spre insula Diaporos.',
    'Proprietate rară situată direct pe malul golfului Vourvourou. Dispune de 4 dormitoare spațioase, foișor acoperit pe plajă, grătar din cărămidă și posibilitatea de a acosta barca direct în fața curții.',
    'Vourvourou, Sithonia', 320, 'EUR', 'night', 8, 4, 4,
    5.00, 26,
    '[
      {"display_name":"Vlad I.","rating":5,"body":"Am fost două familii și ne-am simțit ca într-un paradis privat. Am închiriat o barcă mică și am mers zilnic la Diaporos direct din curte!"}
    ]'::jsonb,
    '2026-05-01', '2026-10-31',
    array['Ieșire directă pe plajă', 'Ponton privat pentru bărci', 'Grădină mare 1500mp', 'Zonă grătar BBQ', 'Caiace incluse', 'Parcare 3 mașini'],
    'Utilizarea gratuită a 2 caiace și 1 placă SUP, coș de fructe și vin grecesc la sosire.',
    'Check-in flexibil la orice oră.',
    '[
      {"url":"https://images.unsplash.com/photo-1580587771525-78b9dba3b914?auto=format&fit=crop&w=1200&q=85","alt":"Vila Vourvourou pe malul apei"}
    ]'::jsonb,
    'published', false, 2
  ) on conflict (destination_id, slug) do update set
    title = excluded.title, summary = excluded.summary, price_from = excluded.price_from,
    capacity = excluded.capacity, bedrooms = excluded.bedrooms, rooms_count = excluded.rooms_count,
    rating_average = excluded.rating_average, review_count = excluded.review_count,
    reviews = excluded.reviews, photos = excluded.photos;

  -- 11. Cazare: Toroni Golden Sunset Apartments
  insert into public.offers (
    destination_id, type, slug, title, summary, description,
    locality, price_from, currency, price_unit, capacity, bedrooms, rooms_count,
    rating_average, review_count, reviews, available_from, available_to,
    amenities, includes_text, contact_text, photos, status, featured, sort_order
  ) values (
    dest_halkidiki, 'accommodation', 'toroni-golden-view-apartment-halkidiki',
    'Toroni Golden Bay Sunset Apartments',
    'Apartamente relaxante la 80m de plaja cu nisip auriu din Toroni, Sithonia.',
    'Ideal pentru vacanțe liniștite. Balcon spațios cu vedere panoramică la cetatea bizantină și la apus, dormitor confortabil, chicinetă utilată și parcare umbrită de viță de vie.',
    'Toroni, Sithonia', 95, 'EUR', 'night', 3, 1, 1,
    4.78, 19,
    '[
      {"display_name":"Daniela S.","rating":5,"body":"Plaja din Toroni este imensă și nu este deloc aglomerată. Apartamentul a fost curat și răcoros."}
    ]'::jsonb,
    '2026-05-15', '2026-10-15',
    array['Aproape de plajă', 'Balcon la apus', 'Aer condiționat', 'Wi-Fi gratuit', 'Parcare privată'],
    'Consumabile baie, prosoape, lenjerii proaspete.',
    'Gazdă la fața locului.',
    '[
      {"url":"https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?auto=format&fit=crop&w=1200&q=85","alt":"Apartament cu balcon mediteranean"}
    ]'::jsonb,
    'published', false, 3
  ) on conflict (destination_id, slug) do update set
    title = excluded.title, summary = excluded.summary, price_from = excluded.price_from,
    rooms_count = excluded.rooms_count, rating_average = excluded.rating_average,
    review_count = excluded.review_count, reviews = excluded.reviews, photos = excluded.photos;

  -- 12. Croazieră: Catamaran Golful Toroneos
  insert into public.offers (
    destination_id, type, slug, title, summary, description,
    locality, price_from, currency, price_unit, capacity, duration_minutes,
    rating_average, review_count, reviews, available_from, available_to,
    amenities, includes_text, contact_text, photos, status, featured, sort_order
  ) values (
    dest_halkidiki, 'cruise', 'croaziera-catamaran-toroneos-halkidiki',
    'Croazieră Catamaran de Lux în Golful Toroneos',
    'Eleganță, intimitate și ape de cristal pe un catamaran modern cu grup restrâns.',
    'O zi exclusivistă între brațele Kassandra și Sithonia. Opriri în golfuri virgine inaccesibile de pe uscat, insula Kelifos (Insula Țestoasă) pentru snorkeling printre recife, paddleboarding și prânz mediteranean proaspăt preparat la bord.',
    'Neos Marmaras, Sithonia', 85, 'EUR', 'person', 12, 360,
    4.96, 47,
    '[
      {"display_name":"Cătălin N.","rating":5,"body":"Experiență de lux autentic! Catamaranul este incredibil de spațios, vinul rece, iar mâncarea excelentă."},
      {"display_name":"Adriana M.","rating":5,"body":"Am înotat cu peștii la Insula Țestoasă. Echipajul este extrem de atent și amabil."}
    ]'::jsonb,
    '2026-05-01', '2026-10-31',
    array['Catamaran modern de lux', 'Open bar & gustări gourmet', 'Plăci SUP (Stand-Up Paddle)', 'Wi-Fi prin satelit la bord', 'Echipament snorkeling'],
    'Platouri cu fructe de mare, salate proaspete, vin alb grecesc, băuturi răcoritoare și echipament complet.',
    'Plecare la 10:00 din Marina Neos Marmaras.',
    '[
      {"url":"https://images.unsplash.com/photo-1540946485063-a40da27545f8?auto=format&fit=crop&w=1200&q=85","alt":"Catamaran navigând în Golful Toroneos"}
    ]'::jsonb,
    'published', true, 1
  ) on conflict (destination_id, slug) do update set
    title = excluded.title, summary = excluded.summary, price_from = excluded.price_from,
    rating_average = excluded.rating_average, review_count = excluded.review_count,
    reviews = excluded.reviews, photos = excluded.photos;

  -- 13. Croazieră: Mănăstirile Muntelui Athos
  insert into public.offers (
    destination_id, type, slug, title, summary, description,
    locality, price_from, currency, price_unit, capacity, duration_minutes,
    rating_average, review_count, reviews, available_from, available_to,
    amenities, includes_text, contact_text, photos, status, featured, sort_order
  ) values (
    dest_halkidiki, 'cruise', 'croaziera-muntele-athos-ouranoupoli-halkidiki',
    'Croazieră Mănăstirile Muntelui Athos din Ouranoupoli',
    'Navigație panoramică de-a lungul coastei vestice a Sfântului Munte Athos.',
    'Admiră de la bord marile așezăminte monahale istorice cocoțate pe stânci masive: Simonos Petra, Grigoriou, Dionysiou și Panteleimon (Mănăstirea Rusească). Ghidaj audio disponibil în limba română.',
    'Ouranoupoli, Halkidiki', 35, 'EUR', 'person', 80, 300,
    4.84, 85,
    '[
      {"display_name":"Gheorghe P.","rating":5,"body":"O experiență spirituală și vizuală profundă. Mănăstirile văzute de pe mare sunt grandioase!"}
    ]'::jsonb,
    '2026-05-01', '2026-10-31',
    array['Vas panoramic cu punte deschisă', 'Ghidaj în limba română', 'Bar și gustări la bord', 'Admirare delfini'],
    'Bilet de croazieră, acces ghidaj audio, vizitarea golfurilor de coastă.',
    'Îmbarcare la ora 10:15 din portul Ouranoupoli (lângă Turnul Bizantin).',
    '[
      {"url":"https://images.unsplash.com/photo-1516483638261-f4dbaf036963?auto=format&fit=crop&w=1200&q=85","alt":"Muntele Athos și mănăstiri de coastă"}
    ]'::jsonb,
    'published', false, 2
  ) on conflict (destination_id, slug) do update set
    title = excluded.title, summary = excluded.summary, price_from = excluded.price_from,
    rating_average = excluded.rating_average, review_count = excluded.review_count,
    reviews = excluded.reviews, photos = excluded.photos;

  -- 14. Excursie: Golfurile Secrete din Sithonia
  insert into public.offers (
    destination_id, type, slug, title, summary, description,
    locality, price_from, currency, price_unit, capacity, duration_minutes,
    rating_average, review_count, reviews, available_from, available_to,
    amenities, includes_text, contact_text, photos, status, featured, sort_order
  ) values (
    dest_halkidiki, 'excursion', 'turul-peninsulei-sithonia-golfuri-halkidiki',
    'Tur Ghidat: Golfurile Secrete & Tradițiile din Sithonia',
    'Excursie relaxantă prin satele din piatră Parthenonas, plantațiile de măslini și plajele ascunse.',
    'Descoperă farmecul autentic al brațului Sithonia alături de un ghid local. Degustare de miere de pin și ulei extravirgin la o cooperativă tradițională din Nikiti, plimbare prin satul istoric Parthenonas și timp liber de înot la plaja Orange Beach (Kavourotripes).',
    'Nikiti, Sithonia', 45, 'EUR', 'person', 16, 360,
    4.87, 34,
    '[
      {"display_name":"Cristina V.","rating":5,"body":"Parthenonas este ca o călătorie în timp, iar degustarea de ulei de măsline a fost o surpriză delicioasă."}
    ]'::jsonb,
    '2026-05-01', '2026-10-31',
    array['Microbuz climatizat modern', 'Ghid vorbitor de română', 'Degustare gratuită produse bio', 'Timp liber pe plajă'],
    'Transport complet dus-întors, ghidaj profesionist, degustare de miere și ulei de măsline.',
    'Preluare dimineața direct de la hotelul tău din Kassandra sau Sithonia.',
    '[
      {"url":"https://images.unsplash.com/photo-1533105079780-92b9be482077?auto=format&fit=crop&w=1200&q=85","alt":"Peisaj de coastă Sithonia Halkidiki"}
    ]'::jsonb,
    'published', false, 1
  ) on conflict (destination_id, slug) do update set
    title = excluded.title, summary = excluded.summary, price_from = excluded.price_from,
    rating_average = excluded.rating_average, review_count = excluded.review_count,
    reviews = excluded.reviews, photos = excluded.photos;

  -- 15. Închiriere Mașină: Fiat 500 Cabrio
  insert into public.offers (
    destination_id, type, rental_kind, slug, title, summary, description,
    locality, price_from, currency, price_unit, capacity,
    rating_average, review_count, reviews, available_from, available_to,
    amenities, includes_text, contact_text, photos, status, featured, sort_order
  ) values (
    dest_halkidiki, 'rental', 'car', 'fiat-500-cabrio-halkidiki',
    'Fiat 500 Hybrid Dolce Vita Cabriolet',
    'Stil italian elegant și consum redus pentru drumurile de coastă dintre peninsulele din Halkidiki.',
    'Ideal pentru cupluri. Foarte ușor de parcat în satele aglomerate de pe brațul Kassandra, plafon textil decapotabil electric și consum de doar 4.5L/100km datorită motorizării Mild Hybrid.',
    'Kallithea, Kassandra', 42, 'EUR', 'day', 4,
    4.85, 41,
    '[
      {"display_name":"Diana & Paul","rating":5,"body":"Mașinuța este superbă pentru poze și se conduce extrem de ușor. Ne-am plimbat pe ambele brațe cu un singur plin!"}
    ]'::jsonb,
    '2026-05-01', '2026-10-31',
    array['Plafon textil electric', 'Apple CarPlay / Android Auto', 'Senzori de parcare', 'Consum redus 4.5L/100km', 'Asigurare inclusă'],
    'Kilometri nelimitați, asigurare CDW inclusă, livrare curată.',
    'Preluare din Kallithea sau livrare direct la aeroportul Salonic (SKG).',
    '[
      {"url":"https://images.unsplash.com/photo-1549399542-7e3f8b79c341?auto=format&fit=crop&w=1200&q=85","alt":"Fiat 500 Cabriolet parcat la plajă"}
    ]'::jsonb,
    'published', false, 1
  ) on conflict (destination_id, slug) do update set
    title = excluded.title, summary = excluded.summary, price_from = excluded.price_from,
    rating_average = excluded.rating_average, review_count = excluded.review_count,
    reviews = excluded.reviews, photos = excluded.photos;

  -- 16. Închiriere ATV: Yamaha Grizzly 700cc
  insert into public.offers (
    destination_id, type, rental_kind, slug, title, summary, description,
    locality, price_from, currency, price_unit, capacity,
    rating_average, review_count, reviews, available_from, available_to,
    amenities, includes_text, contact_text, photos, status, featured, sort_order
  ) values (
    dest_halkidiki, 'rental', 'atv', 'yamaha-grizzly-halkidiki',
    'Yamaha Grizzly 700cc Coast & Hills',
    'Putere brută și manevrabilitate excelentă pentru traseele spre plajele sălbatice din Sithonia.',
    'Explorează peninsulele de smarald ale peninsulei Halkidiki cu cel mai robust ATV din flotă. Perfect pentru drumurile de pământ spre golfurile ascunse dintre Vourvourou și Sarti.',
    'Sithonia, Halkidiki', 80, 'EUR', 'day', 2,
    4.90, 37,
    '[
      {"display_name":"Victor M.","rating":5,"body":"Motorul de 700cc are o putere incredibilă. Am ajuns pe plaje pe care nu le găsești pe nicio hartă turistică."}
    ]'::jsonb,
    '2026-05-01', '2026-10-31',
    array['Motor 700cc injecție', 'Troliu frontal electric', '2 căști incluse', 'Asistență tehnică 24/7', 'Asigurare completă'],
    '2 căști de protecție, plin de carburant la ridicare, suport telefon cu navigație GPS.',
    'Livrări disponibile în toată peninsula Sithonia.',
    '[
      {"url":"https://images.unsplash.com/photo-1509316975850-ff9c5deb0cd9?auto=format&fit=crop&w=1200&q=85","alt":"Yamaha ATV în natură Sithonia"}
    ]'::jsonb,
    'published', false, 1
  ) on conflict (destination_id, slug) do update set
    title = excluded.title, summary = excluded.summary, price_from = excluded.price_from,
    rating_average = excluded.rating_average, review_count = excluded.review_count,
    reviews = excluded.reviews, photos = excluded.photos;


  -- =========================================================================
  -- THASOS
  -- =========================================================================

  -- 17. Cazare: Olive Grove Boutique Villa
  insert into public.offers (
    destination_id, type, slug, title, summary, description,
    locality, price_from, currency, price_unit, capacity, bedrooms, rooms_count,
    rating_average, review_count, reviews, available_from, available_to,
    amenities, includes_text, contact_text, photos, status, featured, sort_order
  ) values (
    dest_thasos, 'accommodation', 'olive-grove-villa-thasos',
    'Olive Grove Boutique Villa & Spa',
    'Vilă autentică din piatră înconjurată de măslini seculari, la 200m de plaja Golden Beach.',
    'O oază de liniște și tradiție. Tavane înalte cu grinzi de castan, decor cald inspirat din insulele grecești, curte spațioasă cu foișor, jacuzzi exterior și zonă de grătar din piatră pentru serile calde de vară.',
    'Golden Beach, Thasos', 145, 'EUR', 'night', 5, 2, 2,
    4.93, 43,
    '[
      {"display_name":"Bogdan & Laura","rating":5,"body":"Mirosul de măslini și pin dimineața este de neegalat. Plaja este la o scurtă plimbare, iar copiii s-au bucurat enorm de curte."},
      {"display_name":"Mihaela T.","rating":5,"body":"Gazda vorbește română și ne-a primit cu plăcintă caldă cu brânză feta. Ne-am simțit ca acasă!"}
    ]'::jsonb,
    '2026-05-01', '2026-10-31',
    array['Curte 2000mp cu măslini', 'Jacuzzi exterior', 'Zonă grătar BBQ din piatră', 'La 200m de Golden Beach', 'Wi-Fi gratuit', 'AC'],
    'Cafea grecească, ceai din plante montane din Thasos, prosoape și consumabile de baie din ulei de măsline.',
    'Gazdă locală prietenoasă, suport disponibil în limba română.',
    '[
      {"url":"https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?auto=format&fit=crop&w=1200&q=85","alt":"Vilă tradițională în livadă de măslini Thasos"},
      {"url":"https://images.unsplash.com/photo-1590490360182-c33d57733427?auto=format&fit=crop&w=1200&q=85","alt":"Interior rustic mediteranean"}
    ]'::jsonb,
    'published', true, 1
  ) on conflict (destination_id, slug) do update set
    title = excluded.title, summary = excluded.summary, price_from = excluded.price_from,
    capacity = excluded.capacity, bedrooms = excluded.bedrooms, rooms_count = excluded.rooms_count,
    rating_average = excluded.rating_average, review_count = excluded.review_count,
    reviews = excluded.reviews, available_from = excluded.available_from,
    available_to = excluded.available_to, photos = excluded.photos;

  -- 18. Cazare: Marble Beach Luxury Suites
  insert into public.offers (
    destination_id, type, slug, title, summary, description,
    locality, price_from, currency, price_unit, capacity, bedrooms, rooms_count,
    rating_average, review_count, reviews, available_from, available_to,
    amenities, includes_text, contact_text, photos, status, featured, sort_order
  ) values (
    dest_thasos, 'accommodation', 'marble-beach-luxury-suites-thasos',
    'Marble Beach Panorama Suites',
    'Suite contemporane de lux cu vedere panoramică spre portul Limenas și apele de smarald.',
    'Finisaje din marmură albă pură de Thasos, terase private suspendate, paturi king-size și design scandinavo-mediteranean. Acces rapid la faimoasa plajă Saliara (Marble Beach).',
    'Limenas, Thasos', 170, 'EUR', 'night', 4, 2, 2,
    4.91, 31,
    '[
      {"display_name":"Gabriel H.","rating":5,"body":"Marmura din apartament și finisajele sunt superbe. Vederea spre portul vechi la apus este spectaculoasă."}
    ]'::jsonb,
    '2026-05-15', '2026-10-15',
    array['Design marmură Thasos', 'Vedere panoramică spre mare', 'Pături king-size', 'Smart TV', 'Parcare privată subterană'],
    'Mic dejun grecesc servit zilnic pe terasă, curățenie zilnică.',
    'Check-in flexibil la recepție.',
    '[
      {"url":"https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?auto=format&fit=crop&w=1200&q=85","alt":"Suită modernă cu marmură"}
    ]'::jsonb,
    'published', false, 2
  ) on conflict (destination_id, slug) do update set
    title = excluded.title, summary = excluded.summary, price_from = excluded.price_from,
    rooms_count = excluded.rooms_count, rating_average = excluded.rating_average,
    review_count = excluded.review_count, reviews = excluded.reviews, photos = excluded.photos;

  -- 19. Cazare: Aliki Bay Stone Cottage
  insert into public.offers (
    destination_id, type, slug, title, summary, description,
    locality, price_from, currency, price_unit, capacity, bedrooms, rooms_count,
    rating_average, review_count, reviews, available_from, available_to,
    amenities, includes_text, contact_text, photos, status, featured, sort_order
  ) values (
    dest_thasos, 'accommodation', 'aliki-bay-stone-cottage-thasos',
    'Aliki Bay Traditional Stone Cottage',
    'Căsuță rustică din piatră la 100m de golful arheologic Aliki și ruinele antice.',
    'Pentru iubitorii de istorie și mare cristalină. Înconjurată de pini și mare pe ambele părți ale istmului, căsuța oferă răcoare naturală, chicinetă utilată și terasă umbrită de leandri.',
    'Aliki, Thasos', 105, 'EUR', 'night', 3, 1, 1,
    4.83, 25,
    '[
      {"display_name":"Ioana B.","rating":5,"body":"Un loc cu o energie specială. Te trezești dimineața și mergi direct la baie în golful Aliki înainte să vină turiștii."}
    ]'::jsonb,
    '2026-05-01', '2026-10-31',
    array['Aproape de golful Aliki', 'Piatră naturală tradițională', 'Curte intimă umbrită', 'Wi-Fi', 'AC'],
    'Lenjerii, prosoape, cafea și dulceață tradițională de nuci verzi din Thasos.',
    'Întâmpinare de către proprietar la sosire.',
    '[
      {"url":"https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?auto=format&fit=crop&w=1200&q=85","alt":"Căsuță de piatră la mare"}
    ]'::jsonb,
    'published', false, 3
  ) on conflict (destination_id, slug) do update set
    title = excluded.title, summary = excluded.summary, price_from = excluded.price_from,
    rooms_count = excluded.rooms_count, rating_average = excluded.rating_average,
    review_count = excluded.review_count, reviews = excluded.reviews, photos = excluded.photos;

  -- 20. Croazieră: Velier Turul Complet al Insulei Thasos
  insert into public.offers (
    destination_id, type, slug, title, summary, description,
    locality, price_from, currency, price_unit, capacity, duration_minutes,
    rating_average, review_count, reviews, available_from, available_to,
    amenities, includes_text, contact_text, photos, status, featured, sort_order
  ) values (
    dest_thasos, 'cruise', 'croaziera-velier-turul-insulei-thasos',
    'Croazieră cu Velierul: Ocolul Insulei Thasos',
    'O zi completă sub pânze explorând Marble Beach, Insula Panagia și golfurile ascunse.',
    'Iaht cu vele confortabil pentru maxim 10 persoane. Opriri repetate pentru înot în larg, snorkeling în peșteri submarine, prânz pescăresc preparat la grătar de către skipper și muzică ambientală grecească.',
    'Potos, Thasos', 70, 'EUR', 'person', 10, 480,
    5.00, 38,
    '[
      {"display_name":"Stefan L.","rating":5,"body":"Cea mai tare zi petrecută pe mare în Thasos! Căpitanul Nikos ne-a gătit pește proaspăt la grătar pe barcă. Superb!"}
    ]'::jsonb,
    '2026-05-01', '2026-10-31',
    array['Velier modern', 'Prânz pescăresc proaspăt inclus', 'Vin rece și băuturi răcoritoare', 'Echipament snorkeling', 'Punte de plajă'],
    'Prânz complet, băuturi pe tot parcursul zilei, fructe de sezon și măști de snorkeling.',
    'Plecare la 09:30 din portul Potos (digul nou).',
    '[
      {"url":"https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?auto=format&fit=crop&w=1200&q=85","alt":"Velier navigând pe apele Thasosului"}
    ]'::jsonb,
    'published', true, 1
  ) on conflict (destination_id, slug) do update set
    title = excluded.title, summary = excluded.summary, price_from = excluded.price_from,
    rating_average = excluded.rating_average, review_count = excluded.review_count,
    reviews = excluded.reviews, photos = excluded.photos;

  -- 21. Excursie: Turul Insulei & Laguna Naturală Giola
  insert into public.offers (
    destination_id, type, slug, title, summary, description,
    locality, price_from, currency, price_unit, capacity, duration_minutes,
    rating_average, review_count, reviews, available_from, available_to,
    amenities, includes_text, contact_text, photos, status, featured, sort_order
  ) values (
    dest_thasos, 'excursion', 'turul-insulei-giola-thasos',
    'Turul Insulei & Laguna Naturală Giola',
    'O zi completă: celebra piscină naturală Giola, Mănăstirea Arhanghelul Mihail și satul Theologos.',
    'Excursie ghidată cu autocar climatizat. Vizită la celebra „Piscina Sirenelor” (Giola), oprire la Mănăstirea Arhanghelul Mihail suspendată deasupra mării și prânz opțional în satul montan Theologos, renumit pentru friptura tradițională de ied.',
    'Potos, Thasos', 35, 'EUR', 'person', 25, 360,
    4.86, 56,
    '[
      {"display_name":"Anca M.","rating":5,"body":"Ghidul a fost excepțional și a povestit atâtea legende despre insulă. Giola este incredibilă în realitate!"}
    ]'::jsonb,
    '2026-05-01', '2026-10-31',
    array['Autocar climatizat modern', 'Ghid vorbitor de română', 'Degustare miere de pin și ulei extravirgin'],
    'Transport complet dus-întors de la hotel, ghid autorizat, vizite ghidate și degustare produse locale.',
    'Preluare dimineața direct de la hotelul sau vila ta.',
    '[
      {"url":"https://images.unsplash.com/photo-1533105079780-92b9be482077?auto=format&fit=crop&w=1200&q=85","alt":"Punct de belvedere panoramic Thasos"},
      {"url":"https://images.unsplash.com/photo-1469854523086-cc02fe5d8800?auto=format&fit=crop&w=1200&q=85","alt":"Traseu spre laguna Giola"}
    ]'::jsonb,
    'published', true, 1
  ) on conflict (destination_id, slug) do update set
    title = excluded.title, summary = excluded.summary, price_from = excluded.price_from,
    rating_average = excluded.rating_average, review_count = excluded.review_count,
    reviews = excluded.reviews, photos = excluded.photos;

  -- 22. Excursie: Safari Jeep 4x4 Vârful Ipsarion
  insert into public.offers (
    destination_id, type, slug, title, summary, description,
    locality, price_from, currency, price_unit, capacity, duration_minutes,
    rating_average, review_count, reviews, available_from, available_to,
    amenities, includes_text, contact_text, photos, status, featured, sort_order
  ) values (
    dest_thasos, 'excursion', 'safari-4x4-varful-ipsarion-thasos',
    'Safari Jeep 4x4 pe Vârful Montan Ipsarion (1204m)',
    'Aventură off-road pe cel mai înalt vârf din Thasos, cu vedere de 360 de grade asupra Mării Egee.',
    'Urcare spectaculoasă cu vehicule 4x4 modificate prin păduri virgine de pin negru, cascade ascunse și lacul de munte Maries. Ajungem pe Vârful Ipsarion de unde, în zilele senine, se vede Muntele Athos și insula Samothraki.',
    'Skala Potamia, Thasos', 55, 'EUR', 'person', 8, 300,
    4.94, 29,
    '[
      {"display_name":"Tudor E.","rating":5,"body":"Senzații tari pe traseul montan! Șoferul a condus exemplar, iar panorama de pe vârf îți taie respirația."}
    ]'::jsonb,
    '2026-05-01', '2026-10-31',
    array['Jeep 4x4 off-road specializat', 'Șofer-ghid montan experimentat', 'Oprire la cascada Maries', 'Popas foto belvedere'],
    'Transport 4x4, apă potabilă, ghidaj, popasuri foto.',
    'Preluare din Skala Potamia sau Golden Beach.',
    '[
      {"url":"https://images.unsplash.com/photo-1469854523086-cc02fe5d8800?auto=format&fit=crop&w=1200&q=85","alt":"Jeep off-road pe traseu montan Thasos"}
    ]'::jsonb,
    'published', false, 2
  ) on conflict (destination_id, slug) do update set
    title = excluded.title, summary = excluded.summary, price_from = excluded.price_from,
    rating_average = excluded.rating_average, review_count = excluded.review_count,
    reviews = excluded.reviews, photos = excluded.photos;

  -- 23. Închiriere Mașină: Suzuki Ignis 4x4
  insert into public.offers (
    destination_id, type, rental_kind, slug, title, summary, description,
    locality, price_from, currency, price_unit, capacity,
    rating_average, review_count, reviews, available_from, available_to,
    amenities, includes_text, contact_text, photos, status, featured, sort_order
  ) values (
    dest_thasos, 'rental', 'car', 'suzuki-ignis-4x4-thasos',
    'Suzuki Ignis AllGrip 4x4 Ultra-Compact',
    'Mini-SUV agil cu tracțiune integrală automată, gardă la sol ridicată și consum redus.',
    'Mașina perfectă pentru Thasos: ajunge pe orice drum pietruit spre Marble Beach sau Giola fără riscul de a atinge scutul. Aer condiționat, Bluetooth și portbagaj generos.',
    'Limenas, Thasos', 48, 'EUR', 'day', 4,
    4.86, 36,
    '[
      {"display_name":"Adrian C.","rating":5,"body":"Tracțiunea 4x4 ne-a ajutat enorm la coborârea spre Marble Beach. Foarte economică și comodă!"}
    ]'::jsonb,
    '2026-05-01', '2026-10-31',
    array['Tracțiune integrală AllGrip', 'Gardă la sol 18cm', 'Aer condiționat', 'Bluetooth Handsfree', 'Consum 5L/100km'],
    'Asigurare CASCO inclusă fără franșiză, kilometri nelimitați, asistență 24h pe insulă.',
    'Predare gratuită la sosirea cu ferryboat-ul în Limenas sau la hotel.',
    '[
      {"url":"https://images.unsplash.com/photo-1549399542-7e3f8b79c341?auto=format&fit=crop&w=1200&q=85","alt":"Suzuki Ignis pe drum de coastă"}
    ]'::jsonb,
    'published', false, 1
  ) on conflict (destination_id, slug) do update set
    title = excluded.title, summary = excluded.summary, price_from = excluded.price_from,
    rating_average = excluded.rating_average, review_count = excluded.review_count,
    reviews = excluded.reviews, photos = excluded.photos;

  -- 24. Închiriere ATV: Polaris 570cc
  insert into public.offers (
    destination_id, type, rental_kind, slug, title, summary, description,
    locality, price_from, currency, price_unit, capacity,
    rating_average, review_count, reviews, available_from, available_to,
    amenities, includes_text, contact_text, photos, status, featured, sort_order
  ) values (
    dest_thasos, 'rental', 'atv', 'polaris-570cc-thasos',
    'Polaris 570cc Quad Safari Explorer',
    'Confort maxim și tracțiune integrală pentru descoperirea cascadelor și vârfurilor din Thasos.',
    'Modelul premium Polaris Sportsman 570 oferă suspensie independentă și servodirecție EPS, ideal pentru urcarea spre Vârful Ipsarion sau golfurile izolate de marmură.',
    'Limenas, Thasos', 75, 'EUR', 'day', 2,
    4.94, 52,
    '[
      {"display_name":"Paul G.","rating":5,"body":"Servodirecția face o diferență uriașă pe drumurile forestiere din Thasos. Am parcurs toată insula cu zâmbetul pe buze."}
    ]'::jsonb,
    '2026-05-01', '2026-10-31',
    array['Tracțiune 4x4 decuplabilă', 'Servodirecție asistată EPS', 'Cutie depozitare spate sigilată', 'Asigurare completă'],
    'Echipament complet de protecție (2 căști), instructaj tehnic detaliat, asistență non-stop pe insulă.',
    'Punct de preluare în Limenas sau livrare la hotel.',
    '[
      {"url":"https://images.unsplash.com/photo-1568772585407-9361f9bf3a87?auto=format&fit=crop&w=1200&q=85","alt":"Polaris Quad Safari pe drum din Thasos"},
      {"url":"https://images.unsplash.com/photo-1558981403-c5f9899a28bc?auto=format&fit=crop&w=1200&q=85","alt":"Peisaj montan Thasos cu ATV"}
    ]'::jsonb,
    'published', true, 1
  ) on conflict (destination_id, slug) do update set
    title = excluded.title, summary = excluded.summary, price_from = excluded.price_from,
    rating_average = excluded.rating_average, review_count = excluded.review_count,
    reviews = excluded.reviews, photos = excluded.photos;

end $$;

commit;
