## SQL Homework Assignment

use sakila;

# Display the first and last name of each actor 
# in a single column in upper case letters. 
# Name the column `Actor Name`.

SELECT first_name, last_name
FROM actor;

SELECT UPPER(CONCAT(first_name, ' ', last_name)) AS `Actor Name`
FROM actor;

# Find the ID number, first name, and last name of an actor "Joe." 

SELECT first_name, last_name, actor_id
FROM actor
WHERE first_name = "Joe";

# Find all actors whose last name contain the letters `GEN`:

SELECT first_name, last_name, actor_id
FROM actor
WHERE last_name LIKE '%GEN%';

# Find all actors whose last names contain the letters `LI` 
# Order the rows by last name and first name, in that order

SELECT first_name, last_name, actor_id
FROM actor
WHERE last_name LIKE '%LI%'
ORDER BY last_name, first_name;

# Display the `country_id` and `country` 
# columns of the following countries: Afghanistan, Bangladesh, and China:

SELECT country_id, country
FROM country
WHERE country IN ('Afghanistan', 'Bangladesh', 'China');

# Keep a description of each actor. 
# Create a column in the table `actor` named `description` 
# Use the data type `BLOB` 

ALTER TABLE actor
ADD COLUMN description blob AFTER last_name;

# Delete the `description` column.

ALTER TABLE actor
DROP COLUMN description;


# List the last names of actors, as well as how many actors 
# have that last name.

SELECT last_name, count(last_name) AS 'last_name_frequency'
FROM actor
GROUP BY last_name
HAVING `last_name_frequency` >= 1;

# List last names of actors and the number of actors who 
# have that last name, but only for names that are shared by 
# at least two actors.

SELECT last_name, count(last_name) AS 'last_name_frequency'
FROM actor
GROUP BY last_name
Having `last_name_frequency` >= 2;

# The actor `HARPO WILLIAMS` was accidentally entered 
# in the `actor` table as `GROUCHO WILLIAMS`. 
# Write a query to fix the record. (And Chico, Zeppo, and Gummo, too?)

UPDATE actor
SET first_name = 'HARPO'
WHERE first_name = 'GROUCHO'
and last_name = 'WILLIAMS';

# Change 'Groucho' back to 'harpo' in a single query. 

UPDATE actor
SET first_name =
CASE
WHEN first_name = 'HARPO'
	THEN 'GROUCHO'
	ELSE 'MUCHO GROUCHO'
END

WHERE actor_id = 172;

# Find the schema of the address table.
# Recreate it using the 'create table' query.

SHOW CREATE TABLE address;

# Use `JOIN` to display the first and last names, 
# as well as the address, of each staff member. 
# Use the tables `staff` and `address`:

SELECT s.first_name, s.last_name, a.address
FROM staff s
INNER JOIN address a
ON (s.address_id = a.address_id);

# Use `JOIN` to display the total amount rung up by each staff member in August of 2005. 
# Use tables `staff` and `payment`.
# Got stuck on this one. 

SELECT s.first_name, s.last_name, SUM(p.amount)
FROM staff AS s
# How do you calculate the total payment? 
# Call it by month and year 
GROUP BY s.staff_id;

# List each film and the number of actors who are 
# listed for that film. Use tables `film_actor` and `film`. 
# Use inner join.

SELECT f.title, COUNT(fa.actor_id) AS 'Actors'
FROM film_actor AS film_actor
INNER JOIN film as film
ON f.film_id = fa.film_id
GROUP BY f.title
ORDER BY Actors desc;

# How many copies of the film `Hunchback Impossible` exist in 
# the inventory system? (It's not a real movie, thankfully.) 

SELECT title, COUNT(inventory_id) AS '# of copies'
FROM film
INNER JOIN inventory
USING (film_id)
WHERE title = 'Hunchback Impossible'
GROUP BY title;

# Using the tables `payment` and `customer` 
# and the `JOIN` command, list the total paid by each customer. 
# List the customers alphabetically by last name.

SELECT c.first_name, c.last_name, SUM(p.amount) AS 'Total Amount Paid'
FROM payment AS p
INNER JOIN customer AS c
ON p.customer_id = c.customer_id
GROUP BY c.customer_id
ORDER BY c.last_name;

# Use subqueries to display the titles of movies 
# starting with the letters `K` and `Q` whose language is English.

SELECT title
FROM film
WHERE title LIKE 'K%'
OR title LIKE 'Q%'
AND language_id IN
(
 SELECT language_id
 FROM language
 WHERE name = 'English'
);

# Use subqueries to display all actors who appear in the film `Alone Trip`.

SELECT first_name, last_name
FROM actor
WHERE actor_id IN
(
SELECT actor_id
FROM film_actor
WHERE film_id =
(
 SELECT film_id
 FROM film
 WHERE title = 'Alone Trip'
)
 );

# You want to run an email marketing campaign in Canada, 
# for which you will need the names and email addresses of all 
# Canadian customers. Use joins to retrieve this information.
# First name, last name, email, country (canada) 

SELECT first_name, last_name, email, country
FROM customer cus
INNER JOIN address a
ON (cus.address_id = a.address_id)
INNER JOIN city cit
ON (a.city_id = cit.city_id)
INNER JOIN country ctr
ON (cit.country_id = ctr.country_id)
WHERE ctr.country = 'canada';

# Identify all movies categorized as _family_ films.

SELECT title, c.name
FROM film f
INNER JOIN film_category fc
ON (f.film_id = fc.film_id)
INNER JOIN category c
ON (c.category_id = fc.category_id)
WHERE name = 'family';

# Display the most frequently rented movies in descending order.

SELECT title, COUNT(title) as 'Rentals'
FROM film
INNER JOIN inventory
ON (film.film_id = inventory.film_id)
INNER JOIN rental
ON (inventory.inventory_id = rental.inventory_id)
GROUP by title
ORDER BY rentals desc;


# Write a query to display how much business, in dollars, each store brought in.
# Search for gross for each store from payment and group by store id.

SELECT s.store_id, SUM(amount) AS Gross
FROM payment payment
INNER JOIN rental rental
ON (payment.rental_id = rental.rental_id)
INNER JOIN inventory inventory
ON (inventory.inventory_id = rental.inventory_id)
INNER JOIN store store
ON (store.store_id = inventory.store_id)
GROUP BY store.store_id;

# Write a query to display for each store its store ID, city, and country.

SELECT store_id, city, country
FROM store s
INNER JOIN address a
ON (s.address_id = a.address_id)
INNER JOIN city cit
ON (cit.city_id = a.city_id)
INNER JOIN country ctr
ON(cit.country_id = ctr.country_id);

# List the top five genres in gross revenue in descending order. 
# Use category, film_category, inventory, payment, and rental.
# Figure this out. 

# In your new role as an executive, you would like to have an 
# easy way of viewing the Top five genres by gross revenue. 
# Use the solution from the problem above to create a view. 

CREATE VIEW top_five_genres AS
SELECT SUM(amount) AS 'Total Sales', c.name AS 'Genre'
FROM payment p
INNER JOIN rental r
ON (p.rental_id = r.rental_id)
INNER JOIN inventory i
ON (r.inventory_id = i.inventory_id)
INNER JOIN film_category fc
ON (i.film_id = fc.film_id)
INNER JOIN category c
ON (fc.category_id = c.category_id)
GROUP BY c.name
ORDER BY SUM(amount) DESC
LIMIT 5;

# Display the view created above. 

SELECT *
FROM top_five_genres;

# You find that you no longer need the view `top_five_genres`. 
# Write a query to delete it.

DROP VIEW top_five_genres;