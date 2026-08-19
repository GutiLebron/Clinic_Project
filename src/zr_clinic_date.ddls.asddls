@AccessControl.authorizationCheck: #MANDATORY
@Metadata.allowExtensions: true
@ObjectModel.sapObjectNodeType.name: 'ZCLINIC_DATE'
@EndUserText.label: '###GENERATED Core Data Service Entity'
define root view entity ZR_CLINIC_DATE
  as select from zclinic_date
  
  association [1..1] to ZR_CLINIC_DOCTOR as _Doctor
    on $projection.Doctoruuid = _Doctor.DoctorUUID
    
  association [1..1] to ZR_CLINIC_PATIENT as _Patient
    on $projection.Patientuuid = _Patient.PatientUUID
{
  key dateuuid as Dateuuid,
  appointment_date as AppointmentDate,
  patientuuid as Patientuuid,
  doctoruuid as Doctoruuid,
  appointment_time as AppointmentTime,
  appointment_status as AppointmentStatus,
  appointment_type as AppointmentType,
  notes as Notes,
  @Semantics.user.createdBy: true
  created_by as CreatedBy,
  @Semantics.systemDateTime.createdAt: true
  created_at as CreatedAt,
  @Semantics.user.lastChangedBy: true
  last_changed_by as LastChangedBy,
  @Semantics.systemDateTime.lastChangedAt: true
  last_changed_at as LastChangedAt,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  local_last_changed_at as LocalLastChangedAt,
  
  _Doctor,
  _Patient
}
