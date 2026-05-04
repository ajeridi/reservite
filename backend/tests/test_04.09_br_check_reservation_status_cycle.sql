set search_path to public;

begin;
do
$test$
    begin
        raise notice 'Test BR_09 : Insertion invalide dans table reservation';
        perform should_fail($$
                insert into reservations(client, restaurant, datetime, number_of_guests, status) VALUES (3, 4, '2024-12-06 19:00:00.000000', 4, 'confirmed');
            $$, 'raise_exception');
        raise notice 'Test BR_09 : Insertion valide dans la table reservation';
        insert into reservations(client, restaurant, datetime, number_of_guests) VALUES (3, 4, '2024-12-06 19:00:00.000000', 4); -- OK
    end
$test$;
rollback;

begin;
do
$test$
    begin
        raise notice 'Test BR_09 : update valide dans table reservation';
        update reservations set status = 'completed' where id = 19; -- OK
    end
$test$;
rollback;

begin;
do
$test$
    begin
        raise notice 'Test BR_09 : update non valide dans table reservation';
        perform should_fail( $$
        update reservations set status = 'confirmed' where id = 19;
        $$, 'raise_exception');
    end
$test$;
rollback;


