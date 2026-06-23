set search_path to public;
/*
(BR-15) Un restaurant ne peut pas avoir plus de 3 réservations VIP actives.

Sont considérées comme actives les réservations dont le statut est pending ou confirmed et dont la date/heure est dans le futur.


Table et operations concernees :
    - Reservation : - INSERT : non, inserer une réservation donne vip false par défaut.
                    - Update : oui, on doit déclencher le trigger quand on essaye de update vip à true (si 3 vips existe déjà)
                    - Delete : non
*/


create or replace function check_vip_fct()
    returns trigger as
$$
declare
    v_current_time timestamp;
begin
    -- récupère le temps simulé. s'il n'existe pas (null) -> on prend le temps réel (c'est à ca que ca sert coalesce)
    v_current_time := coalesce((select simulated_time from system_time limit 1), current_timestamp);

    if exists(
        -- s'il existe, pour un restaurant, plus de 3 reservations vips, raise exception
        select r.id
        from restaurants r, reservations res
        where res.restaurant = r.id
        AND (res.status = 'pending' OR res.status = 'confirmed')
        AND res.datetime > v_current_time
        AND res.is_vip = true
        group by r.id -- on groupe par restaurant
        having count(*) >= 3 -- tel que le groupe contient plus de 3 entrees
    ) then
        raise exception 'Erreur : Un restaurant ne peut pas avoir plus de 3 réservations VIP actives. ';
    end if;
    return null;
end;
$$ language plpgsql security definer;


create or replace trigger trigger_check_vip
    after update
    on reservations
    for each row
execute function check_vip_fct();