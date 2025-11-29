# Spotify Advanced SQL Project and Query Optimization

Dataset
The data for this project is sourced from Kaggle:

![Spotify Logo](https://github.com/sumnima08/spotify_sql_project/blob/main/Spotify_Full_Logo_RGB_Green.png)

**Overview**
This project involves a comprehensive analysis of Netflix's movies and TV shows data using SQL. The goal is to extract valuable insights and answer various business questions based on the dataset.

The analysis focuses on:
-Content type distribution (Movies vs TV Shows)

-Most common ratings

-Content by release years, countries, and durations

-Genre trends and keyword-based categorization

-Insights for content strategy and decision-making

**Dataset Overview**

The dataset includes 24 columns such as:

-artist, track, album, album_type
-danceability, energy, loudness, valence
-views, likes, comments, stream
-licensed, official_video, most_playedon

These fields allow us to study popularity, emotions, platform performance, and engagement.

**Exploratory Data Analysis (EDA)**

✔ Total rows 
```sql
SELECT COUNT(*) FROM spotify;
```

✔ Number of unique artists, albums, and channels
```sql
SELECT COUNT(DISTINCT artist) FROM spotify;
SELECT COUNT(DISTINCT album) FROM spotify;
SELECT COUNT(DISTINCT channel) FROM spotify;
```

✔ Album types present
```sql
SELECT DISTINCT album_type FROM spotify;
```
✔ Track length distribution
```sql
SELECT MAX(duration_min) FROM spotify;
SELECT MIN(duration_min) FROM spotify;
```

✔ Remove invalid tracks
```sql
DELETE FROM spotify
WHERE duration_min = 0;
```

✔ Where tracks are mostly played
```sql
SELECT DISTINCT most_playedon FROM spotify;
```

**📊 Part 2: SQL Analysis & Business Questions**

1️⃣ Tracks with more than 1 billion streams
```sql
SELECT * FROM spotify
WHERE stream > 1000000000;
```

2️⃣ Albums and their artists
```sql
SELECT DISTINCT album, artist
FROM spotify
ORDER BY 1;
```

3️⃣ Total comments on licensed tracks
```sql
SELECT SUM(comments) AS total_comment
FROM spotify
WHERE licensed = 'TRUE';
```

4️⃣ All tracks categorized as “single”
```sql
SELECT * FROM spotify
WHERE album_type = 'single';
```

5️⃣ Total number of tracks per artist
```sql
SELECT artist, COUNT(track) AS total_songs
FROM spotify
GROUP BY 1
ORDER BY 2 DESC;
```

**📈 Part 3: Medium-Level Analysis**

6️⃣ Average danceability per album
```sql
SELECT album, AVG(danceability) AS avg_danceability
FROM spotify
GROUP BY 1
ORDER BY 2 DESC;
```

7️⃣ Top 5 highest-energy tracks
```sql
SELECT track, MAX(energy)
FROM spotify
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;
```

8️⃣ Views and likes for official videos
```sql
SELECT track, SUM(views) AS total_views, SUM(likes) AS total_likes
FROM spotify
WHERE official_video = 'true'
GROUP BY 1
ORDER BY 2 DESC;
```

9️⃣ Total views of each track within an album
```sql
SELECT album, track, SUM(views) AS total_views
FROM spotify
GROUP BY 1, 2
ORDER BY 3 DESC;
```

🔟 Tracks streamed more on Spotify than YouTube
```sql
SELECT *
FROM (
    SELECT
        track,
        COALESCE(SUM(CASE WHEN most_playedon = 'Youtube' THEN stream END), 0) AS streamed_on_youtube,
        COALESCE(SUM(CASE WHEN most_playedon = 'Spotify' THEN stream END), 0) AS streamed_on_spotify
    FROM spotify
    GROUP BY 1
) AS t1
WHERE streamed_on_spotify > streamed_on_youtube
  AND streamed_on_youtube <> 0;
```

**🧠 Part 4: Advanced SQL**

1️⃣1️⃣ Top 3 most-viewed tracks per artist (Window Functions)
```sql
WITH ranking_artist AS (
    SELECT
        artist,
        track,
        SUM(views) AS total_view,
        DENSE_RANK() OVER (
            PARTITION BY artist
            ORDER BY SUM(views) DESC
        ) AS rank
    FROM spotify
    GROUP BY 1, 2
)
SELECT *
FROM ranking_artist
WHERE rank <= 3;
```

1️⃣2️⃣ Tracks with above-average liveness
```sql
SELECT track, artist, liveness
FROM spotify
WHERE liveness > (SELECT AVG(liveness) FROM spotify);
```

1️⃣3️⃣ Energy range (max minus min) per album
```sql
WITH cte AS (
    SELECT
        album,
        MAX(energy) AS highest_energy,
        MIN(energy) AS lowest_energy
    FROM spotify
    GROUP BY 1
)
SELECT album, highest_energy - lowest_energy AS energy_diff
FROM cte
ORDER BY 2 DESC;
```

1️⃣4️⃣ Tracks where energy-to-liveness ratio > 1.2
```sql
SELECT track, energy / liveness AS ratio
FROM spotify
WHERE energy / liveness > 1.2
ORDER BY 2 DESC;
```

1️⃣5️⃣ Cumulative likes ordered by views (Window Function)
```sql
SELECT
    artist,
    track,
    views,
    likes,
    SUM(likes) OVER (ORDER BY views) AS cumulative_likes
```
FROM spotify;

**📌 Key Takeaways**
-Many artists show strong repeat popularity with consistent high-view tracks.

-Danceability and energy metrics help show audience engagement tendencies.

-Spotify-vs-YouTube comparison shows where songs perform best.

-Window functions provide deep insight into ranking and cumulative engagement.


📎 Repository Structure
├── README.md
├── spotify_queries.sql
└── /data
    └── cleaned_dataset.csv

