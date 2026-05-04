/*
Tests sur la table Reservations :
    - INSERT :
        - insertion avec datetime ok
        - insertion avec datetime ko
        - insertion avec datetime ko et status cancelled (passe normalement)
    - UPDATE :
        - update de datetime non valide
        - update de status et dateime non valide
*/

begin;
do
$test$
    begin
        raise notice 'TEST valide : insertion de reservation avec datetime valide';
        insert into reservations (client, restaurant, datetime, number_of_guests) VALUES (3, 1, '2024-12-01 12:30:00.000000', 3);
    end;
$test$;
rollback;

begin;
do
$test$
    begin
        raise notice 'TEST non valide: insertion de reservation avec datetime non valide';
        perform should_fail($$ insert into reservations (client, restaurant, datetime, number_of_guests) VALUES (3, 1, '2024-12-01 15:30:00.000000', 3);
        $$, 'raise_exception');
    end;
$test$;
rollback;



begin;
do
$test$
    begin
        raise notice 'TEST valide : insertion de reservation avec datetime non valide et status cancelled';
         insert into reservations (client, restaurant, datetime, number_of_guests, status) VALUES (3, 1, '2024-12-01 15:30:00.000000', 3, 'cancelled');
    end;
$test$;
rollback;


begin;
do
$test$
    begin
        raise notice 'TEST valide : insertion de reservation avec datetime non valide et status cancelled';
        insert into reservations (client, restaurant, datetime, number_of_guests, status) VALUES (3, 1, '2024-12-01 15:30:00.000000', 3, 'cancelled');
    end;
$test$;
rollback;

