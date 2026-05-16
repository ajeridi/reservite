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
                             'slot_dureation',r.slot_duration,
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

grant execute on function get_restaurant(int) to anon;




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

create or replace function get_restaurants(research text default NULL)
returns json as
    $$
        begin
            return (select json_agg(json_build_object('id',id,
                                                      'name',name,
                                                      'address',address,
                                                      'city',city,
                                                      'phone',phone,
                                                      'description',description,
                                                      'rating',rating,
                                                      'price_range',price_range,
                                                      'slot_duration',slot_duration)) from restaurants where lower(name) like  CONCAT('%',get_restaurants.research,'%')
                                                                                                    or lower(city) like CONCAT('%',get_restaurants.research,'%')
                                                                                                    or lower(description) like CONCAT('%',get_restaurants.research,'%'));
        end;

    $$language plpgsql security definer ;

grant execute on function get_restaurants(text) to anon;
