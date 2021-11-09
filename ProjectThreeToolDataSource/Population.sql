
/*

Population for this query is any patient who had a visit to the health system within 12 months of reference date, this is our definition of an "active" patient. 
This is the population that we will want to show on our dashboard, which is what this project will produce.
Additional patient characteristics will be added throughout the pipeline.

*/

DROP TABLE IF EXISTS ProjectThree.Population;

declare @ReferenceDTS as datetime2;
set @ReferenceDTS = dateadd(day, datediff(Day,0, getdate()), 0); -- will allow us to find patients who are "active" as of date listed here (today)

select distinct PATIENT as PatientID
into ProjectThree.Population
from Encounter.PatientEncounter
where [START] > dateadd(month, -12, @ReferenceDTS) -- get all encounters in the past 12 months of @ReferenceDTS, resulting patients are the patients we say are "active"

