@AccessControl.authorizationCheck: #MANDATORY
@Metadata.allowExtensions: true
@ObjectModel.sapObjectNodeType.name: 'ZCLINIC_DOCTOR'
@EndUserText.label: 'Root View Doctor'

define root view entity ZR_CLINIC_DOCTOR
  as select from zclinic_doctor
  
//Añadimos la asociación con su cardinalidad DOC(1) -> (*)DocSpec
composition [0..*] of ZR_CLINIC_DOC_SPEC as _DocSpec
{
  key doctoruuid as DoctorUUID,
  firstname as FirstName,
  lastname as LastName,
  licensenumber as LicenseNumber,
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
  local_last_changed_at as LocalLastChangedAt,
  
  //Añadimos la entidad relacionada
  _DocSpec
}
