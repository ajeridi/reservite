set search_path to public, auth;

create or replace function get_restaurant(id int)
       returns json as
$$
    begin
        return(select json_build_object('id',r.id,
                             'name',r.name,
                             'address',r.address,
                             'city',r.city,
                             'phone',r.phone,
                             'description',r.description,
                             'rating',r.rating,
                             'price_range', r.price_range,
                             'slot_duration',r.slot_duration,
                              'is_sponsored',r.is_sponsored,
                             'tables',(select json_agg(json_build_object('id',t.id,
                                                                         'restaurant',t.restaurant,
                                                                         'table_number',t.table_number,
                                                                         'capacity',t.capacity)) from tables t where t.restaurant = get_restaurant.id),
                             'services',(select json_agg(json_build_object('id',s.id,
                                                                           'restaurant',s.restaurant,
                                                                           'day_of_week',s.day_of_week,
                                                                           'start_time',s.start_time,
                                                                           'end_time',s.end_time)) from services s where s.restaurant = get_restaurant.id))
        from restaurants r where r.id = get_restaurant.id);
    end;

$$ language plpgsql security definer ;

grant execute on function get_restaurant(int) to authenticated;




-- select json_build_object('id',id,
--                          'name',name,
--                          'address',address,
--                          'city',city,
--                          'phone',phone,
--                          'description',description,
--                          'rating',rating,'price_range',
--                          price_range,'slot_duration',
--                          slot_duration,
--                          'tables',(select json_agg(json_build_object('id',t.id,
--                                                                      'restaurant',t.restaurant,
--                                                                      'table_number',t.table_number,
--                                                                      'capacity',t.capacity)) from tables t where t.restaurant = 2),
--                          'services',(select json_agg(json_build_object('id',s.id,
--                                                                        'restaurant',s.restaurant,
--                                                                        'day_of_week',s.day_of_week,
--                                                                        'start_time',s.start_time,
--                                                                        'end_time',s.end_time)) from services s where s.restaurant = 2))
-- from restaurants where id = 2;


-- {"id" : 1, "name" : "Le Gourmet", "address" : "Rue de la Paix 12", "city" : "Bruxelles", "phone" : "+32 2 123 45 67", "description" : "Restaurant gastronomique français", "rating" : 4.5, "price_range" : 3, "slot_dureation" : 30,
-- "tables" : [{"id" : 1, "restaurant" : 1, "table_number" : 1, "capacity" : 2}, {"id" : 2, "restaurant" : 1, "table_number" : 2, "capacity" : 4}, {"id" : 3, "restaurant" : 1, "table_number" : 3, "capacity" : 6}],
-- "services" : [{"id" : 1, "restaurant" : 1, "day_of_week" : 1, "start_time" : "12:00:00", "end_time" : "14:00:00"}, {"id" : 2, "restaurant" : 1, "day_of_week" : 1, "start_time" : "19:00:00", "end_time" : "22:00:00"}, {"id" : 3, "restaurant" : 1, "day_of_week" : 2, "start_time" : "12:00:00", "end_time" : "14:00:00"}, {"id" : 4, "restaurant" : 1, "day_of_week" : 2, "start_time" : "19:00:00", "end_time" : "22:00:00"}, {"id" : 5, "restaurant" : 1, "day_of_week" : 3, "start_time" : "12:00:00", "end_time" : "14:00:00"}, {"id" : 6, "restaurant" : 1, "day_of_week" : 3, "start_time" : "19:00:00", "end_time" : "22:00:00"}, {"id" : 7, "restaurant" : 1, "day_of_week" : 4, "start_time" : "12:00:00", "end_time" : "14:00:00"}, {"id" : 8, "restaurant" : 1, "day_of_week" : 4, "start_time" : "19:00:00", "end_time" : "22:00:00"}, {"id" : 9, "restaurant" : 1, "day_of_week" : 5, "start_time" : "12:00:00", "end_time" : "14:00:00"}, {"id" : 10, "restaurant" : 1, "day_of_week" : 5, "start_time" : "19:00:00", "end_time" : "23:00:00"}, {"id" : 11, "restaurant" : 1, "day_of_week" : 6, "start_time" : "19:00:00", "end_time" : "23:00:00"}, {"id" : 12, "restaurant" : 1, "day_of_week" : 7, "start_time" : "12:00:00", "end_time" : "14:00:00"}]}

--chercher tous les restaurants par rapport à l'user

-- select json_agg(json_build_object('id',id,
--                         'name',name,
--                         'address',address,
--                         'city',city,
--                         'phone',phone,
--                         'description',description,
--                         'rating',rating,
--                         'price_range',price_range,
--                         'slot_duration',slot_duration)) from restaurants where lower(name) like CONCAT('%',NULL,'%');
--===========================================================================
--creation d'un toggle pour changer la valeur du is_sponsoring
create or replace function toggle(resto_id int)  returns json as
    $$
        begin
            -- verifier si user connecte
            perform auth.check_logged();
            --le restaurant doit exister
                if not exists(select 1 from restaurants where id=resto_id)then
                    raise exception 'The restaurant does not exists';
                end if;
            -- on regarde si le manager travaille dans le restaurant de la reservation a confirmer
            if (auth.id() not in
                (select rm.manager from restaurant_managers rm where manager = auth.id() and restaurant = resto_id)) then
                raise exception 'User is not manager at the reservation''s restaurant';
            end if;
            if((select restaurants.is_sponsored from restaurants where id=resto_id) is false)then
            --verifier qu'il y a au moins une reservation completed or pending
                if not exists(select * from reservations r where r.restaurant = resto_id and (r.status = 'confirmed' or r.status = 'completed'))then
                    raise exception ' The restaurant must have at least one reservation completed or confirmed';
                end if;
            end if;

            --changement
            update restaurants set is_sponsored = not (is_sponsored) where id = resto_id;

            --retourner le resto modifié
            return get_restaurant(resto_id);
        end;
    $$language plpgsql security definer ;

grant execute on function toggle(int) to manager;
--============================================================================
create or replace function get_restaurants(research text default NULL)
returns json as
    $$
        begin
            if auth.role() = 'client' then
                return (select json_agg(json_build_object('id',r.id,
                                                      'name',r.name,
                                                      'address',r.address,
                                                      'city',r.city,
                                                      'phone',r.phone,
                                                      'description',r.description,
                                                      'rating',r.rating,
                                                      'price_range',r.price_range,
                                                      'slot_duration',r.slot_duration,

                                                        'last_reservation_date',(select datetime from reservations where auth.role() = 'client' and reservations.restaurant = r.id ORDER BY datetime DESC Limit 1)))
                    from restaurants r where lower(name) like  CONCAT('%',get_restaurants.research,'%')
                                                                                                    or lower(city) like CONCAT('%',get_restaurants.research,'%')
                                                                                                    or lower(description) like CONCAT('%',get_restaurants.research,'%'));
            end if;

            if auth.role() = 'manager' then
                return (select json_agg(json_build_object('id',r.id,
                                                          'name',r.name,
                                                          'address',r.address,
                                                          'city',r.city,
                                                          'phone',r.phone,
                                                          'description',r.description,
                                                          'rating',r.rating,
                                                          'price_range',r.price_range,
                                                          'slot_duration',r.slot_duration,
                                                            'is_sponsored',r.is_sponsored,
                                                          'last_reservation_date',(select datetime from reservations where reservations.restaurant = r.id ORDER BY datetime DESC Limit 1),
                                                          'reservations_pending',(select get_pending_reservation_count(r.id))))
                        from restaurants r
                        join public.restaurant_managers rm on r.id = rm.restaurant
                        where rm.manager = auth.id()

                );
            end if;
        end;

    $$language plpgsql security definer ;

grant execute on function get_restaurants(text) to authenticated;

-- select json_agg(json_build_object('id',r.id,
--                         'name',r.name,
--                         'address',r.address,
--                         'city',r.city,
--                         'phone',r.phone,
--                         'description',r.description,
--                         'rating',r.rating,
--                         'price_range',r.price_range,
--                         'slot_duration',r.slot_duration,
--                         'last_reservation_date',(select datetime from reservations where reservations.restaurant = r.id ORDER BY datetime DESC Limit 1))) from restaurants r
--                                                         join public.restaurant_managers rm on r.id = rm.restaurant
--                                                         where rm.manager = auth.id();

-- endpoint qui va retourner la capacite d'un restaurant (somme des ses tables)
create or replace function get_restaurant_capacity(restaurant_id int) returns json as
    $$
    declare restaurant_capacity  int := (select sum(capacity) from tables where restaurant = restaurant_id);
    begin
        perform auth.check_logged();
        if (auth.role() != 'client') then
            raise exception 'Not allowed';
        end if;
        return json_build_object('restaurant_capacity', restaurant_capacity);
    end;
    $$language plpgsql security definer ;

grant execute on function get_restaurant_capacity(int) to client;

