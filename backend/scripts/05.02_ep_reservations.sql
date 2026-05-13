set search_path to public, auth;

create or replace function get_reservation(reservation_id int) returns json as
$$
select json_build_object(
       'id', reservations.id,
       'client', reservations.client,
       'datetieme', reservations.datetime,
       'number_of_guests', reservations.number_of_guests,
       'status', reservations.status,
       'sepcial_requests', reservations.special_requests
       )
from reservations
where reservations.id = reservation_id;
 $$ language sql security definer;

grant execute on function get_reservation(int) to client, manager;





