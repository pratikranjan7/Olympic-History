select * from OLYMPICS_HISTORY;
select * from OLYMPICS_HISTORY_NOC_REGIONS;


-- 1 How many olympics games have been held?

SELECT COUNT(distinct games)
FROM OLYMPICS_HISTORY	


-- 2 List down all Olympics games held so far.
	
SELECT DISTINCT games
FROM OLYMPICS_HISTORY
ORDER BY games
	
	
-- 3 Mention the total no of nations who participated in each olympics game?
	
SELECT games,COUNT(DISTINCT noc)
FROM OLYMPICS_HISTORY
GROUP BY games
	
-- 4 Which year saw the highest and lowest no of countries participating in olympics?
	
WITH CTE AS(SELECT games,year,countries_participating,
	DENSE_RANK() OVER(ORDER BY countries_participating) AS lowest,
	DENSE_RANK() OVER(ORDER BY countries_participating DESC) AS highest
	FROM
	(SELECT games,year,COUNT(DISTINCT noc) AS countries_participating
FROM OLYMPICS_HISTORY
GROUP BY games,year
ORDER BY countries_participating DESC)X)

SELECT games,year,countries_participating
	FROM CTE
	WHERE lowest =1 OR highest=1

	

	
-- 5 Which nation has participated in all of the olympic games?

WITH CTE AS(SELECT noc,region,participated,DENSE_RANK() OVER(ORDER BY participated DESC ) AS rn
	FROM (SELECT  OH.noc AS noc,NOC.region AS region,COUNT(DISTINCT games) AS participated
FROM OLYMPICS_HISTORY OH
	JOIN OLYMPICS_HISTORY_NOC_REGIONS NOC
	ON OH.noc = NOC.noc
GROUP BY OH.NOC,NOC.region)X)

SELECT noc,region,participated
FROM CTE
WHERE rn = 1


-- 6 Identify the sport which was played in all summer olympics.
	
WITH CTE AS(SELECT sport,season,no_of_times,DENSE_RANK() OVER(ORDER BY no_of_times DESC) AS rnk
FROM(SELECT sport,season,COUNT(DISTINCT year) AS no_of_times
FROM OLYMPICS_HISTORY
WHERE season = 'Summer'
GROUP BY sport,season)X)

SELECT sport,season,no_of_times,no_of_times 
FROM CTE 
WHERE rnk = 1 


-- 7 Which Sports were just played only once in the olympics?

SELECT DISTINCT T1.sport,T1.games,no_of_times_played
FROM OLYMPICS_HISTORY T1
JOIN
(SELECT sport,COUNT(DISTINCT GAMES) AS no_of_times_played
FROM OLYMPICS_HISTORY
GROUP BY sport
HAVING COUNT(DISTINCT GAMES) = 1)T2
ON T1.sport = T2.sport

	

-- 8 Fetch the total no of sports played in each olympic games.

SELECT games,COUNT(DISTINCT sport) AS total_no_of_sports_played
FROM OLYMPICS_HISTORY
GROUP BY games
ORDER BY total_no_of_sports_played DESC,games

	
-- 9 Fetch details of the oldest athletes to win a gold medal.

WITH CTE AS(SELECT *,
DENSE_RANK() OVER(ORDER BY age DESC) AS rnk
FROM (select name,sex,cast(case when age = 'NA' then '0' else age end as int) as age,
team,games,city,sport, event, medal 
from olympics_history
)X
WHERE medal = 'Gold')
	

SELECT *
FROM CTE
WHERE rnk = 1


-- 10 Find the Ratio of male and female athletes participated in all olympic games.

select * from OLYMPICS_HISTORY_NOC_REGIONS;



-- 11 Fetch the top 5 athletes who have won the most gold medals.

SELECT name,team,
COUNT(CASE WHEN medal = 'Gold' THEN 1 END) AS no_of_gold
FROM OLYMPICS_HISTORY
GROUP BY name,team
ORDER BY no_of_gold DESC
LIMIT 5;

-- 12 Fetch the top 5 athletes who have won the most medals (gold/silver/bronze).

SELECT name,team,
COUNT(1) AS no_of_medals
FROM OLYMPICS_HISTORY
WHERE medal IN ('Gold','Silver','Bronze')
GROUP BY name,team
ORDER BY no_of_medals DESC
LIMIT 5;


-- 13 Fetch the top 5 most successful countries in olympics. Success is defined by no of medals won.


SELECT T2.region,count(medal) as no_of_medals
FROM OLYMPICS_HISTORY T1
JOIN OLYMPICS_HISTORY_NOC_REGIONS T2
ON T1.noc = T2.noc
WHERE medal IN ('Gold','Silver','Bronze')
GROUP BY T2.region
ORDER BY no_of_medals DESC
LIMIT 5

-- 14 List down total gold, silver and broze medals won by each country.


SELECT T2.region,
COUNT(CASE WHEN medal = 'Gold' THEN 1 END) as Gold,
COUNT(CASE WHEN medal = 'Silver' THEN 1 END) as Silver,
COUNT(CASE WHEN medal = 'Bronze' THEN 1 END) as Bronze
FROM OLYMPICS_HISTORY T1
JOIN OLYMPICS_HISTORY_NOC_REGIONS T2
ON T1.noc = T2.noc
GROUP BY T2.region
ORDER BY Gold DESC

-- SELECT medal,T2.region,count(1)
-- FROM OLYMPICS_HISTORY T1
-- JOIN OLYMPICS_HISTORY_NOC_REGIONS T2
-- ON T1.noc = T2.noc
-- WHERE medal IN ('Gold','Silver','Bronze')
-- GROUP BY medal,T2.region
-- ORDER BY T2.region


-- 15 List down total gold, silver and broze medals won by each country corresponding to each olympic games.


select * from OLYMPICS_HISTORY;
select * from OLYMPICS_HISTORY_NOC_REGIONS;


SELECT games,region,COUNT(medal) AS no_of_gold
FROM OLYMPICS_HISTORY T1
JOIN OLYMPICS_HISTORY_NOC_REGIONS T2
ON T1.noc = T2.noc
WHERE medal = 'Gold'
GROUP BY games,region
ORDER BY games,region


SELECT  games,region,COUNT(medal) AS no_of_silver
FROM OLYMPICS_HISTORY T1
JOIN OLYMPICS_HISTORY_NOC_REGIONS T2
ON T1.noc = T2.noc
WHERE medal = 'Silver'
GROUP BY games,region
ORDER BY games,region


SELECT  games,region,COUNT(medal) AS no_of_bronze
FROM OLYMPICS_HISTORY T1
JOIN OLYMPICS_HISTORY_NOC_REGIONS T2
ON T1.noc = T2.noc
WHERE medal = 'Bronze'
GROUP BY games,region
ORDER BY games,region


-- 16 Identify which country won the most gold, most silver and most bronze medals in each olympic games.

SELECT A.games AS games, CONCAT(A.region,' - ',A.no_of_gold) AS max_gold,
CONCAT(B.region, ' - ', B.no_of_silver) AS max_silver,
CONCAT(C.region,' - ',C.no_of_bronze) AS max_bronze
FROM(WITH CTE AS(SELECT *,DENSE_RANK() OVER(PARTITION BY games ORDER BY no_of_gold DESC) AS rnk
FROM(SELECT games,region,COUNT(medal) AS no_of_gold
FROM OLYMPICS_HISTORY T1
JOIN OLYMPICS_HISTORY_NOC_REGIONS T2
ON T1.noc = T2.noc
WHERE medal = 'Gold'
GROUP BY games,region
)X)

SELECT games,region,no_of_gold
FROM cte
WHERE rnk = 1)A
	
JOIN 
	
(WITH CTE AS(SELECT *,DENSE_RANK() OVER(PARTITION BY games ORDER BY no_of_silver DESC) AS rnk
FROM(SELECT games,region,COUNT(medal) AS no_of_silver
FROM OLYMPICS_HISTORY T1
JOIN OLYMPICS_HISTORY_NOC_REGIONS T2
ON T1.noc = T2.noc
WHERE medal = 'Silver'
GROUP BY games,region)X)

SELECT games,region,no_of_silver
FROM cte
WHERE rnk = 1)B
	
ON A.games = B.games

JOIN 
	
(WITH CTE AS(SELECT *,DENSE_RANK() OVER(PARTITION BY games ORDER BY no_of_bronze DESC) AS rnk
FROM(SELECT games,region,COUNT(medal) AS no_of_bronze
FROM OLYMPICS_HISTORY T1
JOIN OLYMPICS_HISTORY_NOC_REGIONS T2
ON T1.noc = T2.noc
WHERE medal = 'Bronze'
GROUP BY games,region)X)

SELECT games,region,no_of_bronze
FROM CTE
WHERE rnk = 1)C

ON C.games = B.games



-- 17 Identify which country won the most gold, most silver, most bronze medals and the most medals in each olympic games.

select * from OLYMPICS_HISTORY;
select * from OLYMPICS_HISTORY_NOC_REGIONS;

	
-- 18 Which countries have never won gold medal but have won silver/bronze medals?

SELECT region, medal FROM(SELECT DISTINCT region,medal FROM OLYMPICS_HISTORY T1
JOIN OLYMPICS_HISTORY_NOC_REGIONS T2
ON T1.noc = T2.noc
WHERE region NOT IN
(SELECT DISTINCT region FROM OLYMPICS_HISTORY T1
JOIN OLYMPICS_HISTORY_NOC_REGIONS T2
ON T1.noc = T2.noc
WHERE medal = 'Gold'))X
WHERE medal IN ('Bronze','Silver')
ORDER BY region


-- 19 In which Sport/event, India has won highest medals.

select sport,count(medal) AS no_of_medals_won from OLYMPICS_HISTORY
WHERE noc = 'IND' AND (medal IN ('Gold','Silver','Bronze'))
GROUP BY sport
ORDER BY no_of_medals_won DESC
LIMIT 1


-- 20 Break down all olympic games where india won medal for Hockey and how many medals in each olympic games.

select  noc,medal,games,sport,COUNT(*) AS no_of_medal
from OLYMPICS_HISTORY
WHERE noc = 'IND' and sport = 'Hockey' AND (medal IN ('Gold','Silver','Bronze'))
GROUP BY NOC,medal,games,sport
ORDER BY no_of_medal DESC;



