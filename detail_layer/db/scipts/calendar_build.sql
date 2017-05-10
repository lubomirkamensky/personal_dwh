use pdwh_detail;
create or replace view v3 as select 1 n union all select 1 union all select 1; 
create or replace view v as select 1 n from v3 a, v3 b union all select 1; 
set @n = 0; 
drop table if exists year; 
create table year(year_Id int primary key, Prior_year_Id int);
insert into year 
  select
   2010 + @n:=@n+1 as year_Id
   ,2010 + @n-1 as Prior_year_Id
  from v a, v b
;
set @n = 0; 
drop table if exists month; 
create table month(month_Id int primary key, Prior_month_Id int, month_In_year tinyint, year_Id int);
insert into month 
  select
   DATE_FORMAT('2010-12-01' + interval @n:=@n+1 month,'%Y%m') AS month_Id
   ,DATE_FORMAT('2010-12-01' + interval @n-1 month,'%Y%m') AS Prior_month_Id
   ,DATE_FORMAT('2010-12-01' + interval @n month,'%m') AS month_In_year
   ,DATE_FORMAT('2010-12-01' + interval @n month,'%Y') AS year_Id
  from v a, v b, v c
;
set @n = 0; 
drop table if exists week; 
create table week(week_Id int primary key, Prior_week_Id int, week_In_year tinyint, year_Id int);
insert into week(year_Id,week_Id,Prior_week_Id,week_In_year) 
  select
   DATE_FORMAT('2010-12-27' + interval @n:=@n+7 day,'%Y') AS year_Id
   ,CASE WHEN DATE_FORMAT('2010-12-27' + interval @n day,'%m') = 1 AND DATE_FORMAT('2010-12-27' + interval @n day,'%v') > 50 THEN DATE_FORMAT('2010-12-27' + interval @n day,'%Y')*100-100+DATE_FORMAT('2010-12-27' + interval @n day,'%v')  WHEN DATE_FORMAT('2010-12-27' + interval @n day,'%m') = 12 AND DATE_FORMAT('2010-12-27' + interval @n day,'%v') = 1 THEN DATE_FORMAT('2010-12-27' + interval @n day,'%Y')*100+100+DATE_FORMAT('2010-12-27' + interval @n day,'%v') ELSE DATE_FORMAT('2010-12-27' + interval @n day,'%Y%v') END AS week_Id 
   ,CASE WHEN DATE_FORMAT('2010-12-27' + interval @n-7 day,'%m') = 1 AND DATE_FORMAT('2010-12-27' + interval @n-7 day,'%v') > 50 THEN DATE_FORMAT('2010-12-27' + interval @n-7 day,'%Y')*100-100+DATE_FORMAT('2010-12-27' + interval @n-7 day,'%v')  WHEN DATE_FORMAT('2010-12-27' + interval @n-7 day,'%m') = 12 AND DATE_FORMAT('2010-12-27' + interval @n-7 day,'%v') = 1 THEN DATE_FORMAT('2010-12-27' + interval @n-7 day,'%Y')*100+100+DATE_FORMAT('2010-12-27' + interval @n-7 day,'%v')ELSE DATE_FORMAT('2010-12-27' + interval @n-7 day,'%Y%v') END AS Prior_week_Id
   ,DATE_FORMAT('2010-12-27' + interval @n day,'%v') AS week_In_year
  from v a, v b, v c, v d
;
set @n = 0; 
drop table if exists day; 
create table day(day_Id int primary key, Prior_day_Id int, day_In_week tinyint, day_In_month tinyint, day_In_year smallint, month_Id int, week_Id int);
insert into day 
  select
   DATE_FORMAT('2010-12-31' + interval @n:=@n+1 day,'%Y%m%d') AS day_Id
   ,DATE_FORMAT('2010-12-31' + interval @n-1 day,'%Y%m%d') AS Prior_day_Id
   ,CASE WHEN DATE_FORMAT('2010-12-31' + interval @n day,'%w') = 0 THEN 7 ELSE DATE_FORMAT('2010-12-31' + interval @n day,'%w') END AS day_In_week
   ,DATE_FORMAT('2010-12-31' + interval @n day,'%d') AS day_In_month
   ,DATE_FORMAT('2010-12-31' + interval @n day,'%j') AS day_In_year
   ,DATE_FORMAT('2010-12-31' + interval @n day,'%Y%m') AS month_Id
   ,CASE WHEN DATE_FORMAT('2010-12-31' + interval @n day,'%m') = 1 AND DATE_FORMAT('2010-12-31' + interval @n day,'%v') > 50 THEN DATE_FORMAT('2010-12-31' + interval @n day,'%Y')*100-100+DATE_FORMAT('2010-12-31' + interval @n day,'%v')  WHEN DATE_FORMAT('2010-12-31' + interval @n day,'%m') = 12 AND DATE_FORMAT('2010-12-31' + interval @n day,'%v') = 1 THEN DATE_FORMAT('2010-12-31' + interval @n day,'%Y')*100+100+DATE_FORMAT('2010-12-31' + interval @n day,'%v') ELSE DATE_FORMAT('2010-12-31' + interval @n day,'%Y%v') END AS week_Id
  from v a, v b, v c, v d, v e
;
set @n = 0; 
drop table if exists hour; 
create table hour(hour_Id int primary key, Prior_hour_Id int, hour_In_day tinyint, day_Id int, hour_Start_Dt datetime, hour_End_Dt datetime, day_Start_Dt datetime, day_End_Dt datetime); 
insert into hour 
  select
   DATE_FORMAT(cast('2010-12-31 23:00:00' + interval @n:=@n+1 hour as datetime),'%Y%m%d%H') as hour_Id
   ,DATE_FORMAT(cast('2010-12-31 23:00:00' + interval @n-1 hour as datetime),'%Y%m%d%H') as Prior_hour_Id
   ,DATE_FORMAT(cast('2010-12-31 23:00:00' + interval @n hour as datetime),'%H') as hour_In_day
   ,DATE_FORMAT(cast('2010-12-31 23:00:00' + interval @n hour as datetime),'%Y%m%d') as day_Id
   ,cast('2010-12-31 23:00:00' + interval @n hour as datetime) as hour_Start_Dt
   ,cast('2010-12-31 23:00:00' + interval @n hour as datetime) + INTERVAL '59:59' MINUTE_SECOND AS hour_End_Dt
   ,DATE_FORMAT(cast('2010-12-31 23:00:00' + interval @n hour as datetime),'%Y-%m-%d 00:00:00') as day_Start_Dt
   ,DATE_FORMAT(cast('2010-12-31 23:00:00' + interval @n hour as datetime),'%Y-%m-%d 23:59:59') as day_End_Dt
  from v a, v b, v c, v d, v e, v
;