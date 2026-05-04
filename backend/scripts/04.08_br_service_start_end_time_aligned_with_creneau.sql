set search_path to public;
/*
(BR-08) Au moment de leur création ou de leur modification, les heures de début et de fin d'un service doivent être alignées sur les créneaux de réservation pour le restaurant.


Tables et operations concernees :
    - Services : - INSERT  : oui, car le start/end time doit respecter le creneau
                - UPDATE : oui, start/end time doit respecter le crenau
                - DELETE : non, suppression du service


    - Restaurant :  - INSERT : non, car un restaurant se cree avant un service
                    - UPDATE : oui, si on modifie un slot duration qui ne serait plus compatible avec les services
                    - DELETE : non, car on delete cascade

    Les creneaux sont soit 10, 15, 20, 30 ou 60 min. Donc il faut que entre start et end, que la difference de temps soit un multiple du creneau

    Si je commence un service commence a 12:15 et je le termine a 12:20 ce n'est pas bon car la difference est de 5min et 5min n'est pas un creneau valide
    Si je commence un service commence a 12:15 et se termine a 13:10, la difference est de 13*60 + 10 - 12*60 + 15 = 790 - 735 = 55
        je dois faire un 55 modulo [creneau restaurant] (10 ou 15 ou 20 ou 30 ou 60) , si res != 0 c'est pas aligned
            ex : 55 % 10 = 5 (reste 5, division non entiere)

    Il faut juste faire la difference entre start et end et regarder si le modulo (end - start) % creneau retourne 0

    Declencher les trigger apres ou avant ?
        - avant : complique si on fait un update du creneau de restaurants,
        - after : apres operation, verifier si il existe au moins un service dont (end-start) % 0 != 0, si c'est le cas, declencher exception
    --> DECLENCHER AFTER !
*/


create or replace function services_times_aligned_with_creneau_fct()
returns trigger as
    $$
    begin
        /*
         S'il existe un service tel que son intervalle de temps (end - start) n'est pas un multiple du creneau -> exception
        */
        if exists(
            select s.id
            from services s join restaurants r on s.restaurant = r.id
            where  MOD(extract(EPOCH from (s.end_time - s.start_time))/60::int, slot_duration) <> 0 -- EPOCH renvoie les secondes, puis /60 pour avoir en minutes et ::int pour convertir en int
        ) then
            raise exception 'A service exists with start/end time not aligned with slot duration';
        end if;
        return null;
    end;
    $$language plpgsql;

create or replace trigger trigger_start_end_time_aligned_slot_duration
    after insert or update of start_time, end_time
    on services
    for each row
    execute function services_times_aligned_with_creneau_fct();

create or replace trigger trigger_check_services_start_end_time_aligned_slot_duration
    after update of slot_duration
    on restaurants
    for each row
    execute function services_times_aligned_with_creneau_fct();


/*
-- Retourne les start et end time des services ainsi que leur alignement avec le creaneau du restaurant
select s.id as service_id, s.start_time, s.end_time, MOD(extract(minute from (s.end_time - s.start_time)), slot_duration) as Aligned, r.id as restaurant_id
from services s join restaurants r on s.restaurant = r.id;

insert into services (restaurant, day_of_week, start_time, end_time) VALUES (1, 7, '15:15:00', '16:20:00');
 */