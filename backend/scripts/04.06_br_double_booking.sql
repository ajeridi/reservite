/*
(BR-06) Une table ne peut pas faire l'objet de deux réservations terminées ou confirmées pour une même date et un même service.

Analyse :
    Quelles tables sont concernées, et quelles opérations doivent être checkées ?

    Tables concernées :
        - reservations :
            - INSERT : OUI. Si on crée directement une réservation avec le statut 'confirmed' ou 'completed'.
            - UPDATE : OUI. Si on change le statut d'une réservation vers 'confirmed' ou 'completed', ou si on change sa date/heure (ce qui pourrait la faire tomber sur un service déjà complet).
            - DELETE : NON. Supprimer une réservation libère de la place, ça ne crée pas de doublon.

        - reservation_tables (Table de liaison) :
            - INSERT : OUI. Quand on assigne une table à une réservation qui est confirmée.
            - UPDATE : NON. Les clés primaires ne peuvent pas être modifiées.
            - DELETE : NON. Retirer une table libère de la place.

        - services :
            - INSERT : NON. Un nouveau service n'a pâs encore de réservations.
            - UPDATE : OUI. Modifier start_time ou end_time pourrait étendre le service et y inclure deux réservations existantes pour la même table ce jour-là, créant un doublon.
            - DELETE : NON.
*/

create or replace function br_06_double_booking_fct() returns trigger as
        $$
        begin
            -- S'il existe deux réservations différentes (r1 et r2) sur la même table, le même jour,
            -- dans le même service et qui sont confirmées/terminées... on bloque !
            if exists (
                select 1
                from reservation_tables rt1
                join reservations r1 on r1.id = rt1.reservation
                join reservation_tables rt2 on rt1."table" = rt2."table" and rt1.reservation < rt2.reservation
                join reservations r2 on r2.id = rt2.reservation
                join services s on s.restaurant = r1.restaurant
                    and extract(isodow from r1.datetime) = s.day_of_week -- (extract isodow tranforme la date en jour de la semaine)
                where r1.status in ('confirmed', 'completed')
                  and r2.status in ('confirmed', 'completed')
                  and r1.datetime::date = r2.datetime::date
                  -- Les deux tombent dans les heures du même service
                  and r1.datetime::time between s.start_time and s.end_time
                  and r2.datetime::time between s.start_time and s.end_time
            ) then
                raise exception 'BR-06: Une table est déjà réservée pour cette date et ce service.';
            end if;

        return null; -- trigger AFTER peut renvoyer null
        end;
        $$ language plpgsql;


create or replace trigger br_06_reservations
    after insert or update of datetime, status on reservations
    for each row execute function br_06_double_booking_fct();

create or replace trigger br_06_services
    after update of start_time, end_time on services
    for each row execute function br_06_double_booking_fct();

create constraint trigger br_06_reservation_tables
    after insert on reservation_tables
    deferrable initially deferred
    for each row execute function br_06_double_booking_fct();