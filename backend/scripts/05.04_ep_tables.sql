set search_path to public, auth;

/*
    - La disponibilité des tables pour le créneau de cette réservation est calculée en excluant la réservation elle-même,
        afin de ne pas la traiter comme une occupation concurrente lors du choix des tables.

    - Tant que la liste des tables du restaurant ou l'information de disponibilité n'est pas disponible, un indicateur de chargement peut occuper la zone centrale ;
        si aucune table n'est configurée pour le restaurant, un message l'indique à la place de la liste.

    - Après une confirmation réussie, l'application revient à l'écran de gestion du restaurant sur l'onglet où se trouvait l'utilisateur avant
        l'attribution des tables.
*/

    /* -------------------------------------- */


/*
ENDPOINT QUI VA RETOURNER UNE LISTE DE TABLES
 on retourne une liste d'objets reservations donc json_agg(json_build_object)
*/

    create or replace function get_tables(restaurant_id int default NULL) returns json as
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
                               'id', tbl.id,
                               'restaurant', tbl.restaurant,
                               'table_number', tbl.table_number,
                               'capacity', tbl.capacity
                       ) ORDER BY capacity ASC, table_number ASC
               )
        from tables tbl
        where tbl.restaurant = restaurant_id);
end if;

end;
    $$ language plpgsql security definer;

-- droit d'execution managers
grant execute on function get_tables(int) to manager;


create or replace function get_table(table_id int, restaurant_id int) returns json as
$$
begin
    -- verification si utilisateur connecte
    perform auth.check_logged();

    -- si user est un manager, il faut qu'il soit manager dans le restaurant dans lequel se trouve la reservation
    if (auth.role() = 'manager' AND not exists(select * from restaurant_managers where manager = auth.id() and restaurant = restaurant_id)) then
        raise exception 'Manager cannot check a table inside a restaurant he is not working in';
    end if;

    return (select json_build_object(
                           'id', tbl.id,
                           'restaurant', tbl.restaurant,
                           'table_number', tbl.table_number,
                           'capacity', tbl.capacity,
                            'has_reservations', (select count(*) from reservation_tables rt where rt."table" = table_id) > 0
                   )
            from tables tbl
            where tbl.id = table_id);
end;
$$ language plpgsql security definer;

grant execute on function get_table(int, int) to manager;


/*
    Verifie si la table est déjà occupée ou non
*/

create or replace function is_occupee(idtable int, reservation_datetime timestamp) returns boolean as
$$
declare
    restaurant_id int;
begin
        -- on récupère le restaurant de la table
        select tbl.restaurant into restaurant_id
        from tables tbl
        where tbl.id = idtable;

    return exists(select rsv_tbl.table
                  from reservation_tables rsv_tbl,
                       get_service_by_datetime(reservation_datetime::date, reservation_datetime::time, restaurant_id) s,
                       reservations rsv
                  where rsv_tbl.table = idtable AND rsv.id = rsv_tbl.reservation
                    AND (rsv.datetime::time >= s.start_time AND rsv.datetime::time <= s.end_time) /* ::time donne l'h/min/sec (ex: 18:00:00) */
                    AND rsv.datetime::date = reservation_datetime::date /* ::date donne le jour */
                    AND rsv.status <> 'cancelled'
                  );
end;
$$ language plpgsql security definer;

grant execute on function is_occupee(int, timestamp) to manager;
