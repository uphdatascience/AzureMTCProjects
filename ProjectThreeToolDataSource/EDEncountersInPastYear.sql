

/*

This query gathers info about the patients in the population to later display in a dashboard.
Certain groups of clinicians are interested in how many ED visits patients had in the past year and how they might prevent frequent use in the future

*/

DROP TABLE IF EXISTS ProjectThree.EDEncounterInPastYear;

select pop.PatientID
       , count(*) as EDVisitsCNT
into ProjectThree.EDEncounterInPastYear
from ProjectThree.Population pop
    inner join Encounter.PatientEncounter enc on 
        pop.PatientID = enc.PATIENT
        and ENCOUNTERCLASS = 'emergency' -- only looking at ED visits
        and enc.START >= dateadd(month, -12, dateadd(day, datediff(Day,0, getdate()), 0)) -- get all that ocurred in the past year
        and enc.START < dateadd(day, datediff(Day,0, getdate()), 0) -- but sometimes scheduled surgeries, etc are in our encounter table so make sure it doesn't count anything beyond today
group by pop.PatientID
