set search_path to public;

--(BR-15) Une ville ne peut pas compter plus de 3 restaurants sponsorisés.

/*
Analise restaurant insert : oui , un admin peut ajouter un nouveau resto is_sponsored a true
                    update : oui , un manager peut update la table is_sponsored
                    delete : non , pas d'impact
*/
create or replace function check_resto_sponsored_fct()  returns trigger as
    $$
    declare city_name text;
        begin
            if(tg_table_name = 'restaurants')then
                city_name = new.city;
            end if;
            if ((select count(*) from restaurants where city = city_name
                                                        and is_sponsored is true) > 3)then
                raise exception 'Une ville ne peut pas compter plus de 3 restaurants sponsorisés';
            end if;
            return new;
        end;
    $$language plpgsql security definer ;

create or replace trigger check_resto_sponsored
after insert or update
    on restaurants
    for each row
    execute function check_resto_sponsored_fct();
