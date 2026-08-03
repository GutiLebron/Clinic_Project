@Metadata.allowExtensions: true
@Metadata.ignorePropagatedAnnotations: true
@EndUserText: {
  label: 'Doctor Projection View'
}
@ObjectModel: {
  sapObjectNodeType.name: 'ZCLINIC_DOCTOR'
}
@AccessControl.authorizationCheck: #MANDATORY
define root view entity ZC_CLINIC_DOCTOR
  provider contract transactional_query
  as projection on ZR_CLINIC_DOCTOR
  association [1..1] to ZR_CLINIC_DOCTOR as _BaseEntity on $projection.DoctorUUID = _BaseEntity.DoctorUUID
{
  key DoctorUUID,
  FirstName,
  LastName,
  LicenseNumber,
  Phone,
  Email,
  Active,
  @Semantics: {
    user.createdBy: true
  }
  CreatedBy,
  @Semantics: {
    systemDateTime.createdAt: true
  }
  CreatedAt,
  @Semantics: {
    user.lastChangedBy: true
  }
  LastChangedBy,
  @Semantics: {
    systemDateTime.lastChangedAt: true
  }
  LastChangedAt,
  @Semantics: {
    systemDateTime.localInstanceLastChangedAt: true
  }
  LocalLastChangedAt,
  _BaseEntity
}
