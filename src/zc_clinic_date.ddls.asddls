@Metadata.allowExtensions: true
@Metadata.ignorePropagatedAnnotations: true
@EndUserText: {
  label: '###GENERATED Core Data Service Entity'
}
@ObjectModel: {
  sapObjectNodeType.name: 'ZCLINIC_DATE'
}
@AccessControl.authorizationCheck: #MANDATORY
define root view entity ZC_CLINIC_DATE
  provider contract transactional_query
  as projection on ZR_CLINIC_DATE
  association [1..1] to ZR_CLINIC_DATE as _BaseEntity on $projection.Dateuuid = _BaseEntity.Dateuuid
{
  key Dateuuid,
  Patientuuid,
  Doctoruuid,
  AppointmentDate,
  AppointmentTime,
  AppointmentStatus,
  AppointmentType,
  Notes,
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
