create or replace function save_review(review_id int, client_id int, restaurant_id int, reservation_id int, new_rating int, new_comment text, update_date timestamp) returns json as
    $$
    declare updated_id int := review_id;
    begin
        perform auth.check_logged();
        if (auth.role() = 'client' and (exists(select * from reservations where client = client_id and restaurant = restaurant_id and id = reservation_id))) then
            if (review_id = 0) then
                insert into reviews(client, restaurant, reservation, rating, comment) VALUES (client_id, restaurant_id, reservation_id, new_rating, new_comment)
                returning id into updated_id;
            else
                update reviews set rating = new_rating, comment = new_comment, created_at = update_date where id = review_id;
            end if;

            return (select json_build_object('id', id, 'client', client, 'restaurant', restaurant, 'reservation', reservation, 'comment', comment, 'rating', rating, 'created_at', created_at) from reviews where id = updated_id);
        end if;
    end;
    $$ language plpgsql security definer;

grant execute on function save_review(int, int, int, int, int, text, timestamp) to client;
