/*	Ricardo Farias
	Database Programming Project #1
*/


-- First Table: RATINGS
-- USERID | MOVIEID | RATING | TIMESTAMP

CREATE TABLE RATINGS (
	USERID INT,
	MOVIEID INT,
	RATING INT,
	STAMP TIMESTAMP,

	PRIMARY KEY (USERID, MOVIEID),
	FOREIGN KEY (MOVIEID) REFERENCES MOVIES(MOVIEID)
);




-- Second Table: USERS
-- USERID | GENDER | AGE | OCCUPATION | ZIPCODE

CREATE TABLE USERS (
	USERID INT,
	GENDER CHAR(1),
	AGE INT,
	OCCUPATION VARCHAR2(40),
	ZIPCODE INT,

	PRIMARY KEY (USERID)
);


-- Third Table: MOVIES
-- MOVIEID | TITLE | GENRE *(Multivalued cell)* 

CREATE TABLE MOVIES (
	MOVIEID INT,
	TITLE VARCHAR2(50),

	PRIMARY KEY (MOVIEID)
);

/* Possible genres
		Action
		Adventure
		Animation
		Children's
		Comedy
		Crime
		Documentary
		Drama
		Fantasy
		Film-Noir
		Horror
		Musical
		Mystery
		Romance
		Sci-Fi
		Thriller
		War
		Western
*/


CREATE TABLE MOVIE_GENRE (
	MOVIEID INT,
	GENRE VARCHAR2(20),
	PRIMARY KEY (MOVIEID, GENRE),
	FOREIGN KEY (MOVIEID) REFERENCES MOVIES
);

-------------------------CONVERSION TO PLSQL-----------------------


DECLARE
	ratings VARCHAR2(1000) := 
		'CREATE TABLE RATINGS (
		USERID INT,
		MOVIEID INT,
		RATING INT,
		STAMP TIMESTAMP,

		PRIMARY KEY (USERID, MOVIEID),
		FOREIGN KEY (MOVIEID) REFERENCES MOVIES(MOVIEID)
			);';
	users VARCHAR2(1000) := 
		'CREATE TABLE USERS (
		USERID INT,
		GENDER VARCHAR2(1),
		AGE INT,
		OCCUPATION VARCHAR2(40),
		ZIPCODE INT,

		PRIMARY KEY (USERID)
			);';
	movies VARCHAR2(1000) :=
		'CREATE TABLE MOVIES (
		MOVIEID INT,
		TITLE VARCHAR2(50),

		PRIMARY KEY (MOVIEID)
			);';
	genres VARCHAR2(1000) := 
		'CREATE TABLE GENRES (
		GENRE VARCHAR2(20),
		PRIMARY KEY (GENRE)
			);';
	genres_movie VARCHAR2(1000) := 
		'CREATE TABLE MOVIE_GENRE (
		MOVIEID INT,
		GENRE VARCHAR2(20),
		PRIMARY KEY (MOVIEID, GENRE),
		FOREIGN KEY (MOVIEID) REFERENCES MOVIES,
		FOREIGN KEY (GENRE) REFERENCES GENRES
			);';
BEGIN
	
END;




-------------------CREATE PROCEDURES FOR PLSQL-----------------------

-- Creates all the tables 
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
				TITLE VARCHAR2(50),
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
				FOREIGN KEY (MOVIEID) REFERENCES MOVIES,
				FOREIGN KEY (GENRE) REFERENCES GENRES))';

		-- executes the sql create table statements
		EXECUTE IMMEDIATE users_query;
		EXECUTE IMMEDIATE movies_query;
		EXECUTE IMMEDIATE ratings_query;
		EXECUTE IMMEDIATE movie_genre_query;
	EXCEPTION
		WHEN OTHERS THEN
			IF SQLCODE != -955 THEN
				NULL;
			ELSE
				RAISE;
			END IF;
	END create_tables;


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
			END IF
	END drop_tables;


-- Extracting data from userxlsx table and inserting into users
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
            CASE r_user_info.occupation -- Changing numerical value to a text attribute
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
           users_insert := 'INSERT INTO users VALUES(:a, :b, :c, :d, :e);';
           EXECUTE IMMEDIATE users_insert
            USING r_user_info.userid, r_user_info.gender, r_user_info.age, occupation, r_user_info.zipcode;
        END LOOP;
        CLOSE z_user_info;
    END;
END parse_users;


CREATE OR REPLACE PROCEDURE parse_ratings IS
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


CREATE OR REPLACE PROCEDURE parse_movies IS
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



CREATE OR REPLACE PROCEDURE main IS
	BEGIN
		drop_tables();
		create_tables();
		parse_users();
		parse_movies();
		parse_ratings();
	END main;



-- Interesting Query 1 :
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


-- Interesting Query 2 :
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





/* Using cursors to parse data from tables

--------------------MOVIE DATA FETCHER---------------------

DECLARE
	CURSOR z_movie_info IS
		SELECT *
		FROM moviexlsx
	r_movie_info z_movie_info%ROWTYPE
BEGIN
	OPEN z_movie_info
	LOOP
		FETCH z_movie_info INTO r_movie_info;
		EXIT WHEN z_movie_info%NOTFOUND;
		DBMS_OUTPUT.PUT_LINE('Movie id: ' || r_movie_info.movieid || ' Movie Title: ' || r_movie_info.title || CHR(9) || 'Movie Genre: ' || r_movie_info.genre);
	END LOOP;
END;

----------------------USER INFO DATA FETCHER------------------

DECLARE
	CURSOR z_user_info IS
		SELECT *
		FROM userxlsx;
	r_user_info z_user_info%ROWTYPE;
BEGIN
	OPEN z_user_info;
	LOOP
		FETCH z_user_info INTO r_user_info;
		EXIT WHEN z_user_info%NOTFOUND;
		DBMS_OUTPUT.PUT_LINE('User id: ' || r_user_info.userid || CHR(9) || 'Gender: ' || r_user_info.gender || CHR(9) || 'Age: ' || r_user_info.age || CHR(9) || 'Occupation: ' || r_user_info.occupation || CHR(9) || 'Zip Code: ' || r_user_info.zipcode);
	END LOOP;
	CLOSE z_user_info;
END;


------------------------RATING INFO DATA FETCHER---------------

DECLARE
	CURSOR z_ratings_info IS
		SELECT *
		FROM ratingsxlsx;
	r_ratings_info z_ratings_info%ROWTYPE;
BEGIN
	OPEN z_ratings_info;
	LOOP
		FETCH z_ratings_info INTO r_ratings_info;
		EXIT WHEN z_ratings_info%NOTFOUND;
		DBMS_OUTPUT.PUT_LINE('User id: ' || r_ratings_info.userid || CHR(9) || 
                            'Movie Id: ' || r_ratings_info.movieid || CHR(9) ||
                            'Ratings: ' || r_ratings_info.rating || CHR(9) ||
                            'Timestamp: ' || r_ratings_info.timestamp);
    END LOOP;
    CLOSE z_ratings_info;
END;		



*/

