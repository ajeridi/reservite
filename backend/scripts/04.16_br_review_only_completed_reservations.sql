/*
BR 16 :  On ne peut creer une review concernant une reservation non terminee

Analyse : Tables concernees et operations

    - reservations :    - insert : non, une reservation est cree avant un review
                        - update : non, une fois que c'est completed c'est impossible de changer le status d'une reservation
                        - delete : delete cascade

    - reviews :         - insert : oui, car il faut verifier si la reservation est completed avant insertion
                        - update : non, car on ne peut pas changer la reservation d'un review
                        - delete : non, aucun impact
*/

create or replace function check_status_of_reviewed_reservation_fct() returns trigger as
$$
begin
    if ((select rsv.status from reservations rsv where rsv.id = new.reservation) <> 'completed') then
        raise exception 'Reservation must be completed before reviewing it';
    end if;
    return new;
end;
$$ language plpgsql security definer;

create or replace trigger reservation_status_of_reviewed_reservation
    before insert
    on reviews
    for each row
    execute function check_status_of_reviewed_reservation_fct();



/*select rv.*, res.status
from reviews rv join reservations res on rv.reservation = res.id
*/


/*-- tests
delete from reviews where id = 6;
delete from reviews where id = 5;
insert into reviews(client, restaurant, reservation, rating) values (6, 3, 12, 3);
insert into reviews(client, restaurant, reservation, rating) values (4, 2, 11, 3);


select * from reservations where status = 'completed';

select * from reviews;*/