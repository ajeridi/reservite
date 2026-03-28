set search_path to public ;

/**************************************************************
  Partie user
**************************************************************/
--constraint full name doit avoir min 3 char
alter table users
add constraint cs_name_length
check (length(trim(full_name)) >= 3);

--tests
insert into users( email, password, full_name, role, phone)
values ('test_password', 'Projet123@','Test','client','12345');

--constraint user password
alter table users
add constraint cs_password_regex
check ( password ~ '^(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])(?=.*[,;.:!?/$%&@#]).{8,}$' );

delete from users
where full_name ='Edy';



