set search_path to public;
/*
(BR-04) L'heure d'une réservation confirmée, terminée ou en attente doit être comprise entre l'heure de début et l'heure de fin d'un service pour le même jour de la semaine..

Tables concernées : (sur quelle table et sur quelles opération dois-je declencher le trigger)
    - Reservations :    - INSERT : oui, car je peux faire une reservation dont le temps n'est pas dans un service ('pending' à la création)
                        - Update : oui, car je peux modifier le temps d'une reservation
                        - Delete : non, car supprimer une reservation induit qu'elle ne sera pas dans le service

    - Services :        - INSERT : non, car la creation d'un service se fait avant une la creation d'une reservation
                        - UPDATE  : oui, car si je modifie le start ou end time d'un service, je peux faire ressortir le temps d'une reservation du service
                            (ex : je recule le end time avant le datetime d'une reservation, c'est pas bon)
                        - DELETE : si je delete un service, il se peut qu'une reservation existe dans ce service


    si une reservation existe avec datetime inferieure à l'heure du debut du service, ou une date supérieure à l'heure de fin d'un service
        alors annuler l'opération, faire un after, on verifie apres ajout.
    Problème : probleme avec cette requete, c'est que si j'ai une reservation a 19h, bah le service de 12 à 14h, comme la reservation est apres, ça me compter faux
    il faut mieux comparer.
    Il faut que pour ma reservation, que son temps soit entre un des crénau de service
    si ma reservation est dans aucun des crenaux, c'est pas ok

    select from services, where rsv.dow = service.dow and rsv.time in between service.start et service.end -> si j'ai 0 resultat, alors c'est que ma reservation n'existe pas dans un des crenaux



    DONC POUR CONCLURE :
        SI il EXISTE UNE RESERVATION (non annulee) QUI EST PAS DANS LA LISTE DES RESERVATION QUI SE TROUVENT DANS UN SERVICE, ALORS MA RESERVATION N EST PAS DANS UN SERVICE */

create or replace function reservation_time_inside_service_fct() returns trigger as
    $$
    begin
        if exists (select reservations.id  from reservations where reservations.status <> 'cancelled' and reservations.id not in (
            select  rsv.id
            from reservations rsv
                     join restaurants rst on rst.id = rsv.restaurant
                     join services ser on ser.restaurant = rst.id
            where extract(isodow from rsv.datetime::date) = ser.day_of_week and rsv.datetime::time >= ser.start_time and rsv.datetime::time <= ser.end_time
            ))
            then
                raise exception 'A reservation exists with a date time outside of service';
        end if;
        return null;
    end;
    $$ language plpgsql security definer;


create or replace trigger trigger_reservations_time_inside_service
    after insert or update of datetime, status
    on reservations
    for each row
    execute function reservation_time_inside_service_fct();

create or replace trigger trigger_check_reservations_time_after_services_update
    after update or delete
    on services
    for each row
    execute function reservation_time_inside_service_fct();


/*
select  rsv.id
from reservations rsv
         join restaurants rst on rst.id = rsv.restaurant
         join services ser on ser.restaurant = rst.id
where extract(isodow from rsv.datetime::date) = ser.day_of_week and rsv.datetime::time >= ser.start_time and rsv.datetime::time <= ser.end_time
*/

