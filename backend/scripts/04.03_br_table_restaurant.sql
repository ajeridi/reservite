/*
(BR-03) Les tables associées à une réservation doivent appartenir au restaurant de la réservation.

Analyse :
    Quelles tables sont concernées, et quelles opérations doivent être checkées ?

    Tables concernées :
        - reservation_tables (Table de liaison) :
            - INSERT : OUI. C'est ici qu'on associe la table et la réservation, il faut vérifier la correspondance des restaurants.
            - UPDATE : NON. Les clés primaires (reservation, table) ne peuvent pas être modifiées selon le cahier des charges.
            - DELETE : NON. Enlever une table d'une réservation ne risque pas de lier deux restaurants différents.

        - reservations :
            - INSERT : NON. À la création, la réservation n'a pas encore de table associée.
            - UPDATE : NON. Géré par une autre règle qui empêche de modifier le restaurant d'une réservation existante.
            - DELETE : NON. Supprime juste la réservation.

        - tables :
            - INSERT : NON. À la création, la table n'est liée à aucune réservation.
            - UPDATE : NON. Géré par une autre règle qui empêche de modifier le restaurant d'une table existante.
            - DELETE : NON. Supprime juste la table.
*/

create or replace function check_table_restaurant_match() returns trigger as
        $$
        declare
            res_restaurant_id int;
            tab_restaurant_id int;
        begin
            -- Dans quel restaurant se fait cette réservation ?
            -- "new" représente la nouvelle ligne qu'on essaie d'insérer dans reservation_tables
            select restaurant into res_restaurant_id
            from reservations
            where id = new.reservation;

            -- Dans quel restaurant se trouve cette table ?
            select restaurant into tab_restaurant_id
            from tables
            where id = new."table"; -- j'ai mis entre guillemet pour éviter des ambiguités.

            -- Est-ce que ce sont les mêmes ?
            if res_restaurant_id != tab_restaurant_id then
               raise exception 'BR-03: La table n''appartient pas au restaurant de la réservation.';
            end if;

            -- Si on arrive ici, on laisse l'insertion continuer
            return new;
        end;
        $$ language plpgsql;

create or replace trigger br_03_trigger
       before insert
       on reservation_tables
       for each row
       execute function check_table_restaurant_match();