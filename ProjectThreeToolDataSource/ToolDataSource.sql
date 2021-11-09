

/*

This query prepares our data source for a visualization tool

*/

DROP TABLE IF EXISTS ProjectThree.ToolDataSource;

select pop.PatientID
       , demo.StateDSC
       , ed.EDVisitsCNT
into ProjectThree.ToolDataSource
from ProjectThree.Population pop
    left join ProjectThree.PatientDemographics demo on pop.PatientID = demo.PatientID
    left join ProjectThree.EDEncounterInPastYear ed on pop.PatientID = ed.PatientID