-- Movie Database Joins Exercise
-- See the file movies_erd for table and column info.
-- 1.	Give the name, release year, and worldwide gross of the lowest grossing movie.
--Need: name, release year, worldwide gross
--specs.film_title, specs.realease_year, revenue.worldwide_gross

SELECT 
	specs.film_title,
	specs.release_year,
	revenue.worldwide_gross
FROM specs
LEFT JOIN revenue
ON specs.movie_id = revenue.movie_id
ORDER BY worldwide_gross 
LIMIT 1;
--ANSWER: Semi-Tough, 1977, $37,187,139

-- 2.	What year has the highest average imdb rating?
--specs.release_year, rating.AVG(imdb_rating) AS avg_rating

SELECT
	specs.release_year,
	ROUND(AVG(imdb_rating),2) AS avg_rating
FROM specs
LEFT JOIN rating
ON specs.movie_id = rating.movie_id
GROUP BY specs.release_year
ORDER BY avg_rating DESC;
--ANSWER: 1991 average rating of 7.45


-- 3.	What is the highest grossing G-rated movie? Which company distributed it?
--specs.film_title,revenue.worldwide_gross, distributors.company_name

SELECT
	specs.film_title,
	revenue.worldwide_gross,
	distributors.company_name
FROM specs
INNER JOIN revenue
	ON specs.movie_id = revenue.movie_id
INNER JOIN distributors
	ON specs.domestic_distributor_id = distributors.distributor_id
WHERE specs.mpaa_rating = 'G'
ORDER BY revenue.worldwide_gross DESC;
--ANSWER: Toy Story 4, distributed by Walt Disney

-- 4.	Write a query that returns, for each distributor in the distributors table, the distributor name 
--		and the number of movies associated with that distributor in the movies table. 
--		Your result set should include all of the distributors, whether or not they have any movies in the movies table.
--distributors.company_name, specs.COUNT(movie_id) 

SELECT
	COUNT(movie_id) AS total_movies,
	distributors.company_name
FROM specs
RIGHT JOIN distributors
ON specs.domestic_distributor_id = distributors.distributor_id
GROUP BY distributors.company_name
ORDER BY total_movies DESC;
--This worked, but below is better.

SELECT
	distributors.company_name,
	COUNT(movie_id) AS total_movies
FROM distributors
LEFT JOIN specs
ON distributors.distributor_id = specs.domestic_distributor_id
GROUP BY distributors.company_name
ORDER BY total_movies DESC;
--Answer:	

-- 5.	Write a query that returns the five distributors with the highest average movie budget.
--distributors.company_name, AVG(film_budget)--use specs to get common column

SELECT
	distributors.company_name,
	ROUND(AVG(film_budget), 2) AS avg_film_budget
FROM distributors
LEFT JOIN specs
ON distributors.distributor_id = specs.domestic_distributor_id
LEFT JOIN revenue
ON specs.movie_id = revenue.movie_id
WHERE revenue.film_budget IS NOT NULL
GROUP BY distributors.company_name
ORDER BY avg_film_budget DESC
LIMIT 5;
--Answer: Walt Disney, Sony Pictures, Lionsgate, DreamWorks, Warner Bros.

-- 6.	How many movies in the dataset are distributed by a company which is not headquartered in California? 
--		Which of these movies has the highest imdb rating?
--distributors.company_name, distributors.headquarters, specs COUNT(movie_id), rating.imdb_rating

SELECT
	distributors.company_name,
	distributors.headquarters,
	specs.film_title,
	COUNT(specs.movie_id) AS no_cal_movies,
	rating.imdb_rating
FROM distributors 
JOIN specs
ON distributors.distributor_id = specs.domestic_distributor_id
JOIN rating
ON specs.movie_id = rating.movie_id
WHERE distributors.headquarters NOT LIKE '%, CA'
GROUP BY distributors.company_name, distributors.headquarters, specs.film_title, rating.imdb_rating
ORDER BY no_cal_movies DESC,
--Answer: 2, Dirty Dancing

-- 7.	Which have a higher average rating, movies which are over two hours long or movies which are under two hours?
--specs.length_in_min, , rating.imdb_rating

SELECT
	ROUND(AVG(imdb_rating), 2) AS avg_rating,
	ROUND(s.length_in_min/60.0) > 2 AS over_two_hours,
	ROUND(s.length_in_min/60.0) < 2 AS under_two_hours
FROM rating r
LEFT JOIN specs s
USING (movie_id)
GROUP BY s.length_in_min
ORDER BY avg_rating DESC;
--Answer: Movies over 2 hours have higher IMDB ratings

-- ## Joins Exercise Bonus Questions

-- 1.	Find the total worldwide gross and average imdb rating by decade. 
--		Then alter your query so it returns JUST the second highest average imdb rating and its decade. 
--		This should result in a table with just one row.
--revenue.worldwide_gross, rating.imdb_rating, specs.release_year

SELECT 
	(s.release_year/10) * 10 AS decade,
	SUM(r.worldwide_gross) AS total_gross,
	ROUND(AVG(r2.imdb_rating), 2) AS avg_rating
FROM specs s
LEFT JOIN revenue r
USING (movie_id)
LEFT JOIN rating r2
USING (movie_id)
GROUP BY decade
ORDER BY avg_rating DESC
LIMIT 1 OFFSET 1;
--Answer: 1990, avg_rating 7.10
	
-- 2.	Our goal in this question is to compare the worldwide gross for movies compared to their sequels.   
-- 	a.	Start by finding all movies whose titles end with a space and then the number 2.  

SELECT film_title
FROM specs
WHERE film_title LIKE '% 2' 
--18 rows

-- 	b.	For each of these movies, create a new column showing the original film’s name 
--		by removing the last two characters of the film title. 
--		For example, for the film “Cars 2”, the original title would be “Cars”. 
--		Hint: You may find the string functions listed in Table 9-10 of 
--		https://www.postgresql.org/docs/current/functions-string.html to be helpful for this. 

SELECT 
	film_title AS sequel_title,
	TRIM(TRAILING ' 2' FROM film_title) AS original_title
FROM specs
WHERE film_title LIKE '% 2';
____
SELECT
	film_title AS sequel_title,
	RTRIM (film_title, ' 2') AS original_title
FROM specs
WHERe film_title LIKE '% 2';

-- 	c.	Bonus: This method will not work for movies like “Harry Potter and the Deathly Hallows: Part 2”, 
--		where the original title should be “Harry Potter and the Deathly Hallows: Part 1”. 
--		Modify your query to fix these issues.  

-- 		alias the table so it can be self joined, regexp_replace = regular expression replaced. 
--		So, regexp_replace(sequel.film_title, ' 2$', '') takes the resulting expression from sequel.film_title 
--		which is identified by the ' 2' and replaces it with empty characters ''.

SELECT 
	original.film_title AS original_title,
	sequel.film_title AS sequel_title
FROM specs sequel
JOIN specs original
	ON original.film_title = regexp_replace(sequel.film_title, ' 2$', '')
WHERE sequel.film_title LIKE '% 2';

-- 	d.	Now, build off of the query you wrote for the previous part to pull in worldwide revenue for both the original movie 
--		and its sequel. Do sequels tend to make more in revenue? Hint: You will likely need to perform a 
--		self-join on the specs table in order to get the movie_id values for both the original films and their sequels. 
--		Bonus: A common data entry problem is trailing whitespace. In this dataset, it shows up in the film_title field, 
--		where the movie “Deadpool” is recorded as “Deadpool “. One way to fix this problem is to use the TRIM function. 
--		Incorporate this into your query to ensure that you are matching as many sequels as possible.


-- 3.	Sometimes movie series can be found by looking for titles that contain a colon. For example, 
--		Transformers: Dark of the Moon is part of the Transformers series of films.  
-- 	a.	Write a query which, for each film will extract the portion of the film name that occurs before the colon. 
--		For example, “Transformers: Dark of the Moon” should result in “Transformers”.  If the film title does not 
--		contain a colon, it should return the full film name. For example, “Transformers” should result in “Transformers”. 
--		Your query should return two columns, the film_title and the extracted value in a column named series. 
--		Hint: You may find the split_part function useful for this task.


-- 	b.	Keep only rows which actually belong to a series. Your results should not include “Shark Tale” but should 
--		include both “Transformers” and “Transformers: Dark of the Moon”. 
--		Hint: to accomplish this task, you could use a WHERE clause which checks whether the film title either 
--		contains a colon or is in the list of series values for films that do contain a colon.  


-- 	c.	Which film series contains the most installments?  


-- 	d.	Which film series has the highest average imdb rating? Which has the lowest average imdb rating?


-- 4.	How many film titles contain the word “the” either upper or lowercase? 

SELECT
	COUNT(s.film_title) 
FROM specs s
WHERE film_title iLIKE '% The %';
--Answer: 75

--		How many contain it twice? three times? four times? 
--		Hint: Look at the sting functions and operators here: https://www.postgresql.org/docs/current/functions-string.html 

SELECT 
	COUNT(s.film_title) AS the_twice
FROM specs s
WHERE(length(lower(film_title)) - length(replace(lower(film_title), 'the', '')))/3 = 2;

SELECT 
	COUNT(s.film_title) AS the_thrice
FROM specs s
WHERE(length(lower(film_title)) - length(replace(lower(film_title), 'the', '')))/3 = 3;

SELECT 
	COUNT(s.film_title) AS the_quad
FROM specs s
WHERE(length(lower(film_title)) - length(replace(lower(film_title), 'the', '')))/3 = 4;

--To see film titles, not count
SELECT 
	s.film_title
FROM specs s
WHERE(length(lower(film_title)) - length(replace(lower(film_title), 'the', '')))/3 = 4;
--Answer: At least once-75, Twice-12, Thrice-3, Quad-3

-- 5.	For each distributor, find its highest rated movie. Report the company name, the film title, and the imdb rating. 
--		Hint: you may find the LATERAL keyword useful for this question. This keyword allows you to join two or more 
--		tables together and to reference columns provided by preceding FROM items in later items. 
--		See this article for examples of lateral joins in postgres: 
--		https://www.cybertec-postgresql.com/en/understanding-lateral-joins-in-postgresql/ 

-- 6.	Follow-up: Another way to answer 5 is to use DISTINCT ON so that your query returns only one row per company. 
--		You can read about DISTINCT ON on this page: https://www.postgresql.org/docs/current/sql-select.html. 

-- 7.	Which distributors had movies in the dataset that were released in consecutive years? 
--		For example, Orion Pictures released Dances with Wolves in 1990 and The Silence of the Lambs in 1991. 
--		Hint: Join the specs table to itself and think carefully about what you want to join ON. 
--specs.domestic_distributor_id, specs.release_year, specs.film_title

SELECT
	d.company_name,
	s1.film_title AS film_year1,
	s1.release_year AS year1,
	s2.film_title AS film_year2,
	s2.release_year AS year2
FROM specs s1
JOIN specs s2
	ON s1.domestic_distributor_id = s2.domestic_distributor_id
	AND s1.release_year +1 = s2.release_year
JOIN distributors d
	ON s1.domestic_distributor_id = d.distributor_id

