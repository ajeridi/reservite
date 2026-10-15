/*
(BR-11) Une réservation terminée ou annulée ne peut pas être modifiée.

Analyse :
    Quelles tables sont concernées, et quelles opérations doivent être checkées ?

    - reservations :
        - INSERT : NON. Ca concerne la création d'une nouvelle réservation (qui doit être 'pending' selon la BR-09).
        - UPDATE : OUI. Si l'état AVANT modification de la réservation était 'completed' ou 'cancelled' -> obligé de bloquer.
        - DELETE : NON. La règle parle uniquement de modification.
*/

create or replace function br_11_no_update_completed_cancelled_fct() returns trigger as
        $$
        begin
            -- avant que le manager ou le client n'essaie de la modifier. (si c'est complete ou cancel)
            if OLD.status in ('completed', 'cancelled') then
                raise exception 'BR-11: Une réservation terminée ou annulée ne peut pas être modifiée.';
            end if;

            -- si on arrive ici, c'est que le statut OLD était 'pending' ou 'confirmed'
            -- on laisse l'update s'exécuter en donnant la nouvelle ligne NEW
            return NEW;
        end;
        $$ language plpgsql security definer;


create or replace trigger br_11_reservations
    before update on reservations
    for each row execute function br_11_no_update_completed_cancelled_fct();