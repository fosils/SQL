create table external_data.spiir_raw_data(id serial, customer_id int , transaction_id text, AccountId text,
							AccountName text, AccountType text, Date text, Description text,
							OriginalDescription text, MainCategoryId text, MainCategoryName text, CategoryId text, 
							CategoryName text, CategoryType text, ExpenseType text, Amount text,Balance text, CounterEntryId text, Comment text, Tags text, Extraordinary text, SplitGroupId text, CustomDate text);

create table external_data.spiir_raw_data_temp ( transaction_id text, AccountId text,
							AccountName text, AccountType text, Date text, Description text,
							OriginalDescription text, MainCategoryId text, MainCategoryName text, CategoryId text, 
							CategoryName text, CategoryType text, ExpenseType text, Amount text,Balance text, CounterEntryId text, Comment text, Tags text, Extraordinary text, SplitGroupId text, CustomDate text);