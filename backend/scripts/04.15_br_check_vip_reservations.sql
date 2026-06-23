set search_path to public;

/*
(BR-15) Un restaurant ne peut pas avoir plus de 3 réservations VIP actives.

Sont considérées comme actives les réservations dont le statut est pending
ou confirmed et dont la date/heure est dans le futur.

Analyse : max 3 vip par resto, reservation pending ou confirmed, date/heure > simulatedTime
reservations -insert : oui, car on peut ajouter une reservation directement dans la DB, comme Admin
            -update : oui , c'est a ce moment que le manager peut ajouter ou enlever l'option VIP
            -delete : non , pas d'impact
*/
create or replace function check_vip_reservations_fct()
returns trigger as
    $$
        declare
            v_current_time timestamp;
            resto_id int;
        begin
            -- récupère le temps simulé. s'il n'existe pas (null) -> on prend le temps réel (c'est à ca que ca sert coalesce)
            v_current_time := coalesce((select simulated_time from system_time limit 1), current_timestamp);
            if(tg_table_name = 'reservations') then
                resto_id = new.restaurant;
            end if;

            if((SELECT count(*) from reservations r where r.restaurant=resto_id
                                                   and r.datetime > v_current_time
                                                      and (r.status ='pending' or r.status = 'confirmed')
                                                    and r.is_vip is true) > 3)then
                raise exception 'Le restaurant ne peut pas avoir plus de 3 VIP ';
            end if;
        return new;
        end;

    $$language plpgsql security definer;

create trigger check_vip_reservations_admin
    after insert on reservations
    for each row
    execute function check_vip_reservations_fct();

create trigger check_vip_reservations_managers
    after update on reservations
    for each row
execute function check_vip_reservations_fct();

/*SELECT count(*) from reservations r where r.restaurant=2
                                      and r.datetime > '2024-11-15 19:00:00.000000'
                                      and r.is_vip is false;*/
