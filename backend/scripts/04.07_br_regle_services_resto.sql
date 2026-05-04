set search_path to public;
--(BR-07) Pour un même jour de la semaine, les services d'un restaurant ne peuvent pas se chevaucher.

/*
Analyse :
services : INSERT - oui, car le nouveau service peut se chevaucher avec un autre
            UPDATE - oui , car on doit verifier qu'on ne chevauche pas avec un autre service
            DELETE - non
*/


create or replace function verif_resto_service_fct() returns trigger as
$$
begin
    if exists(select * from services s
              where s.restaurant = new.restaurant
              and s.day_of_week = new.day_of_week
              and s.id is distinct from new.id
              and s.start_time < new.end_time
              and new.start_time < s.end_time)then
        raise exception 'Les services se chevauchent';
    end if;
    return null;
end;
$$language plpgsql security definer ;

create or replace trigger verif_resto_service
    before insert or update
    on services
    for each row
    execute function verif_resto_service_fct();

