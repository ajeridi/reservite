set search_path to public;


-- test1 : cas valide (même service, mais sur des tables DIFFERENTES)
begin;
do $test$
    begin
        raise notice 'TEST BR-06: Succès - Tables différentes pour le même service';

        -- client 3 prend la table 1 à 12h30
        insert into reservations (id, client, restaurant, datetime, number_of_guests)
        values (901, 3, 1, '2024-12-01 12:30:00', 2);
        insert into reservation_tables (reservation, "table") values (901, 1);

        update reservations set status = 'confirmed'
        where id = 901;

        -- client 4 prend la table 2 à 12h30 (tout va bien)
        insert into reservations (id, client, restaurant, datetime, number_of_guests)
        values (902, 4, 1, '2024-12-01 12:30:00', 2);
        insert into reservation_tables (reservation, "table") values (902, 2);

        update reservations set status = 'confirmed'
        where id = 902;

        set constraints all immediate;
    end;
$test$;
rollback;


-- test2 : cas valide (même table, mais pour des services DIFFERENTS : midi et soir)
begin;
do $test$
    begin
        raise notice 'TEST BR-06: Succès - Même table mais services différents (Midi vs Soir)';

        -- Client 3, Table 1, service de midi (12h30)
        insert into reservations (id, client, restaurant, datetime, number_of_guests)
        values (903, 3, 1, '2024-12-02 12:30:00', 2);
        insert into reservation_tables (reservation, "table") values (903, 1);

        update reservations set status = 'confirmed'
        where id = 903;

        -- Client 4, Table 1, service du soir (20h00) (Tout va bien)
        insert into reservations (id, client, restaurant, datetime, number_of_guests)
        values (904, 4, 1, '2024-12-02 20:00:00', 2);
        insert into reservation_tables (reservation, "table") values (904, 1);

        update reservations set status = 'confirmed'
        where id = 904;

        set constraints all immediate;
    end;
$test$;
rollback;


-- test3 : cas invalide (même table, même service = erreur)
begin;
do $test$
    begin
        raise notice 'TEST BR-06: Échec attendu - Même table et même service';

        perform should_fail($$
            -- Client 3, Table 1 à 12h30
            insert into reservations (id, client, restaurant, datetime, number_of_guests)
            values (905, 3, 1, '2024-12-01 12:30:00', 2);
            insert into reservation_tables (reservation, "table") values (905, 1);

            update reservations set status = 'confirmed'
            where id = 905;

            -- Client 4, Table 1 à 13h00 (plein milieu du même service)
            insert into reservations (id, client, restaurant, datetime, number_of_guests)
            values (906, 4, 1, '2024-12-01 13:00:00', 2);
            insert into reservation_tables (reservation, "table") values (906, 1);

            update reservations set status = 'confirmed'
            where id = 906;

        $$, 'raise_exception');
    end;
$test$;
rollback;