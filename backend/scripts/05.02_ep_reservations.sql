set search_path to public, auth;

/*
Operations possible pour une reservation
    - lister (manager, client)
    - voir (details) (manager, client), peut etre voir aussi si json retourne est different en fonction du role
    - insert/update (client)
    - confirm (manager)
    - cancel (manager, client)
    - complete (manager)

    - liste des creneau de reservation possibles, pour un client. (donc pour une date donnee, les horaire de reservation possibles)
*/

-- METHODES UTILITAIRES

/*
Verifie si un manager travaille dans un restaurant
*/

create or replace function check_manager_works_in_restaurant(manager_id int, restaurant_id int) returns boolean as
$$
begin
    if not exists(select manager
                  from restaurant_managers rm
                  where restaurant = restaurant_id
                    and manager = manager_id) then
        raise exception 'Manager is not working at that restaurant';
    end if;
    return true;
end;
$$ language plpgsql security definer;


/*
    Verifie si la reservation est celle d'un client
*/
create or replace function is_client_reservation(client_id int, reservation_id int) returns boolean as
$$
begin
    return exists(select rsv.id from reservations rsv where rsv.client = client_id AND reservation_id = rsv.id);
end;
$$ language plpgsql security definer;



-- =====================================================================================================================
/*
FONCTION QUI RETOURNE UNE RESERVATION avec les details du client, du restaurant et la/les tables assignees
*/
create or replace function get_reservation(reservation_id int) returns json as
$$
begin
    -- verification si utilisateur connecte
    perform auth.check_logged();

    -- si user est un client il faut que ca soit sa reservation
    if (auth.role() = 'client' AND
        (select client from reservations rsv where rsv.id = reservation_id) <> auth.id()) then
        raise exception 'Reservation must be of client';
    end if;
    -- si user est un manager, il faut qu'il soit manager dans le restaurant dans lequel se trouve la reservation
    if (auth.role() = 'manager' AND not exists(select *
                                               from restaurant_managers
                                               where manager = auth.id()
                                                 and restaurant = (select rsv.restaurant
                                                                   from reservations rsv
                                                                   where rsv.id = reservation_id))) then
        raise exception 'Manager cannot check a reservation inside a restaurant he is not working in';
    end if;

    return (select json_build_object(
                           'id', rsv.id,
                           'client',
                           (select json_build_object('id', u.id, 'name', u.full_name, 'email', u.email, 'phone',
                                                     u.phone)
                            from users u
                            where u.id = rsv.client),
                           'restaurant',
                           (select json_build_object('id', rsv.restaurant, 'name', rst.name, 'address', rst.address,
                                                     'city', rst.city, 'phone', rst.phone)
                            from restaurants rst
                            where rst.id = rsv.restaurant),
                           'datetime', rsv.datetime,
                           'number_of_guests', rsv.number_of_guests,
                           'status', rsv.status,
                           'special_requests', rsv.special_requests,
                           'is_vip', rsv.is_vip,
                           'tables',
                           (select json_agg(json_build_object('id', t.id, 'table_number', t.table_number, 'capacity',
                                                              t.capacity))
                            from reservation_tables rt
                                     join tables t on rt."table" = t.id
                            where rt.reservation = reservation_id)
                   )
            from reservations rsv
            where rsv.id = reservation_id);
end;
$$ language plpgsql security definer;


--grant execute on function get_reservation(int) to client, manager;
grant execute on function get_reservation(int) to authenticated;

/*-- query get_reservation avec les types sur mesures
select row (rsv.id,
    (select row(u.id, u.full_name, u.email, u.phone)::client_details from users u where u.id = rsv.client),
    (select row(rsv.id, rst.name, rst.address, rst.city, rst.phone)::restaurant_details from restaurants rst where rst.id = rsv.restaurant),
    rsv.datetime,
    rsv.number_of_guests,
    rsv.status,
    rsv.special_requests,
    array(select row(t.id, t.table_number, t.capacity)::table_details from reservation_tables rt join tables t on rt."table" = t.id where rt.reservation = 14 )::table_details[]
    )::reservation_type from reservations rsv where rsv.id = 14;
*/

-- =====================================================================================================================

/*
ENDPOINT QUI VA RETOURNER UNE LISTE DE RESERVATIONS
    on retourne une liste d'objets reservations donc json_agg(json_build_object)
*/

create or replace function get_reservations(restaurant_id int default NULL) returns json as
$$
declare
    user_id           int       := auth.id();
    declare user_role role_type := auth.role();
begin
    -- verification si le user est logged
    perform auth.check_logged();
    -- un client a besoin uniquement du nom du restaurant, de la ville du restaurant, de la date et du nombre de convives, le statut
    if (user_role = 'client'::role_type) then
        return (select json_agg(
                               json_build_object(
                                       'id', rsv.id,
                                       'client', (select(json_build_object('id', rsv.client))),
                                       'restaurant',
                                       (select json_build_object('id', rsv.id, 'name', rst.name, 'address', rst.address,
                                                                 'city', rst.city, 'phone', rst.phone)
                                        from restaurants rst
                                        where rst.id = rsv.restaurant),
                                       'datetime', rsv.datetime,
                                       'number_of_guests', rsv.number_of_guests,
                                       'status', rsv.status,
                                       'special_requests', rsv.special_requests,
                                       'is_vip', rsv.is_vip
                               )
                               ORDER BY rsv.datetime DESC, rsv.id DESC
                       )
                from reservations rsv
                where rsv.client = user_id);

    end if;
    if (user_role = 'manager'::role_type) then
        -- on verifie si le manager travaille dans ce restaurant
        perform check_manager_works_in_restaurant(user_id, restaurant_id);
        return (select json_agg(
                               json_build_object(
                                       'id', rsv.id,
                                       'client',
                                       (select json_build_object('id', u.id, 'name', u.full_name, 'email', u.email,
                                                                 'phone', u.phone)
                                        from users u
                                        where u.id = rsv.client),
                                       'restaurant',
                                       (select json_build_object('id', rsv.id, 'name', rst.name, 'address', rst.address,
                                                                 'city', rst.city, 'phone', rst.phone)
                                        from restaurants rst
                                        where rst.id = rsv.restaurant),
                                       'datetime', rsv.datetime,
                                       'number_of_guests', rsv.number_of_guests,
                                       'status', rsv.status,
                                       'special_requests', rsv.special_requests,
                                       'is_vip', rsv.is_vip,
                                       'tables',
                                       (select json_agg(json_build_object('id', t.id, 'table_number', t.table_number,
                                                                          'capacity', t.capacity))
                                        from reservation_tables rt
                                                 join tables t on rt."table" = t.id
                                        where rt.reservation = rsv.id)
                               )
                               ORDER BY rsv.datetime DESC, rsv.id DESC -- faut mettre le order by ici, et pas en fin de query apres le where sinon ca ne marchera pas
                       )
                from reservations rsv
                where rsv.restaurant = restaurant_id);
    end if;

end;
$$ language plpgsql security definer;

-- droit d'execution pour les clients et managers
grant execute on function get_reservations(int) to authenticated;

-- =====================================================================================================================
/*
    INSERT UPDATE RESERVATION
        SEUL UN CLIENT PEUT CREER OU MODIFIER SA RESERVATION
    retourne la reservation ajoutee ou modifiee
*/

create or replace function save_reservation(restaurant_id int, datetime_ timestamp, number_of_guests_ int,
                                            special_requests_ text DEFAULT NULL, reservation_id int DEFAULT NULL, is_vip_ bool DEFAULT false)
    returns json as
$$
declare
    updated_reservation_id int := reservation_id;
begin
    -- verification si utilisateur connecte
    perform auth.check_logged();
    if (auth.role() <> 'client') then
        raise exception 'Cannot add/edit a reservation if you are not a client';
    end if;
    -- si reservation_id est null alors on cree une nouvelle reservation
    if (reservation_id is NULL) then
        INSERT INTO reservations(client, restaurant, datetime, number_of_guests, special_requests, is_vip)
        VALUES (auth.id(), restaurant_id, datetime_, number_of_guests_, special_requests_, is_vip_)
        returning id into updated_reservation_id;
        -- sinon on update reservation
    else
        -- si la reservation a des tables on va les enlever (car si on modifie une reservation confirmee, son statut passe a pending
        DELETE from reservation_tables where reservation = reservation_id;

        UPDATE reservations
        set datetime         = datetime_,
            number_of_guests = number_of_guests_,
            special_requests = special_requests_,
            is_vip = is_vip_,
            status = 'pending'::status_type
        WHERE id = reservation_id;
    end if;
    return get_reservation(updated_reservation_id);
end;
$$ language plpgsql security definer;

grant execute on function save_reservation(int, timestamp, int, text, int, bool) to client;

-- =====================================================================================================================

/*
Confirmation d'une reservation et assignation des tables pour cette reservation
    recoit un id de reservation et un liste d'id de tables
*/

create or replace function confirm_reservation(reservation_id int, tables_id int[]) returns json as
$$
declare
    restaurant_id int;
begin
    -- verifier si user connecte
    perform auth.check_logged();
    -- user doit etre un manager
    if (auth.role() <> 'manager') then
        raise exception 'Operation prohibited for non managers';
    end if;
    -- on recupere l'id du restaurant
    select rsv.restaurant from reservations rsv where rsv.id = reservation_id into restaurant_id;
    -- on regarde si le manager travaille dans le restaurant de la reservation a confirmer
    if (auth.id() not in
        (select rm.manager from restaurant_managers rm where manager = auth.id() and restaurant = restaurant_id)) then
        raise exception 'User is not manager at the reservation''s restaurant';
    end if;
    -- verifier si la table est bien dans le restaurant (en regardant comparant le nombre de lignes avec le nombre d'elements dans le tableau)
    if (select count(*) from tables t where t.restaurant = restaurant_id and t.id = any (tables_id)) <
       array_length(tables_id, 1) then -- le any est comme un 'OR'
        raise exception 'At least one of the tables is not in the restaurant of the reservation';
    end if;
    -- assigner les tables
    insert into reservation_tables (reservation, "table") select reservation_id, t from unnest(tables_id) as t;
    -- unnest parcours la liste de table et pour chaque element insere la ligne reservation_id, tables_id[i]
    -- update le statut vers confirmed
    update reservations set status = 'confirmed' where reservations.id = reservation_id;
    -- retourner la reservation confirmee
    return get_reservation(reservation_id);
end;
$$ language plpgsql security definer;

grant execute on function confirm_reservation(int, int[]) to manager;

-- =====================================================================================================================

/*
    CANCEL_RESERVATION
    changement du status de la reservation vers cancelled
        - client peut annuler sa reservation
        - manager peut annuler une reservation dans son restaurant
*/

create or replace function cancel_reservation(reservation_id int) returns json as
$$
declare
    role                  role_type := auth.role();
    declare restaurant_id int       := (select restaurant
                                        from reservations
                                        where id = reservation_id);
    declare user_id       int       := auth.id();
begin
    -- verification connexion du user
    perform auth.check_logged();
    if (role = 'client'::role_type AND is_client_reservation(user_id, reservation_id) OR
        role = 'manager'::role_type AND check_manager_works_in_restaurant(user_id, restaurant_id)) then
        --on suprime la table du reservation_table avant supprimer la reservation
        delete from reservation_tables where reservation = reservation_id;
        --ensuite on supprime traquillement sans avoir des problemes avec les triggers (BR)
        update reservations set status = 'cancelled' where id = reservation_id;

        return get_reservation(reservation_id);
    else
        raise exception 'User does not have the rights to call this method';
    end if;
end;
$$ language plpgsql security definer;

grant execute on function cancel_reservation(int) to authenticated;

-- =====================================================================================================================
/*
    Complete reservation
        uniquement le manager peut terminer une reservation
        il faut qu'il soit manager dans le restaurant
*/

create or replace function complete_reservation(reservation_id int) returns json as
$$
declare
    restaurant_id int := (select restaurant
                          from reservations
                          where id = reservation_id);
begin
    -- verification connexion du user
    perform auth.check_logged();
    if (auth.role() = 'manager' AND check_manager_works_in_restaurant(auth.id(), restaurant_id)) then
        update reservations set status = 'completed' where id = reservation_id;
        return get_reservation(reservation_id);
    end if;
end;
$$ language plpgsql security definer;

grant execute on function complete_reservation(int) to manager;

-- =====================================================================================================================
/*
    ENDPOINT qui va retourner les creneaux disponible le jour d'une reservation
        la disponibilites des creneaux depends de deux choses : 1 - si le restaurant est ouvert
                                                                2 - si le client a deja une reservation ce jour la dans un service
    Si une reservation existe deja le jour selectionne, on doit afficher le service dans lequel se trouve cette reservation
    Si c'est une nouvelle reservation, on ne prends pas en compte les services contenant deja une reservation
*/

-- methode qui va retourner les services qui contiennent les reservations d'un utilisateur pour un jour donne
create or replace function services_containing_reservations(date_of_reservation date) returns
    TABLE (id int) as -- attention a bien faire attention au retour (au debut j'avais fait int puis ca ne retournait q'un resultat alors qu'il pouvait en avoir plusieurs)
    $$
    select s.id
    from services s join restaurants rst on s.restaurant = rst.id
                    join reservations rsv on rsv.restaurant = rst.id
    where   rsv.client = auth.id() and -- les reservations qui ont comme client l'utilisateur connecte
            rsv.datetime::date = date_of_reservation and -- qui sont a la date de selectionnee
            s.day_of_week = extract(isodow from date_of_reservation::date) and  -- les services du jour de la reservation
            rsv.datetime::time between s.start_time and s.end_time; -- dont la reservation se trouve dans ce service
    $$ language sql security definer;



create or replace function get_available_slots(restaurant_id int, date_of_reservation date, reservation_id int DEFAULT 0) returns json as
$$
declare
    service                 RECORD;
    hours           time[];
    first_slot      time;
    slot            int := (select slot_duration
                                    from restaurants
                                    where id = restaurant_id);
    reservation_dow int := extract(isodow from date_of_reservation);
    simulated_time timestamp := (select system_time.simulated_time from system_time);
begin
    -- check si utilisateur est connecte
    perform auth.check_logged();
    if (auth.role() = 'client') then
        -- recuperation des services pour le jour de la reservation (si new reservation -> on ne l'inclut pas)
        FOR service IN
            SELECT s.start_time, s.end_time
            FROM services s
                    -- qui se trouve dans le restaurant a la date de la reservation
            WHERE   s.restaurant = restaurant_id AND
                    s.day_of_week = reservation_dow AND
                    -- et qui ne contient pas une reservation existante dans le cas d'une nouvelle reservation
                    (reservation_id != 0 OR
                    reservation_id = 0 AND  s.id not in (select services_containing_reservations(date_of_reservation))) -- liste des services contenant une reservation du client pour le meme jour
            LOOP
                -- pour chacun des services calculer les heures de reservations
                first_slot = service.start_time;
                WHILE first_slot < service.end_time
                    LOOP
                        if (simulated_time::date != date_of_reservation or  first_slot >= simulated_time::time) then
                            hours := array_append(hours, first_slot);
                        end if;
                        first_slot := first_slot + slot * INTERVAL '1 minutes'; -- ajouter slot_duration
                    END LOOP;
            END LOOP;
        -- si les heures sont vides, c'est que aucun service n'a ete trouve
        if (hours IS NULL) then
            -- si c'est parce que le restaurant est ferme
            if (not exists(select s.id
                           from services s
                           where s.day_of_week = reservation_dow
                             and s.restaurant = restaurant_id)) then
                return json_build_object('message', 'Le restaurant est ferme ce jour la.');
                -- sinon c'est parce que la personne a une reservation dans chaque service du jour
            else
                return json_build_object('message',
                                         'Vous avez deja une reservation pour chaque service de ce jour la.');
            end if;
        end if;
        return json_build_object('slots', hours);
    end if;
end;
$$ language plpgsql security definer;

grant execute on function get_available_slots(int, date, int) to client;


-- =====================================================================================================================

/*
        ENDPOINT QUI RETOURNE SI LE RESTAURANT A ASSEZ DE PLACES POUR ACCEUILLIR LES CONVIVES

        Ce qu'il faut faire c'est comparer la capacite totale du restaurant (somme des tables au sein du restaurant) et
        la somme des convives des reservations le jour de la reservation au service de la reservation
        (si la reservation existe, on en prends pas en compte son nombre de convive de la base)
*/

create or replace function check_number_of_guests_validity(restaurant_id int, selected_date date, time_slot time, _number_of_guests int,  reservation_id int default 0) returns bool as
    $$
    declare restaurant_capacity int := (select sum(capacity) from tables where restaurant = restaurant_id);
    declare total_number_of_guests int;
    begin
        select sum(rsv.number_of_guests)
        from reservations rsv   join restaurants rst on rst.id = rsv.restaurant,
        (select * from get_service_by_datetime(selected_date, time_slot, restaurant_id)) as s -- retourne le service du jour de la reservation qui contient le creneau
        where rsv.datetime::date = selected_date and -- reservations a la date selectionne
              rsv.restaurant = restaurant_id and -- reservation dans le restaurant selectionne
              rsv.status in ('pending'::status_type, 'confirmed'::status_type) and -- ayant le status en attente ou confirmee
              s.day_of_week = extract(isodow from rsv.datetime::date) and -- au jour du service selectionne
              rsv.datetime::time between s.start_time and s.end_time and -- compris dans le service selectionne
              (reservation_id = 0 OR (reservation_id != 0 and rsv.id != reservation_id)) -- si c'est une nouvelle reservation prendre en compte toutes les reservations, si ce n'est pas une nouvelle, ne pas prendre en compte la reservation en cours d'edition
        into total_number_of_guests;
        return (coalesce(total_number_of_guests,0) + _number_of_guests) <= restaurant_capacity; -- retourne vrai si ya assez de places
    end;
    $$ language plpgsql security definer;

grant execute on function check_number_of_guests_validity(int, date, time, int, int) to client;

/*
Retourne le nombre de reservations en attentes
*/
create or replace function get_pending_reservation_count(restaurant_id int) returns integer as
$$
begin
    return (select count(*) from reservations r where r.status = 'pending' and r.restaurant = restaurant_id);
end;
$$ language plpgsql security definer;

grant execute on function get_pending_reservation_count(int) to manager;

/*
    Va verifier si il y'a assez de place pour acceuillir les convives
*/

create or replace function get_service_by_datetime(service_date date, time_slot time, restaurant_id int)
    returns setof services as
    $$
        -- cherchons tous les services...
        select s.*
        from services s
        where s.restaurant = restaurant_id -- dans le restaurant selectionne
          and s.day_of_week = extract(isodow from service_date)::int -- au jour selectionne
          and time_slot >= s.start_time -- tel que le creneau est situe entre le debut et la fin de ce service
          and time_slot < s.end_time;
    $$ language sql security definer;


create or replace function get_occupied_tables(date_of_reservation date, time_slot time, restaurant_id int)
    returns table(id int) as
    $$
        select distinct rt."table" as id
        from reservation_tables rt
                 join reservations r on r.id = rt.reservation
                 join get_service_by_datetime(date_of_reservation,time_slot,restaurant_id) s
                      on r.datetime::time >= s.start_time
                          and r.datetime::time < s.end_time
        where r.restaurant = restaurant_id
          and r.datetime::date = date_of_reservation
          and r.status <> 'cancelled';
    $$ language sql security definer;

create or replace function check_service_tables_capacity(number_of_guests int, date_of_reservation date, time_slot time, restaurant_id int)
    returns bool as
$$
select coalesce(sum(t.capacity), 0) >= number_of_guests
from tables t
where t.restaurant = restaurant_id
  and not exists (
    select 1
    from get_occupied_tables(date_of_reservation,time_slot,restaurant_id) ot
    where ot.id = t.id
);
$$ language sql security definer;

grant execute on function get_service_by_datetime(date, time, int) to client;
grant execute on function get_occupied_tables(date, time, int) to client;
grant execute on function check_service_tables_capacity(int, date, time, int) to client;

create or replace function vip_true(reservation_id int)
    returns json as
$$
declare
    updated_reservation_id int := reservation_id;
begin
    -- verification si utilisateur connecte
    perform auth.check_logged();
    if (auth.role() <> 'manager') then
        raise exception 'Cannot update a reservation VIP if you are not a manager';
    end if;

        UPDATE reservations
        set is_vip         = true
        WHERE id = reservation_id;
    return get_reservation(updated_reservation_id);
end;
$$ language plpgsql security definer;

grant execute on function vip_true(int) to manager;


create or replace function vip_false(reservation_id int)
    returns json as
$$
declare
    updated_reservation_id int := reservation_id;
begin
    -- verification si utilisateur connecte
    perform auth.check_logged();
    if (auth.role() <> 'manager') then
        raise exception 'Cannot update a reservation VIP if you are not a manager';
    end if;

    UPDATE reservations
    set is_vip         = false
    WHERE id = reservation_id;
    return get_reservation(updated_reservation_id);
end;
$$ language plpgsql security definer;

grant execute on function vip_false(int) to manager;