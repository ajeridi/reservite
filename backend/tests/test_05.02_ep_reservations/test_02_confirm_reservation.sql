set search_path to public;
select * from tables t join restaurants r on r.id = t.restaurant
                        join reservations rsv on rsv.restaurant = r.id
where rsv.status = 'pending' and rsv.number_of_guests < t.capacity;

--assigner table 5 a la reservation 2

/*
Prendre une reservation qui est pending, puis l'assigner a une table
    - trouver une reservation pending
    - trouver une table contenue dans le meme restaurant, qui n'est pas assignee et qui a une capacity >= number_of_guests

*/
-- nouvelle reservation au restaurant 1 pour le 10-12-2024 a 19h
select * from services where day_of_week = extract(dow from '2024-12-10'::date) and restaurant = 1; -- services disponibles au restaurant 1 le 10-12-2024
select * from tables where restaurant = 1 and capacity >= 2; -- tables au restaurant 1 ayant une capacite >= 2

insert into reservations(client, restaurant, datetime, number_of_guests) VALUES (3, 1, '2024-12-10 12:00:00', 2);
select * from reservations;

-- on prend la table 3, manager boverhaegen qui va assigner la reservation 23 a la table 3
select auth.login_for_test('boverhaegen@epfc.eu');
select confirm_reservation(23, ARRAY[3]);
select auth.logout_for_test();

begin;
do
$test$
    begin
        insert into reservations(client, restaurant, datetime, number_of_guests) VALUES (3, 1, '2024-12-10 12:00:00', 2);
        select auth.login_for_test('boverhaegen@epfc.eu');
        select confirm_reservation(23, ARRAY[3]);
        raise notice 'reservation confirmed';
        select auth.logout_for_test();
    end
$test$;
rollback;



