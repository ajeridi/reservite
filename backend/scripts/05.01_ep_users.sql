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

-- Endpoint : is_email_available (vérifie si un email est dispo pour s'inscrire)

create or replace function is_email_available(email text) returns boolean as
$$
begin
    return not exists(select 1 from users where users.email = is_email_available.email);
end
$$ language plpgsql security definer;

grant execute on function is_email_available(text) to anon;


-- Endpoint : is_full_name_available (vérifie si un nom complet est dispo)

create or replace function is_full_name_available(full_name text) returns boolean as
$$
begin
    return not exists(select 1 from users where users.full_name = is_full_name_available.full_name);
end
$$ language plpgsql security definer;

grant execute on function is_full_name_available(text) to anon;