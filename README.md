# 🎬 Netflix Data Analysis using SQL (PostgreSQL)

<p align="center">
  <img src="https://github.com/Dundigala-Bhargavi/Netflix-Data-Analysis-using-SQL-PostgreSQL-/blob/main/netflix_logo.png" 
       alt="Netflix Logo" 
       height="300" width="450" />
</p>


## 📘 Overview

This project presents a **comprehensive analysis of Netflix’s Movies and TV Shows dataset** using **PostgreSQL (SQL)**.  
The goal is to uncover meaningful insights and answer various business questions related to Netflix’s content library.  
This analysis focuses on identifying trends in content types, genres, ratings, countries, and key contributors.

### 🔍 Key Objectives
- Analyze the **distribution of content types** (Movies vs TV Shows).  
- Identify the **most common ratings** across both categories.  
- Examine content trends based on **release year, country, and duration**.  
- Explore and **categorize titles based on keywords** and thematic attributes.  
- Derive **business insights** to understand Netflix’s content strategy and audience reach.

## 📊 About the Dataset

The dataset used in this project is sourced from **[Kaggle – Netflix Movies and TV Shows Dataset](https://www.kaggle.com/shivamb/netflix-shows)**.  
It contains information about the Movies and TV Shows available on Netflix as of 2021.
 ## 🧩 Business Problems Solved

This project answers **15 real-world business questions** using advanced SQL queries in PostgreSQL.  

| No. | Business Problem | Description |
|:---:|:-----------------|:------------|
| **1** | Movies vs TV Shows | Count the number of Movies and TV Shows on Netflix. |
| **2** | Common Ratings | Identify the most common rating for both Movies and TV Shows. |
| **3** | Movies by Year | List all Movies released in a specific year (e.g., 2020). |
| **4** | Top Countries | Find the top 5 countries with the most content on Netflix. |
| **5** | Longest Movie | Identify the longest Movie by duration. |
| **6** | Recent Additions | Find all content added to Netflix in the last 5 years. |
| **7** | Director Analysis | List all Movies/TV Shows directed by *Rajiv Chilaka*. |
| **8** | TV Shows with 5+ Seasons | List all TV Shows that have more than 5 seasons. |
| **9** | Genre Distribution | Count the number of titles in each genre. |
| **10** | Indian Releases | Find each year and the average number of content releases in India. |
| **11** | Documentaries | List all Movies that are categorized as Documentaries. |
| **12** | Missing Directors | Find all content without a director. |
| **13** | Actor Analysis | Find how many Movies actor *Salman Khan* appeared in during the last 10 years. |
| **14** | Top Indian Actors | Find the top 10 actors with the highest number of Movies produced in India. |
| **15** | Content Categorization | Categorize content as *Good* or *Bad* based on keywords (“kill”, “violence”) in descriptions. |

---

### 🧠 Skills Demonstrated
- Data extraction, cleaning, and transformation using SQL.  
- String and array functions (`SPLIT_PART`, `STRING_TO_ARRAY`, `UNNEST`, `TRIM`).  
- Date manipulation with `TO_DATE`, `EXTRACT`, and `INTERVAL`.  
- Regular expressions (`~`, `~*`) for pattern matching.  
- Aggregation, filtering, and sorting to generate meaningful insights.  

## 💻 SQL Queries and Analysis

Below are the SQL queries used to solve each business problem, along with their objectives and purposes.

---

### 1️⃣ Count the Number of Movies vs TV Shows

```sql
SELECT 
    type,
    COUNT(*) AS total_contents
FROM netflix
GROUP BY 1;
```
Objective: Determine the distribution of content types (Movies vs TV Shows).
### 2️⃣ Find the Most Common Rating for Movies and TV Shows
```sql
select 
	type,
	rating
from
(
	select
	type,
		rating,
		count(*) as rating_count,
		rank() over(partition by type order by count(*) DESC) as ranking
	from netflix
	group by 1,2
) as t1
where ranking = 1
```
Objective: Identify the most common maturity rating for Movies and TV Shows.

### 3️⃣ List All Movies Released in a Specific Year (e.g., 2020)
```sql
select *from netflix
where 
    type= 'Movie'
    and 
    release_year= 2020
```
Objective: List all movies released in 2020.

### 4️⃣ Find the Top 5 Countries with the Most Content on Netflix
```sql
select 
    unnest(string_to_array(country, ',')) as new_country,
    count(show_id) as Total_content
from netflix
group by 1
Order By 2 Desc
limit 5
```
Objective: Identify the top countries by content count (splits comma-separated country values).
### 5️⃣ Identify the Longest Movie
```sql
select title, duration 
from netflix
where
	type= 'Movie'
	and  duration ~ '^\d+\s+min$'
order by split_part(duration,' ',1):: int Desc
limit 1
```
Objective: Find the movie with the maximum runtime (in minutes).

### 6️⃣ Find Content Added in the Last 5 Years
```sql
select * from netflix
where 
to_date(date_added,'Month DD, YYYY') >= current_date - Interval '5 years'
```
Objective: Retrieve titles added to Netflix in the last 5 years (based on date_added).

### 7️⃣ Find All Movies/TV Shows by Director 'Rajiv Chilaka'
```sql
Select *
From (
    Select
        *,
        UNNEST(STRING_TO_ARRAY(director, ',')) AS director_name
    FROM netflix
) AS t
Where director_name = 'Rajiv Chilaka';
```
Objective: List all titles where the director field contains 'Rajiv Chilaka'.

###8️⃣ List All TV Shows with More Than 5 Seasons
```sql 
SELECT *
from netflix 
where 
	type= 'TV Show'
	and
	split_part(duration,' ',1)::numeric > 5 
```
Objective: Return TV Shows with more than 5 seasons (extracts numeric part of duration).

### 9️⃣ Count the Number of Content Items in Each Genre
```sql
SELECT 
    unnest(string_to_array(listed_in, ',')) as genre,
    count(show_id) as total_content
from netflix 
Group by 1
```
Objective: Count how many titles belong to each genre (splits comma-separated listed_in).

### 1️⃣0️⃣ Find Each Year and the Average Number of Content Releases in India — Top 5 Years
``` sql
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
```
Objective: Show yearly counts and each year's share of total Indian content (returns top 5 by share).

### 1️⃣1️⃣ List All Movies that are Documentaries
``` sql
select 
*from netflix
where 
	type='Movie'
	and listed_in ILike '% Documentaries%'
```
Objective: Retrieve Movies categorized as Documentaries.

### 1️⃣2️⃣ Find All Content Without a Director
```sql
select 
*from netflix
where director is NULL or director=''
```
Objective: Show titles with missing or blank director field.

### 1️⃣3️⃣ Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years
```sql
select 
COUNT(*) AS total_movies
from netflix
where 
	type= 'Movie'
	and casts ILIKE '%Salman Khan%'
	and release_year >= Extract(year from current_date) :: INT - 9;
```
Objective: Count Movies featuring Salman Khan released in the last 10 years.

### 1️⃣4️⃣ Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India
```sql
select 
	unnest(string_to_array(casts,',')) as actors,
	count(*) as movie_count
from netflix
where country ILike '%India%'
group by actors
order by movie_count Desc
limit 10
```
Objective: Identify top actors by number of Indian movies (splits casts and counts per actor).

###  1️⃣5️⃣ Categorize Content Based on 'kill' and 'violence' Keywords in Description
```sql
with new_table -- Creating a CT (current table) 
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
```
Objective: Label content as Bad_Content if description contains 'kill' or 'violence', otherwise Good_Content, then count totals.
## 📊 Findings and Conclusion

**Content Distribution:**  
The dataset reveals a wide range of Movies and TV Shows, showcasing Netflix’s diverse content library across multiple genres, durations, and formats.

**Common Ratings:**  
The analysis of ratings highlights the most frequent maturity levels, providing insights into Netflix’s target audience and viewing preferences.

**Geographical Insights:**  
The findings emphasize Netflix’s global reach, with countries like the United States, India, and the United Kingdom contributing the most content.  
Additionally, analyzing India’s yearly content releases offers a deeper understanding of its growing role in regional production.

**Content Categorization:**  
Categorizing titles based on specific keywords such as *“kill”* and *“violence”* helps assess the tone and nature of Netflix’s content portfolio.

**Overall Conclusion:**  
This analysis provides a comprehensive overview of Netflix’s catalog, revealing patterns in content type, audience focus, and regional distribution.  
The insights gained can support data-driven **content strategy**, **audience targeting**, and **decision-making** for streaming and entertainment analytics.
