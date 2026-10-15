set search_path to public;

/*
(BR-09) Une nouvelle réservation doit avoir le status pending. Une réservation existante ne peut pas revenir "en arrière" dans son cycle de vie. Les transitions autorisées sont :

    pending -> confirmed
    pending -> cancelled
    confirmed -> completed
    confirmed -> cancelled

La transition confirmed -> pending est autorisée dans certains cas (voir règles temporelles).
   Depuis regles temporelles : 'En plus des transitions décrites ci-dessus, le statut d'une réservation peut passer de confirmed à pending uniquement si la réservation est dans le futur (pour permettre l'édition par le client.'

Aucune transition depuis completed ou cancelled n'est autorisée.


Tables et operations concernees :

    Reservation :   - INSERT : oui, verifier sur le statut est pending, sinon exception
                    - UPDATE : oui, verifier si on respecte le cycle de statut, donc if old.status == pending et (new.status = confirmed ou cancelled) c'est ok
                                CAS PARTICULIER -> si reservation est dans le futur, on peut faire confirmed -> pending
                    - Delete : non, car aucun impact
*/

create or replace function check_reservation_status_cycle_fct()
returns trigger as
    $$
    begin
        if  (tg_op = 'INSERT' and new.status = 'pending') OR
            (tg_op = 'UPDATE') AND
                ((old.status = 'pending' AND (new.status = 'pending' OR new.status = 'confirmed' OR new.status = 'cancelled')) OR
                ((old.status = 'confirmed') AND (new.status = 'confirmed' OR new.status = 'completed' OR new.status = 'cancelled')) OR
                (new.datetime > (SELECT simulated_time FROM system_time) AND old.status = 'confirmed' AND new.status = 'pending')) THEN
            return new;
        end if;
        raise exception 'Reservation status cycle not respected';
    end;
    $$language plpgsql security definer ;


create or replace trigger check_reservation_status_cycle
    before insert or update of status
    on reservations
    for each row
    execute function check_reservation_status_cycle_fct();


/*
Tests :
*/

/*
insert into reservations(client, restaurant, datetime, number_of_guests, status) VALUES (3, 4, '2024-12-06 19:00:00.000000', 4, 'confirmed'); -- KO
insert into reservations(client, restaurant, datetime, number_of_guests) VALUES (3, 4, '2024-12-06 19:00:00.000000', 4); -- OK
update reservations set status = 'completed' where id = 19; -- OK
-- de completed a confirmed KO
update reservations set status = 'confirmed' where id = 19; -- KO
-- de completed a pending KO
update reservations set status = 'pending' where id = 19; -- KO
-- de completed a cancelled KO
update reservations set status = 'cancelled' where id = 19; -- KO

-- reservation 19 se fait a la date du 3/12/2024, simulated time est 4/12/2024, changement de simulated time en 1/12/2024
update system_time set simulated_time = '2024-12-01 16:00:00.000000';
-- update de confirmed a pending dans le futur OK
update reservations set status = 'pending' where id = 19; -- OK

*/
