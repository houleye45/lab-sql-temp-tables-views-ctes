use sakila;

-- Step 1: Create a View
-- First, create a view that summarizes rental information for each customer. 
-- The view should include the customer's ID, name, email address, and total number of rentals (rental_count).

/* DROP VIEW customer_rental_summary;*/

CREATE VIEW customer_rental_summary AS
SELECT c.customer_id, c.first_name, c.last_name, c.email, COUNT(r.rental_id) AS total_number_rentals
FROM customer c
LEFT JOIN rental r ON c.customer_id = r.customer_id
GROUP BY c.customer_id;

SELECT * FROM customer_rental_summary;


-- Step 2: Create a Temporary Table
-- Next, create a Temporary Table that calculates the total amount paid by each customer (total_paid). 
-- The Temporary Table should use the rental summary view created in Step 1 to join with the payment table and calculate the total amount paid by each customer.

/*DROP TEMPORARY TABLE customer_total_paid;*/

CREATE TEMPORARY TABLE customer_total_paid AS
SELECT crs.customer_id, crs.first_name, crs.last_name, SUM(p.amount) AS total_payments
FROM customer_rental_summary crs 
INNER JOIN payment p 
on crs.customer_id = p.customer_id
GROUP BY customer_id;

SELECT * FROM customer_total_paid;

-- Step 3: Create a CTE and the Customer Summary Report
-- Create a CTE that joins the rental summary View with the customer payment summary Temporary Table created in Step 2. 
-- The CTE should include the customer's name, email address, rental count, and total amount paid.

WITH customer_summary_report AS 

(SELECT crs.first_name, crs.last_name, crs.email, crs.total_number_rentals, ctp.total_payments
FROM customer_rental_summary crs 
INNER JOIN customer_total_paid ctp 
on crs.customer_id = ctp.customer_id)

SELECT * FROM customer_summary_report;


-- Next, using the CTE, create the query to generate the final customer summary report, 
-- which should include: customer name, email, rental_count, total_paid and average_payment_per_rental, 
-- this last column is a derived column from total_paid and rental_count.

WITH customer_info AS (
  SELECT
    crs.customer_id, crs.first_name, crs.last_name, crs.email, crs.total_number_rentals,
    ctp.total_payments
  FROM customer_rental_summary crs
  INNER JOIN customer_total_paid ctp ON crs.customer_id = ctp.customer_id
)
SELECT
  first_name, last_name,
  email,
  total_number_rentals,
  total_payments,
  CASE WHEN total_number_rentals > 0 THEN total_payments / total_number_rentals ELSE 0 END AS average_payment_per_rental
FROM customer_info;

