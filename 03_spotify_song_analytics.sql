/* 
03_spotify_song_analytics.sql
Author: Budhaditya Das

Assumed table:

TABLE songs (
    track_id         VARCHAR(50) PRIMARY KEY,
    track_name       VARCHAR(200),
    artist_name      VARCHAR(200),
    sub_genre        VARCHAR(50),
    popularity       INT,
    danceability     NUMERIC,
    energy           NUMERIC,
    valence          NUMERIC,
    tempo            NUMERIC,
    mood             VARCHAR(50),
    season           VARCHAR(20),   -- e.g. 'Spring/Summer'
    release_date     DATE
);
*/

-- 1. Average popularity by sub-genre
SELECT 
    sub_genre,
    COUNT(*) AS num_songs,
    AVG(popularity) AS avg_popularity
FROM songs
GROUP BY sub_genre
HAVING COUNT(*) >= 50
ORDER BY avg_popularity DESC;

-- 2. Which moods are associated with higher popularity?
SELECT 
    mood,
    COUNT(*) AS num_songs,
    AVG(popularity) AS avg_popularity
FROM songs
GROUP BY mood
HAVING COUNT(*) >= 50
ORDER BY avg_popularity DESC;

-- 3. Seasonal popularity comparison
SELECT 
    season,
    AVG(popularity) AS avg_popularity,
    AVG(danceability) AS avg_danceability,
    AVG(energy) AS avg_energy
FROM songs
GROUP BY season
ORDER BY avg_popularity DESC;

-- 4. Top 10 tracks by popularity in each season (window function)
SELECT *
FROM (
    SELECT 
        track_name,
        artist_name,
        season,
        popularity,
        ROW_NUMBER() OVER (PARTITION BY season ORDER BY popularity DESC) AS rn
    FROM songs
) t
WHERE rn <= 10
ORDER BY season, popularity DESC;
