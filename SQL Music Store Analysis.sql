--Q1: Who is the senior most employee based on Jon Title?
SELECT TOP 1 * FROM employee
ORDER BY levels desc;

-- Q2: Which countries have the most invoices?
SELECT TOP 5 billing_country as country, COUNT(1) as no_of_invoices
FROM invoice
GROUP BY billing_country
ORDER BY no_of_invoices DESC

-- Q3: What are top 3 values of total invoice?
SELECT TOP 3 ROUND(total,1) AS Total_invoice
FROM  invoice
ORDER BY total DESC

-- Q4: Write a query that results 1 city that has the highes sum of ivoice totals. 
--	   Returns city name and sum of invoice.
SELECT TOP 10 
	billing_city AS city,
	ROUND(SUM(total),1) AS sum_of_invoices
FROM invoice
GROUP BY billing_city
ORDER BY sum_of_invoices DESC

-- Q5: Write a query that returns the person who spent most most money.
SELECT first_name, last_name, ROUND(SUM(total),1) as money_spent
FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
GROUP BY first_name, last_name
ORDER BY money_spent DESC

-- Q6: Write query to return the email, first_name, last_name and genre of all rock music listeners.
-- return the list in alphabetic order by email starting with A
SELECT first_name, last_name, email
FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
JOIN invoice_line il ON i.invoice_id = il.invoice_id
WHERE track_id IN 
	( SELECT track_id FROM track t
		JOIN genre g ON t.genre_id = g.genre_id
		WHERE g.name LIKE 'ROCK')
GROUP BY first_name, last_name, email
ORDER BY email;

-- Q7: Write a query that returns the artist name and total track count of top 10 rock bands.
SELECT TOP 10 
	a.name,
	COUNT(track_id) as number_of_tracks
FROM artist a
JOIN album al ON a.artist_id =al.artist_id
JOIN track t on al.album_id = t.album_id
WHERE track_id in (SELECT track_id 
		   FROM track T
		   JOIN genre g on T.genre_id = g.genre_id
		   WHERE g.name LIKE 'Rock')
GROUP BY a.name
ORDER BY number_of_tracks DESC

-- Q8: Return all the track names that have a song length longer than the average length. Return name and 
-- milliseconds for each track. Order by the song length in descending.
SELECT name, milliseconds
FROM track
WHERE milliseconds > (SELECT AVG(milliseconds)FROM track)
ORDER BY milliseconds DESC

-- Q9: Find how much amount spent by each customer on artists? write a query to return customer's name, 
-- artist's name and total spent.
SELECT CONCAT(first_name,' ',last_name) as full_name, 
	   ROUND(SUM(il.quantity*il.unit_price),2) as total_spent, 
	   ar.name as artist_name
FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
JOIN invoice_line il ON i.invoice_id = il.invoice_id
JOIN track t ON il.track_id = t.track_id
JOIN album a ON t.album_id = a.album_id
JOIN artist ar ON a.artist_id = ar.artist_id
GROUP by first_name, last_name, ar.name

-- Q10: We want to find out the most popular music genre for each country, determine most popular genre with 
-- the highes amount of purchases. Write a query that returns each country along with top genre. For countries where the maximum
-- number of purchase is shared return all genres.
WITH cte AS (
SELECT 
	billing_country, 
	COUNT(quantity) as number_purchases, 
	g.name,
	ROW_NUMBER() OVER(PARTITION BY billing_country ORDER BY COUNT(quantity) DESC) AS row_no
FROM invoice i
JOIN invoice_line il ON i.invoice_id = il.invoice_id
JOIN track t ON il.track_id = t.track_id
JOIN genre g ON t.genre_id = g.genre_id
GROUP BY billing_country, g.name
)
SELECT billing_country, number_purchases, name 
FROM cte WHERE row_no <=1

-- Q11: Write a query that determines the customer that has spent most on music for each country, return customer name, country
-- and how much they spent. For countries where top amount is shared, provide all customers who spent this amount.
WITH CTE AS (
SELECT 
	first_name, 
	last_name, 
	ROUND(SUM(total),2) AS amount_spent, 
	country,
	ROW_NUMBER() OVER(PARTITION BY country ORDER BY SUM(total) DESC) AS row_num	
FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
GROUP BY first_name, last_name, country
)
SELECT first_name +' '+ last_name as full_name, amount_spent, country
FROM CTE 
WHERE row_num= 1

