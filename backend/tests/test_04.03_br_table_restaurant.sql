set search_path to public;

-- test 1 : cas valide (table et réservation ont le même restaurant)
begin;
do $test$
    begin
        raise notice 'TEST BR-03: Succès - Même restaurant';

        insert into reservation_tables (reservation, "table") values (1,3);
    end
$test$;
rollback;

-- test 2 : cas invalide (table et réservation n'ont pas le même restaurant)
begin;
do $test$
    begin
        raise notice 'TEST BR-03: Echec - Restaurants différents';

        perform should_fail($$
            insert into reservation_tables (reservation, "table") values (1, 4);
            $$);
    end;
$test$;
rollback;