set search_path to public;

-- test 1 : cas - table reservations
begin;
do $test$
    declare
    begin
        raise notice 'TEST BR-02: Succès - Numero convivies valide';
        update reservations set number_of_guests = 1 where id =1;

        raise notice 'TEST BR-02: Error - Numero convivies invalide';
        perform should_fail($$
            update reservations set number_of_guests = 10 where id =1;
            $$,'raise_exception');

    end
$test$;
rollback;

select * from reservation_tables
    join public.reservations r on reservation_tables.reservation = r.id
    where not(r.status ='confirmed' or r.status ='completed');

-- test 2 : cas - table reservations_table
begin;
do $test$
    begin
        raise notice 'TEST BR-02: Succès - Suppression effectuée';
        --delete from reservation_tables where reservation = 1;

        raise notice 'TEST BR-02: Error - Suppression invalide';
        perform should_fail($$
            insert into reservations(client, restaurant, datetime, number_of_guests,special_requests)
            VALUES(3,1,'2024-11-15 19:05:00.000000',2,'balablabla');
        $$,'raise_exception');
    end
$test$;
rollback;
