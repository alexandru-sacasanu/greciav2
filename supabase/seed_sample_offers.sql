-- Script pentru inserarea ofertelor direct în baza de date Supabase.
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
    raise exception 'Destinațiile nu au fost găsite.';
  end if;

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

  -- 2. ATV Lefkada
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

  -- 3. Croazieră Lefkada
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

  -- 4. Cazare Halkidiki: Sani Pine Suites
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
      {"display_name":"Oana & George","rating":5,"body":"Locație impecabilă, nisipul pe plaja Sani este cel mai fin din Halkidiki. Suita a depășit așteptările noastre."}
    ]'::jsonb,
    '2026-05-01', '2026-10-31',
    array['La 50m de plajă', 'Grădină privată', 'Bucătărie complet utilată', 'Smart TV & Netflix', 'Parcare inclusă', 'Șezlonguri rezervate'],
    'Șezlonguri și umbrelă pe plajă incluse, curățenie și lenjerii proaspete la 2 zile.',
    'Recepție dedicată și asistență turistică în limba română.',
    '[
      {"url":"https://images.unsplash.com/photo-1571896349842-33c89424de2d?auto=format&fit=crop&w=1200&q=85","alt":"Suită la malul mării Sani Halkidiki"}
    ]'::jsonb,
    'published', true, 1
  ) on conflict (destination_id, slug) do update set
    title = excluded.title, summary = excluded.summary, price_from = excluded.price_from,
    capacity = excluded.capacity, bedrooms = excluded.bedrooms, rooms_count = excluded.rooms_count,
    rating_average = excluded.rating_average, review_count = excluded.review_count,
    reviews = excluded.reviews, photos = excluded.photos;

  -- 5. Cazare Thasos: Olive Grove Villa
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
      {"display_name":"Bogdan & Laura","rating":5,"body":"Mirosul de măslini și pin dimineața este de neegalat. Plaja este la o scurtă plimbare, iar copiii s-au bucurat enorm de curte."}
    ]'::jsonb,
    '2026-05-01', '2026-10-31',
    array['Curte 2000mp cu măslini', 'Jacuzzi exterior', 'Zonă grătar BBQ din piatră', 'La 200m de Golden Beach', 'Wi-Fi gratuit', 'AC'],
    'Cafea grecească, ceai din plante montane din Thasos, prosoape și consumabile de baie din ulei de măsline.',
    'Gazdă locală prietenoasă, suport disponibil în limba română.',
    '[
      {"url":"https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?auto=format&fit=crop&w=1200&q=85","alt":"Vilă tradițională în livadă de măslini Thasos"}
    ]'::jsonb,
    'published', true, 1
  ) on conflict (destination_id, slug) do update set
    title = excluded.title, summary = excluded.summary, price_from = excluded.price_from,
    capacity = excluded.capacity, bedrooms = excluded.bedrooms, rooms_count = excluded.rooms_count,
    rating_average = excluded.rating_average, review_count = excluded.review_count,
    reviews = excluded.reviews, photos = excluded.photos;

  -- 6. ATV Thasos
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
      {"url":"https://images.unsplash.com/photo-1568772585407-9361f9bf3a87?auto=format&fit=crop&w=1200&q=85","alt":"Polaris Quad Safari pe drum din Thasos"}
    ]'::jsonb,
    'published', true, 1
  ) on conflict (destination_id, slug) do update set
    title = excluded.title, summary = excluded.summary, price_from = excluded.price_from,
    rating_average = excluded.rating_average, review_count = excluded.review_count,
    reviews = excluded.reviews, photos = excluded.photos;

end $$;

commit;
