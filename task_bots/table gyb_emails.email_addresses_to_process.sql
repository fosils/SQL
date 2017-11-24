create table gyb_emails.email_addresses_to_process (
id serial,
address text
);


insert into gyb_emails.email_addresses_to_process (address) values ('udgift@revisor1.dk');
insert into gyb_emails.email_addresses_to_process (address) values ('indtaegt@revisor1.dk');
insert into gyb_emails.email_addresses_to_process (address) values ('indtÃ¦gt@revisor1.dk');
insert into gyb_emails.email_addresses_to_process (address) values ('indtægt@revisor1.dk');

