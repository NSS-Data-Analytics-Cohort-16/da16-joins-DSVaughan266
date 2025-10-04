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
ORDER BY avg_rating DESC
--ANSWER: 1991 average rating of 7.45


-- 3.	What is the highest grossing G-rated movie? Which company distributed it?
--specs.film_title,revenue.worldwide_gross, distributors.company_name

SELECT
	specs.film_title,
	revenue.worldwide_gross,
	distributors.company_name
FROM specs
INNER JOIN rating
	ON specs.movie_id = rating.movie_id
INNER JOIN revenue
	ON specs.movie_id = revenue.movie_id
INNER JOIN distributors
	ON specs.domestic_distributor_id = distributors.distributor_id
WHERE specs.mpaa_rating = 'G'
ORDER BY revenue.worldwide_gross DESC
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
LIMIT 5
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
ORDER BY no_cal_movies DESC
--Answer: 2, Dirty Dancing


-- 7.	Which have a higher average rating, movies which are over two hours long or movies which are under two hours?
--specs.length_in_min, , rating.imdb_rating

SELECT
	specs.length_in_min/60.0 > 2 AS over_two_hours,
	specs.length_in_min/60.0 < 2 AS under_two_hours,
	ROUND(AVG(imdb_rating), 2) AS avg_rating
FROM specs
LEFT JOIN rating
USING (movie_id)
GROUP BY specs.length_in_min
ORDER BY avg_rating DESC;
	

SELECT
	ROUND(AVG(r.imdb_rating),2) AS avg_rating
	ROUND(s.length_in_min/60.0) > 2 AS over_two_hours,
	ROUND(s.legth_in_min/60.0) < 2 AS under_two_hours
FROM specs s
LEFT JOIN rating r
	USING (movie_id)
GROUP BY s.length_in_min
ORDER BY avg_rating DESC;