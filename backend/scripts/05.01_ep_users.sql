set search_path to public;

-- Endpoint : signup (permet à un visiteur de se créer un compte client)

create or replace function signup(
    email text,
    password text,
    full_name text,
    phone text default null
) returns void as $$
begin
-- insère le nouvel utilisateur et le rôle est forcé à 'client'
insert into users (email, password, full_name, role, phone)
values (signup.email, signup.password, signup.full_name, 'client', signup.phone);
end;
$$ language plpgsql security definer;


grant execute on function signup(text, text, text, text) to anon;