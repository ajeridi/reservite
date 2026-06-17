-- (BR-15) Un restaurant ne peut pas avoir plus de 3 réservations VIP actives.
-- Sont considérées comme actives les réservations dont le statut est pending ou confirmed et dont la date/heure est dans le futur.

/*
Analyse:

Reservations :  INSERT : non, car quand on insère une réservation, le vip est false par défaut.
                UPDATE : oui, si on change la colonne is_vip en true alors qu'on a déjà 3 réservations vips. Ou si on update cancelled à pending. Ou si datetime dans le passée.
                DELETE : non
*/

create or replace function check_reservation_vip_fct()
    returns trigger as
$$
declare
    v_current_time timestamp;
begin

    -- récupère le temps simulé. s'il n'existe pas (null) -> on prend le temps réel (c'est à ca que ca sert coalesce)
    v_current_time := coalesce((select simulated_time from system_time limit 1), current_timestamp);

    if exists(
        -- s'il existe, pour un restaurant, plus de 3 réservations VIP actives => raise exception
        select res.id
        from restaurants res, reservations rsv
        where res.id = rsv.restaurant -- liaison de l'id restaurant avec les réservations
        AND (rsv.status = 'pending' OR rsv.status = 'confirmed') -- si reservation active (pending ou confirmed)
        AND rsv.datetime > v_current_time -- ET que la réservation est dans le futur
        AND is_vip = true -- VIP true
        group by res.id -- on groupe par restaurants
        having count(*) > 3 -- tel que le groupe contient plus de 3 entrées
    ) then
        raise exception 'Un restaurant ne peut pas avoir plus de 3 réservations VIP actives.';
    end if;
    return null;
end;
$$ language plpgsql security definer;


create or replace trigger trigger_reservation_vip
    after update
    on reservations
    for each row
execute function check_reservation_vip_fct();