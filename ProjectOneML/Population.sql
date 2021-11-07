
/*

Population for this project is any patient who had a visit to the health system within 12 months of reference date
Reference date for training pipeline is 18 months ago because the target is ED visit in the next 12 months so 18 months gives us plenty of time to find outcome
Features will be labs, etc that happened within 12 months of reference date (kinda like how target is 12 months forward from reference date)

Production/Scoring pipeline would use today as reference date and features will look back 12 months from today.
Target flag might run but it's looking 12 months from getdate() so it would find nothing. In current system, we would jus deactivate that query when putting in PROD

*/

DROP TABLE IF EXISTS ProjectOne.Population;

declare @ReferenceDTS as datetime2;
set @ReferenceDTS = dateadd(month, -18, dateadd(day, datediff(Day,0, getdate()), 0)); -- TRAINING | will allow for feature 12 month window and target 12 month post window;
-- set @ReferenceDTS = dateadd(month, -12, dateadd(day, datediff(Day,0, getdate()), 0)); -- PRODUCTION | will allow scoring of "active" patients (patients who have been seen in past 12 months)

select distinct PATIENT
                , @ReferenceDTS as ReferenceDTS
into ProjectOne.Population
from Encounter.PatientEncounter
where [START] > dateadd(month, -12, cast(@ReferenceDTS as datetime2)) -- get all encounters in the past 12 months of @ReferenceDTS

