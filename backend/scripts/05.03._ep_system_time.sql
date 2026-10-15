set search_path to public;

-- methode qui va retourner la date heure courante
create or replace function get_simulated_time() returns json as
    $$
    declare result timestamp;
    begin
        select simulated_time from system_time into result;

        -- si temps simule inexistant, on retourne la date courante
        if (result IS NULL) then
            select CURRENT_TIMESTAMP into result;
        end if;

        return json_build_object('simulated_time',result);
    end;
    $$ language plpgsql security definer;

grant execute on function get_simulated_time() to anon;

-- methode qui va sauvegarder la nouvelle date modifiee
create or replace function save_simulated_time(new_time timestamp) returns json as
    $$
    begin
        update system_time set simulated_time = new_time;

        return json_build_object('system_time', (SELECT * from system_time));
    end;
    $$ language plpgsql security definer;

grant execute on function save_simulated_time(timestamp) to anon;
