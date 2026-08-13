@AccessControl.authorizationCheck: #MANDATORY
@Metadata.allowExtensions: true
@ObjectModel.sapObjectNodeType.name: 'ZCLINIC_DOC_SPEC'
@EndUserText.label: '###GENERATED Core Data Service Entity'
//Definimos como una vista
define view entity ZR_CLINIC_DOC_SPEC
    as select from zclinic_doc_spec
    
//Definimos asociaciones  
association to ZR_CLINIC_DOCTOR as _Doctor
    on $projection.Doctoruuid = _Doctor.DoctorUUID

association to ZR_CLINIC_SPEC as _Spec
    on $projection.Specuuid = _Spec.Specuuid
{
  key doctoruuid as Doctoruuid,
  key specuuid as Specuuid,
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
  
//Añadimos las entidades de la asociación  
  _Doctor,
  _Spec
}

//Definimos las relaciones donde Doctor va a ser el padre y 
//Spec va a ser una asociación
