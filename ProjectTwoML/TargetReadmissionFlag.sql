
/*

This query identifies if a patient had a readmission following the index hospitalization
This info will be used as the target of the model, the thing we're trying to predict
A readmission is another inpatient stay within 30 days of discharge of an inpatient stay

*/

DROP TABLE IF EXISTS ProjectTwo.TargetReadmission;

-- using a distinct because a patient could have more than 1 inpatient visit within 30 days of the index discharge but we only care that it happened or didn't happen, not how many
select distinct pop.PatientID
                , pop.PatientEncounterID
                , 1 as TargetReadmissionFLG
into ProjectTwo.TargetReadmission
from ProjectTwo.Population pop
    inner join Encounter.PatientEncounter enc on 
        pop.PatientID = enc.PATIENT
        and ENCOUNTERCLASS = 'inpatient' -- readmissions are only inpatient visits
        and enc.START > pop.ReferenceDTS -- happened after the discharge of the index encounter (ReferenceDTS)...
        and enc.START <= dateadd(day, 30, pop.ReferenceDTS) -- ...but within 30 days of discharge/ReferenceDTS, any visits past that don't matter in the context of this encounter

