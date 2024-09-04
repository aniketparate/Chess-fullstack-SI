SHOW search_path;
SET search_path to chess, public;

CREATE TABLE Players (
	player_id SERIAL PRIMARY KEY ,
	first_name VARCHAR(50) NOT NULL,
	last_name VARCHAR(50) NOT NULL,
	country VARCHAR(50) NOT NULL,
	current_world_ranking INTEGER UNIQUE NOT NULL,
	total_matches_played INTEGER NOT NULL DEFAULT 0
);

INSERT INTO Players (first_name, last_name, country, current_world_ranking, total_matches_played) VALUES 
('Magnus', 'Carlsen', 'Norway', 1, 100),
('Fabiano', 'Caruana', 'USA', 2, 95),
('Ding', 'Liren', 'China', 3, 90),
('Ian', 'Nepomniachtchi', 'Russia', 4, 85),
('Wesley', 'So', 'USA', 5, 80),
('Anish', 'Giri', 'Netherlands', 6, 78),
('Hikaru', 'Nakamura', 'USA', 7, 75),
('Viswanathan', 'Anand', 'India', 8, 120),
('Teimour', 'Radjabov', 'Azerbaijan', 9, 70),
('Levon', 'Aronian', 'Armenia', 10, 72);


CREATE TABLE Matches (
	match_id SERIAL PRIMARY KEY,
	player1_id INT NOT NULL REFERENCES Players(player_id),
	player2_id INT NOT NULL REFERENCES Players(player_id),
	match_date DATE NOT NULL,
	match_level VARCHAR(20) NOT NULL CHECK (match_level IN ('International', 'National')),
	winner_id INT REFERENCES Players(player_id)
);

INSERT INTO Matches (player1_id, player2_id, match_date, match_level, winner_id)
VALUES 
(1, 2, '2024-08-01', 'International', 1),
(3, 4, '2024-08-02', 'International', 3),
(5, 6, '2024-08-03', 'National', 5),
(7, 8, '2024-08-04', 'International', 8),
(9, 10, '2024-08-05', 'National', 10),
(1, 3, '2024-08-06', 'International', 1),
(2, 4, '2024-08-07', 'National', 2),
(5, 7, '2024-08-08', 'International', 7),
(6, 8, '2024-08-09', 'National', 8),
(9, 1, '2024-08-10', 'International', 1);


CREATE TABLE Sponsors (
	sponsor_id SERIAL PRIMARY KEY,
	sponsor_name VARCHAR(100) UNIQUE NOT NULL,
	industry VARCHAR(50) NOT NULL,
	contact_email VARCHAR(100) NOT NULL,
	contact_phone VARCHAR(20) NOT NULL
);

INSERT INTO Sponsors (sponsor_name, industry, contact_email, contact_phone)
VALUES 
('TechChess', 'Technology', 'contact@techchess.com', '123-456-7890'),
('MoveMaster', 'Gaming', 'info@movemaster.com', '234-567-8901'),
('ChessKing', 'Sports', 'support@chessking.com', '345-678-9012'),
('SmartMoves', 'AI', 'hello@smartmoves.ai', '456-789-0123'),
('GrandmasterFinance', 'Finance', 'contact@grandmasterfinance.com', '567-890-1234');


CREATE TABLE Player_Sponsors(
	player_id INT NOT NULL REFERENCES Players(player_id), 
	sponsor_id INT NOT NULL REFERENCES Sponsors(sponsor_id),
	sponsorship_amount NUMERIC(10, 2) NOT NULL,
	contract_start_date DATE NOT NULL,
	contract_end_date DATE NOT NULL,
	Primary Key (player_id, sponsor_id)
);

INSERT INTO Player_Sponsors (player_id, sponsor_id, sponsorship_amount, contract_start_date, contract_end_date)
VALUES 
(1, 1, 500000.00, '2023-01-01', '2025-12-31'),
(2, 2, 300000.00, '2023-06-01', '2024-06-01'),
(3, 3, 400000.00, '2024-01-01', '2025-01-01'),
(4, 4, 350000.00, '2023-03-01', '2024-03-01'),
(5, 5, 450000.00, '2023-05-01', '2024-05-01'),
(6, 1, 250000.00, '2024-02-01', '2025-02-01'),
(7, 2, 200000.00, '2023-08-01', '2024-08-01'),
(8, 3, 600000.00, '2023-07-01', '2025-07-01'),
(9, 4, 150000.00, '2023-09-01', '2024-09-01'),
(10, 5, 300000.00, '2024-04-01', '2025-04-01');

SELECT * FROM Players;
SELECT * FROM Matches;
SELECT * FROM Sponsors;
SELECT * FROM Player_Sponsors;

-- -----------------------------------------------------------------------------
-- 1 List the match details including the player names (both player1 and player2), match date, and match level for all International matches.
select concat(pt.first_name,' ',pt.last_name) as player_1,
       concat(pt2.first_name,' ',pt2.last_name) as player_2,
       mt.match_date, mt.match_level from matches mt
join players pt on mt.player1_id = pt.player_id
join players pt2 on mt.player2_id = pt2.player_id
where mt.match_level like 'International';

-- 2  Extend the contract end date of all sponsors associated with players from the USA by one year.
update player_sponsors set contract_end_date = to_date(
    concat(date_part('year', contract_end_date) + 1, '0',
        date_part('month', contract_end_date), '0',
        date_part('day', contract_end_date)), 'yyyymmdd')
where player_id in (
    select p.player_id from players p
    join player_sponsors ps on p.player_id = ps.player_id
    where p.country = 'USA');

select date_part('year', contract_end_date),
       date_part('month', contract_end_date),
       date_part('day', contract_end_date)
from players p join player_sponsors ps on p.player_id = ps.player_id
where p.country = 'USA';

-- 3 List all matches played in August 2024, sorted by the match date in ascending order.
select * from matches where date_part('year', match_date) = '2024' 
and date_part('month', match_date) = 8 order by match_date;

--4 Calculate the average sponsorship amount provided by sponsors and display it along with the total number of sponsors. Dispaly with the title Average_Sponsorship  and Total_Sponsors.
select avg(sponsorship_amount) as average_sponsorship,
count(distinct sponsor_id) as total_sponsors from player_sponsors;

-- 5 Show the sponsor names and the total sponsorship amounts they have provided across all players. Sort the result by the total amount in descending order.
select s.sponsor_name,
       sum(ps.sponsorship_amount) as total_sponsorship_amount from player_sponsors ps
join sponsors s on ps.sponsor_id = s.sponsor_id group by s.sponsor_name
order by total_sponsorship_amount desc;

-- -------------------------------------------------------------------------------
-- 1 Retrieve the names of players along with their total number of matches won, calculated as a percentage of their total matches played.Display the full_name along with  Win_Percentage rounded to 4 decimals
select concat(p.first_name, ' ', p.last_name) as full_name,
       round((count(m.winner_id) * 100.0) / p.total_matches_played, 4) as win_percentage
from players p left join matches m on p.player_id = m.winner_id
group by p.player_id order by win_percentage desc;

-- 2 Retrieve the match details for matches where the winner's current world ranking is among the top 5 players. Display the match date, winner's name, and the match level. 
select m.match_date,
       concat(p.first_name, ' ', p.last_name) as winners_full_name,
       m.match_level from matches m
join players p on m.winner_id = p.player_id where p.current_world_ranking < 6;

-- 3 Find the sponsors who are sponsoring the top 3 players based on their current world ranking. Display the sponsor name and the player's full name an their world ranking.
select s.sponsor_name,
       p.first_name || ' ' || p.last_name as player_name,
       p.current_world_ranking from players p
join player_sponsors ps on p.player_id = ps.player_id
join sponsors s on s.sponsor_id = ps.sponsor_id
where p.current_world_ranking <= 3 order by p.current_world_ranking;

-- 4  Create a query that retrieves the full names of all players along with a label indicating their performance in the tournament based on their match win percentage. The label should be:
-- "Excellent" if the player has won more than 75% of their matches.
-- "Good" if the player has won between 50% and 75% of their matches.
-- "Average" if the player has won between 25% and 50% of their matches.
-- "Needs Improvement" if the player has won less than 25% of their matches.
-- The query should also include the player's total number of matches played and total number of matches won. The calculation for the win percentage should be done using a subquery.
select concat(p.first_name, ' ', p.last_name) as full_name,
       p.total_matches_played,
       count(m.winner_id) as total_won,
       case
           when (count(m.winner_id) * 100.0) / p.total_matches_played > 75 then 'Excellent'
           when (count(m.winner_id) * 100.0) / p.total_matches_played between 50 and 75 then 'Good'
           when (count(m.winner_id) * 100.0) / p.total_matches_played between 25 and 50 then 'Average'
           when (count(m.winner_id) * 100.0) / p.total_matches_played < 25 then 'Needs Improvement'
       end as label
from players p left join matches m on p.player_id = m.winner_id group by p.player_id;

-- 5 Retrieve the names of players who have never won a match (i.e., they have participated in matches but are not listed as a winner in any match). Display their full name and current world ranking.
select concat(p.first_name, ' ', p.last_name) as full_name,
       p.current_world_ranking
from players p left join matches m on p.player_id = m.winner_id
where m.winner_id is null order by p.current_world_ranking;

-- ------------------------------------------------------------------------------------
--PHASE 4
-- 1 Create a view named PlayerRankings that lists all players with their full name (first name and last name combined), country, and current world ranking, sorted by their world ranking in ascending order.
create view playerrankings as 
    select concat(first_name, ' ', last_name) as full_name,
           country, current_world_ranking from players order by current_world_ranking;

select * from playerrankings;

-- 2 Create a view named MatchResults that shows the details of each match, including the match date, the names of the players (both player1 and player2), and the name of the winner. If the match is yet to be completed, the winner should be displayed as 'TBD'.
create view matchresults as select m.match_date, 
           concat(p1.first_name, ' ', p1.last_name) as player_1,
           concat(p2.first_name, ' ', p2.last_name) as player_2,
           coalesce(concat(w.first_name, ' ', w.last_name), 'TBD') as winner
    from matches m
    join players p1 on p1.player_id = m.player1_id
    join players p2 on p2.player_id = m.player2_id
    left join players w on w.player_id = m.winner_id;

select * from matchresults;

-- 3  Create a view named SponsorSummary that shows each sponsor's name, the total number of players they sponsor, and the total amount of sponsorship provided by them.
create view sponsorsummary as select s.sponsor_name, 
           count(ps.player_id) as players_sponsored,
           sum(ps.sponsorship_amount) as total_amount
    from player_sponsors ps join sponsors s on ps.sponsor_id = s.sponsor_id
    group by s.sponsor_name;

select * from sponsorsummary;

-- 4 Create a view named ActiveSponsorships that lists the active sponsorships (where the contract end date is in the future). The view should include the player’s full name, sponsor name, and sponsorship amount. Ensure the view allows updates to the sponsorship amount.
create view activesponsorships as
    select concat(p.first_name, ' ', p.last_name) as player_full_name,
           s.sponsor_name, ps.sponsorship_amount, ps.contract_end_date
    from player_sponsors ps
    join players p on ps.player_id = p.player_id
    join sponsors s on s.sponsor_id = ps.sponsor_id
    where ps.contract_end_date > current_date;

select * from activesponsorships;

-- 5 
create view playerperformancesummary as
    select concat(p.first_name, ' ', p.last_name) as player_name,
           p.total_matches_played as total_matches_played,
           count(m.winner_id) as total_wins,
           round((count(m.winner_id) * 100.0) / p.total_matches_played, 4) as win_percentage,
           case 
               when national > international then 'National'
               when international > national then 'International'
               when national = international then 'Balanced'
               else 'No Winning Data'
           end as best_match_level
    from players p
    left join matches m on p.player_id = m.winner_id
    left join (
        select winner_id,
               count(case when match_level = 'National' then 1 end) as national,
               count(case when match_level = 'International' then 1 end) as international
        from matches
        group by winner_id
    ) mt on p.player_id = mt.winner_id
    group by p.player_id, p.first_name, p.last_name, p.total_matches_played, national, international
    order by win_percentage desc;

select * from playerperformancesummary;

select p.player_id,
       concat(p.first_name, ' ', p.last_name) as full_name,
       round((count(m.winner_id) * 100.0) / p.total_matches_played, 4) as win_percentage,
       count(m.winner_id) as total_won,
       p.total_matches_played
from players p
left join matches m on p.player_id = m.winner_id
group by p.player_id;

select p.player_id,
       concat(p.first_name, ' ', p.last_name) as full_name,
       round((count(m.winner_id) * 100.0) / p.total_matches_played, 4) as win_percentage,
       count(m.winner_id) as total_won,
       p.total_matches_played
from players p
left join matches m on p.player_id = m.winner_id
group by p.player_id;