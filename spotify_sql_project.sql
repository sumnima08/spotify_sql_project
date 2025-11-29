ALTER TABLE cleaned_dataset
RENAME TO spotify;

-- EDA 
SELECT
	COUNT(*)
FROM
	spotify;

SELECT
	COUNT(DISTINCT artist)
FROM
	spotify;

SELECT
	COUNT(DISTINCT album)
FROM
	spotify;

SELECT DISTINCT
	album_type
FROM
	spotify;

SELECT
	MAX(duration_min)
FROM
	spotify;

SELECT
	MIN(duration_min)
FROM
	spotify;

SELECT
	*
FROM
	spotify
WHERE
	duration_min = 0;

DELETE FROM spotify
WHERE
	duration_min = 0;

SELECT
	COUNT(DISTINCT channel)
FROM
	spotify;

SELECT DISTINCT
	most_playedon
FROM
	spotify;

----------------------------------------------
-- Data Analysis (Using Subquery and Group By)
----------------------------------------------
--1. Retrieving the name of all tracks that have more than 1 billion streams.
SELECT
	*
FROM
	spotify
WHERE
	stream > 1000000000;

--2. Listing all the albums and their artists
SELECT DISTINCT
	album,
	artist
FROM
	spotify
ORDER BY
	1;

--3. Getting the total number of comments for tracks where licenses =TRUE.
SELECT
	SUM(comments) AS total_comment
FROM
	spotify
WHERE
	licensed = 'TRUE';

--4. Finding all tracks that belong to album type single.
SELECT
	*
FROM
	spotify
WHERE
	album_type = 'single';

--5. Couting the total number of tracks by each artist.
SELECT
	artist,
	COUNT(track) AS total_songs
FROM
	spotify
GROUP BY
	1
ORDER BY
	2 DESC;

-- Medium Level--
--6. Calculate the average danceability of tracks in each album.
SELECT
	album,
	AVG(danceability) AS avg_danceability
FROM
	spotify
GROUP BY
	1
ORDER BY
	2 DESC;

--7. Find the top 5 tracks with the highest energy values
SELECT
	track,
	MAX(energy)
FROM
	spotify
GROUP BY
	1
ORDER BY
	2 DESC
LIMIT
	5;

--8. Listing all tracks along with their views and likes where official video = TRUE.
SELECT
	track,
	SUM(views) AS total_views,
	SUM(likes) AS total_likes
FROM
	spotify
WHERE
	official_video = 'true'
GROUP BY
	1
ORDER BY
	2 DESC;

--9. For each album, caluclating the views of all associated tracks.
SELECT
	album,
	track,
	SUM(views) AS total_views
FROM
	spotify
GROUP BY
	1,
	2
ORDER BY
	3 DESC;

FROM
	spotify;

--10. Retrieving the track names that have been streamed on Spotify more than YouTube.
SELECT
	*
FROM
	(
		SELECT
			track,
			COALESCE(
				SUM(
					CASE
						WHEN most_playedon = 'Youtube' THEN stream
					END
				),
				0
			) AS streamed_on_youtube,
			COALESCE(
				SUM(
					CASE
						WHEN most_playedon = 'Spotify' THEN stream
					END
				),
				0
			) AS streamed_on_spotify
		FROM
			spotify
		GROUP BY
			1
	) AS t1
WHERE
	streamed_on_spotify > streamed_on_youtube
	AND streamed_on_youtube <> 0;

--Advanced Problems--
--11. Finding all the top 3 most-viewed tracks for each artist using window functions.
WITH
	ranking_artist AS (
		SELECT
			artist,
			track,
			SUM(views) AS total_view,
			DENSE_RANK() OVER (
				PARTITION BY
					artist
				ORDER BY
					SUM(views) DESC
			) AS RANK
		FROM
			spotify
		GROUP BY
			1,
			2
		ORDER BY
			1,
			3 DESC
	)
SELECT
	*
FROM
	ranking_artist
WHERE
	RANK <= 3;

--12. Finding tracks where the liveness score is above the average
SELECT
	track,
	artist,
	liveness
FROM
	spotify
WHERE
	liveness > (
		SELECT
			AVG(liveness)
		FROM
			spotify
	);

--13. Using a WITH clause to calculate the difference between the highest and lowerst energy values in each album.
WITH
	cte AS (
		SELECT
			album,
			MAX(energy) AS highest_energy,
			MIN(energy) AS lowest_energy
		FROM
			spotify
		GROUP BY
			1
	)
SELECT
	album,
	highest_energy - lowest_energy AS energy_diff
FROM
	cte
ORDER BY
	2 DESC;

--14. Finding tracks where the energy to livenes ratio is greater than 1.2
SELECT
	track,
	energy / liveness AS ratio
FROM
	spotify
WHERE
	energy / liveness > 1.2
ORDER BY
	2 DESC;

--15. Calculating the cumulative sum of likes for tracks ordered by the number of views using window functions
SELECT
	artist,
	track,
	views,
	likes,
	SUM(likes) OVER (
		ORDER BY
			views
	) AS cumulative_likes
FROM
	spotify;