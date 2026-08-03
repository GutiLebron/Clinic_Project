@AccessControl.authorizationCheck: #MANDATORY
@Metadata.allowExtensions: true
@ObjectModel.sapObjectNodeType.name: 'ZCLINIC_PATIENT'
@EndUserText.label: '###GENERATED Core Data Service Entity'
define root view entity ZR_CLINIC_PATIENT
  as select from ZCLINIC_PATIENT as Patient
{
  key patient_uuid as PatientUUID,
  first_name as FirstName,
  last_name as LastName,
  birth_date as BirthDate,
  phone as Phone,
  email as Email,
  active as Active,
  @Semantics.user.createdBy: true
  created_by as CreatedBy,
  @Semantics.systemDateTime.createdAt: true
  created_at as CreatedAt,
  @Semantics.user.lastChangedBy: true
  last_changed_by as LastChangedBy,
  @Semantics.systemDateTime.lastChangedAt: true
  last_changed_at as LastChangedAt,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  local_last_changed_at as LocalLastChangedAt
}
