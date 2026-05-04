set search_path to public;

-- test 1 : cas valide (service valide)
begin;
do $test$
    begin
        raise notice 'TEST BR-07: Succès - service valide';

        insert into services(restaurant, day_of_week, start_time, end_time)
        VALUES(1,1,'15:00:00','16:00:00');
    end
$test$;
rollback;

-- test 2 : cas invalide (service invalide)
begin;
do $test$
    begin
        raise notice 'TEST BR-05: Error - Creneau invalide';
        perform should_fail($$
            insert into services(restaurant, day_of_week, start_time, end_time)
            VALUES(1,1,'13:00:00','16:00:00');
        $$,'raise_exception');
    end
$test$;
rollback;
