set search_path to public;

/*

Tests :
    Table Service :
        - insertion start end time valide
        - insertion start end time non valide
        - update start end time non valide

    Table Restaurants :
        - update slot duration qui entre en conflit avec un service (donc mettre un slot duration de 10 pour un creneau fait pour 15)
*/

-- test table service
begin;
do
$test$
    begin
        raise notice 'Test BR_08 : Table service';
        -- insertion valide
        insert into services (restaurant, day_of_week, start_time, end_time) VALUES (1, 7, '15:15:00', '16:45:00'); -- restaurant 1 a un slot de 30
        -- insertion non valide
        perform should_fail($$
            insert into services (restaurant, day_of_week, start_time, end_time) VALUES (1, 7, '15:15:00', '16:20:00');
            $$, 'raise_exception');
        -- update non valide, restaurant 4 a un slot de 15, ajouter 10 au service du end_time du service 31
        perform should_fail($$
            update services set end_time = end_time + '00:10:00' where id = 31;
            $$, 'raise_exception');
    end
$test$;
rollback;


-- test table restaurant
begin;
do
$test$
    begin
        raise notice 'Test BR_08 : Table restaurants';
        -- update pour changer le end time d'un service pour simuler le cas suivant (augmentation du end_time de 15 min, pour declencher une exception quand on change le slot duration de 15 a 10
        update services set end_time = end_time + '00:15:00' where id = 31;
        -- update non valide d'un slot duration
        perform should_fail($$
            update restaurants set slot_duration = 10 where id = 4;
        $$, 'raise_exception');
    end
$test$;
rollback;
