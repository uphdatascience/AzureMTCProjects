
/*

Population for this project is patients who have been discharged from our facilites in the past 18-ish months and have been out of the hospital for at least 30 days. 30 days is the window needed to identify if the outcome happened

Purpose of date(s) variable(s) | @StartDTS and @EndDTS will be used only by training pipeline to get patients who will be the training examples, production will use different fields
Date(s) for Training | The time period of patient discharges we want as training example. StartDTS captures patients who have discharged "recently", subjective assessment of what dates that the current healthcare environment applies to, EndDTS ensures patients have had the outcome window surpassed
Date(s) for Production | Production patients are anyone currently in the hospital which is identified differently (STOP is null) so they won't be used in production

Extra notes:
    when switching to production system, the current uncommented WHERE clause will be commented out and will be replaced by commented out WHERE at the bottom

*/

DROP TABLE IF EXISTS ProjectTwo.Population;

declare @StartDTS as datetime2;
declare @EndDTS as datetime2;

set @StartDTS = dateadd(month, -18, dateadd(day, datediff(Day,0, getdate()), 0)); -- TRAINING | The furthest back we want to go to find discharges to use to train the models. More than 18 months might not reflect what the healthcare environment looks like right now
set @EndDTS = dateadd(day, -30, dateadd(day, datediff(Day,0, getdate()), 0)); -- TRAINING | The date that any training examples must be as of, anyone after this has not had 30 outside of the hospital so they haven't met the outcome window (30 days readmissions)

select distinct PATIENT
                , [STOP] as ReferenceDTS -- all features and target will be judged on this, different for every patient. readmission target is 30 days from this date, features within 12 months looking back
into ProjectTwo.Population
from Encounter.PatientEncounter
-- TRAINING | below is the logic for finding patients who will be training examples
where ENCOUNTERCLASS = 'inpatient' -- readmissions work applies to inpatient stays, not observation or ED visits
      and [STOP] >= @StartDTS -- the start date of all "recent" hospitalizations or hospitalizations that we estimate are indicative of the current healthcare environment
      --and [STOP] <= @EndDTS -- ensures that training patients have met the outcome window, 30 days out of hospital

-- PRODUCTION | population is any patient that is currently in the hospital, they will get a prediction for 30 day readmit risk each day
-- where ENCOUNTERCLASS = 'inpatient' -- readmissions work applies to inpatient stays, not observation or ED visits
--       and [STOP] is null -- the patients who get scores are patients in the hospital, hence NULL stop/discharge date
