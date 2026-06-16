set search_path to public;
-- test valides
begin;
do
$test$
    begin
        raise notice 'Test1 BR_15 : update reservation is_vip  ';
        update reservations set is_vip = true where id = 24;
        update reservations set is_vip = true where id = 25;
        update reservations set is_vip = true where id = 26;


    end
$test$;
rollback;

--Tests invalides
begin;
do
$test$
    begin
        raise notice 'Test3 BR_15 : Update is_vip = true d''une 4eme reservation du même resto' ;
        perform should_fail($$
            update reservations set is_vip=true where id=23;
        $$, 'raise_exception');

    end;
$test$;
rollback;