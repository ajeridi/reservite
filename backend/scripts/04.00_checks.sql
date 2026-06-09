set search_path to public ;

/**************************************************************
  Partie user
**************************************************************/
--constraint full name doit avoir min 3 char
alter table users
add constraint cs_name_length
check (length(trim(full_name)) >= 3);

--tests
/*insert into users( email, password, full_name, role, phone)
values ('test_password', 'Projet123@','Test','client','12345');*/

--constraint user password
alter table users
add constraint cs_password_regex
check ( password ~ '^(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])(?=.*[,;.:!?/$%&@#]).{8,}$' );

--trigger pour empêcher le changement du 'rôle' d'un user
create or replace function no_edit_user_role_fct() returns trigger as
$$
begin
    if (new.role <> old.role) then
        raise exception 'Can''t edit client''s role';
    end if;
    return new;
end;
$$language plpgsql;

create or replace trigger no_edit_user_role
    before update
    on users
    for each row
execute function no_edit_user_role_fct();

/*update users set role = 'manager' where id =6;*/

--REGLES INVARIANTES DE LA TABLE RESTAURANTS
--contrainte nom min 5 charactères
alter table restaurants
add constraint cs_name_length_restaurants
check ( length(trim(name)) >=5);

/*insert into restaurants(name, address, city, phone, description, rating, price_range)
values ('Abcde','test','test','123','test description',5,1);

delete from restaurants
    where name ='Abcde';*/

--contrainte adresse min 5 charactères
alter table restaurants
add constraint cs_adress_length_restaurants
check ( length(trim(address)) >= 5);

/*insert into restaurants(name, address, city, phone, description, rating, price_range)
values ('Abcde','test','test','123','test description',5,1);

delete from restaurants
    where name ='Abcde';*/

--contrainte city name min 3 charactères
    alter table restaurants
    add constraint cs_city_length_restaurants
    check ( length(trim(city)) >= 3);

/*insert into restaurants(name, address, city, phone, description, rating, price_range)
values ('Abcde','test123','ci','123','test description',5,1);*/

--contrainte phone format belge avec ou sans éspaces
alter table restaurants
add constraint cs_phone_format_restaurants
check ( phone ~ '^(\+32|0)[0-9\s]{10,17}$' );

/*insert into restaurants(name, address, city, phone, description, rating, price_range)
values ('Abcde','test123','city','+32 1 234 56 89','test description',5,1);

delete from restaurants
    where city = 'city';*/

--contrainte description length >=10 if not null
alter table restaurants
    add constraint cs_description_restaurants
    check ( (description is null) or (length(trim(description))>=10));

/*insert into restaurants(name, address, city, phone, rating, price_range)
values ('Abcde','test123','city','+32 1 234 56 89',5,1);

delete from restaurants
where city = 'city';*/

-- contrainte note if not null
alter table restaurants
    add constraint cs_note_restaurant
    check ( (rating is null) or (rating >= 0.0 and rating <= 5.0));

/*insert into restaurants(name, address, city, phone, rating, price_range)
values ('Abcde','test123','city','+32 1 234 56 89',0.1,1);
delete from restaurants
where city = 'city';*/

-- contrainte price_range if not null
alter table restaurants
    add constraint cs_price_range_restaurants
    check ( (price_range is null) or (price_range >=1 and price_range <=4));

/*insert into restaurants(name, address, city, phone, rating, price_range)
values ('Abcde','test123','city','+32 1 234 56 89',0.1,1);
delete from restaurants
where city = 'city';*/

--contrainte slot_duration
alter table restaurants
    add constraint cs_slot_duration_restaurants
    check ( (slot_duration = 10) or (slot_duration = 15) or (slot_duration = 20) or (slot_duration = 30) or (slot_duration = 60));

insert into restaurants(name, address, city, phone, rating, price_range, slot_duration)
values ('Abcde','test123','city','+32 1 234 56 89',0.1,1, 15);
delete from restaurants
where city = 'city';

-- REGLES INVARIANTES DE LA TABLE RESERVATIONS
-- contrainte de check sur le statut (le fait automatiquement car c'est un enum)
alter table reservations
add constraint cs_statut_reservation
CHECK (status in ('pending', 'confirmed', 'cancelled',  'completed'));

/*-- tests
insert into reservations (client, restaurant, datetime, number_of_guests, status)
values (2, 3, '2026-03-28', 12, 'pending');
update reservations set status = 'confirmed' where client = 2 and restaurant = 3;
update reservations set status = 'cancelled' where client = 2 and restaurant = 3;
update reservations set status = 'completed' where client = 2 and restaurant = 3;
update reservations set status = 'COMPLETED' where client = 2 and restaurant = 3;
update reservations set status = 'en cours' where client = 2 and restaurant = 3;
update reservations set status = 'pending' where client = 2 and restaurant = 3;
*/

-- contrainte de check sur le nombre de convives
alter table reservations
add constraint cs_strictly_positive_guest_number
check ( number_of_guests > 0 );

-- tests
/*
insert into reservations (client, restaurant, datetime, number_of_guests, status)
values (2, 4, '2026-03-28', 2 , 'pending');
update reservations set number_of_guests = 0 where client = 2 and restaurant = 4;
 */

-- contrainte de check sur la longueur du special request
    -- si la special request est non nulle alors length >= 10 --> special_request != null => length >= 10
    -- not p or q : special_request == null OR length >= 10
alter table reservations
add constraint cs_special_request_length
check ( special_requests is null OR length(trim(special_requests)) >= 10 );

/*-- tests
insert into reservations (client, restaurant, datetime, number_of_guests, special_requests) values (2, 3,  current_date, 2, null);
insert into reservations (client, restaurant, datetime, number_of_guests, special_requests) values (2, 4,  current_date, 2, 'this is a special request that is longer than 10 characters');
insert into reservations (client, restaurant, datetime, number_of_guests, special_requests) values (2, 5,  current_date, 2, 'abc');

delete from reservations where id > 22
*/

-- trigger qui empeche la modification du client ou du restaurant d'une reservation
create or replace function no_edit_client_restaurant_fct() returns trigger as
    $$
    begin
        if (new.client <> old.client OR new.restaurant <> old.restaurant) then
            raise exception 'Can''t edit client or restaurant of a reservation';
        end if;
        return new;
    end;
    $$language plpgsql;

create or replace trigger no_edit_client_restaurant
    before update
    on reservations
    for each row
    execute function no_edit_client_restaurant_fct();

/*update reservations set client = 2 where id = 22;
update reservations set restaurant = 2 where id = 22;
update reservations set client = 2, restaurant = 2 where id = 22;
update reservations set client = 6, restaurant = 4 where id = 22;

insert into reservations (client, restaurant, datetime, number_of_guests, special_requests) VALUES (3, 5, current_date, 3, null);
*/




-- REGLE INVARIANTES DE LA TABLE TABLES

-- un numero de table doit etre strictement positif
alter table tables
add constraint cs_strictly_positive_table_number
check (table_number > 0);

-- test
/*insert into tables (restaurant, table_number, capacity) values (1, 0, 4);
insert into tables (restaurant, table_number, capacity) values (1, 2, 4);
*/

-- la capacite doit etre strictement positive
alter table tables
add constraint cs_strictly_positive_capacity
check ( capacity > 0 );

/*insert into tables (restaurant, table_number, capacity) values (8, 5, 0);
insert into tables (restaurant, table_number, capacity) values (8, 5, 4);
*/

-- le restaurant d'une table est non modifiable
create or replace function no_edit_restaurant_table() returns trigger as
    $$
    begin
        if (new.restaurant <> old.restaurant) then
            raise exception 'Cannot edit the restaurant of an existing table';
        end if;
        return new;
    end;
    $$language plpgsql;

create or replace trigger no_edit_restaurant_table
    before update
    on tables
    for each row
    execute function no_edit_restaurant_table();

-- tests
/*update tables set restaurant = 9 where id = 29;
update tables set table_number = 9 where id = 29;
*/


-- REGLES INVARIANTES DE LA TABLE SERVICES

-- day_of_week doit etre compris entre 1 et 7
alter table services
add constraint cs_day_of_week_between_1_7
check ( day_of_week between 1 and 7);
/*
insert into services (restaurant, day_of_week, start_time, end_time) VALUES (3, 1, current_time, current_time);
insert into services (restaurant, day_of_week, start_time, end_time) VALUES (3, 7, current_time, current_time);
insert into services (restaurant, day_of_week, start_time, end_time) VALUES (3, 8, current_time, current_time);
insert into services (restaurant, day_of_week, start_time, end_time) VALUES (3, 0, current_time, current_time);
*/

-- l'heure de fin doit etre posterieure a l'heure de debut d'au moins une heure
alter table services
add constraint cs_end_time_one_hour_min_after_start_time
check ( end_time - start_time >= '01:00:00' );

-- tests
/*
insert into services (restaurant, day_of_week, start_time, end_time) VALUES (3, 3, '01:00:00', '01:30:00'); -- NOK
insert into services (restaurant, day_of_week, start_time, end_time) VALUES (3, 3, '01:00:00', '02:00:00'); -- OK
*/

-- on ne peut pas modifier le restaurant d'un service
create or replace function no_edit_restaurant_of_service() returns trigger as
    $$
    begin
        if (new.restaurant <> old.restaurant) then
            raise exception 'Cannot edit restaurant of service';
        end if;
        return new;
    end;
    $$ language plpgsql;

create or replace trigger no_edit_restaurant_of_service
    before update
    on services
    for each row
    execute function no_edit_restaurant_of_service();

-- tests
/*update services set restaurant = 9 where id = 88;
update services set day_of_week = 2 where id = 88;
*/



/*
        TABLE RESTAURANT_MANAGERS ET RESERVATIONS TABLES ET REVIEWS : PREVENT UPDATE
*/

create or replace function prevent_update_fct()
returns trigger as
    $$
    begin
        if (tg_table_name = 'restaurant_managers') then
            if (old.restaurant <> new.restaurant OR old.manager <> new.manager) then
                raise exception 'Cannot update composed key of table %', tg_table_name;
            end if;
        end if;
        if (tg_table_name = 'reservation_tables') then
            if (old.reservation <> new.reservation OR old.table <> new.table) then
                raise exception 'Cannot update composed key of table %', tg_table_name;
            end if;
        end if;
        if (tg_table_name = 'reviews') then
            if (old.client <> new.client OR old.reservation <> new.reservation OR old.restaurant <> new.restaurant) then
                raise exception 'Cannot update composed key of table %', tg_table_name;
            end if;
        end if;
        return new;
    end;
    $$ language plpgsql;

create or replace trigger prevent_update_restaurant_managers_trigger
    before update
    on restaurant_managers
    for each row
    execute function prevent_update_fct();

create or replace trigger prevent_update_reservation_tables_trigger
    before update
    on reservation_tables
    for each row
execute function prevent_update_fct();

create or replace trigger prevent_update_reviews_table_trigger
    before update
    on reviews
    for each row
    execute function prevent_update_fct();
