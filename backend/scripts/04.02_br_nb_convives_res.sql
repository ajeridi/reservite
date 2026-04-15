set search_path to public ;

/*(BR-02) Le nombre de convives d'une réservation confirmée ou terminée ne peut pas dépasser la
  capacité totale des tables associées à la réservation. Ceci implique qu'une réservation
  confirmée ou terminée doit avoir au moins une table réservée appartenant au restaurant
  de la réservation.*/

/*Analyse
reservation -INSERT : OUI , si le status est confirmed ou completed
            -UPDATE : OUI , pour status ou number_of_guests
            -DELETE : NON ,
reservation_table -INSERT : non ,
                    -UPDATE : non
                    -DELETE : OUI, car on ne peut pas delete status completed ou terminated
table -INSERT : NON , ça augmente la capacité
        -UPDATE : OUI , en cas de diminution de la capacity d'une table
        -DELETE : OUI , ça diminue la capacity
*/


create or replace function nb_convives_reservation_fct() returns trigger as
       $$
        declare capacity_total int;
            begin

                    select not exists(select * from reservations
                                            join public.reservation_tables rt on reservations.id = rt.reservation
                                            join public.tables t on rt.table = t.id  where number_of_guests > t.capacity);

            end;
       $$language plpgsql;

create or replace trigger nb_convives_reservation_reservation
    before insert or update
    on reservations
    for each row
    execute function nb_convives_reservation_fct();

update reservations set number_of_guests = 10 where id =1;

create or replace trigger nb_convives_reservation_reserv_tables
    before delete
    on reservation_tables
    referencing old table as old_table
    for each row
    execute function nb_convives_reservation_fct();

delete from reservation_tables where reservation_tables.id





