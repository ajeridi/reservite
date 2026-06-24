set search_path to public;
/*
(BR-15) Une ville ne peut pas compter plus de 3 restaurants sponsorisés.


Table et operations concernees :
    - Restaurants : - INSERT : oui, car on peut inserer un restaurant avec sponsored sur true sur une ville qui en compose déjà 3 sur true.
                    - Update : oui, car on peut modifier la colonne is_sponsored sur true ou changer la ville
                    - Delete : non, si on delete ca n'aura aucun impact.
*/


create or replace function check_restaurant_sponsored_fct()
    returns trigger as
$$
begin
    if exists(
        -- s'il existe, pour une ville, plus de 3 restaurants sponsorisés, raise exception
        select res.city
        from restaurants res
        where res.is_sponsored = true
        group by res.city -- on groupe par ville
        having count(*) > 3 -- tel que le groupe contient plus de 3 entrees
    ) then
        raise exception '(BR-15) Une ville ne peut pas compter plus de 3 restaurants sponsorisés.';
    end if;
    return null;
end;
$$ language plpgsql security definer;


create or replace trigger trigger_restaurants_sponsored
    after update
    on restaurants
    for each row
execute function check_restaurant_sponsored_fct();

