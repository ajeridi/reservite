/*
(BR-13) Un client ne peut pas avoir deux réservations en attente, confirmées ou terminées pour une même date et un même service.


Table et operations concernees :
    - Reservation : - INSERT : oui, car on peut inserer une reservation le meme jour au meme service qu'une autre
                    - Update : oui, car on peut modifier la date et le status
                    - Delete : non
    - Service : - INSERT : non,  car un service se cree avant une reservation
                - UPDATE : oui, car on peut changer start/end et ca peut englober plusieurs reservations
                - DELETE : non.

Query qui va chercher afficher pour chaque client toutes les reservations du client, groupee par jour et par service

D'abord chercher les clients et leur reservations, puis pour chaque reservation les services dans lesquels ils sont (donc meme dow et time entre start et end)
et ensuite grouper les lignes qui ont le meme client, la meme date de reservation et le meme service et ne retenir que les groupe qui contiennent
plus de 1 ligne
*/


create or replace function check_reservation_count_per_user_day_and_service_fct()
returns trigger as
    $$
    begin
        if exists(
            -- s'il existe, pour un meme user, une meme date et un meme service, plus d'une reservation, raise exception
            select u.id,rsv.datetime::date, s.id
            from users u
                     join reservations rsv on rsv.client = u.id
                     join restaurants rst on rsv.restaurant = rst.id
                     join services s on rst.id = s.restaurant
            where extract(isodow from rsv.datetime) = s.day_of_week -- meme dow que service
                and rsv.datetime::time between s.start_time and s.end_time -- time entre start et end
                and rsv.status in ('pending'::status_type, 'confirmed'::status_type, 'completed'::status_type) -- statut de reservation en attente, confirmee ou completed
            group by u.id, rsv.datetime::date, s.id -- on groupe par client, date de reservation et service
            having count(*) > 1 -- tel que le groupe contient plus de 1 entree
        ) then
            raise exception 'A client has two reservations on the same day and on the same service';
        end if;
        return null;
    end;
    $$ language plpgsql;


create or replace trigger trigger_reservation_count_per_user_day_and_service
    after insert or update
    on reservations
    for each row
    execute function check_reservation_count_per_user_day_and_service_fct();

create or replace trigger trigger_reservation_count_per_user_day_after_update
    after update
    on services
    for each row
    execute function check_reservation_count_per_user_day_and_service_fct();
