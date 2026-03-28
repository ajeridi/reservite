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