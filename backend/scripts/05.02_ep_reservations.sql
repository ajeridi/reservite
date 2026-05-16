set search_path to public, auth;

/*
Operations possible pour une reservation
    - lister (manager, client)
    - voir (details) (manager, client), peut etre voir aussi si json retourne est different en fonction du role
    - insert/update (client)
    - confirm (manager)
    - cancel (manager, client)
    - complete (manager)
*/

-- METHODES UTILITAIRES

/*
Verifie si un manager travaille dans un restaurant
*/

create or replace function check_manager_works_in_restaurant(manager_id int, restaurant_id int) returns void as
    $$
    begin
        if not exists(select manager from restaurant_managers rm where restaurant = restaurant_id and manager = manager_id ) then
            raise exception 'Manager is not working at that restaurant';
        end if;
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
    if (auth.role() = 'client' AND (select client from reservations rsv where rsv.id = reservation_id) <> auth.id()) then
        raise exception 'Reservation must be of client';
    end if;
    -- si user est un manager, il faut qu'il soit manager dans le restaurant dans lequel se trouve la reservation
    if (auth.role() = 'manager' AND not exists(select * from restaurant_managers where manager = auth.id() and restaurant = (select rsv.restaurant from reservations rsv where rsv.id = reservation_id))) then
        raise exception 'Manager cannot check a reservation inside a restaurant he is not working in';
    end if;

    return (select json_build_object(
           'id', rsv.id,
           'client', (select json_build_object('id', u.id, 'name', u.full_name, 'email', u.email, 'phone', u.phone) from users u where u.id = rsv.client),
           'restaurant', (select json_agg(json_build_object('id', rsv.restaurant, 'name', rst.name, 'address', rst.address, 'city', rst.city, 'phone', rst.phone)) from restaurants rst where rst.id = rsv.restaurant),
           'datetime', rsv.datetime,
           'number_of_guests', rsv.number_of_guests,
           'status', rsv.status,
           'sepcial_requests', rsv.special_requests,
           'tables', (select json_agg(json_build_object('id', t.id, 'table_number', t.table_number, 'capacity', t.capacity)) from reservation_tables rt join tables t on rt."table" = t.id where rt.reservation = reservation_id)
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
    declare user_id int := auth.id();
    declare user_role role_type := auth.role();
    begin
        -- verification si le user est logged
        perform auth.check_logged();
        -- un client a besoin uniquement du nom du restaurant, de la ville du restaurant, de la date et du nombre de convives, le statut
        if (user_role = 'client'::role_type) then
            return (select json_agg(
                           json_build_object(
                                'id', rsv.id,
                                'client', rsv.client,
                                'restaurant', (select json_build_object('id', rsv.id, 'name', rst.name, 'city', rst.city) from restaurants rst where rst.id = rsv.restaurant),
                                'datetime', rsv.datetime,
                                'number_of_guests', rsv.number_of_guests,
                                'status', rsv.status
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
                                           'client', (select json_build_object('full_name', u.full_name) from users u where u.id = rsv.client),
                                           'restaurant', (select json_build_object('id', rsv.id, 'name', rst.name, 'city', rst.city) from restaurants rst where rst.id = rsv.restaurant),
                                           'datetime', rsv.datetime,
                                           'number_of_guests', rsv.number_of_guests,
                                           'status', rsv.status
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
Confirmation d'une reservation et assignation des tables pour cette reservation
    recoit un id de reservation et un liste d'id de tables
*/

create or replace function confirm_reservation(reservation_id int, tables_id int[]) returns json as
    $$
    declare restaurant_id int;
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
        if (auth.id() not in (select rm.manager from restaurant_managers rm where manager = auth.id() and restaurant = restaurant_id )) then
            raise exception 'User is not manager at the reservation''s restaurant';
        end if;
        -- verifier si la table est bien dans le restaurant (en regardant comparant le nombre de lignes avec le nombre d'elements dans le tableau)
        if (select count(*) from tables t where t.restaurant = restaurant_id and t.id = any(tables_id)) < array_length(tables_id, 1) then -- le any est comme un 'OR'
            raise exception 'At least one of the tables is not in the restaurant of the reservation';
        end if;
        -- assigner les tables
        insert into reservation_tables (reservation, "table") select reservation_id, t from unnest(tables_id) as t; -- unnest parcours la liste de table et pour chaque element insere la ligne reservation_id, tables_id[i]
        -- update le statut vers confirmed
        update reservations set status = 'confirmed' where reservations.id = reservation_id;
        -- retourner la reservation confirmee
        return get_reservation(reservation_id);
    end;
    $$ language plpgsql security definer;

grant execute on function confirm_reservation(int, int[]) to manager;

-- =====================================================================================================================


