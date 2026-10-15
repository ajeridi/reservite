set search_path to public;

-- On teste ici la règle métier "l'email d'un user doit être unique".
-- On passe 'unique_violation' à should_fail pour indiquer que l'on
-- s'attend précisément à cette erreur de contrainte UNIQUE, et que
-- toute autre erreur (ou aucune erreur) doit faire échouer le test.
begin;
do
$test$
    begin
        raise notice 'TEST: email du user est unique';
        perform should_fail($$
            update users set email = 'bepenelle@reservite.com' where id = 1;
        $$, 'unique_violation');
    end
$test$;
rollback;

begin;
do
$test$
    begin
        raise notice 'TEST: update de cle composee de la table restaurant managers';
        insert into restaurants(id, name, address, city, phone, rating, price_range)
        values (400,'Abcde','test123','city','+32 1 234 56 89',0.1,1);

        insert into restaurant_managers (restaurant, manager) VALUES (400,1);
        insert into restaurant_managers (restaurant, manager) VALUES (400,2);


        perform should_fail($$
        update restaurant_managers set manager = 5 where restaurant = 400 and manager =1 ;
        $$, 'raise_exception');
    end
$test$;
rollback;


