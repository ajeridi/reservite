set search_path to public;

begin;
do
$test$
    begin
        raise notice 'TEST BR-15 non valide : update de quatres reservations d''un même restaurant, is_vip sur true';
        perform should_fail($$
                update reservations set is_vip = 'true' where id = 23;
                update reservations set is_vip = 'true' where id = 24;
                update reservations set is_vip = 'true' where id = 25;
                update reservations set is_vip = 'true' where id = 27;
            $$, 'raise_exception');
    end;
$test$;
rollback;


update reservations set is_vip = 'true' where id = 23;
update reservations set is_vip = 'true' where id = 24;
update reservations set is_vip = 'true' where id = 25;
update reservations set is_vip = 'true' where id = 27;