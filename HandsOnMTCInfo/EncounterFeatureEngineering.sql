

select pt.____ as PatientID
        , peh.____ as PatientEncounterID
        , grptwelve.____ as RegionDSC
        , grpthirteen.____ as FacilityNM
        , cd.____ as DepartmentID
        , cd.____ as DepartmentNM
        , peh.____ as PatientClassificationCD
        , ptclass.____ as PatientClassificationDSC
        , case when cd.____ = 10 then 'UPH'
                else 'Rural'
            end as DepartmentAffiliateStatusDSC -- codes used to identify rural vs senior afiiliate status
        , peh.____ as HospitalAdmitDTS
        , peh.____ as HospitalDischargeDTS
        , cd.____ as SpecialtyDSC
        , 1 as InpatientEncounterFLG
        , case when peh.____ = '104' and peh.____ in (2,3) then 1 -- codes for obs encounters
                when hact.____ IN (1) then 0 -- code for inpatient encounters
                else null
            end as ObservationEncounterFLG
from _____ pt
    inner join PatientHospitalEncounter peh  on 
        pt._____ = peh._____
        and peh._____ between 101401000 and 999999999
        and peh._____ >= @ReferenceDTS
        and peh._____ not in (2,3) -- get rid of cancelled and pending records
    inner join Identity idid on 
        peh._____ = idid._____ 
        and idid._____ = 14
    inner join HospitalAccount hact on 
        peh._____ = hact._____ 
        and peh._____ = hact._____
        and (
                (peh._____ = '104' and peh._____ in (2,3)) -- OBSERVATION
                or 
                hact._____ IN (1) -- INPATIENT
            )
    inner join Department cd on 
        peh._____ = cd._____
        and cd._____ between 101401 and 999999
    inner join Location cl on cd._____ = cl._____
    left join PatientClass ptclass on peh._____ = ptclass._____
    left join Report12 grptwelve on cd._____ = grptwelve._____
    left join Report13 grpthirteen on cd._____ = grpthirteen._____
