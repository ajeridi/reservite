/*

(BR-01) Une réservation doit être associée à un utilisateur ayant le rôle de client.

Analyse :
    Quelles tables sont concernées, et quelles operations doivent etre checkees

    Tables concernees :
        - Reservations :
            - Insert : oui uniquement si le user reférencé est un client
            - Update : cas géré par la regle métier qui empeche la modification d'une reservation ou d'un client
            - delete : non car on delete la reservation et par consequent le client

        - User :
            - Insert : non, car un nouveau client est créé avant une reservation, donc il n'en impacte pas
            - Update : non, car on ne peut pas modifier le role d'un client
            - delete : delete un user delete la reservation (on cascade)
*/

set search_path to public;

create or replace function reservation_associated_with_client_fct() returns trigger as
       $$
        declare user_role role_type;
       begin
            -- on ne check pas le type d'operation, car seul le insert est concerné
            -- chercher le role du user associé à la reservation
            select u.role from users u where new.client = u.id into user_role;
            -- si le role du user associé n'est pas un client, refuser l'insertion
            if (user_role  != 'client') then
                raise exception 'User associé à la réservation n''est pas un client';
            end if;
            return new;
       end;
       $$ language plpgsql security definer;

create or replace trigger reservation_associated_with_client
    before insert
    on reservations
    for each row
    execute function reservation_associated_with_client_fct();


-- insert into reservations (client, restaurant, datetime, number_of_guests) VALUES (2, 2, current_date, 3)
