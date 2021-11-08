

/*

This query identifies if a patient had any ED visits in the following 12 months of ReferenceDTS
This info will be used as the target of the model, the thing we're trying to predict
ED visits are something the team is trying to prevent happening so knowing the risk will help prioritize outreach

*/

DROP TABLE IF EXISTS ProjectOne.TargetEDEncounter;

-- using a distinct because a patient could have more than 1 ED visit within 12 months of ReferenceDTS but we only care that it happened or didn't happen, not how many
select distinct pop.PatientID
                , 1 as TargetEDEncounterFLG
into ProjectOne.TargetEDEncounter
from ProjectOne.Population pop
    inner join Encounter.PatientEncounter enc on 
        pop.PatientID = enc.PATIENT
        and ENCOUNTERCLASS = 'emergency' -- only looking at ED visits
        and enc.START > pop.ReferenceDTS -- happened after the reference date that clinical data is accurate as of (ReferenceDTS)...
        and enc.START <= dateadd(month, 12, pop.ReferenceDTS) -- ...but within 12 months

