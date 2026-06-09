/*
BR 15 : Il faut que le review soit publie par le client de la reservation dans le restaurant de la reservation

Analyse (tables et operations concernees) :
    - client :      - insert : non, car un client est cree avant un review
                    - update : non, car aucun lien avec review
                    - delete : non, car delete cascade
    - restaurant :  - pareil que client

    - reservation : - on ne peut pas modifier le client et le restaurant d'une reservation

    - reviews :     - insert : oui, car il faut verifier si le client et le restaurant sont celles de la reservation
                    - update : non, on ne peut pas modifier le client, le restaurant, la reservation
                    - delete : non car record plus disponible

    Trigger qui ne prends en compte qu'une seule table -> Reviews
*/

set search_path to public;

create or replace function client_restaurant_of_reservation_review_fct() returns trigger as
    $$
    declare
        client_of_reservation int ;
        restaurant_of_reservation int ;
    begin
        client_of_reservation := (select rsv.client from reservations rsv where rsv.id = new.reservation);
        restaurant_of_reservation := (select rsv.restaurant from reservations rsv where rsv.id = new.reservation);

        if (client_of_reservation != new.client OR restaurant_of_reservation != new.restaurant) then
            raise exception 'client or restaurant are not linked to the reservation';
        end if;
        return new;
    end;
    $$language plpgsql security definer;

create or replace trigger client_restaurant_of_reservation_review
    before insert
    on reviews
    for each row
    execute function client_restaurant_of_reservation_review_fct();




