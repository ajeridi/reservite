set search_path to public;

--(BR-10) Un restaurant doit avoir au moins un manager.

/*
Analyse:
Restaurant : INSERT : oui , on doit verifier qu'il a au moins un manager
            UPDATE : non
            DELETE : non

Table_managers : INSERT : non
                UPDATE : oui , on doit verifier que si on modifie la colonne 'restaurant',
            on doit tjr avoir au moins un manager par resto
                DELETE : oui , verifier qu'il y a toujours un manager par resto
*/

select 1 from restaurant_managers
    join public.restaurants r on r.id = restaurant_managers.restaurant
    where r.id = 9;

create or replace function check_nb_managers_fct() returns trigger as
$$
    declare
        resto_id int;
        manager_count int;
    begin
        if tg_table_name = 'restaurants' then
            resto_id := new.id;
        elseif tg_op = 'DELETE' then
            resto_id := old.restaurant;
        elseif tg_op = 'UPDATE' then
            resto_id := old.restaurant;
        end if;
        --verif que resto existe encore
        if not exists(select 1 from restaurants where id = resto_id) then
            return null;
        end if;

        select count(*) into manager_count
        from restaurant_managers
        where restaurant = resto_id;

        if manager_count < 1 then
            raise exception 'Le restaurant % doit avoir au moins un manager', resto_id;
        end if;

        return null;
    end ;
$$language plpgsql security definer ;

create constraint trigger check_nb_managers_on_resto
    after insert on restaurants
    deferrable initially deferred
    for each row
    execute function check_nb_managers_fct();

create trigger check_nb_managers_on_resto_managers
    after delete or update of restaurant
    on restaurant_managers
    for each row
    execute function check_nb_managers_fct();