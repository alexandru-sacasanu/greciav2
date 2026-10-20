-- Hello Grecia CMS. Run once in a new Supabase project, as postgres.
-- This is a content catalog, not a reservations/inventory/payment database.
begin;
create schema if not exists private;
revoke all on schema private from public, anon, authenticated;
create table private.admin_users (
 user_id uuid primary key references auth.users(id) on delete cascade,
 created_at timestamptz not null default now()
);
revoke all on private.admin_users from public, anon, authenticated;
create function public.is_admin() returns boolean language sql stable security definer set search_path = '' as $$
 select exists(select 1 from private.admin_users where user_id=(select auth.uid()));
$$;
revoke all on function public.is_admin() from public;
grant execute on function public.is_admin() to anon, authenticated;

create type public.offer_type as enum ('accommodation','excursion','cruise','rental');
create type public.rental_type as enum ('car','atv');
create type public.content_status as enum ('draft','published');
create type public.price_unit as enum ('night','person','day','trip');

create table public.media (
 id uuid primary key default gen_random_uuid(),
 storage_path text not null unique check(storage_path ~ '^media/[a-zA-Z0-9/_\.\-]+$'),
 alt_text text not null default '',
 original_name text not null default '',
 created_at timestamptz not null default now()
);
create table public.destinations (
 id uuid primary key default gen_random_uuid(),
 slug text not null unique check(slug in ('lefkada','halkidiki','thasos')),
 name text not null check(length(trim(name)) between 1 and 100),
 description text not null default '',
 hero_media_id uuid references public.media(id) on delete restrict,
 hero_alt text not null default '',
 hero_local_path text not null,
 boat_x numeric not null default 68 check(boat_x between 0 and 100),
 boat_y numeric not null default 78 check(boat_y between 0 and 100),
 boat_width numeric not null default 7 check(boat_width between 1 and 20),
 show_yacht boolean not null default true,
 show_pins boolean not null default true,
 is_active boolean not null default true,
 sort_order integer not null default 0,
 updated_at timestamptz not null default now(),
 check(hero_local_path in ('assets/lefkada-animated-base.png','assets/halkidiki-animated-base.png','assets/thasos-animated-base.png'))
);
create table public.offers (
 id uuid primary key default gen_random_uuid(),
 destination_id uuid not null references public.destinations(id) on delete restrict,
 type public.offer_type not null,
 rental_kind public.rental_type,
 slug text not null check(slug ~ '^[a-z0-9]+(-[a-z0-9]+)*$'),
 title text not null check(length(trim(title)) between 1 and 160),
 summary text not null default '',
 description text not null default '',
 locality text not null default '',
 address text not null default '',
 price_from numeric(12,2) check(price_from>=0),
 currency text not null default 'EUR' check(currency ~ '^[A-Z]{3}$'),
 price_unit public.price_unit not null default 'night',
 capacity integer check(capacity between 1 and 10000),
 bedrooms integer check(bedrooms between 0 and 1000),
 rooms_count integer check(rooms_count is null or rooms_count between 1 and 1000),
 duration_minutes integer check(duration_minutes between 1 and 100000),
 amenities text[] not null default '{}',
 includes_text text not null default '',
 contact_text text not null default '',
 rating_average numeric(3,2) check(rating_average is null or (rating_average between 1.0 and 5.0)),
 review_count integer not null default 0 check(review_count >= 0),
 reviews jsonb not null default '[]'::jsonb check(jsonb_typeof(reviews) = 'array'),
 photos jsonb not null default '[]'::jsonb check(jsonb_typeof(photos) = 'array'),
 available_from date,
 available_to date,
 status public.content_status not null default 'draft',
 featured boolean not null default false,
 sort_order integer not null default 0,
 created_at timestamptz not null default now(),
 updated_at timestamptz not null default now(),
 unique(destination_id,slug),
 check((type='rental' and rental_kind is not null) or (type<>'rental' and rental_kind is null)),
 check(bedrooms is null or type='accommodation'),
 check(rooms_count is null or type='accommodation'),
 check(duration_minutes is null or type in ('excursion','cruise')),
 check(available_from is null or available_to is null or available_from <= available_to)
);
create index offers_destination_type_status_idx on public.offers(destination_id,type,status,sort_order);
create table public.offer_images (
 offer_id uuid not null references public.offers(id) on delete cascade,
 media_id uuid not null references public.media(id) on delete restrict,
 sort_order integer not null default 0,
 primary key(offer_id,media_id)
);
create index offer_images_media_idx on public.offer_images(media_id);
create table public.site_settings (
 id boolean primary key default true check(id=true),
 ui_labels jsonb not null default '{"nav_destinations":"Destinații","nav_stays":"Cazări","nav_offers":"Oferte","nav_contact":"Contact","cat_accommodation":"Cazări","cat_excursion":"Excursii","cat_cruise":"Croaziere","cat_car":"Mașini","cat_atv":"ATV","scene_caption":"Explorează în ritmul tău","inquiry":"Solicită detalii"}'::jsonb check(jsonb_typeof(ui_labels)='object'),
 brand_name text not null default 'Hello Grecia',
 hero_title text not null default 'Vacanța ta în Grecia începe aici',
 hero_subtitle text not null default 'Descoperă cazări și locuri de neuitat, alese pentru tine.',
 search_label text not null default 'Caută oferte',
 section_title text not null default 'Descoperă experiențe și locuri de neuitat',
 footer_text text not null default 'Un pic de soare. O mulțime de amintiri.',
 contact_email text not null default '',
 trust_title_1 text not null default 'Cazări verificate',
 trust_text_1 text not null default 'Doar proprietăți de încredere',
 trust_title_2 text not null default 'Suport în română',
 trust_text_2 text not null default 'Suntem aici pentru tine',
 trust_title_3 text not null default 'Rezervări simple',
 trust_text_3 text not null default 'Informații clare, fără bătăi de cap',
 primary_color text not null default '#0669ef' check(primary_color ~ '^#[0-9A-Fa-f]{6}$'),
 background_color text not null default '#fcfaf5' check(background_color ~ '^#[0-9A-Fa-f]{6}$'),
 text_color text not null default '#071e56' check(text_color ~ '^#[0-9A-Fa-f]{6}$'),
 logo_media_id uuid references public.media(id) on delete restrict,
 yacht_media_id uuid references public.media(id) on delete restrict,
 show_animation boolean not null default true,
 updated_at timestamptz not null default now()
);
create function public.touch_updated_at() returns trigger language plpgsql set search_path='' as $$
begin new.updated_at=now();return new;end;$$;
create trigger destinations_updated before update on public.destinations for each row execute function public.touch_updated_at();
create trigger offers_updated before update on public.offers for each row execute function public.touch_updated_at();
create trigger settings_updated before update on public.site_settings for each row execute function public.touch_updated_at();

alter table public.media enable row level security;
alter table public.destinations enable row level security;
alter table public.offers enable row level security;
alter table public.offer_images enable row level security;
alter table public.site_settings enable row level security;
create policy destinations_public on public.destinations for select to anon,authenticated using(is_active);
create policy destinations_admin on public.destinations for all to authenticated using((select public.is_admin())) with check((select public.is_admin()));
create policy offers_public on public.offers for select to anon,authenticated using(status='published' and exists(select 1 from public.destinations d where d.id=destination_id and d.is_active));
create policy offers_admin on public.offers for all to authenticated using((select public.is_admin())) with check((select public.is_admin()));
create policy images_public on public.offer_images for select to anon,authenticated using(exists(select 1 from public.offers o where o.id=offer_id and o.status='published'));
create policy images_admin on public.offer_images for all to authenticated using((select public.is_admin())) with check((select public.is_admin()));
create policy media_public on public.media for select to anon,authenticated using(
 exists(select 1 from public.offer_images i where i.media_id=media.id)
 or exists(select 1 from public.destinations d where d.hero_media_id=media.id and d.is_active)
 or exists(select 1 from public.site_settings s where s.logo_media_id=media.id or s.yacht_media_id=media.id)
);
create policy media_admin on public.media for all to authenticated using((select public.is_admin())) with check((select public.is_admin()));
create policy settings_public on public.site_settings for select to anon,authenticated using(true);
create policy settings_admin_update on public.site_settings for update to authenticated using((select public.is_admin())) with check((select public.is_admin()));
revoke all on public.media,public.destinations,public.offers,public.offer_images,public.site_settings from anon,authenticated;
grant select on public.media,public.destinations,public.offers,public.offer_images,public.site_settings to anon;
grant select,insert,update,delete on public.media,public.destinations,public.offers,public.offer_images to authenticated;
grant select,update on public.site_settings to authenticated;

-- Atomic create/update with gallery. Invoker privileges + RLS remain active.
create function public.save_offer(p_offer jsonb,p_images uuid[]) returns uuid language plpgsql security invoker set search_path='' as $$
declare v public.offers; saved_id uuid;begin
 if not public.is_admin() then raise exception 'Admin access required' using errcode='42501';end if;
 v=jsonb_populate_record(null::public.offers,p_offer);
 if v.id is null then
  insert into public.offers(destination_id,type,rental_kind,slug,title,summary,description,locality,address,price_from,currency,price_unit,capacity,bedrooms,rooms_count,duration_minutes,amenities,includes_text,contact_text,rating_average,review_count,reviews,photos,available_from,available_to,status,featured,sort_order)
  values(v.destination_id,v.type,v.rental_kind,v.slug,v.title,coalesce(v.summary,''),coalesce(v.description,''),coalesce(v.locality,''),coalesce(v.address,''),v.price_from,coalesce(v.currency,'EUR'),coalesce(v.price_unit,'night'),v.capacity,v.bedrooms,v.rooms_count,v.duration_minutes,coalesce(v.amenities,'{}'),coalesce(v.includes_text,''),coalesce(v.contact_text,''),v.rating_average,coalesce(v.review_count,0),coalesce(v.reviews,'[]'::jsonb),coalesce(v.photos,'[]'::jsonb),v.available_from,v.available_to,coalesce(v.status,'draft'),coalesce(v.featured,false),coalesce(v.sort_order,0)) returning id into saved_id;
 else
  update public.offers set destination_id=v.destination_id,type=v.type,rental_kind=v.rental_kind,slug=v.slug,title=v.title,summary=coalesce(v.summary,''),description=coalesce(v.description,''),locality=coalesce(v.locality,''),address=coalesce(v.address,''),price_from=v.price_from,currency=coalesce(v.currency,'EUR'),price_unit=v.price_unit,capacity=v.capacity,bedrooms=v.bedrooms,rooms_count=v.rooms_count,duration_minutes=v.duration_minutes,amenities=coalesce(v.amenities,'{}'),includes_text=coalesce(v.includes_text,''),contact_text=coalesce(v.contact_text,''),rating_average=v.rating_average,review_count=coalesce(v.review_count,0),reviews=coalesce(v.reviews,'[]'::jsonb),photos=coalesce(v.photos,'[]'::jsonb),available_from=v.available_from,available_to=v.available_to,status=v.status,featured=coalesce(v.featured,false),sort_order=coalesce(v.sort_order,0) where id=v.id returning id into saved_id;
  if saved_id is null then raise exception 'Offer not found';end if;
 end if;
 delete from public.offer_images where offer_id=saved_id;
 insert into public.offer_images(offer_id,media_id,sort_order) select saved_id,x.media_id,(x.n-1)::integer from unnest(coalesce(p_images,'{}'::uuid[])) with ordinality x(media_id,n);
 return saved_id;
end;$$;
revoke all on function public.save_offer(jsonb,uuid[]) from public;
grant execute on function public.save_offer(jsonb,uuid[]) to authenticated;

-- Public bucket for marketing photos only. Draft image URLs are NOT private.
insert into storage.buckets(id,name,public,file_size_limit,allowed_mime_types)
values('site-media','site-media',true,10485760,array['image/jpeg','image/png','image/webp','image/avif']);
create policy site_media_admin_select on storage.objects for select to authenticated using(bucket_id='site-media' and (select public.is_admin()));
create policy site_media_admin_insert on storage.objects for insert to authenticated with check(bucket_id='site-media' and (select public.is_admin()));
create policy site_media_admin_update on storage.objects for update to authenticated using(bucket_id='site-media' and (select public.is_admin())) with check(bucket_id='site-media' and (select public.is_admin()));
create policy site_media_admin_delete on storage.objects for delete to authenticated using(bucket_id='site-media' and (select public.is_admin()));
insert into public.destinations(slug,name,hero_local_path,boat_x,boat_y,boat_width,sort_order) values
('lefkada','Lefkada','assets/lefkada-animated-base.png',68,78,7,0),
('halkidiki','Halkidiki','assets/halkidiki-animated-base.png',20,78,5,1),
('thasos','Thasos','assets/thasos-animated-base.png',53,80,5.5,2);
insert into public.site_settings(id) values(true);
commit;
