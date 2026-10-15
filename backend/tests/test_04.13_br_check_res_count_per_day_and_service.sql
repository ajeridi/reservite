set search_path to public;

begin;
do
$test$
    begin
        raise notice 'TEST BR-13 non valide : insertion de deux reservations le meme jour au meme service';
        perform should_fail($$
                insert into reservations(client, restaurant, datetime, number_of_guests) VALUES (3, 1, '2024-12-09 19:00:00', 3);
                insert into reservations(client, restaurant, datetime, number_of_guests) VALUES (3, 1, '2024-12-09 19:30:00', 3);
            $$, 'raise_exception');
    end;
$test$;
rollback;



