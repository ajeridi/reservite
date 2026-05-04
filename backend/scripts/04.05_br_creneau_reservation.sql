set search_path  to public;
/*
 reservation : INSERT : OUI
                UPDATE: OUI
                DELETE: NON
slot_duration
convertir heure reserv en minutes
l'heure reserv en min depuis 00h % (Modulo) durré creneau == 0 OK

 dans notre cas: MOD(heures * 60 + minutes, slot_duration) !!!
 */


-- select extract(minutes from datetime )
-- from reservations
-- where id =3;
-- select extract(hour from datetime )
-- from reservations
-- where id =3;

-- select * from reservations r
--                   join public.restaurants r2 on r.restaurant = r2.id
--                     where MOD(extract(hour from datetime)* 60 + extract(minutes from datetime),r2.slot_duration) = 0;

create or replace function verif_time_reserv_fct() returns trigger as
    $$
        begin
            if exists(select * from reservations r
                               join public.restaurants r2 on r.restaurant = r2.id
                               where MOD(extract(hour from datetime)* 60 + extract(minutes from datetime),r2.slot_duration) <> 0) then
                raise exception 'Reservation Hour does not respect de restaurant slot_duration';
            end if;
            return null;
        end;
    $$language plpgsql security definer ;

create or replace trigger verif_time_reseration
    after insert or update of datetime
    on reservations
    for each row
    execute function verif_time_reserv_fct();

-- insert into reservations(client, restaurant, datetime, number_of_guests,special_requests)
-- VALUES(3,1,'2024-11-15 19:05:00.000000',2,'balablabla');
