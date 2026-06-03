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
                       )
               )
        from tables tbl
        where tbl.restaurant = restaurant_id);
end if;

end;
    $$ language plpgsql security definer;

-- droit d'execution managers
grant execute on function get_tables(int) to manager;


create or replace function get_table(reservation_id int) returns json as
$$
begin
    -- verification si utilisateur connecte
    perform auth.check_logged();

    -- si user est un manager, il faut qu'il soit manager dans le restaurant dans lequel se trouve la reservation
    if (auth.role() = 'manager' AND not exists(select * from restaurant_managers where manager = auth.id() and restaurant = (select rsv.restaurant from reservations rsv where rsv.id = reservation_id))) then
        raise exception 'Manager cannot check a table inside a restaurant he is not working in';
    end if;

    return (select json_build_object(
                           'id', tbl.id,
                           'restaurant', tbl.restaurant,
                           'table_number', tbl.table_number,
                           'capacity', tbl.capacity
                   )
            from tables tbl
            where tbl.id = reservation_id);
end;
$$ language plpgsql security definer;

grant execute on function get_table(int) to manager;
