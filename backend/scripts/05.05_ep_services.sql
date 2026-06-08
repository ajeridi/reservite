set search_path to public, auth;

/* Chercher les services d'un restaurant*/

create or replace function get_services(restaurant_id int default null)
returns  json as
    $$
    declare user_id int := auth.id();
    declare user_role role_type := auth.role();
        begin
        perform auth.check_logged();
        if(user_role = 'manager' :: role_type) then
            perform check_manager_works_in_restaurant(user_id,restaurant_id);
            return  (select json_agg(
                            json_build_object(
                            'id', s.id,
                            'restaurant', s.restaurant,
                            'day_of_week', s.day_of_week,
                            'start_time', s.start_time,
                            'end_time', s.end_time
                            )
                            )
                     from services s
                     where s.restaurant = restaurant_id);
        end if;
    end;
    $$language plpgsql security definer ;

grant execute on function  get_services(int) to manager;

/* chercher un service specifique*/

create or replace function get_service(service_id int default null)
    returns  json as
$$
        begin
        perform auth.check_logged();


            return  (select
                            json_build_object(
                            'id', s.id,
                            'restaurant', s.restaurant,
                            'day_of_week', s.day_of_week,
                            'start_time', s.start_time,
                            'end_time', s.end_time
                            )

                     from services s
                     where s.id = service_id);

    end;
    $$language plpgsql security definer ;

grant execute on function  get_service(int) to manager;

/* Insert/update service , si l'id est null ça veut dire que c'est un nouuveau service*/

create or replace function save_service(service_id int, restaurant_id int , day_of_week int ,start_time time, end_time time)
returns  json as
    $$
    declare
        updated_service_id int := service_id;
        begin
        -- verification si manager connecte
        perform auth.check_logged();
        if (auth.role() <> 'manager') then
            raise exception 'Cannot add/edit a service if you are not a manager';
        end if;
        -- si service_id Null , alors on cree un nouveau service
        if(service_id is NULL) then
            Insert Into services(restaurant, day_of_week, start_time, end_time)
            VALUES(restaurant_id,save_service.day_of_week,save_service.start_time,save_service.end_time)
            returning id into updated_service_id;
        else
            Update services
            set restaurant = restaurant_id,
                day_of_week = save_service.day_of_week,
                start_time = save_service.start_time,
                end_time = save_service.end_time
            where id = service_id;
        end if;
        return  get_service(updated_service_id);
    end;
    $$language plpgsql security definer ;

grant execute on function save_service(int,int,int,time,time) to manager;

/* supprimer un service*/
create or replace function delete_service(service_id int)
returns void as
    $$
    declare v_service services%rowtype;
        begin
            -- verification si manager connecte
            perform auth.check_logged();
            if (auth.role() <> 'manager') then
                raise exception 'Cannot add/edit a service if you are not a manager';
            end if;

            --recup service à supprimer
            select * into v_service from services where id = service_id;

            --verif s'il y a des reservations liees au service
            if exists(select 1 from reservations r
                               where r.restaurant = v_service.restaurant
                               and extract(dow from r.datetime) = v_service.day_of_week
                               and r.datetime::time >= v_service.start_time
                               and r.datetime::time <= v_service.end_time
                               and r.status not in ('cancelled','completed'))then
                raise exception 'Cannot delete a service with active reservations';
            end if;

            delete from services where id = service_id;
        end;
    $$language plpgsql security definer ;

grant execute on function delete_service(int) to manager;