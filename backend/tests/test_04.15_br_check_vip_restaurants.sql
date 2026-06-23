set search_path to public;


-- test1 : cas valide (ajout d'une reservation comme admin dans la db)

begin;
do $test$
    begin
        raise notice 'TEST BR-15: Succès - d''une reservation comme admin dans la db';


        -- un admin ajoute une réservation pour le même jour à 12h30 (c'est dans le futur donc ca passe)
        insert into reservations (id, client, restaurant, datetime, number_of_guests, status)
        values (914, 4, 1, '2024-12-05 20:00:00.000000', 2, 'pending');

    end;
$test$;
rollback;

-- test2 : cas invalide ajout update dans le passé

begin;
do $test$
    begin
        raise notice 'TEST BR-15: Échec attendu - Création dans le passé';

        -- fixe le temps simulé au 15 Novembre 2024 à 15h
        delete from system_time;
        insert into system_time (simulated_time) values ('2024-11-15 15:00:00');

        perform should_fail($$
            insert into reservations (id, client, restaurant, datetime, number_of_guests, status)
        values (914, 4, 1, '2024-11-05 20:00:00.000000', 2, 'pending');
        $$, 'raise_exception');

    end;
$test$;
rollback;

-- test2 : cas invalide ajout update plus de 3 reservations vip

begin;
do $test$
    begin
        raise notice 'TEST BR-15: Échec attendu - Update a plus de 3 reserations en vip';


        -- un manager essaie de faire
        perform should_fail($$
            update reservations set is_vip = true where restaurant = 1 and id = 23;
             update reservations set is_vip = true where restaurant = 1 and id = 24;
              update reservations set is_vip = true where restaurant = 1 and id = 25;
             update reservations set is_vip = true where restaurant = 1 and id = 27;
        $$, 'raise_exception');

    end;
$test$;
rollback;