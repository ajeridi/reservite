-- test pour get_reservations
select auth.login_anonymously_for_test();
select auth.id();

select auth.login_for_test('bepenelle@epfc.eu');
select public.get_reservation(17);
select public.get_reservation(2);
select auth.logout_for_test();


-- toutes les reservations dans le restaurant ou penelle n'est pas manager
select * from reservations
where reservations.restaurant not in (select rm.restaurant from restaurant_managers rm where manager = (select u.id from users u where email = 'bepenelle@epfc.eu'));
