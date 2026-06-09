set search_path to public;


-- test1 : cas valide creation d'un review
begin;
do $test$
    begin
        raise notice 'TEST 1 : BR-15: Succès - Création d''un review';
        insert into reviews (client, restaurant, reservation, rating)
        values (4, 2, 5, 4);
    end;
$test$;
rollback;

-- test2 : cas invalide, client non appartenant a la reservation
begin;
do $test$
    begin
        raise notice 'TEST 2: BR-15: Echec - Création d''un review avec un client non associe a la reservation';
        perform should_fail($$
                insert into reviews (client, restaurant, reservation, rating) values (3, 2, 5, 4);
            $$, 'raise_exception');
    end;
$test$;
rollback;

-- test3 : cas invalide, restaurant non appartenant a la reservation
begin;
do $test$
    begin
        raise notice 'TEST 3: BR-15: Echec - Création d''un review avec un restaurant non associe a la reservation';
        perform should_fail($$
                insert into reviews (client, restaurant, reservation, rating) values (4, 3, 5, 4);
            $$, 'raise_exception');
    end;
$test$;
rollback;
