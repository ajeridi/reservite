set search_path to public;

--cas valide review

begin;
do
$test$
    begin
        raise notice 'TEST BR-15: Succès - Création valide review';

        insert into reviews(client, restaurant, reservation, rating)
        values (4,2,5,4);

    end;
$test$;
rollback;


/*insert into reviews(client, restaurant, reservation, rating)
values (4,2,5,4);

delete from reviews where id = 15;*/




