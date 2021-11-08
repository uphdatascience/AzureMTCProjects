
/*

Population for this project is any patient who had a visit to the health system within 12 months of reference date, this is our definition of an "active" patient. We only want to predict risk for patients we are currently caring for

Purpose of date(s) variable(s) | @ReferenceDTS will be used in downstream queries to gather features and target. Serves as an anchor date.
Date(s) for Training | Reference date for training pipeline is 18 months ago because the target is ED visit in the next 12 months so 18 months gives us plenty of time to find outcome, Features and target queries will use this date to determine where to look from
Date(s) for Production | Production/Scoring pipeline would use today as reference date because downstream queries will want to get current patient info. Scoring/Production is predicted risk in the next 12 months of going to the ED

*/

DROP TABLE IF EXISTS ProjectOne.Population;

declare @ReferenceDTS as datetime2;
set @ReferenceDTS = dateadd(month, -18, dateadd(day, datediff(Day,0, getdate()), 0)); -- TRAINING | will allow us to find patients who were active of the date listed here (with help of dateadd in the WHERE clause)
-- set @ReferenceDTS = dateadd(day, datediff(Day,0, getdate()), 0); -- PRODUCTION | will allow us to find patients who are active as of date listed here (today), only want to score active patients

select distinct PATIENT as PatientID
                , @ReferenceDTS as ReferenceDTS -- the date by which features and target will be measured from in downstream queries
into ProjectOne.Population
from Encounter.PatientEncounter
where [START] > dateadd(month, -12, @ReferenceDTS) -- get all encounters in the past 12 months of @ReferenceDTS, resulting patients are the patients we say are "active" patients when assessing as of @ReferenceDTS
