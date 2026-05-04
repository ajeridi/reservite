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
        if (old.status = 'pending' AND (new.status = 'confirmed' OR new.status = 'cancelled')) OR
           ((old.status = 'confirmed') AND (new.status = 'completed' OR new.status = 'cancelled')) OR
           (new.datetime > (SELECT simulated_time FROM system_time) AND old.status = 'confirmed' AND new.status = 'pending') THEN
            return new;
        else
            raise exception 'Reservation status cycle not respected';
        end if;
    end;
    $$language plpgsql;


create or replace trigger check_reservation_status_cycle
    before insert or update
    on reservations
    for each row
    execute function check_reservation_status_cycle_fct();



