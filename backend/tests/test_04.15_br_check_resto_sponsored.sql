set search_path to public;


-- test1 : cas valide (création d'un restaurant avec is_sponsored true)

begin;
do $test$
    begin
        raise notice 'TEST BR-15: Succès - d''un restaurant avec is_sponsored true';



        -- un admin ajoute un resto sposored true
        insert into restaurants(id,name, address, city, phone, description, rating, price_range,slot_duration,is_sponsored)
        values (20,'La fricadelle' ,'Rue de la bouffe','Bruxelles', '+32 3 456 78 90','La bonne bouffe 100% halal',3,3,30,true);
        insert into restaurant_managers (restaurant, manager) values (20,2);
    end;
$test$;
rollback;



insert into restaurants(id,name, address, city, phone, description, rating, price_range,slot_duration,is_sponsored)
values (20,'La fricadelle' ,'Rue de la bouffe','Bruxelles', '+32 3 456 78 90','La bonne bouffe 100% halal',3,3,30,true);
insert into restaurant_managers (restaurant, manager) values (20,2);