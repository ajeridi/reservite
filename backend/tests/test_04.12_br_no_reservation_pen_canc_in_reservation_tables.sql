set search_path to public;


begin;
do
$test$
    begin
        raise notice 'Test BR_12 : update invalide dans la table reservation';
        perform should_fail($$
                update reservations set status = 'cancelled' where id = 1;
            $$, 'raise_exception');
    end
$test$;
rollback;


begin;
do
$test$
    begin
        raise notice 'Test BR_12 valide : new reservation, association et update vers confirmed';
        -- creation reservation pour 3 personnes au restaurant 4 le 06 dec 2024 (Vddi) a 18h
        insert into reservations (id, client, restaurant, datetime, number_of_guests) VALUES (900, 3, 4, '2024-12-06 18:00:00', 2);
        -- association de la reservation a la table 9
        insert into reservation_tables(reservation, "table") VALUES (900, 9);
        -- update de reservation a confirmed
        update reservations set status = 'confirmed' where id = 900;
        set constraints all immediate;
    end
$test$;
rollback;


begin;
do
$test$
    begin
        raise notice 'Test BR_12 non valide : new reservation, association d''une reservation pending a une table';
        -- creation reservation pour 3 personnes au restaurant 4 le 06 dec 2024 (Vddi) a 18h
        insert into reservations (id, client, restaurant, datetime, number_of_guests) VALUES (900, 3, 4, '2024-12-06 18:00:00', 2);
        -- association de la reservation a la table 9
        perform should_fail($$
                insert into reservation_tables(reservation, "table") VALUES (900, 9);
            $$, 'raise_exception');
    end
$test$;
rollback;


begin;
do
$test$
    begin
        raise notice 'Test BR_12 non valide : new reservation, update de reservation table en changeant la reservation vers la nouvelle pending';
        -- creation reservation pour 3 personnes au restaurant 4 le 06 dec 2024 (Vddi) a 18h
        insert into reservations (id, client, restaurant, datetime, number_of_guests) VALUES (900, 3, 4, '2024-12-06 18:00:00', 2);
        -- association de la reservation a la table 9
        perform should_fail($$
                update reservation_tables set reservation = 900 where reservation = 15 and "table" = 9;
            $$, 'raise_exception');
    end
$test$;
rollback;


