set search_path to public ;

/*(BR-02) Le nombre de convives d'une réservation confirmée ou terminée ne peut pas dépasser la
  capacité totale des tables associées à la réservation. Ceci implique qu'une réservation
  confirmée ou terminée doit avoir au moins une table réservée appartenant au restaurant
  de la réservation.*/

/*Analyse
reservation -INSERT : OUI , si le status est confirmed ou completed
            -UPDATE : OUI , pour status ou number_of_guests
            -DELETE : NON , car on supprime les tables associées en cascade
reservation_table -INSERT : non , car on augmente la capacité
                    -UPDATE : non
                    -DELETE : OUI, car on ne peut pas delete status completed ou terminated
table -INSERT : NON , ça augmente la capacité
        -UPDATE : OUI , en cas de diminution de la capacity d'une table
        -DELETE : OUI , ça diminue la capacity
*/

select r.id, r.number_of_guests, coalesce(sum(t.capacity), 0)
from reservations r
    left join reservation_tables rt on rt.reservation = r.id
    left join tables t on t.id = rt."table"
where r.status in ('confirmed'::status_type, 'completed'::status_type)
group by r.id, r.number_of_guests
having r.number_of_guests > coalesce(sum(t.capacity), 0);


create or replace function nb_convives_reservation_fct() returns trigger as
       $$
            begin
                  if exists(select r.id, r.number_of_guests, coalesce(sum(t.capacity),0)
                            from reservations r
                                left join reservation_tables rt on r.id = rt.reservation
                                left join tables t on rt."table" = t.id
                            where r.status in ('confirmed'::status_type, 'completed'::status_type)
                            group by r.id , r.number_of_guests
                            having r.number_of_guests> coalesce(sum(t.capacity),0))then
                      raise exception 'Le nombre de convivies dépasse la capacité totale';
                  end if;
                  return null;
            end;
       $$language plpgsql security definer ;


create or replace trigger nb_convives_reservation_reservation
    after insert or update
    on reservations
    for each row
    execute function nb_convives_reservation_fct();

-- update reservations set number_of_guests = 10 where id =1;

create constraint trigger nb_convives_reservation_reserv_tables
    after delete
    on reservation_tables
    deferrable initially deferred
    for each row
    execute function nb_convives_reservation_fct();

-- delete from reservation_tables where reservation_tables.id=1;

create or replace trigger nb_convivies_reservation_validate_table_capacity
    after update of capacity or delete
    on tables
    for each row
    execute function nb_convives_reservation_fct();





