
/*

This query joins the output of the other queries into one table to use as the input to a ML training pipeline or scoring pipeline

Training | this has the features and target in it so it will feed into an ML training pipeline to produce a model at the end
Production | the target column will be commented out in a production system (or left in and removed in a scoring script) and the output will be fed into an already trained model, be scored, and then saved to an output table

*/

DROP TABLE IF EXISTS ProjectOne.ModelingData;

-- SELECT statement contains all the pieces we need for predicting and recording the prediction depending on training/production
-- for each feature/target, decision needs to be made about isnull. for example, 0 is not an appropriate value for A1c and Potassium, those will be imputed later. 0 is appropriate for target because we know if it's NULL, it didn't happen
select pop.PatientID
       -- the features
       , a1c.LastLabA1c
       , potassium.LastLabPotassium
       -- the target
       , isnull(ed_enc.TargetEDEncounterFLG, 0) as TargetEDEncounterFLG
into ProjectOne.ModelingData
from ProjectOne.Population pop
    -- all of the features and targets
    -- PatientID is used because it's the unique identifier, it can only be used once in the population
    left join ProjectOne.LabA1c a1c on pop.PatientID = a1c.PatientID
    left join ProjectOne.LabPotassium potassium on pop.PatientID = potassium.PatientID
    left join ProjectOne.TargetEDEncounter ed_enc on pop.PatientID = ed_enc.PatientID

