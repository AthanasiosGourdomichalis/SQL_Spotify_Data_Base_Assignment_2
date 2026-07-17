--1)    Retrieve the names and popularity of the top 10 most popular artists (descending) (10)
SELECT name, popularity
FROM artists 
ORDER BY popularity DESC
LIMIT 10;

--2)    Calculate the total duration in minutes for each genre, 
--based on the tracks that belong to it (5,489)
SELECT ag.genre_id as genre, SUM(t.duration) / 60000 as total_playtime
FROM r_artist_genre as ag
JOIN r_track_artist as ta on ag.artist_id = ta.artist_id
JOIN tracks as t on t.id = ta.track_id
GROUP BY ag.genre_id
ORDER BY total_playtime DESC;

--3)    Retrieve the names of artists and their followers 
--who have a follower count greater than the average (48,219)
SELECT DISTINCT a.name, a.followers, (SELECT AVG(followers) FROM artists)  as average
from artists a
WHERE followers > (
    SELECT AVG(followers)
    FROM   artists
);

--4)    Retrieve the names of artists who only have single tracks and 
--DO NOT have albums OR compilations (144,322)
SELECT DISTINCT a.name 
FROM artists as a
JOIN r_albums_artists as aa on a.id = aa.artist_id
JOIN albums AS al ON aa.album_id = al.id
WHERE al.album_type = 'single'
EXCEPT 
SELECT DISTINCT a.name 
FROM artists as a
JOIN r_albums_artists as aa on a.id = aa.artist_id
JOIN albums AS al ON aa.album_id = al.id
WHERE al.album_type in ('album', 'compilation');


--5)    Retrieve the names and popularity of the top 10 most popular 
--albums of the '90s (01-01-1990 to 31-12-1999 using UNIX TIME) (10)
SELECT name,popularity
FROM albums
WHERE release_date >= 631152000000 AND release_date <=946684799999
AND album_type = 'album'
ORDER BY popularity DESC
LIMIT 10;

--6)    Retrieve the names of albums that do not correspond to any artist (4,008,119)
SELECT al.name AS album_name
FROM albums AS al
LEFT JOIN r_albums_artists AS aa ON al.id = aa.album_id
WHERE aa.artist_id IS NULL;

--7)    Retrieve the top genres that have more than 400 distinct artists, 
--ordered by the total number of artists (descending) (28)
SELECT g.id as genre, COUNT(DISTINCT a.name) as number_of_artists
FROM genres g 
JOIN r_artist_genre as ag on g.id = ag.genre_id
JOIN artists as a ON ag.artist_id = a.id
GROUP BY g.id 
HAVING COUNT(DISTINCT a.name)> 400
ORDER BY COUNT(DISTINCT a.name) DESC;

--8)    Retrieve the genre and the average popularity of the artists for each genre 
--that has an average popularity score greater than 50 (on a scale of 0-100) (13)
SELECT g.id AS genre, AVG(a.popularity) AS genre_popularity
FROM genres g 
JOIN r_artist_genre AS ag ON g.id = ag.genre_id
JOIN artists AS a ON ag.artist_id = a.id
GROUP BY g.id 
HAVING AVG(a.popularity)>50
ORDER BY AVG(a.popularity) DESC;



--9)    Retrieve the tracks that are the most popular, grouped by album type (single, album, compilation) 
--(i.e., the most popular single, the most popular album, and the most popular compilation) (3)
SELECT al.name, al.album_type, al.popularity
from albums al
GROUP BY album_type
HAVING al.popularity = MAX(al.popularity);



--10)   Retrieve the genres whose least popular track 
--has a popularity score greater than 0 (on a scale of 0-100) (19)
SELECT ag.genre_id as genre, MIN(t.popularity) as least_popular
from tracks t 
JOIN r_track_artist as ta ON t.id = ta.track_id
JOIN r_artist_genre as ag ON ag.artist_id = ta.artist_id
GROUP BY ag.genre_id
HAVING MIN(t.popularity)>0;



--11)   Retrieve the artists who do not correspond to any genre (739,908)
SELECT DISTINCT a.name
FROM artists a 
LEFT JOIN r_artist_genre as ag on ag.artist_id = a.id 
WHERE ag.genre_id IS NULL 
ORDER BY a.name;



--12)   Retrieve the top 10 tracks with the highest danceability 
--(audio feature) that belong to any artist 
--with at least one appearance in a Greek genre (10)
SELECT t.name
from tracks t 
JOIN audio_features as af ON t.audio_feature_id = af.id
where t.id in (
    SELECT ta.track_id 
    FROM r_track_artist ta 
    JOIN r_artist_genre as ag ON ag.artist_id = ta.artist_id
    where ag.genre_id like '%greek%') 
ORDER BY af.danceability DESC
LIMIT 10;
