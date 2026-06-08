set search_path to public, auth;

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
                                       'id', svc.id,
                                       'restaurant', svc.restaurant,
                                       'day_of_week', svc.day_of_week,
                                       'start_time', svc.start_time,
                                       'end_time', svc.end_time
                               )
                       )
                from services svc
                where svc.restaurant = restaurant_id);
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
                           'id', svc.id,
                           'restaurant', svc.restaurant,
                           'day_of_week', svc.day_of_week,
                           'start_time', svc.start_time,
                           'end_time', svc.end_time
                   )
            from services svc
            where svc.id = service_id);
end;
$$ language plpgsql security definer;

grant execute on function get_service(int, int) to manager;


create or replace function isEmpty(day_of_weekk int, restaurantid int) returns boolean as
    $$
    begin
        return not exists(select svc.id
                      from services svc, restaurants rst
                      where svc.day_of_week = day_of_weekk
                      AND restaurantid = svc.restaurant
        );
    end;
    $$ language plpgsql security definer;

grant execute on function isEmpty(int, int) to manager;

-- true = on peut supprimer (aucune résa active dans ce créneau)
create or replace function can_delete_service(service_id int) returns boolean as $$
begin
    return not exists (
        select 1
        from reservations r
                 join services s on s.id = service_id
        where r.restaurant = s.restaurant
          and r.status <> 'cancelled'
          and extract(isodow from r.datetime) = s.day_of_week
          and r.datetime::time >= s.start_time
          and r.datetime::time <= s.end_time
    );
end;
$$ language plpgsql security definer;

grant execute on function can_delete_service(int) to manager;


create or replace function delete_service(service_id int) returns boolean as $$
declare
    restaurant_id int;
begin
    -- utilisateur connecté
    perform auth.check_logged();

    -- on récupère le restaurant du service
    select restaurant into restaurant_id
    from services
    where id = service_id;

    if restaurant_id is null then
        raise exception 'Service not found';
    end if;

    -- le manager doit travailler dans ce restaurant
    perform check_manager_works_in_restaurant(auth.id(), restaurant_id);

    -- pas de résa active sur ce créneau (même règle que le bouton gris)
    if not can_delete_service(service_id) then
        raise exception 'Cannot delete service: active reservations use this time slot';
    end if;

    -- suppression
    delete from services where id = service_id;
    return true;
end;
$$ language plpgsql security definer;

grant execute on function delete_service(int) to manager;


-- modification d'un service (jour, heure de debut, heure de fin)
create or replace function update_service(service_id int, day_of_week_ int, start_time_ time, end_time_ time) returns json as $$
declare
    restaurant_id int;
begin
    -- utilisateur connecte
    perform auth.check_logged();

    -- on recupere le restaurant du service
    select restaurant into restaurant_id
    from services
    where id = service_id;

    if restaurant_id is null then
        raise exception 'Service not found';
    end if;

    -- le manager doit travailler dans ce restaurant
    perform check_manager_works_in_restaurant(auth.id(), restaurant_id);

    -- mise a jour
    update services
    set day_of_week = day_of_week_,
        start_time  = start_time_,
        end_time    = end_time_
    where id = service_id;

    return get_service(service_id, restaurant_id);
end;
$$ language plpgsql security definer;

grant execute on function update_service(int, int, time, time) to manager;


-- nombre de reservations confirmees ou en attente qui seraient en dehors des nouvelles heures du service
create or replace function count_reservations_outside_service(service_id int, day_of_week_ int, start_time_ time, end_time_ time) returns int as $$
declare
    nb int;
begin
    perform auth.check_logged();

    select count(*)
    into nb
    from reservations r
             join services s on s.id = service_id
    where r.restaurant = s.restaurant
      and r.status in ('pending'::status_type, 'confirmed'::status_type)
      and extract(isodow from r.datetime) = s.day_of_week
      and r.datetime::time >= s.start_time
      and r.datetime::time <= s.end_time
      and not (
            extract(isodow from r.datetime) = day_of_week_
        and r.datetime::time >= start_time_
        and r.datetime::time <= end_time_
        );

    return nb;
end;
$$ language plpgsql security definer;

grant execute on function count_reservations_outside_service(int, int, time, time) to manager;


-- creation d'un nouveau service pour un restaurant
create or replace function create_service(restaurant_id_ int, day_of_week_ int, start_time_ time, end_time_ time) returns json as $$
declare
    new_id int;
begin
    -- utilisateur connecte
    perform auth.check_logged();

    -- le manager doit travailler dans ce restaurant
    perform check_manager_works_in_restaurant(auth.id(), restaurant_id_);

    -- insertion
    insert into services(restaurant, day_of_week, start_time, end_time)
    values (restaurant_id_, day_of_week_, start_time_, end_time_)
    returning id into new_id;

    return get_service(new_id, restaurant_id_);
end;
$$ language plpgsql security definer;

grant execute on function create_service(int, int, time, time) to manager;