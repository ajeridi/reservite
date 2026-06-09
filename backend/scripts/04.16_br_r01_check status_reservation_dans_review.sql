/* une Review ne peut pas être associé qu'à une reservation ayant le status completed
   Analyse:
   -verifier que pour chaque review, la reservation a laquelle est liée a le status completed, sinon raise exception

   reservation: insert : non, car reservation crée avant review
                update: non, car le statut completed ne peut pas etre changé
                delete: non , suppression en cascade

   review insert: oui , verfier que la reservation est completed
            update: non, on ne peut pas changer la reservation d'un review
            delete: non
   */

   create or replace function  check_status_reviewed_reservation_fct() returns trigger as
       $$
            begin
                if((select r.status from reservations r where r.id = new.reservation) <> 'completed')then
                    raise exception 'Reservation must be completed before reviewing';
                end if;
                return new;
            end;
       $$language plpgsql security definer ;


create or replace  trigger check_status_reviewed_reservation
    before insert
    on reviews
    for each row
    execute function check_status_reviewed_reservation_fct();


