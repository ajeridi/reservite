set search_path to public;


-- test1 : cas valide (modification d'une réservation 'pending')

begin;
do $test$
    begin
        raise notice 'TEST BR-11: Succès - Modification autorisée sur une réservation en attente';

        -- crée la réservation en 'pending'
        insert into reservations (id, client, restaurant, datetime, number_of_guests, status)
        values (910, 1, 1, '2024-11-15 12:30:00', 2, 'pending');

        -- le client change d'avis et modifie le nombre de guests
        update reservations set number_of_guests = 4 where id = 910;
    end;
$test$;
rollback;



-- test2 : cas invalide (tentative de modification sur cancelled)

begin;
do $test$
    begin
        raise notice 'TEST BR-11: Échec attendu - Modification d''une réservation annulée';

        -- on crée en pending
        insert into reservations (id, client, restaurant, datetime, number_of_guests, status)
        values (911, 1, 1, '2024-11-15 12:30:00', 2, 'pending');

        -- on l'annule (ca c'est tjrs autorisé)
        update reservations set status = 'cancelled' where id = 911;

        -- on essaie mtn de la modifier APRES annulation (et là du coup erreur)
        perform should_fail($$
            update reservations set special_requests = 'Finalement je viens' where id = 911;
        $$, 'raise_exception');
    end;
$test$;
rollback;



-- test3 : cas invalide (tentative de modification sur completed)
begin;
do $test$
    begin
        raise notice 'TEST BR-11: Échec attendu - Modification d''une réservation terminée';

        -- on crée tjrs en pending
        insert into reservations (id, client, restaurant, datetime, number_of_guests, status)
        values (912, 1, 1, '2024-11-15 12:30:00', 2, 'pending');

        -- on lui donne une table (OBLIGATOIRE pour que BR-02 laisse passer completed)
        insert into reservation_tables (reservation, "table") values (912, 1);

        -- on passe la réservation en completed (ca on peut tjrs)
        update reservations set status = 'completed' where id = 912;

        -- le manager essaie de changer la date APRES completed (erreur)
        perform should_fail($$
            update reservations set datetime = '2024-11-15 13:00:00' where id = 912;
        $$, 'raise_exception');
    end;
$test$;
rollback;