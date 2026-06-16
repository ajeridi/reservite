set search_path to public, auth;

create or replace function save_review(review_id int DEFAULT null, client_id int,restaurant_id int,reservation_id int,rating_ int,comment_ text,date timestamp) returns json as
    $$
    declare updated_review_id int := review_id;
    begin
        -- verification si utilisateur connecte
        perform auth.check_logged();
        if (auth.role() <> 'client') then
            raise exception 'Cannot save a review if you are not a client';
        end if;

        if(review_id = 0)then
            Insert INTO reviews( client, restaurant, reservation, rating, comment, created_at)
            VALUES (client_id,restaurant_id,reservation_id,rating_,comment_,date)
            returning id into updated_review_id;
        else
            Update reviews
            set client = client_id,
                restaurant = restaurant_id,
                reservation = reservation_id,
                rating = rating_,
                comment = comment_,
                created_at = date
            where id = review_id;
        end if;
        return (select json_build_object(
                               'id', r.id,
                               'client', r.client,
                               'restaurant', r.restaurant,
                               'reservation', r.reservation,
                               'rating', r.rating,
                               'comment', r.comment,
                               'created_at', r.created_at
                       ) from reviews r where r.id = updated_review_id);

    end;

    $$language plpgsql security definer ;

grant execute on function save_review(int,int,int,int,int,text,timestamp)to client;