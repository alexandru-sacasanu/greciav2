-- 1. Create your user in Supabase Dashboard > Authentication > Users.
-- 2. Change the email below. Run this only in the SQL Editor as postgres.
-- Never grant access by user_metadata or by browser-side role fields.
do $$
declare admin_id uuid;
begin
 select id into admin_id from auth.users where email='CHANGE_ME@example.com';
 if admin_id is null then raise exception 'Create the Auth user and replace CHANGE_ME@example.com first.';end if;
 insert into private.admin_users(user_id) values(admin_id) on conflict do nothing;
end $$;
-- To revoke access later:
-- delete from private.admin_users where user_id='USER_UUID_HERE'::uuid;
