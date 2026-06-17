-- query pour supprimer les tables du resetaurant 1 (pour afficher le message invitant a ajouter une nouvelle table)
delete from reservations where restaurant = 1;
delete from reservation_tables rt where "table" in (select t.id from tables t where t.restaurant = 1);
delete from tables where restaurant = 1;
