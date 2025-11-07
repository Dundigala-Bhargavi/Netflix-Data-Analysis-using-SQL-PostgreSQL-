create table netflix
(
show_id	varchar(6),
type varchar(10),	
title varchar(150),	
director varchar(208),	
casts varchar(1000),
country	varchar(150),
date_added varchar(50),	
release_year INT,
rating varchar(10),
duration varchar(15),	
listed_in varchar(100),	
description varchar(250)
);
select * from netflix;

select count(*) as total_contents
from netflix;

select 
distinct type
from netflix;

-- 1. Count the number of Movies and TV shows

select 
type,
count(*) as total_contents
from netflix
group by type;

-- 2. Find the most common rating for movies and TV shows
-- (we can not do min or max since they are text form, so we have to count the values)
-- Using groupby and window functions

select 
type,
rating
from
(
	select
	type,
	rating,
	count(*),
	rank() over(partition by type order by count(*) DESC) as ranking
	from netflix
	group by 1,2
) as t1
where ranking = 1
--order by 1,3 Desc

-- 3. List all the movies released in a specific year

select *from netflix
where 
	type= 'Movie'
	and 
	release_year= 2020

-- 4. Find the top 5 countries with the most content on Netflix

/*In the dataset, the country column is comma-separated.
Example: "United States, India, United Kingdom"
So, one row can list multiple countries.
If you just group by country, you’ll treat that whole string as one value — which is wrong.
We need to split this text into individual countries before counting.
STRING_TO_ARRAY(country, ',')
This converts "India, United States" → {India, United States} (a PostgreSQL array).
It uses, as the delimiter.
UNNEST takes an array and turns it into multiple rows.So now, if one Netflix title is available in 3 countries, that one row becomes 3 rows — one per country.
Each of those rows inherits the original COUNT(*) grouping logic.
*/

select 
	unnest(string_to_array(country, ',')) as new_country,
	count(show_id) as Total_content
from netflix
group by 1
Order By 2 Desc
limit 5

-- 5. Identify the longest movie
/* 
The duration column is stored as text, not numbers
Focus only on Movies, extract the number of minutes from that text.
Sort by the duration number (largest first). Return the top 1 record (the longest movie).
*/
select title, duration 
from netflix
where
type= 'Movie'
and  duration ~ '^\d+\s+min$'
order by split_part(duration,' ',1):: int Desc
limit 1
-- Regex filter (~) keeps only durations like '90 min'
-- ^\d+\s+min$ → start → digits → space → 'min' → end Ensures only valid minute-based movies are included
-- split_part(duration,' ',1):: int → extracts numeric part ('90') and converts to integer
-- ORDER BY ... DESC → sorts by longest duration (highest minutes first)

-- Find the  content added in the last 5 years
select * from netflix
where 
to_date(date_added,'Month DD, YYYY') >= current_date - Interval '5 years'
-- Converts date_added text to DATE format
-- Filters content added within last 5 years from current date


-- 7. Find All Movies/TV Shows by Director 'Rajiv Chilaka'
select * from netflix
where director ILike '%Rajiv Chilaka%'

-- some movies have more than one director, hence where director= 'Rajiv Chilaka' can't fetch all the records
-- ILIKE is case-insensitive (matches 'rajiv chilaka' or 'RAJIV CHILAKA')
-- Returns all Movies and TV Shows directed by Rajiv Chilaka

8. List All TV Shows with More Than 5 Seasons
-- we only need the number before season (Eg 4Seasons)
SELECT *
from netflix 
where 
type= 'TV Show'
and
split_part(duration,' ',1)::numeric > 5 
-- Filters only TV Shows with more than 5 seasons
-- SPLIT_PART() extracts the number before 'Season(s)'
--:: INT converts it to an integer for numeric comparison

-- 9. Count the Number of Content Items in Each Genre
SELECT 
	unnest(string_to_array(listed_in, ',')) as genre,
	count(show_id) as total_content
from netflix 
Group by 1
-- Splits 'listed_in' (genres) into individual genre rows using UNNEST()
-- Counts how many titles belong to each genre
-- GROUP BY 1 groups results by genre

-- 10. Find each year and the average number of content release in India on netflix.
--return top 5 year with highest avg content release!
SELECT 
    country,
    release_year,
    COUNT(show_id) AS total_release,
    ROUND(
        COUNT(show_id)::numeric /
        (SELECT COUNT(show_id) FROM netflix WHERE country = 'India')::numeric * 100, 2
    ) AS avg_release
FROM netflix
WHERE country = 'India'
GROUP BY country, release_year
ORDER BY avg_release DESC
LIMIT 5;

-- 11. List All Movies that are 11. List All Movies that are Documentaries
select 
*from netflix
where 
type='Movie'
and listed_in ILike '% Documentaries%'

-- 12. Find All Content Without a Director
select 
*from netflix
where director is NULL or director=''

-- 13. Find how many movies actor 'Salman Khan' appeared in last ten years
select 
COUNT(*) AS total_movies
from netflix
where 
type= 'Movie'
and casts ILIKE '%Salman Khan%'
and release_year >= Extract(year from current_date) :: INT - 9;
-- Counts total number of Movies featuring 'Salman Khan' released in the last 10 years
-- Filters only 'Movie' type and compares release_year using CURRENT_DATE

-- 14. Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India

select 
unnest(string_to_array(casts,',')) as actors,
count(*) as movie_count
from netflix
where country ILike '%India%'
group by actors
order by movie_count Desc
limit 10
-- Splits 'cast' column into individual actor names using UNNEST()
-- Counts the number of Movies each actor appeared in from India
-- Orders by highest count and returns the top 10 actors

-- 15.Categorise Content Based on the Presence of 'Kill' and 'Violence' Keywords in description field
-- Categorise content as 'Bad' if it contains 'kill' or 'violence' and 'Good' otherwise. Count the number of items in each category.
with new_table -- Creating a CT (current table) --> new table
as
(
select *,
	case 
	when
		description Ilike '%kill%' or
		description Ilike '%Violence%' then 'Bad_Content'
		else 'Good_Content'
	End category
from netflix	
)
select 
category,
count(*) as total_content
from new_table
group by 1