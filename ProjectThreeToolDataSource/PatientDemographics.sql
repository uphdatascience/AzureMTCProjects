

/*

This query gathers info about where a patient lives because resources are allocated to different locations based on number of patients. Clinicians will also work with patients only in their area
This will allow for filtering on the dashboard to make it useful for clinicians

*/

DROP TABLE IF EXISTS ProjectThree.PatientDemographics;

select pop.PatientID
       , STATE as StateDSC
into ProjectThree.PatientDemographics
from ProjectThree.Population pop
    inner join Epic.Patient.Patient pt on pop.PatientID = pt.Id

