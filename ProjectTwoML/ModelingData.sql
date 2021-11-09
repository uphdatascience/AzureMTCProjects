
/*

This query joins the output of the other queries into one table to use as the input to a ML training pipeline or scoring pipeline

Training | this has the features and target in it so it will feed into an ML training pipeline to produce a model at the end
Production | the target column will be commented out in a production system (or left in and removed in a scoring script) and the output will be fed into an already trained model, be scored, and then saved to an output table

*/

DROP TABLE IF EXISTS ProjectTwo.ModelingData;

-- SELECT statement contains all the pieces we need for predicting and recording the prediction depending on training/production
-- for each feature/target, decision needs to be made about isnull. for example, 0 is not an appropriate value for A1c and Potassium, those will be imputed later. 0 is appropriate for target because we know if it's NULL, it didn't happen
select pop.PatientID
       , pop.PatientEncounterID
       -- the features
       , a1c.LastLabA1c
       , potassium.LastLabPotassium
       -- the target
       , isnull(readmit.TargetReadmissionFLG, 0) as TargetReadmissionFLG
into ProjectTwo.ModelingData
from ProjectTwo.Population pop
    -- all of the features and targets
    -- PatientEncounterID is used because it will be unique, usually keep PatientID in SELECT for validation or further use down the line 
    left join ProjectTwo.LabA1c a1c on pop.PatientEncounterID = a1c.PatientEncounterID
    left join ProjectTwo.LabPotassium potassium on pop.PatientEncounterID = potassium.PatientEncounterID
    left join ProjectTwo.TargetReadmission readmit on pop.PatientEncounterID = readmit.PatientEncounterID

