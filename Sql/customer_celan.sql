--Removing duplicates from customer_id col
WITH dedup_customers AS(
SELECT
	*,
	ROW_NUMBER() OVER(PARTITION BY	customer_id ORDER BY signup_date DESC) as rn
FROM purchase.customers_raw
) 
SELECT *
FROM dedup_customers
WHERE rn = 1;

--Fix and validate signup dates
SELECT 
	customer_id,
	TRY_CAST(signup_date AS DATE) as signup_date,
	segment
FROM purchase.customers_raw

--Standardize the segments
SELECT 
	customer_id,
	CASE 
		WHEN UPPER(segment) IN ('PREMIUM') THEN 'PREMIUM'
		WHEN UPPER(segment) IN ('REG','REGULAR') THEN 'REGULAR'
	END as segment_clean
FROM purchase.customers_raw




-- CREATing cleaned customer_view

CREATE VIEW purchase.vw_customers_clean AS
	WITH base AS(
		SELECT 
			customer_id,
			TRY_CAST(signup_date AS DATE) as signup_date,
			CASE
				WHEN UPPER(segment) = 'PREMIUM' THEN 'PREMIUM'
				ELSE 'REGULAR'
			END AS segment
		FROM purchase.customers_raw
	),
	dedup AS(
		SELECT *,
			ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY signup_date DESC) as rn
		FROM base
		) 
	SELECT 
	customer_id,signup_date,segment
	FROM dedup
	WHERE rn = 1;
