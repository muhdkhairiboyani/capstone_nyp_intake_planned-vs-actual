-------------------------------------------------------------------
-------------------------------------------------------------------
-------------------------------------------------------------------

-- 1_TABLE MODS for intake

--CHECK for NULL
select * from planned_intake
where code is null and year is null;

select * from intake
where code is null and year is null;

-- Result: NO NULLS


-- 1.1_RENAME COLUMNS
select * from intake;

ALTER TABLE intake 
RENAME COLUMN academic_year TO year;

ALTER TABLE intake 
RENAME COLUMN jae_course_code TO code;

ALTER TABLE intake 
RENAME COLUMN course_name TO course;


-- 1.2_DUPLICATE intake as intake_dupe as a backup
create table intake_dupe as (select * from intake);


-- 1.3_DELETE ROWS with year between 2013 and 2015 because year in planned_intake table starts from 2016
delete from intake
where year between '2013' and '2015';


-- 1.4_ALTER column type
alter table intake
alter column intake type numeric
using intake::numeric;


------------------------>>><<<---------------------------------

-- 2_TABLE MODS for planned_intake

-- 2.1_RENAME COLUMNS
select * from planned_intake;

ALTER TABLE planned_intake 
RENAME COLUMN academic_year TO year;

ALTER TABLE planned_intake 
RENAME COLUMN course_name TO course;

ALTER TABLE planned_intake 
RENAME COLUMN jae_course_code TO code;

ALTER TABLE planned_intake 
RENAME COLUMN planned_intake_numbers TO planned_intake_num;

-- 2.2_ALTER column type
alter table planned_intake
alter column planned_intake_num type numeric
using planned_intake_num::numeric;


-------------------------------------------------------------------
-------------------------------------------------------------------
-------------------------------------------------------------------

-- 3_Further NORMALIZATION 

-- 3.1_CREATE SEPARATE intake tables for MALE & FEMALE
create table intake_m as (
select * from intake
where gender = 'MALE'
);

create table intake_f as (
select * from intake
where gender = 'FEMALE'
);


-------------------------------------------------------------------
-------------------------------------------------------------------
-------------------------------------------------------------------

-- 4_DATA ANALYZING

-- 4.1_SUM of Intake GROUP BY year, school, gender

-- SUM Intake FEMALE
select year, school, gender, sum(intake) as sum_intake_f
	from intake_f
	group by year, school, gender
	order by year;

-- SUM Intake MALE
select year, school, gender, sum(intake) as sum_intake_m
	from intake_m
	group by year, school, gender
	order by year;


-- 4.2_CREATE TABLE for total intake
-- SUM of Intake by year GROUP BY year, school, jae_cluster, code, course
create table total_intake as (
	select year, school, code, course, sum(intake) as total_intake
		from intake
		group by year, school, code, course
		order by year);

-- 4.3_CREATE TABLE for Percentage of total_intake Vs planned_intake using INNER JOIN
create table percent as (
	select p.year, p.school, p.code, p.course, p.planned_intake_num, t.total_intake, round (100 * (t.total_intake / p.planned_intake_num)) as percent
		from planned_intake p
		inner join total_intake t
		on p.course = t.course
		where p.year = t.year
		order by p.year, p.code);

-- 5_ TOP 5 POPULAR courss

--for FEMALE intake
select * from intake_f
where year = '2022'
order by intake desc
limit 5;

--for MALE intake
select * from intake_m
where year = '2022'
order by intake desc
limit 5;

-- SELECT for tables
select * from intake_f;
select * from intake_m;
select * from intake;
select * from total_intake;
select * from planned_intake;
select * from percent;


-------------------------------------------------------------------
-------------------------------------------------------------------
-------------------------------------------------------------------

-- DUMP tables as CSV
copy intake to '/Users/simplyroy/Downloads/05 CAPSTONE PROJECT 2_RELATIONAL DATABASE AND MS EXCEL DASHBOARD/CAPSTONE 2 SQL/DATASET/intake.csv' delimiter ',' CSV header;
copy intake_f to '/Users/simplyroy/Downloads/05 CAPSTONE PROJECT 2_RELATIONAL DATABASE AND MS EXCEL DASHBOARD/CAPSTONE 2 SQL/DATASET/intake_f.csv' delimiter ',' CSV header;
copy intake_m to '/Users/simplyroy/Downloads/05 CAPSTONE PROJECT 2_RELATIONAL DATABASE AND MS EXCEL DASHBOARD/CAPSTONE 2 SQL/DATASET/intake_m.csv' delimiter ',' CSV header;
copy planned_intake to '/Users/simplyroy/Downloads/05 CAPSTONE PROJECT 2_RELATIONAL DATABASE AND MS EXCEL DASHBOARD/CAPSTONE 2 SQL/DATASET/planned_intake.csv' delimiter ',' CSV header;
copy total_intake to '/Users/simplyroy/Downloads/05 CAPSTONE PROJECT 2_RELATIONAL DATABASE AND MS EXCEL DASHBOARD/CAPSTONE 2 SQL/DATASET/total_intake.csv' delimiter ',' CSV header;
copy percent to '/Users/simplyroy/Downloads/05 CAPSTONE PROJECT 2_RELATIONAL DATABASE AND MS EXCEL DASHBOARD/CAPSTONE 2 SQL/DATASET/percent.csv' delimiter ',' CSV header;



------------------------>>><<<---------------------------------

------------------------>>><<<---------------------------------

