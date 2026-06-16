set search_path to public, auth;

create or replace function get_review(reservation_id int) returns json as
$$
begin
    -- verification si utilisateur connecte
    perform auth.check_logged();

    return (select json_build_object(
                           'id', rev.id,
                           'client', rev.client,
                           'restaurant', rev.restaurant,
                           'reservation', rev.reservation,
                           'rating', rev.rating,
                           'comment', rev.comment,
                           'created_at', rev.created_at
                   )
            from reviews rev
            where rev.reservation = reservation_id);
end;
$$ language plpgsql security definer;

grant execute on function get_review(int) to client;



create or replace function deja_review(idclient int, reservationId int) returns boolean as
$$
begin
    return exists(select rev.id
                  from reviews rev
                  where rev.client = idclient
                  AND rev.reservation = reservationId
    );
end;
$$ language plpgsql security definer;

grant execute on function deja_review(int, int) to client;


drop function if exists publier_avis(int, int, int, text, timestamp, int);

create or replace function publier_avis(restaurantId int, reservationId int, ratingg int, datetime_ timestamp, commentt text DEFAULT NULL, reviews_id int DEFAULT NULL)
    returns json as
$$
declare
    updated_review_id int := reviews_id;
begin
    -- verification si utilisateur connecte
    perform auth.check_logged();
    if (auth.role() <> 'client') then
        raise exception 'Cannot publier_avis if you are not a client';
    end if;

    -- si reviews_id est null alors on cree un nouvel avis
    if (reviews_id is NULL) then
        INSERT INTO reviews(client, restaurant, reservation, rating, comment, created_at)
        VALUES (auth.id(), restaurantId, reservationId, ratingg, commentt, datetime_)
        returning id into updated_review_id;
    else
        UPDATE reviews
        set rating = ratingg,
            comment = commentt
        WHERE id = reviews_id;
    end if;
    return get_review(reservationId);
end;
$$ language plpgsql security definer;

grant execute on function publier_avis(int, int, int, timestamp, text, int) to client;