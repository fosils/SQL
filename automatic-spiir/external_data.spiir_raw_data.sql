create table external_data.spiir_raw_data(id serial, customer_id int , transaction_id text, account_id text,
							account_name text, account_type text, date text, description text,
							original_description text, main_category_id text, main_category_name text, category_id text, 
							category_name text, category_type text, expense_type text, amount text,balance text, counter_entry_id text, comment text, tags text, extraordinary text, split_group_id text, custom_date text);

create table external_data.spiir_raw_data_temp ( transaction_id text, account_id text,
							account_name text, account_type text, date text, description text,
							original_description text, main_category_id text, main_category_name text, category_id text, 
							category_name text, category_type text, expense_type text, amount text,balance text, counter_entry_id text, comment text, tags text, extraordinary text, split_group_id text, custom_date text);