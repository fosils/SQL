--select allunmatchedreceipts(200060,'01-01-2000','01-01-2020')

--select allunmatchedreceipts_with(200060,'01-01-2000'::date,'01-01-2020'::date)


CREATE OR REPLACE FUNCTION public.allunmatchedreceipts_with(_customer_id integer, _start_date date, _end_date date)
 RETURNS TABLE(customer_id integer, id integer, textlink character varying, to_char text, currency currency_enum, receiptsignedamount_amount_original_currency numeric)
 LANGUAGE plpgsql
AS $function$ 
begin
	
RETURN QUERY
with temp as (
select receipt_id, bank_transaction_id, receipts.customer_id, receiptsignedamount ((expense)::INTEGER, receipts.amount)  receipt_amount, bank_transactions.amount bank_transaction_amount
from receipts inner join reconciliations on (receipts.id = receipt_id) 
left join bank_transactions on (bank_transactions.id = bank_transaction_id) where bank_transaction_id <> -1 and (receipts.customer_id = _customer_id or _customer_id is null) and bank_transactions.customer_id = _customer_id

),
unperfect_matches as
(
select receipt_id, bank_transaction_id, receipts.customer_id, receiptsignedamount ((expense)::INTEGER, receipts.amount)  receipt_amount, bank_transactions.amount bank_transaction_amount
from receipts inner join reconciliations on (receipts.id = receipt_id) 
left join bank_transactions on (bank_transactions.id = bank_transaction_id) 
	where (bank_transaction_id <> -1 
			and (receipts.customer_id = _customer_id or _customer_id is null) 
			and bank_transactions.customer_id = _customer_id
			)
			and (
				receipt_id not in (
					select receipt_id from (
								select receipt_id, max(receipt_amount) as receipt_amount, sum(bank_transaction_amount) as bank_transaction_amount from temp group by receipt_id
					) as egg where bank_transaction_amount = receipt_amount)
				and 
	 			bank_transaction_id not in (
					select bank_transaction_id from (
						select bank_transaction_id, max(bank_transaction_amount) as bank_transaction_amount, SUM(receipt_amount) as receipt_amount from temp group by bank_transaction_id 
					) as egg where bank_transaction_amount = receipt_amount
				)
		)
)

SELECT
    receipts.customer_id,
    receipts. ID,
    textlink (receipts. ID) AS textlink,
    to_char(
        (receipts.entry_date) :: TIMESTAMP WITH TIME ZONE,
        'DD-MM-YYYY' :: TEXT
    ) AS to_char,
    receipts.currency,
    receiptsignedamount (
        (receipts.expense) :: INTEGER,
        CASE
    WHEN (
        receipts.currency = 'DKK'
        AND customers.market = 'DK'
    )
    OR (
        receipts.currency = 'USD'
        AND customers.market = 'US'
    ) THEN
        receipts.amount
    ELSE
        receipts.amount_original_currency
    END
    ) AS receiptsignedamount_amount_original_currency
FROM
    receipts
LEFT JOIN customers ON customers. ID = receipts.customer_id 
inner join (select receipts.id from receipts where (receipts.id not in (select receipt_id from reconciliations) or
receipts.id in (select receipt_id from unperfect_matches)) and deleted = false) as no_perfect_matches on (no_perfect_matches.id = receipts.id)
WHERE
    (
        (
            (
                    (
                        (
                            (
                                EXISTS (
                                    SELECT
                                        1
                                    FROM
                                        credit_notes C
                                    WHERE
                                        (
                                            (C .receipt_id1 = receipts. ID)
                                            OR (C .receipt_id2 = receipts. ID)
                                        )
                                )
                            )
                            AND (
                                (
                                    - COALESCE (
                                        receiptsignedamount (
                                            (receipts.expense) :: INTEGER,
                                            receipts.amount
                                        ),
                                        (0) :: NUMERIC
                                    )
                                ) <> (
                                    COALESCE (
                                        (
                                            SELECT
                                                SUM (
                                                    COALESCE (
                                                        receiptsignedamount (
                                                            (cr1.expense) :: INTEGER,
                                                            cr1.amount
                                                        ),
                                                        (0) :: NUMERIC
                                                    )
                                                ) AS SUM
                                            FROM
                                                (
                                                    credit_notes c1
                                                    LEFT JOIN receipts cr1 ON ((cr1. ID = c1.receipt_id1))
                                                )
                                            WHERE
                                                (c1.receipt_id2 = receipts. ID)
                                        ),
                                        (0) :: NUMERIC
                                    ) + COALESCE (
                                        (
                                            SELECT
                                                SUM (
                                                    COALESCE (
                                                        receiptsignedamount (
                                                            (cr2.expense) :: INTEGER,
                                                            cr2.amount
                                                        ),
                                                        (0) :: NUMERIC
                                                    )
                                                ) AS SUM
                                            FROM
                                                (
                                                    credit_notes c2
                                                    LEFT JOIN receipts cr2 ON ((cr2. ID = c2.receipt_id2))
                                                )
                                            WHERE
                                                (c2.receipt_id1 = receipts. ID)
                                        ),
                                        (0) :: NUMERIC
                                    )
                                )
                            )
                        )
                        OR (
                            NOT (
                                EXISTS (
                                    SELECT
                                        1
                                    FROM
                                        credit_notes C
                                    WHERE
                                        (
                                            (C .receipt_id1 = receipts. ID)
                                            OR (C .receipt_id2 = receipts. ID)
                                        )
                                )
                            )
                        )
                    )
                )
                AND (receipts.deleted = FALSE)
                and (receipts.customer_id = _customer_id or _customer_id is null)
								and receipts.offset_account in (6860)
                AND receipts.entry_date >= _start_date AND receipts.entry_date <= _end_date
            )

    )
ORDER BY
    receipts.customer_id,
    receipts.entry_date;
END;
$function$
