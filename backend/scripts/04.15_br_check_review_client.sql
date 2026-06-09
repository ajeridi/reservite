/*
il faut que le review soit publié par le client de la reservation dans le restaurant de la reservation

Analyse:
    client insert : non, client créé avant un review
            update: non, que l'id est en lien avec le review
            delete: non, delete en cascade, client supprimé,review aussi

    reviews insert : oui, verifier que le client et le restaurant sont celles de la reservation
            update : non, pas de modification de client, restaurant ou reservation
            delete : non
*/

/*create or replace function client_restaurant_of_reservation_review_fct() returns trigger as
    $$
    declare
        client_of_reservation int;
        restaurant_of_reservation int;
        begin
            (select r.client from reservations r where r.id = new.reservation) into client_of_reservation;
            (select r.restaurant from reservations r where  r.id = new.reservation) into restaurant_of_reservation;
            if(client_of_reservation != new.client Or restaurant_of_reservation != new.reservation)then
                raise exception ' client and restaurant are not linked to the reservation';
            end if;
            return new;
        end;
    $$language plpgsql security definer ;*/
create or replace function client_restaurant_of_reservation_review_fct() returns trigger as
$$

begin

    if not exists(select r.client from reservations r where r.id = new.reservation)then
        raise exception ' client  are not linked to the reservation';
    end if;
    if not exists(select r.restaurant from reservations r where  r.id = new.reservation)then
        raise exception ' restaurant are not linked to the reservation';
    end if;
    return new;
end;
$$language plpgsql security definer ;

create or replace trigger client_restaurant_of_reservation_review
    before insert on reviews
    for each row
    execute function client_restaurant_of_reservation_review_fct();