-- Creates all the tables that will be part of the project
CREATE OR REPLACE PROCEDURE create_tables IS
	users_query VARCHAR2(1000);
	movies_query VARCHAR2(1000);
	ratings_query VARCHAR2(1000);
	movie_genre_query VARCHAR2(1000);
	BEGIN
		-- create table sql statements
		users_query := 
				'CREATE TABLE USERS (
				USERID INT,
				GENDER VARCHAR2(1),
				AGE INT,
				OCCUPATION VARCHAR2(40),
				ZIPCODE INT,
				PRIMARY KEY (USERID))';
		movies_query := 
				'CREATE TABLE MOVIES (
				MOVIEID INT,
				TITLE VARCHAR2(90),
				PRIMARY KEY (MOVIEID))';
		ratings_query := 
				'CREATE TABLE RATINGS (
				USERID INT,
				MOVIEID INT,
				RATING INT,
				STAMP TIMESTAMP,
				PRIMARY KEY (USERID, MOVIEID),
				FOREIGN KEY (MOVIEID) REFERENCES MOVIES(MOVIEID))';
		movie_genre_query := 
				'CREATE TABLE MOVIE_GENRE (
				MOVIEID INT,
				GENRE VARCHAR2(20),
				PRIMARY KEY (MOVIEID, GENRE),
				FOREIGN KEY (MOVIEID) REFERENCES MOVIES(MOVIEID))';

		-- executes the sql create table statements
		EXECUTE IMMEDIATE users_query;
		EXECUTE IMMEDIATE movies_query;
		EXECUTE IMMEDIATE ratings_query;
		EXECUTE IMMEDIATE movie_genre_query;
	EXCEPTION
		WHEN OTHERS THEN
			IF SQLCODE != -955 THEN
				NULL;
			END IF;
	END create_tables;


-- Drops all the tables 
CREATE OR REPLACE PROCEDURE drop_tables IS
	drop_users VARCHAR2(1000);
	drop_movies VARCHAR2(1000);
	drop_ratings VARCHAR2(1000);
	drop_movie_genre VARCHAR2(1000);

	BEGIN 
		-- sql drop table statements
		drop_users := 'DROP TABLE users';
		drop_movies := 'DROP TABLE movies';
		drop_ratings := 'DROP TABLE ratings';
		drop_movie_genre := 'DROP TABLE movie_genre';

		-- executes the sql drop table statements
		EXECUTE IMMEDIATE drop_movie_genre;
		EXECUTE IMMEDIATE drop_ratings;
		EXECUTE IMMEDIATE drop_movies;
		EXECUTE IMMEDIATE drop_users;

	EXCEPTION
		WHEN OTHERS THEN 
			IF SQLCODE != -955 THEN
				NULL;
			ELSE
				RAISE;
			END IF;
	END drop_tables;


-- Parses userxlsx table and inserts values into users table
CREATE OR REPLACE PROCEDURE parse_users IS
BEGIN
    DECLARE
        users_insert VARCHAR2(1000);
        occupation VARCHAR2(40);
        CURSOR z_user_info IS
            SELECT *
            FROM userxlsx;
        r_user_info z_user_info%ROWTYPE;
    BEGIN
        OPEN z_user_info;
        LOOP
            FETCH z_user_info INTO r_user_info;
            EXIT WHEN z_user_info%NOTFOUND;
            CASE r_user_info.occupation
                WHEN 0 THEN
                    occupation := 'other';
                WHEN 1 THEN
                    occupation := 'academic/educator';
                WHEN 2 THEN
                    occupation := 'artist';
                WHEN 3 THEN
                    occupation := 'clerical/admin';
                WHEN 4 THEN
                    occupation := 'college/grad student';
                WHEN 5 THEN
                    occupation := 'customer service';
                WHEN 6 THEN
                    occupation := 'doctor/health care';
                WHEN 7 THEN
                    occupation := 'executive/managerial';
                WHEN 8 THEN
                    occupation := 'farmer';
                WHEN 9 THEN
                    occupation := 'homemaker';
                WHEN 10 THEN
                    occupation := 'k-12 student';
                WHEN 11 THEN
                    occupation := 'lawyer';
                WHEN 12 THEN
                    occupation := 'programmer';
                WHEN 13 THEN
                    occupation := 'retired';
                WHEN 14 THEN
                    occupation := 'sales/marketing';
                WHEN 15 THEN 
                    occupation := 'scientist';
                WHEN 16 THEN
                    occupation := 'self-employed';
                WHEN 17 THEN
                    occupation := 'technicial/engineer';
                WHEN 18 THEN
                    occupation := 'tradesman/craftsman';
                WHEN 19 THEN
                    occupation := 'unemployed';
                WHEN 20 THEN
                    occupation := 'writer';
           END CASE;
           users_insert := 'INSERT INTO users VALUES(:a, :b, :c, :d, :e)';
           EXECUTE IMMEDIATE users_insert
            USING r_user_info.userid, r_user_info.gender, r_user_info.age, occupation, r_user_info.zipcode;
        END LOOP;
        CLOSE z_user_info;
    END;
END parse_users;



-- Parses the moviexlsx and inserts values into movies, and movie_genre tables
create or replace PROCEDURE parse_movies IS
BEGIN
    DECLARE
        movies_insert VARCHAR2(1000);
        movie_genre_insert VARCHAR2(1000);
        genre VARCHAR2(20);
        CURSOR z_movie_info IS
            SELECT *
            FROM moviexlsx;
        r_movie_info z_movie_info%ROWTYPE;
    BEGIN
        OPEN z_movie_info;
        movies_insert := 'INSERT INTO movies VALUES(:movieid, :title)';
        movie_genre_insert := 'INSERT INTO movie_genre VALUES(:movieid, :genre)';
        LOOP
            FETCH z_movie_info INTO r_movie_info;
            EXIT WHEN z_movie_info%NOTFOUND;
            EXECUTE IMMEDIATE movies_insert
                 USING r_movie_info.movieid, r_movie_info.title;
            FOR i IN 1..10 LOOP
                genre := regexp_substr(REPLACE(r_movie_info.genre, '|', ' '), '[^ ]+', 1, i);
               IF LENGTH(genre) > 0 THEN
                    EXECUTE IMMEDIATE movie_genre_insert
                        USING r_movie_info.movieid, genre;
                END IF;
            END LOOP;
        END LOOP;
    END;
END parse_movies;



-- Parses ratingsxlsx and inserts values into ratings table
create or replace PROCEDURE parse_ratings IS
BEGIN
    DECLARE
        insert_statement VARCHAR2(1000);
        CURSOR z_ratings_info IS
            SELECT *
            FROM ratingsxlsx;
        r_ratings_info z_ratings_info%ROWTYPE;
    BEGIN
        OPEN z_ratings_info;
        insert_statement := 'INSERT INTO ratings VALUES(:userid, :movieid, :rating, :stamp)';
        LOOP
            FETCH z_ratings_info INTO r_ratings_info;
            EXIT WHEN z_ratings_info%NOTFOUND;
            EXECUTE IMMEDIATE insert_statement
                USING r_ratings_info.userid, r_ratings_info.movieid, r_ratings_info.rating, to_date('19700101', 'YYYYMMDD')+ (1/24/60/60)* r_ratings_info.timestamp;
        END LOOP;
        CLOSE z_ratings_info;
    END;
END parse_ratings;


-- Condensed all procedures into one callable procedure
create or replace PROCEDURE main IS
BEGIN   
    drop_tables();
    create_tables();
    parse_users();
    parse_movies();
    parse_ratings();
END main;

----------------Compare and Contrast Query [Interesting Query]---------------------

-- The average rating females give children's movies

SELECT
     AVG(ratings.rating)
 FROM
     movies
     INNER JOIN ratings ON ratings.movieid = movies.movieid
     INNER JOIN users ON users.userid = ratings.userid
 WHERE
     movies.movieid = (
         SELECT
             movie_genre.movieid
         FROM
             movie_genre
         WHERE
             movie_genre.genre = 'Children''s'
             AND movies.movieid = movie_genre.movieid
     )
     AND users.gender = 'F';



-- The average rating males give children's movies

SELECT
     AVG(ratings.rating)
 FROM
     movies
     INNER JOIN ratings ON ratings.movieid = movies.movieid
     INNER JOIN users ON users.userid = ratings.userid
 WHERE
     movies.movieid = (
         SELECT
             movie_genre.movieid
         FROM
             movie_genre
         WHERE
             movie_genre.genre = 'Children''s'
             AND movies.movieid = movie_genre.movieid
     )
     AND users.gender = 'M';

