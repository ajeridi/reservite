set search_path to public, auth;

/*
    -retourner une liste d'objets services pour le restaurant passé en parametres
*/

create or replace function get_services_par_restaurant(restaurant_id int)
    returns json as
    $$
    declare user_id int := auth.id();
    declare user_role role_type := auth.role();
        begin
            perform auth.check_logged();
            if (user_role = 'manager'::role_type) then
                -- on verifie si le manager travaille dans ce restaurant
                perform check_manager_works_in_restaurant(user_id, restaurant_id);
                return (select json_agg(json_build_object('id',s.id,
                        'restaurant',s.restaurant,
                        'day_of_week',s.day_of_week,
                        'start_time',s.start_time,
                        'end_time',s.end_time)) from services s where s.restaurant = restaurant_id);
            end if;
        end;
    $$language plpgsql security definer ;

grant execute  on function get_services_par_restaurant(int) to manager;

create or replace function get_service_par_restaurant(service_id int,restaurant_id int)
    returns json as
$$
declare user_id int := auth.id();
    declare user_role role_type := auth.role();
begin
    perform auth.check_logged();
    if (user_role = 'manager'::role_type) then
        -- on verifie si le manager travaille dans ce restaurant
        perform check_manager_works_in_restaurant(user_id, restaurant_id);
        return (select json_build_object('id',s.id,
                                                  'restaurant',s.restaurant,
                                                  'day_of_week',s.day_of_week,
                                                  'start_time',s.start_time,
                                                  'end_time',s.end_time) from services s
                                                                         where s.id = service_id and
                                                                             s.restaurant = restaurant_id);
    end if;
end;
$$language plpgsql security definer ;

grant execute  on function get_service_par_restaurant(int,int) to manager;