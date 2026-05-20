set search_path to public;

/*
(BR-12) Une réservation en attente ou annulée ne peut être associée à aucune une table.

Tables et operations concernees :
    - Reservations :    - INSERT : non, car la creation d'une reservation se fait avant l'association avec une table
                        - UPDATE : oui, car on peut annuler une reservation confirmee (associee a une table)
                        - DELETE : non, car supprimer une reservation supprime les associations

    - Reservation_Tables :  - INSERT : oui, car on peut creer une association entre une reservation pending/cancelled et un table
                            - UPDATE : oui, car on peut changer la reservation correcte vers une reservation pending/cancelled
                            - DELETE : non, suppression d'association

    On regarde pour toutes les reservations dans reservations_table, s'il existe une ou son status est soit pending, soit cancelled, si c'est le cas
    raise exception

    On doit faire le trigger en deferred, comme ca quand on doit associer une table puis la mettre en confirmed, le trigger se declenche une fois ces deux actions terminees
*/

create or replace function no_reservation_pending_cancelled_in_reservation_tables_fct()
returns trigger as
    $$
    begin
        -- s'il existe une reservation avec le status pending ou cancelled, associee a une table, declencher exception
        if exists(
            SELECT res.id, res.status
            from reservations res join reservation_tables rt on rt.reservation = res.id
            where res.status in ('pending'::status_type, 'cancelled'::status_type)
        ) then
            raise exception 'A pending or cancelled reservation is associated to a table';
        end if;
        return null;
    end;
    $$ language plpgsql security definer;

create or replace trigger trigger_check_reservation_table_after_cancellation
    after update of status
    on reservations
    for each row
    execute function no_reservation_pending_cancelled_in_reservation_tables_fct();

create constraint trigger trigger_no_reservation_pend_canc_in_reservation_tables
    after insert or update of reservation
    on reservation_tables
    deferrable initially deferred
    for each row
    execute function no_reservation_pending_cancelled_in_reservation_tables_fct();




/*-- liste des reservations associees groupee par id et status
select res.id, res.status
from reservations res   join reservation_tables rt on rt.reservation = res.id
where res.status = 'confirmed' or res.status = 'completed'
group by res.id, res.status;*/

/*
-- update invalide, on change le status a cancelled a une reservation associee
update reservations set status = 'cancelled' where id = 1;

-- creation reservation pour 3 personnes au restaurant 4 le 06 dec 2024 (Vddi) a 18h
insert into reservations (id, client, restaurant, datetime, number_of_guests) VALUES (900, 3, 4, '2024-12-06 18:00:00', 2);
-- association de la reservation a la table 9, donc refus normalement car reservation pending
insert into reservation_tables(reservation, "table") VALUES (900, 9);
update reservations set status = 'confirmed' where id = 900;
*/