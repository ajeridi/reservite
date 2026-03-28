set search_path to public;


-- Regles invariantes de la table Reservations
-- contrainte de check sur le statut (le fait automatiquement car c'est un enum)
alter table reservations
add constraint cs_statut_reservation
CHECK (status in ('pending', 'confirmed', 'cancelled',  'completed'));

-- tests
insert into reservations (client, restaurant, datetime, number_of_guests, status)
values (2, 3, '2026-03-28', 12, 'pending');
update reservations set status = 'confirmed' where client = 2 and restaurant = 3;
update reservations set status = 'cancelled' where client = 2 and restaurant = 3;
update reservations set status = 'completed' where client = 2 and restaurant = 3;
update reservations set status = 'COMPLETED' where client = 2 and restaurant = 3;
update reservations set status = 'en cours' where client = 2 and restaurant = 3;
update reservations set status = 'pending' where client = 2 and restaurant = 3;


-- contrainte de check sur le nombre de convives
alter table reservations
add constraint cs_strictly_positive_guest_number
check ( number_of_guests > 0 );

-- tests
insert into reservations (client, restaurant, datetime, number_of_guests, status)
values (2, 4, '2026-03-28', 2 , 'pending');
update reservations set number_of_guests = 0 where client = 2 and restaurant = 4;


