set search_path to public;
-- test valides
begin;
do
$test$
    begin
        raise notice 'Test1 BR_10 : ajout manager à un resto';
        insert into restaurant_managers(restaurant, manager) VALUES (1,5);-- OK

        raise notice 'test2 BR_10 : Succès : Suppression d''un manager quand il y a au moins 2';
        delete from restaurant_managers
        where restaurant = 1 and manager = 5;

        raise notice 'Test3 BR_10 : Insert nouveau Restaurant ensuite ajout manager';
        insert into restaurants( id,name, address, city, phone) values (99,'Testtest', 'Test123' , 'Test' ,'+32 1 234 56 89');
        insert into restaurant_managers (restaurant, manager) VALUES (99,2);
    end
$test$;
rollback;
--Tests invalides
begin;
do
$test$
    begin
        raise notice 'Test3 BR_10 : Insert Restaurant sans manager';
        perform should_fail($$
            delete from restaurant_managers
            where restaurant = 3;
        $$, 'raise_exception');

        raise notice 'Test4 BR_10 : update nom Restaurant ';
        perform should_fail($$
            update restaurant_managers set restaurant = 7 where restaurant = 3;
        $$, 'raise_exception');

        raise notice 'Test4 BR_10 : update nom Restaurant ';
        perform should_fail($$
            insert into restaurants(name, address, city, phone) values ('Testtest', 'Test123' , 'Test' ,'+32 1 234 56 89');
        $$, 'raise_exception');

    end;
$test$;
rollback;

