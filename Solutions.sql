-- CREATE A TABLE 

DROP TABLE IF EXISTS netflix;
CREATE TABLE netflix
(
    show_id      VARCHAR(5),
    type         VARCHAR(10),
    title        VARCHAR(250),
    director     VARCHAR(550),
    casts        VARCHAR(1050),
    country      VARCHAR(550),
    date_added   VARCHAR(55),
    release_year INT,
    rating       VARCHAR(15),
    duration     VARCHAR(15),
    listed_in    VARCHAR(250),
    description  VARCHAR(550)
);

SELECT * FROM netflix ; 

-- 15 Business Problems & Solutions

-- 1. Count the number of Movies vs TV Shows

SELECT 
    type,
    COUNT(*) AS total_count
FROM netflix
GROUP BY type;


-- 2. Find the most common rating for movies and TV shows

WITH RatingCounts AS (
    SELECT 
        type,
        rating,
        COUNT(*) AS rating_count
    FROM netflix
    GROUP BY type, rating
),
RankedRatings AS (
    SELECT 
        type,
        rating,
        rating_count,
        RANK() OVER (PARTITION BY type ORDER BY rating_count DESC) AS rank_value
    FROM RatingCounts
)
SELECT 
    type,
    rating AS most_frequent_rating
FROM RankedRatings
WHERE rank_value = 1;


-- 3. List all movies released in a specific year (e.g., 2020)

SELECT * 
FROM netflix
WHERE release_year = 2020;


-- 4. Find the top 5 countries with the most content on Netflix

SELECT 
    country,
    COUNT(*) AS total_content
FROM netflix
WHERE country IS NOT NULL
GROUP BY country
ORDER BY total_content DESC
LIMIT 5;


-- 5. Identify the longest movie

SELECT *
FROM netflix
WHERE type = 'Movie'
ORDER BY CAST(SUBSTRING_INDEX(duration, ' ', 1) AS UNSIGNED) DESC;


-- 6. Find content added in the last 5 years

SELECT *
FROM netflix
WHERE STR_TO_DATE(date_added, '%M %d, %Y') >= DATE_SUB(CURDATE(), INTERVAL 5 YEAR);


-- 7. Find all the movies/TV shows by director 'Rajiv Chilaka'!

SELECT *
FROM netflix
WHERE FIND_IN_SET('Rajiv Chilaka', director) > 0;


-- 8. List all TV shows with more than 5 seasons

SELECT *
FROM netflix
WHERE 
    type = 'TV Show'
    AND CAST(SUBSTRING_INDEX(duration, ' ', 1) AS UNSIGNED) > 5;


-- 9. Count the number of content items in each genre

SELECT 
    genre,
    COUNT(*) AS total_content
FROM (
    SELECT SUBSTRING_INDEX(SUBSTRING_INDEX(listed_in, ',', n), ',', -1) AS genre
    FROM netflix
    JOIN (SELECT 1 AS n UNION SELECT 2 UNION SELECT 3) numbers
) AS genre_list
GROUP BY genre;


-- 10.Find each year and the average numbers of content release in India on netflix. 
-- return top 5 year with highest avg content release!

SELECT 
    release_year,
    COUNT(*) AS total_release,
    ROUND((COUNT(*) / (SELECT COUNT(*) FROM netflix WHERE country = 'India')) * 100, 2) AS avg_release
FROM netflix
WHERE country = 'India'
GROUP BY release_year
ORDER BY avg_release DESC
LIMIT 5;

-- 11. List all movies that are documentaries

SELECT * FROM netflix
WHERE listed_in LIKE '%Documentaries%';


-- 12. Find all content without a director

SELECT * FROM netflix
WHERE director IS NULL OR director = '';


-- 13. Find how many movies actor 'Salman Khan' appeared in last 10 years!

SELECT * FROM netflix
WHERE 
    casts LIKE '%Salman Khan%'
    AND release_year > YEAR(CURDATE()) - 10;


-- 14. Find the top 10 actors who have appeared in the highest number of movies produced in India.

SELECT 
    actor,
    COUNT(*) AS total_movies
FROM (
    SELECT SUBSTRING_INDEX(SUBSTRING_INDEX(casts, ',', n), ',', -1) AS actor
    FROM netflix
    JOIN (SELECT 1 AS n UNION SELECT 2 UNION SELECT 3 UNION SELECT 4) numbers
    WHERE country = 'India'
) AS actor_list
GROUP BY actor
ORDER BY total_movies DESC
LIMIT 10;


-- 15.Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
-- the description field. Label content containing these keywords as 'Bad' and all other 
-- content as 'Good'. Count how many items fall into each category.

SELECT 
    category,
    type,
    COUNT(*) AS content_count
FROM (
    SELECT 
        *,
        CASE 
            WHEN LOWER(description) LIKE '%kill%' OR LOWER(description) LIKE '%violence%' THEN 'Bad'
            ELSE 'Good'
        END AS category
    FROM netflix
) AS categorized_content
GROUP BY category, type
ORDER BY type;




