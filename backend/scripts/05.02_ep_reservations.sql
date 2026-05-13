set search_path to public, auth;

-- types sur mesures
create type client_details as
(
    id integer,
    name varchar,
    email varchar,
    phone varchar
);

create type restaurant_details as
(
    id integer,
    name varchar,
    address varchar,
    city varchar,
    phone varchar
);

create type table_details as
(
    id integer,
    table_number integer,
    capacity integer
);

create type reservation_type as
(
    id integer,
    client client_details,
    restaurant restaurant_details,
    datetime timestamp,
    number_of_guests integer,
    status status_type,
    special_requests text,
    tables table_details[]
);



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




/*
Confirmation d'une reservation et assignation des tables pour cette reservation
    recoit un id de reservation et un liste d'id de tables
*/

create or replace function confirm_reservation(reservation_id int, tables_id int[]) returns json as
    $$
    begin
        -- assigner les tables
        insert into reservation_tables (reservation, "table") select reservation_id, t from unnest(tables_id) as t;
        -- update le statut vers confirmed
        update reservations set status = 'confirmed' where reservations.id = reservation_id;
        -- retourner la reservation confirmee
        return get_reservation(reservation_id);
    end;
    $$ language plpgsql security definer;

grant execute on function confirm_reservation(int, int[]) to manager;




