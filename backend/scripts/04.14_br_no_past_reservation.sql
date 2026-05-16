/*
(BR-14) Une réservation ne peut pas être créée dans le passé (ne doit être vérifié qu'au moment de la création).

Analyse :
    Quelles tables sont concernées, et quelles opérations doivent être checkées ?

    - reservations :
        - INSERT : OUI. La règle stipule expressément que cela doit être vérifié à la création.
        - UPDATE : NON. La règle dit "ne doit être vérifié qu'au moment de la création". Donc on ne vérifie pas lors d'une modification.
        - DELETE : NON.

    - system_time :
        - INSERT / UPDATE : NON. Les consignes précisent que "Le changement de temps simulé n'a pas d'effet sur le statut des réservations existantes".
*/

create or replace function br_14_no_past_reservation_fct() returns trigger as
        $$
        declare
            v_current_time timestamp;
        begin
            -- récupère le temps simulé. s'il n'existe pas (null) -> on prend le temps réel (c'est à ca que ca sert coalesce)
            v_current_time := coalesce((select simulated_time from system_time limit 1), current_timestamp);

            -- si la date de la nouvelle réservation est plus bas que le temps simulé/réel
            if NEW.datetime < v_current_time then
                raise exception 'BR-14: Une réservation ne peut pas être créée dans le passé.';
            end if;

            return NEW;
        end;
        $$ language plpgsql security definer;


create or replace trigger br_14_reservations
    before insert on reservations
    for each row execute function br_14_no_past_reservation_fct();