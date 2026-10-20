-- Migration 002: Add ratings, reviews, availability dates, rooms count and photo array
-- Run this in Supabase SQL Editor if you already ran 001_cms.sql previously.

begin;

alter table public.offers
  add column if not exists rooms_count integer check (rooms_count is null or rooms_count between 1 and 1000),
  add column if not exists rating_average numeric(3,2) check (rating_average is null or (rating_average between 1.0 and 5.0)),
  add column if not exists review_count integer not null default 0 check (review_count >= 0),
  add column if not exists reviews jsonb not null default '[]'::jsonb,
  add column if not exists photos jsonb not null default '[]'::jsonb,
  add column if not exists available_from date,
  add column if not exists available_to date;

do $$
begin
  if not exists (select 1 from pg_constraint where conname = 'offers_rooms_count_type_check') then
    alter table public.offers add constraint offers_rooms_count_type_check check (rooms_count is null or type = 'accommodation');
  end if;
  if not exists (select 1 from pg_constraint where conname = 'offers_available_dates_check') then
    alter table public.offers add constraint offers_available_dates_check check (available_from is null or available_to is null or available_from <= available_to);
  end if;
end $$;

-- Update atomic save_offer RPC to persist the new fields
create or replace function public.save_offer(p_offer jsonb,p_images uuid[]) returns uuid language plpgsql security invoker set search_path='' as $$
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

commit;
