-- To find the columns of the table 

SELECT column_name 
FROM information_schema.columns
WHERE table_name = 'spotify_data'


-- 14 Practice Questions



-- Easy Level


-- 1.Retrieve the names of all tracks that have more than 1 billion streams.

SELECT * FROM spotify_data 
WHERE stream > 100000000



-- 2.List all albums along with their respective artists.


SELECT DISTINCT album,artist FROM spotify_data
ORDER BY 1;



-- 3.Get the total number of comments for tracks where licensed = TRUE.


SELECT SUM(comments) FROM spotify_data
WHERE licensed = 'true';



-- 4.Find all tracks that belong to the album type single.

SELECT * FROM spotify_data
WHERE album_type = 'single';




-- 5.Count the total number of tracks by each artist.

SELECT artist, COUNT(track) AS Total_songs_By_Artist FROM spotify_data
GROUP BY 1
ORDER BY 2 DESC;




-- Medium Level


-- 1.Calculate the average danceability of tracks in each album.


SELECT 
	album,
	AVG(danceability) AS AVG_danceability
FROM spotify_data
GROUP BY 1
ORDER BY 2 DESC;




-- 2.Find the top 5 tracks with the highest energy values.

SELECT 
	track ,
	AVG(energy)
FROM spotify_data
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;



-- 3.List all tracks along with their views and likes where official_video = TRUE.

SELECT 
	track,
	SUM(views) AS total_views,
	SUM(likes) AS total_likes
FROM spotify_data
WHERE official_video = 'true'
GROUP BY 1
ORDER BY 2 DESC;



-- 4.For each album, calculate the total views of all associated tracks.


SELECT 
	album,
	track,
	SUM(views) AS Total_views
FROM spotify_data
GROUP BY 1,2
ORDER BY 3 DESC;



-- 5.Retrieve the track names that have been streamed on Spotify more than YouTube.


SELECT * FROM 
(SELECT 
	track,
	-- most_played_on,
	COALESCE(SUM(CASE WHEN most_played_on = 'Youtube' THEN stream END),0) AS streamed_on_youtube,
	COALESCE(SUM(CASE WHEN most_played_on = 'Spotify' THEN stream END),0) AS streamed_on_spotify
FROM spotify_data
GROUP BY 1) AS t1
WHERE 
	streamed_on_spotify > streamed_on_youtube
	AND 
	streamed_on_youtube <> 0;




-- Advanced Level


-- 1.Find the top 3 most-viewed tracks for each artist using window functions.

-- each artist and total view for each track 
-- track with highest view for each artist (we need top)
-- dense rank 
-- cte and filter rank  <=3


WITH ranking_artist 
AS
(SELECT 
	artist,
	track,
	SUM(views) AS total_views,
	DENSE_RANK() OVER(PARTITION BY artist ORDER BY SUM(views) DESC) AS rank
FROM spotify_data
GROUP BY 1,2
ORDER BY 1,3 DESC
)
SELECT * FROM ranking_artist
WHERE rank <=3;



-- 2.Write a query to find tracks where the liveness score is above the average.


SELECT  
	artist, 
	track,
	liveness
FROM spotify_data
WHERE liveness > (SELECT AVG(liveness) FROM spotify_data);







-- 3.Use a WITH clause to calculate the difference between the highest and lowest energy values for tracks in each album.




WITH cte 
AS 
(
SELECT 
	album,
	MAX(energy) AS highest_energy,
	MIN(energy) AS lowest_energy
FROM spotify_data
GROUP BY 1
)
SELECT 
	album,
	highest_energy - lowest_energy AS energy_diff
FROM cte;




-- 4.Find tracks where the energy-to-liveness ratio is greater than 1.2.

SELECT 
	track,
	SUM(energy) AS sum_energy,
	SUM(liveness) AS sum_liveness,
	SUM(energy) / SUM(liveness) AS ratio
FROM spotify_data
GROUP BY 1
HAVING 
	SUM(liveness) > 0
	AND
	SUM(energy) / SUM(liveness) > 1.2
ORDER BY ratio DESC;



	

