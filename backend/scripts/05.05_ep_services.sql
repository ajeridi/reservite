set search_path to public, auth;


/*
    fonction qui va retourner si oui ou non des reservations utilisent le service entre en parametre
*/
create or replace function is_service_used(service_id int) returns bool as
    $$
    declare
        -- on declare une variable service qui sera la ligne de la query qui retourne un service avec id = service_id
        service services%ROWTYPE; -- https://www.postgresql.org/docs/current/plpgsql-declarations.html#PLPGSQL-DECLARATION-ROWTYPES (section 41.3.4) pour voir comment on cree une variable de type ROW
    begin
        select * into service from services where id = service_id;

        -- on va regarder s'il existe des reservations non annulee au sein de ce service
        return exists (select * from reservations
                        WHERE restaurant = service.restaurant
                        AND extract(isodow from datetime::date) = service.day_of_week
                        AND datetime::time between service.start_time AND service.end_time
                        AND status <> 'cancelled');
    end;
    $$ language plpgsql security definer;

/*
ENDPOINT QUI VA RETOURNER UNE LISTE DE SERVICES
 on retourne une liste d'objets services donc json_agg(json_build_object)
*/

create or replace function get_services(restaurant_id int default NULL) returns json as
$$
declare user_id int := auth.id();
    declare user_role role_type := auth.role();
begin
    -- verification si le user est logged
    perform auth.check_logged();
    if (user_role = 'manager'::role_type) then
        -- on verifie si le manager travaille dans ce restaurant
        perform check_manager_works_in_restaurant(user_id, restaurant_id);
        return (select json_agg(
                               json_build_object(
                                       'id', srv.id,
                                       'restaurant', srv.restaurant,
                                       'day_of_week', srv.day_of_week,
                                       'start_time', srv.start_time,
                                       'end_time', srv.end_time,
                                        'is_used', is_service_used(srv.id)
                               ) ORDER BY day_of_week ASC
                       )
                from services srv
                where srv.restaurant = restaurant_id);
    end if;

end;
$$ language plpgsql security definer;

-- droit d'execution managers
grant execute on function get_services(int) to manager;



create or replace function get_service(service_id int, restaurant_id int) returns json as
$$
begin
    -- verification si utilisateur connecte
    perform auth.check_logged();

    -- si user est un manager, il faut qu'il soit manager dans le restaurant dans lequel se trouve la reservation
    if (auth.role() = 'manager' AND not exists(select * from restaurant_managers where manager = auth.id() and restaurant = restaurant_id)) then
        raise exception 'Manager cannot check a service inside a restaurant he is not working in';
    end if;

    return (select json_build_object(
                           'id', srv.id,
                           'restaurant', srv.restaurant,
                           'day_of_week', srv.day_of_week,
                           'start_time', srv.start_time,
                           'end_time', srv.end_time
                   )
            from services srv
            where srv.id = service_id);
end;
$$ language plpgsql security definer;

grant execute on function get_service(int, int) to manager;



create or replace function save_service(service_id int, new_service_day int, new_heure_debut int, new_heure_fin int, restaurant_id int) returns json as
$$
declare updated_id int := service_id;
begin
    perform auth.check_logged();
    if (auth.role() = 'manager' and check_manager_works_in_restaurant(auth.id(), restaurant_id)) then
        if (service_id = 0) then
            INSERT INTO services(restaurant, day_of_week, start_time, end_time) VALUES (restaurant_id, new_service_day, new_heure_debut, new_heure_fin)
            returning id into updated_id;
        else
            UPDATE services set day_of_week = new_service_day, start_time = new_heure_debut, end_time = new_heure_fin where id = service_id;
        end if;
        return get_service(updated_id, restaurant_id);
    end if;
    raise exception 'Not allowed';
end;
$$ language plpgsql security definer;

grant execute on function save_service(int, int, int, int, int) to manager;