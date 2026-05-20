/*
    FICHIER QUI VA CONTENIR LES TYPES SUR MESURES
*/

create type client_details as
(
    id integer,
    name varchar,
    email varchar,
    phone varchar
);

create type restaurant_details as
(
    id integer,
    name varchar,
    address varchar,
    city varchar,
    phone varchar
);

create type table_details as
(
    id integer,
    table_number integer,
    capacity integer
);

create type reservation_type as
(
    id integer,
    client client_details,
    restaurant restaurant_details,
    datetime timestamp,
    number_of_guests integer,
    status status_type,
    special_requests text,
    tables table_details[]
);