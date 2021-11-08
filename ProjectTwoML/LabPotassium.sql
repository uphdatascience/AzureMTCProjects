
/*

This query gathers the last potassium lab of each patient in the population that is being used. 
Last potassium lab will be a feature used to predict the target since it is a major lab that has implications on the health of the patient.
The lab will have to have been taken within 12 months of the ReferenceDTS to ensure it is "current"

Training | potassium lab might not be the most recent the patient has taken but is most recent compared the reference date. as a reminder, the reference date is the date that is cemented as the "as of" date to allow for appropriate feature and target collection
    the ReferenceDTS is different for every patient also
Production | potassium lab will be the last one the patient had taken unless it was more than 12 months ago, then no value will be returned

*/

DROP TABLE IF EXISTS ProjectTwo.LabPotassium;

with all_labs as (
    select pop.PatientID
           , pop.PatientEncounterID
           , labs.[DATE] as DateDTS
           , labs.[VALUE] as ValueNBR
           , row_number() over(
               partition by pop.PatientID, pop.PatientEncounterID -- same patient can have multiple inpatient stays in the timeframe so patientencounterid identifier will be the main way to keep different hospitalizations separate
               order by labs.DATE desc
           ) as rn -- patient probably has many of lab done in past 12 months, but this will allow us to get most recent
    from ProjectTwo.Population pop
        inner join Orders.Results labs on 
            pop.PatientID = labs.PATIENT
            and labs.[DATE] >= dateadd(month, -12, ReferenceDTS) -- lab has to be within one year of ReferenceDTS, done to ensure the data is "recent"...
            and labs.[DATE] < ReferenceDTS -- ...but we don't want labs that haven't happened yet as of ReferenceDTS, solely a concern in training data
            and CODE = '4548-4' -- lab code for this lab
)
select PatientID
       , PatientEncounterID
       , DateDTS -- would normally keep here as a validation measure to come back to
       , ValueNBR as LastLabPotassium -- will eventually be joined to modeling data set
into ProjectTwo.LabPotassium
from all_labs
where rn = 1 -- this is how we get the most recent one, row_number in above CTE will prevent query from returning multiple rows 
