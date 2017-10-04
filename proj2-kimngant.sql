/************************************************************************
 * Program Name: Databases_Project2.sql                                 *
 *                                                                      *
 * Purpose: write some SQL queries and execute them in a database       * 
 *          server. The schemas of the tables will be given             *
 *          and such tables are loaded with real NBA statistics data.   *
 *          Specifically, the database contains six tables.             *
 *                                                                      *
 *                                                                      *
 *                                                                      *
 * Author: Kim Ngan Thai                      COP 4710 Databases        *
 ************************************************************************/

\o proj2-kimngant.out


-- Put your SQL statement under the following lines:

 --1. Find all the coaches who have coached exactly ONE team. List their first names followed by their last names;

SELECT t1.firstname, t1.lastname 
FROM(   SELECT c.cid, c.firstname, c.lastname, c.tid 
        FROM coaches_season c 
        GROUP BY c.cid, c.firstname, c.lastname, c.tid ) as t1 
GROUP BY t1.cid, t1.firstname, t1.lastname 
HAVING count(t1.cid) =1;

--2. Find all the players who played in a Boston team and a Denver team (this does not have to happen in the same season). List their first names only. 

SELECT p2.firstname 
FROM (( SELECT prs.ilkid, prs.firstname 
        FROM player_rs prs, teams t 
        WHERE prs.tid=t.tid AND t.tid='BOS') 
INTERSECT ( SELECT prs.ilkid, prs.firstname 
            FROM player_rs prs, teams t 
            WHERE prs.tid=t.tid AND t.tid='DEN')) as P2;

--3. Find those who happened to be a coach and a player in the same team in the same season. List their first names, last names, the team where this happened, and the year(s) when this happened. 

SELECT c.firstname, c.lastname, c.tid, c.year 
FROM coaches_season c, player_rs p 
WHERE c.cid=p.ilkid AND c.tid=p.tid AND c.year=p.year;

--4. Find the average height (in centimeters) of each team coached by Phil Jackson in each season. Print the team name, season and the average height value (in centimeters), and sort the results by the average height. 

SELECT t.name as Team_Name, prs.year as season, avg(((p.h_feet*12)+p.h_inches)*2.54) 
FROM players p, teams t, player_rs prs, coaches_season c 
WHERE c.tid = prs.tid and t.tid = prs.tid and p.ilkid = prs.ilkid and t.league = prs.league and c.year = prs.year and c.cid = 'JACKSPH01' 
GROUP BY prs.tid, t.name, prs.year 
ORDER BY avg(((p.h_feet*12)+p.h_inches)*2.54);		

--5. Find the coach(es) (first name and last name) who have coached the largest number of players in year 1999.

SELECT distinct c.firstname, c.lastname
FROM coaches_season c
WHERE (c.year = 1999) and (c.cid IN (SELECT c.cid 
                                 FROM player_rs ps,coaches_season c 
                                 WHERE (ps.year = c.year) and (ps.tid = c.tid) and (c.year = 1999)
                                 group by c.cid
                                 HAVING count(ps.ilkid) = (SELECT max(C2.total_p)
                                                           FROM (SELECT c.firstname, c.lastname,count(ps.ilkid) as total_p
                                                                 FROM coaches_season c, player_rs PS
                                                                 WHERE (c.tid = ps.tid) and (c.year = 1999) AND (ps.year = 1999) 
                                                                 group by c.firstname, c.lastname) as C2)));

--6. Find the coaches who coached in ALL leagues. List their first names followed by their last names.

SELECT c.firstname, c.lastname 
FROM coaches_season c, teams t 
WHERE c.tid = t.tid AND c.cid NOT IN( (	SELECT c.cid 
                                        FROM coaches_season c, teams t 
                                        WHERE c.tid = t.tid GROUP BY c.cid 
                                        HAVING every(t.league='A')) UNION ( SELECT c.cid 
                                                                            FROM coaches_season c, teams t 
                                                                            WHERE c.tid = t.tid 
                                                                            GROUP BY c.cid 
                                                                            HAVING every(t.league='N'))) 
GROUP BY c.cid, c.firstname, c.lastname;  

--7. Find those who happened to be a coach and a player in the same season, but in different teams. List their first names, last names, the season and the teams this happened.
SELECT 	C.firstname ,C.lastname ,C.year ,C.tid AS coach_team ,P.tid AS player_team 
FROM coaches_season AS C , player_rs AS P , teams AS T 
WHERE C.cid = P.ilkid  AND 	C.year = P.year  AND 	C.tid <> P.tid 
GROUP BY c.cid , C.year , C.tid , P.tid , C.firstname , C.lastname 
ORDER BY C.cid ;

--8. Find the players who have scored more points than Michael Jordan did. Print out the first name, last name, and total number of points they scored.

SELECT prsc.firstname, prsc.lastname, sum(prsc.pts) 
FROM player_rs_career prsc 
GROUP BY prsc.ilkid, prsc.firstname, prsc.lastname 
HAVING sum(pts) > ( SELECT pts FROM player_rs_career prsc 
                    WHERE prsc.firstname='Michael' and prsc.lastname='Jordan');

--9. Find the second most successful coach in regular seasons in history. The level of success of a coach is measured as season_win /(season_win + season_loss). Note that you have to count in all seasons a coach attended to calculate this value.
	
SELECT c.cid, c.firstname, c.lastname, (sum(season_win) + 0.0)/(sum(season_win) + sum(season_loss) + 0.0) as Sucess_Pt 
FROM coaches_season c 
GROUP BY c.cid, c.firstname, c.lastname 
ORDER BY Sucess_Pt 
DESC LIMIT 1 OFFSET 1;

--10. List the top 10 schools that sent the largest number of drafts to NBA. List the name of each school and the number of drafts sent. Order the results by number of drafts (hint: use "order by" to sort the results and 'limit xxx' to limit the number of rows returned); 
SELECT draft_FROM, count(*) as Draft_Sent 
FROM draft d 
GROUP BY draft_FROM 
ORDER BY Draft_Sent 
DESC limit 10;

-- redirecting output to console 
\o