set search_path to public;

/*
(BR-15) Un restaurant ne peut pas avoir plus de 3 réservations VIP actives.

Sont considérées comme actives les réservations dont le statut est pending ou confirmed et dont la date/heure est dans le futur.

Analyse: reservation insert : non, car une nouvelle reservation n'est pas VIP par default
                    update : oui , on doit verifier que le status est pending ou confirmed
                                    et la date/heure est dans le futur
                    delete : non , la suppression n'affecte pas
*/

create or replace function check_vip_reservation_fct()
returns trigger as
    $$
    declare
        v_current_time timestamp;
        resto_id int;
        begin
        -- récupère le temps simulé. s'il n'existe pas (null) -> on prend le temps réel (c'est à ca que ca sert coalesce)
        v_current_time := coalesce((select simulated_time from system_time limit 1), current_timestamp);

        if tg_table_name ='reservations' then
            resto_id = new.restaurant;
        end if;
        if ((Select count(*) from reservations
                                where (status='pending' or status='confirmed')
                                and restaurant = resto_id
                                and datetime >= v_current_time
                                and is_vip = true) > 3 ) then
            raise exception 'Un restaurant ne peut pas avoir plus de 3 réservations VIP actives.';

        end if;
        return new;

        end;
    $$language plpgsql security definer ;

create trigger check_vip_reservation
    after update
    on reservations
    for each row
    execute function check_vip_reservation_fct();

/*update reservations set is_vip = true where id = 24;
update reservations set is_vip = true where id = 25;
update reservations set is_vip = true where id = 27;
update reservations set is_vip = true where id = 23;/*