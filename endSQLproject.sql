use movies ;

create table netflix
(
show_id  varchar(6),
type varchar(10),
title varchar(150),
director varchar(208),
casts varchar(1000),
country varchar(150),
date_added  varchar(50),
release_year int ,
rating  varchar(10),
duration  varchar(15),
listed_in varchar(100),
description varchar(250)
);

select * from netflix;

select 
  count(*) as total_content
from netflix;       /* data is 8807 but mysql is not taking such large data tried everything but not working */

/* checking diferent type of content netflix is having */
select
  distinct type
from netflix;

-- 15 problems related to netflix 

-- 1. count no. of movies vs tv shows 
select
  type,
  count(*) as total_content
from netflix
group by type;

-- 2. find the most common rating for movies and tv shows

select
  type,
  rating
from 
(
   select 
     type,
     rating,
     count(*),
     rank() over( partition by type order by count(*) desc) as ranking   
   from netflix 
   group by 1, 2
) as t1
where 
ranking = 1 ;

-- 3.list all movie release in a same year (e.g.2020)

select * from netflix 
where 
   type = 'tv show'
   and
   release_year = 2020;
   
-- 4.find the top 5 country with the most content on netflix

select 
	 country,
     count(show_id) as total_content
from netflix
group by 1 ;

select
    --  (-1)neg value takes text from the right side of the comma 
   substring_index(country, ',' , 1 ) as new_country 
from netflix ;

select 
  substring_index(country, ',' , 1 ) as new_country,
  count(show_id) as total_content
from netflix
group by 1 
order by 2 desc
limit 5 ;

-- 5. identify the longest table 
   
select *  from netflix
where
  type = 'movie'
  and
  duration = (select max(duration) from netflix);
  
  
-- 6.find the content added in  the last five year

desc netflix;

select
    date_added,
    str_to_date(trim(date_added), '%M %e, %Y') as converted_date
FROM netflix;

alter table netflix
add column new_date date;


set sql_safe_updates = 0 ;
update netflix
set new_date = str_to_date(trim(date_added), '%M %e, %Y');

set sql_safe_updates = 1;

select *  from netflix
where
new_date >= date_sub(curdate(), interval 5 year);

-- 7. find all the movies and tv shows by dierector 'toshiya shinohara'

select *  from netflix 
where director = 'toshiya shinohara';

-- for multiple directors

select * from netflix
where director like '%Robert Cullen%'; 

-- 8. list all  tv shows  more than 5 season
select
    title,
    duration
from netflix
where 
type = 'TV Show'
and cast(substring_index(duration, ' ', 1) as unsigned) > 5; 
/* substring_index(column, delimiter, count) ,
cast(.., as unsigned) converts text into number*/


-- 9.count the number of  content item in each genre

/*SELECT
    listed_in,
    COUNT(*)
FROM netflix
GROUP BY listed_in;*/

select
  trim(substring_index(substring_index(listed_in, ',', numbers.n), ',', -1)) as genre,
  count(*) as total_content
from
(                     -- creates temperory table
    select 1 n
    union select 2
    union select 3
    union select 4
    union select 5
) numbers
join netflix
ON char_length(listed_in)
   - char_length(replace(listed_in, ',', '')) >= numbers.n - 1

group by genre
order by total_content desc;

-- 10. find the each year and the average numbers of content release by Unites States on netflix , return top 5 years with highest avg content release :

select 
   extract( year from str_to_date(date_added, '%M %d, %Y')) as year,
   count(*),
   round(
   count(*) /(Select count(*) from netflix where country = 'United States') * 100 
   ,2) as avg_content
from netflix
where country =  'United States'
group by 1;

-- 11. list all  movies that are crime TV shows

select *
from netflix
where 
type = 'TV Show'
and listed_in like '%Crime TV Shows%';

-- 12. find all the content without a director

set sql_safe_updates = 0 ;
select 
    concat('[', director, ']') as director_value, -- joining strings
    length(director)
from netflix
order by length(director); 

update netflix
set director = null
where director = '';

select *
from netflix
where director is null;

set sql_safe_updates = 1;

-- 13. find how many movies actor 'salman khan' appeard in last 10 year

select  * from netflix
where casts like '%Koji Tsujitani%'
and
release_year <= extract(year from new_date) - 19
and
release_year > extract(year from new_date) - 21 ;

-- 14.find the top 10 actors who have appeard in the highest number of movies produced United States

Select 
   substring_index(casts, ',' , 1 ) as actors,
   count(*)
from netflix
where
country like '%United States%'
group by 1
order by 2 desc
limit 10 ;

/* 15. categorize the content based on the presence of the keywords 'kill' 
and 'violence' and 'dead'in the description field. label content containig these keywords
as 'bad' and all other content as 'good'. count how many item fall into each category.*/


with new_table as
(
  select *,
    case
       when description like '%kill%' 
         or description like '%violence%' 
         or description like '%dead%'
	   then 'bad content'
       else 'good content'
  end as category
from netflix 
)
select 
   category,
   count(*) as total_content
from new_table
/*where description like '%kill%'
  or description like '%violence%'
  or description like '%dead%'*/
 group by 1;
 
 
 -- window function 

 -- 16. comparing current year with previous year
 
 with yearly as (
  select
   release_year,
   count(*) as total_content
from netflix
group by release_year
)

select
 *,
 lag(total_content)   /*lag() gives row values */
 over(order by release_year) as previous_year,
 total_content
  - lag(total_content) 
	over( order by release_year) as growth
from yearly;
 
 -- 17.  filter movies  whose duration is  greater than 100 minutes

 select * from netflix ;

 with movie_data as (
   select
      title,
      release_year,               /* cast() convert string to number */
      cast(substring_index( duration, ' ', 1) as unsigned) as mins
   from netflix
   where type = 'Movie'
   )
   select *
   from movie_data
   where mins > 100;
   
   
   -- 18. conditional aggregation important for dashboard creation 
   
   select 
      count(case when type = 'movie' then 1 end) as movies,
      count(case when type = 'tv show' then 1 end) as tv_shows
   from netflix;
      
      -- 19. join function
      
      create table directors(
       director_id int,
       director_name varchar(100)
      );
      
      insert into directors values
       (1, 'Raj'),
       (2, 'Steven'),
       (3, 'Nolan');
      
      create table movies(
        movie_id int,
        title varchar(100),
        director_id int,
        rating decimal(3,1)
       );
      
      insert into movies values
       (101, 'Dark World', 3, 8.9),
       (102, 'Future Man', 2, 7.5),
       (103, 'Unknown Film', null, 6.0),
       (104, 'Action Hero', 1, 8.0);
       
       -- INNER JOIN
       select 
         m.title,
         d.director_name,
         m.rating
       from movies m
       inner join directors d
       on m.director_id = d.director_id;
       
       -- LEFT JOIN
       select 
         m.title,
         d.director_name
       from movies m
       left  join directors d
       on m.director_id = d.director_id;
      
      -- RIGHT JOIN
       select 
         m.title,
         d.director_name
       from movies m
       right join directors d
       on m.director_id = d.director_id;
       
       -- CROSS JOIN (rarely used)
       
       select *
       from directors
       cross join movies;
       
       -- ADVANCED JOIN QUERY ON NETFLIX DATASET
       
with movie_data as (
	select 
           director,
           country,
           title,
           cast(substring_index(duration, ' ', 1) as unsigned) as mins
	from netflix
	where type = 'movie'
	and director is not null
    and country is not null
	),
        
director_stats as (
	select
           director,
           country,
           count(title) as total_movies,
           round(avg(mins),2) as avg_duration
	from movie_data
	group by director, country
	having count(title) >=2
	),
        
ranked_directors AS (
    SELECT
	  *,
	  rank() 
	  over( partition by country order by total_movies desc, avg_duration desc ) as rnk
    from director_stats
)

select
    country,
    director,
    total_movies,
    avg_duration
from ranked_directors
where rnk = 1
order by total_movies desc;