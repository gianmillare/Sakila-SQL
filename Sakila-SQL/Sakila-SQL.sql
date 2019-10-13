USE sakila;

# Display All Data
SELECT *
FROM actor;

# 1A. Display the first and last names of all actors from the table `actor`.
SELECT first_name, last_name
FROM actor;

# 1B. Display the first and last name of each actor in a single column in upper case letters. Name the column `Actor Name`.
SELECT concat(first_name, ' ' , last_name) 
AS 'Actor Name' 
FROM actor;

# 2A. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." 
# What is one query would you use to obtain this information?
SELECT actor_id, first_name, last_name
FROM actor
WHERE first_name = 'JOE';

# 2B. Find all actors whose last name contain the letters `GEN`
SELECT actor_id, first_name, last_name
FROM actor
WHERE last_name
LIKE '%GEN';

# 2C. Find all actors whose last names contain the letters `LI`. This time, order the rows by last name and first name, in that order
SELECT last_name, first_name
FROM actor
WHERE last_name
LIKE '%LI%';

# Display All Data
SELECT *
FROM country;

# 2D. Using `IN`, display the `country_id` and `country` columns of the following countries: Afghanistan, Bangladesh, and China
SELECT country_id, country
FROM country
WHERE country IN ('Afghanistan', 'Bangladesh', 'China');

# 3A. You want to keep a description of each actor. You don't think you will be performing queries on a description, so create a 
# column in the table `actor` named `description` and use the data type `BLOB`
	### https://stackoverflow.com/questions/5414551/what-is-it-exactly-a-blob-in-a-dbms-context
	### BLOB ---> Binary Large Object = can store large amounts of data 
    
SELECT *
FROM actor;

ALTER TABLE actor
ADD description
BLOB(500);

# 3B. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the `description` column.
SELECT *
FROM actor;

ALTER TABLE actor
DROP description;

# 4A. List the last names of actors, as well as how many actors have that last name
SELECT last_name, count(last_name)
FROM actor
GROUP BY last_name;

# 4B. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
SELECT last_name, count(last_name)
FROM actor
GROUP BY last_name
HAVING count(last_name) >= 2;

# 4C. The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as `GROUCHO WILLIAMS`. Write a query to fix the record.

SELECT *
FROM actor
WHERE last_name = 'WILLIAMS';

SET SQL_SAFE_UPDATES=0;

UPDATE actor
SET first_name = 'HARPO'
WHERE first_name = 'GROUCHO'
AND last_name = 'WILLIAMS';

SELECT *
FROM actor
WHERE last_name = 'WILLIAMS';

SET SQL_SAFE_UPDATES=1;

# 4D. Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. It turns out that `GROUCHO` was the correct name after all! 
# In a single query, if the first name of the actor is currently `HARPO`, change it to `GROUCHO`.
SELECT *
FROM actor
WHERE last_name = 'WILLIAMS';

SET SQL_SAFE_UPDATES=0;

UPDATE actor
SET first_name = 'GROUCHO'
WHERE first_name = 'HARPO'
AND last_name = 'WILLIAMS';

SELECT *
FROM actor
WHERE last_name = 'WILLIAMS';

SET SQL_SAFE_UPDATES=1;

# 5A. You cannot locate the schema of the `address` table. Which query would you use to re-create it?
SHOW CREATE TABLE address;

CREATE TABLE `address` (
  `address_id` smallint(5) unsigned NOT NULL AUTO_INCREMENT,
  `address` varchar(50) NOT NULL,
  `address2` varchar(50) DEFAULT NULL,
  `district` varchar(20) NOT NULL,
  `city_id` smallint(5) unsigned NOT NULL,
  `postal_code` varchar(10) DEFAULT NULL,
  `phone` varchar(20) NOT NULL,
  `location` geometry NOT NULL,
  `last_update` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`address_id`),
  KEY `idx_fk_city_id` (`city_id`),
  SPATIAL KEY `idx_location` (`location`),
  CONSTRAINT `fk_address_city` FOREIGN KEY (`city_id`) REFERENCES `city` (`city_id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=606 DEFAULT CHARSET=utf8;

SELECT *
FROM address;

# 6A. Use `JOIN` to display the first and last names, as well as the address, of each staff member. Use the tables `staff` and `address`
SHOW CREATE TABLE staff;

CREATE TABLE `staff` (
  `staff_id` tinyint(3) unsigned NOT NULL AUTO_INCREMENT,
  `first_name` varchar(45) NOT NULL,
  `last_name` varchar(45) NOT NULL,
  `address_id` smallint(5) unsigned NOT NULL,
  `picture` blob,
  `email` varchar(50) DEFAULT NULL,
  `store_id` tinyint(3) unsigned NOT NULL,
  `active` tinyint(1) NOT NULL DEFAULT '1',
  `username` varchar(16) NOT NULL,
  `password` varchar(40) CHARACTER SET utf8 COLLATE utf8_bin DEFAULT NULL,
  `last_update` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`staff_id`),
  KEY `idx_fk_store_id` (`store_id`),
  KEY `idx_fk_address_id` (`address_id`),
  CONSTRAINT `fk_staff_address` FOREIGN KEY (`address_id`) REFERENCES `address` (`address_id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_staff_store` FOREIGN KEY (`store_id`) REFERENCES `store` (`store_id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8;

SELECT *
FROM staff; 

SELECT staff.first_name, staff.last_name, address.address
FROM staff
JOIN address ON staff.address_id = address.address_id;

# 6B. Use `JOIN` to display the total amount rung up by each staff member in August of 2005. Use tables `staff` and `payment`.
SELECT *
FROM staff;

SELECT *
FROM payment;
		-- ANY OF THE BELOW CODES PROVIDE THE SAME OUTPUT
SELECT staff.staff_id, staff.first_name, staff.last_name, SUM(payment.amount)
FROM staff
INNER JOIN payment on staff.staff_id = payment.staff_id
WHERE MONTH(payment.payment_date) = 08 AND YEAR(payment.payment_date)=2005
GROUP BY staff.staff_id;

SELECT staff.staff_id, staff.first_name, staff.last_name, SUM(payment.amount)
FROM staff
INNER JOIN payment on staff.staff_id = payment.staff_id
AND payment.payment_date LIKE '2005-08%'
GROUP BY staff.staff_id;

# 6C. List each film and the number of actors who are listed for that film. Use tables `film_actor` and `film`. Use inner join.
SELECT *
FROM film;

SELECT *
FROM film_actor;


            -- ANY OF THE BELOW CODES PROVIDE THE SAME OUTPUT
SELECT film.title, COUNT(film_actor.actor_id)
FROM film
INNER JOIN film_actor 
ON film.film_id = film_actor.film_id
GROUP BY film.film_id;

SELECT film.title, COUNT(film_actor.actor_id)
FROM film_actor
INNER JOIN film
ON film_actor.film_id = film.film_id
GROUP BY film.title;

# 6D. How many copies of the film `Hunchback Impossible` exist in the inventory system?
SELECT *
FROM inventory;

SELECT film.title, COUNT(inventory.film_id)
FROM film
INNER JOIN inventory
ON film.film_id = inventory.film_id
GROUP BY film.film_id
HAVING film.title = "Hunchback Impossible";

# 6E. Using the tables `payment` and `customer` and the `JOIN` command, list the total paid by each customer. List the customers alphabetically by last name
SELECT *
FROM payment;

SELECT *
FROM customer;

SELECT customer.first_name, customer.last_name, SUM(payment.amount)
FROM customer
JOIN payment 
ON customer.customer_id = payment.customer_id
GROUP BY customer.customer_id
ORDER BY customer.last_name;

# 7A. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters `K` and `Q` 
# have also soared in popularity. Use subqueries to display the titles of movies starting with the letters `K` and `Q` whose language is English.

SELECT *
FROM film;

SELECT *
FROM language;

SELECT title
FROM film
WHERE language_id 
IN 
	(SELECT language_id
	FROM language
	WHERE name = 'English')
AND title LIKE 'K%'
OR title LIKE 'Q%';

# 7B. Use subqueries to display all actors who appear in the film `Alone Trip`.
SELECT *
FROM actor;

SELECT *
FROM film_actor;

SELECT *
FROM film;

SELECT first_name, last_name 
FROM actor
WHERE actor_id
	IN (SELECT actor_id
	FROM film_actor
	WHERE film_id
		IN (SELECT film_id
        FROM film
        WHERE title = 'Alone Trip'));

# 7C. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.
SELECT *
FROM country;

SELECT *
FROM customer;

SELECT *
FROM address;

SELECT *
FROM city;

SELECT customer.first_name, customer.last_name, customer.email
FROM customer
INNER JOIN address
ON customer.address_id = address.address_id
INNER JOIN city
ON address.city_id = city.city_id
INNER JOIN country
ON city.country_id = country.country_id
WHERE country.country = 'Canada'
GROUP BY customer.first_name, customer.last_name, customer.email;

# 7D. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as _family_ films.
SELECT *
FROM film;

SELECT *
FROM film_category;

SELECT *
FROM category;

SELECT title, description, rating
FROM film
WHERE film_id
	IN (SELECT film_id
    FROM film_category
    WHERE category_id
		IN (SELECT category_id
        FROM category
        WHERE name = 'Family'));

# 7E. Display the most frequently rented movies in descending order
SELECT *
FROM film;

SELECT *
FROM inventory;

SELECT *
FROM rental;

SELECT title, COUNT(rental.rental_id) AS 'Times Rented'
FROM film
INNER JOIN inventory
ON film.film_id = inventory.film_id
INNER JOIN rental
ON inventory.inventory_id = rental.inventory_id
GROUP BY title
ORDER BY COUNT(rental.rental_id) desc;
# https://www.w3schools.com/sql/sql_orderby.asp

# 7F. Write a query to display how much business, in dollars, each store brought in.
SELECT *
FROM payment;

SELECT *
FROM store;

SELECT *
FROM customer;

SELECT store.store_id, SUM(payment.amount)
FROM store
INNER JOIN customer
ON store.store_id = customer.store_id
INNER JOIN payment
ON customer.customer_id = payment.customer_id
GROUP BY store.store_id;


# 7G. Write a query to display for each store its store ID, city, and country.
SELECT *
FROM store;

SELECT *
FROM address;

SELECT *
FROM city;

SELECT *
FROM country;

SELECT store.store_id, city.city, country.country
FROM store
INNER JOIN address
ON store.address_id = address.address_id
INNER JOIN city
ON address.city_id = city.city_id
INNER JOIN country
ON city.country_id = country.country_id
GROUP BY store.store_id, city.city, country.country;

# 7H. List the top five genres in gross revenue in descending order. (**Hint**: you may need to use the following tables: category, film_category, inventory, payment, and rental)
SELECT *
FROM category;
SELECT *
FROM film_category;
SELECT *
FROM inventory;
SELECT *
FROM rental;
SELECT *
FROM payment;

SELECT category.name, SUM(payment.amount)
FROM category
INNER JOIN film_category
ON category.category_id = film_category.category_id
INNER JOIN inventory
ON film_category.film_id = inventory.film_id
INNER JOIN rental
ON inventory.inventory_id = rental.inventory_id
INNER JOIN payment
ON rental.rental_id = payment.rental_id
GROUP BY category.name
ORDER BY SUM(payment.amount) desc LIMIT 10;

# 8A. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. 
# Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view
-- https://www.1keydata.com/sql/sql-create-view.html
CREATE VIEW TOP_5_GROSSING_FILMS AS
SELECT category.name, SUM(payment.amount)
FROM category
INNER JOIN film_category
ON category.category_id = film_category.category_id
INNER JOIN inventory
ON film_category.film_id = inventory.film_id
INNER JOIN rental
ON inventory.inventory_id = rental.inventory_id
INNER JOIN payment
ON rental.rental_id = payment.rental_id
GROUP BY category.name
ORDER BY SUM(payment.amount) desc LIMIT 10;

# 8B. How would you display the view that you created in 8a?
SELECT *
FROM TOP_5_GROSSING_FILMS;

# 8C. You find that you no longer need the view `top_five_genres`. Write a query to delete it.
DROP VIEW TOP_5_GROSSING_FILMS;

#-----------------------------------------------------------------