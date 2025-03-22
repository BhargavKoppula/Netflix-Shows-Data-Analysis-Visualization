-- CREATE A DUPLICATE CLEANED TABLE
CREATE TABLE netflix_titles_cleaned AS 
SELECT * FROM netflix_titles;

-- CHECK FOR MISSING VALUES
SELECT 
    SUM(CASE WHEN director IS NULL OR director = '' THEN 1 ELSE 0 END) AS missing_director,
    SUM(CASE WHEN cast IS NULL OR cast = '' THEN 1 ELSE 0 END) AS missing_cast,
    SUM(CASE WHEN country IS NULL OR country = '' THEN 1 ELSE 0 END) AS missing_country,
    SUM(CASE WHEN date_added IS NULL OR date_added = '' THEN 1 ELSE 0 END) AS missing_date_added,
    SUM(CASE WHEN rating IS NULL OR rating = '' THEN 1 ELSE 0 END) AS missing_rating,
    SUM(CASE WHEN duration IS NULL OR duration = '' THEN 1 ELSE 0 END) AS missing_duration
FROM netflix_titles_cleaned;

--  HANDLE MISSING VALUES
UPDATE netflix_titles_cleaned SET director = 'Unknown' WHERE director IS NULL OR director = '';
UPDATE netflix_titles_cleaned SET cast = 'Unknown' WHERE cast IS NULL OR cast = '';
UPDATE netflix_titles_cleaned SET country = 'Unknown' WHERE country IS NULL OR country = '';
UPDATE netflix_titles_cleaned SET rating = 'Unrated' WHERE rating IS NULL OR rating = '';


--  STANDARDIZE TEXT FORMATTING
UPDATE netflix_titles_cleaned SET title = TRIM(title);
UPDATE netflix_titles_cleaned SET director = TRIM(director);
UPDATE netflix_titles_cleaned SET country = TRIM(country);

-- CONVERT `date_added` TO YYYY-MM-DD FORMAT
ALTER TABLE netflix_titles_cleaned ADD COLUMN date_added_clean DATE;
UPDATE netflix_titles_cleaned 
SET date_added_clean = STR_TO_DATE(date_added, '%M %d, %Y');

--  SPLIT `duration` COLUMN INTO NUMERIC & TYPE
ALTER TABLE netflix_titles_cleaned ADD COLUMN duration_num INT;
ALTER TABLE netflix_titles_cleaned ADD COLUMN duration_type VARCHAR(20);

UPDATE netflix_titles_cleaned 
SET duration_num = CAST(REGEXP_SUBSTR(duration, '[0-9]+') AS UNSIGNED);

UPDATE netflix_titles_cleaned 
SET duration_type = 
    CASE 
        WHEN duration LIKE '%Season%' THEN 'Season'
        ELSE 'Minutes'
    END;

--  SPLIT `listed_in` COLUMN INTO GENRE_1, GENRE_2, GENRE_3
ALTER TABLE netflix_titles_cleaned ADD COLUMN genre_1 VARCHAR(50);
ALTER TABLE netflix_titles_cleaned ADD COLUMN genre_2 VARCHAR(50);
ALTER TABLE netflix_titles_cleaned ADD COLUMN genre_3 VARCHAR(50);

UPDATE netflix_titles_cleaned 
SET genre_1 = SUBSTRING_INDEX(listed_in, ',', 1);

UPDATE netflix_titles_cleaned 
SET genre_2 = NULLIF(SUBSTRING_INDEX(SUBSTRING_INDEX(listed_in, ',', -2), ',', 1), listed_in);

UPDATE netflix_titles_cleaned 
SET genre_3 = NULLIF(SUBSTRING_INDEX(listed_in, ',', -1), listed_in);

SELECT * FROM netflix_titles_cleaned;

SELECT * FROM netflix_titles_cleaned
INTO OUTFILE 'C:/Downloads/netflix_titles_cleaned.csv'
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n';
