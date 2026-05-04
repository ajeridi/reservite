set search_path to public;

-- test 1 : cas valide (creneau reservation valide)
begin;
do $test$
    begin
        raise notice 'TEST BR-05: Succès - Creneau valide';

        insert into reservations(client, restaurant, datetime, number_of_guests,special_requests)
        VALUES(3,1,'2024-11-15 19:30:00.000000',2,'balablabla');
    end
$test$;
rollback;

-- test 2 : cas invalide (creneau reservation invalide)
begin;
do $test$
    begin
        raise notice 'TEST BR-05: Error - Creneau invalide';
        perform should_fail($$
            insert into reservations(client, restaurant, datetime, number_of_guests,special_requests)
            VALUES(3,1,'2024-11-15 19:05:00.000000',2,'balablabla');
        $$,'raise_exception');
    end
$test$;
rollback;

