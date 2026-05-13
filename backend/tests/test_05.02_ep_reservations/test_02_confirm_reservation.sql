select * from tables t join restaurants r on r.id = t.restaurant
                        join reservations rsv on rsv.restaurant = r.id
where rsv.status = 'pending' and rsv.number_of_guests < t.capacity;

--assigner table 5 a la reservation 2
