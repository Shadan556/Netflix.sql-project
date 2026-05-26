  #netflix datasets through sql
# Netflix SQL Data Analysis Project

## Overview

This project is based on Netflix dataset where i perform different SQL queries for data analysis and learning purpose. In this project i use many SQL concepts like filtering, grouping, aggregate functions, string functions, CTEs, subqueries and joins.
Main purpose of this project was improving my SQL skills with real world dataset.



## Tools Used

* MySQL
* Netflix Dataset
* SQL



## What i Learn From This Project

* Data Cleaning in SQL
* Working with NULL values
* Using GROUP BY and ORDER BY
* Aggregate functions like COUNT(), AVG(), MAX()
* String functions
* CTE (Common Table Expression)
* Subqueries
* Date functions
* Splitting columns data
* Finding trends and insights from data



## Some Analysis Done

* Total movies and TV shows count
* Most common ratings on Netflix
* Movies longer than 120 minutes
* TV Shows with more than 5 seasons
* Content added in last few years
* Top directors and actors
* Genre based analysis
* Good content and bad content categorization using CASE statement
* Year wise content release analysis


## Example Query

sql
WITH movie_data AS (
    SELECT
        title,
        release_year,
        CAST(SUBSTRING_INDEX(duration, ' ', 1) AS UNSIGNED) AS mins
    FROM netflix
    WHERE type = 'Movie'
)

SELECT *
FROM movie_data
WHERE mins > 120;


This query is used for finding movies which duration is more than 120 minutes.



## Dataset Information

The dataset contains:

* Title
* Director
* Cast
* Country
* Release Year
* Rating
* Duration
* Genre
* Date Added


## Conclusion

This project help me alot in understanding SQL concepts in practical way. I learn how to solve real data problems using SQL queries and improve my thinking for data analysis.
Still learning more advanced SQL concepts and trying to build more projects.



## Author

Shadan Ali
Information Technology Student
Learning Data Analytics and SQL 🚀
