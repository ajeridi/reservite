set search_path to public;


-- test1 : cas valide (création d'une réservation dans le futur)

begin;
do $test$
    begin
        raise notice 'TEST BR-14: Succès - Création dans le futur';

        -- fixe le temps simulé au 15 Novembre 2024 à 10h
        delete from system_time;
        insert into system_time (simulated_time) values ('2024-11-15 10:00:00');

        -- un client réserve pour le même jour à 12h30 (c'est dans le futur donc ca passe)
        insert into reservations (id, client, restaurant, datetime, number_of_guests, status)
        values (914, 3, 1, '2024-11-15 12:30:00', 2, 'pending');

    end;
$test$;
rollback;


-- test2 : cas invalide (création d'une réservation dans le passé)

begin;
do $test$
    begin
        raise notice 'TEST BR-14: Échec attendu - Création dans le passé';

        -- fixe le temps simulé au 15 Novembre 2024 à 15h
        delete from system_time;
        insert into system_time (simulated_time) values ('2024-11-15 15:00:00');

        -- un client essaie de réserver pour 12h30 (c'est dans le passé, ca passe pas)
        perform should_fail($$
            insert into reservations (id, client, restaurant, datetime, number_of_guests, status)
            values (915, 3, 1, '2024-11-15 12:30:00', 2, 'pending');
        $$, 'raise_exception');

    end;
$test$;
rollback;


-- test3 : cas valide (modification d'une réservation passée - autorisée par la règle)

begin;
do $test$
    begin
        raise notice 'TEST BR-14: Succès - Modification d''une réservation passée';

        -- fixe le temps simulé au 15 Novembre à 10h
        delete from system_time;
        insert into system_time (simulated_time) values ('2024-11-15 10:00:00');

        -- on crée une réservation pour 12h30 (on a vu que c'était autorisé)
        insert into reservations (id, client, restaurant, datetime, number_of_guests, status)
        values (916, 3, 1, '2024-11-15 12:30:00', 2, 'pending');

        -- mtn on avance dans le temps et on se place à demain (16 Novembre)
        update system_time set simulated_time = '2024-11-16 10:00:00';

        -- on modifie la réservation (qui est maintenant dans le passé) et ca doit marcher
        update reservations set number_of_guests = 3 where id = 916;

    end;
$test$;
rollback;