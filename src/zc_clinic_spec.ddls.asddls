@Metadata.allowExtensions: true
@Metadata.ignorePropagatedAnnotations: true
@EndUserText: {
  label: 'Spec Projection View'
}
@ObjectModel: {
  sapObjectNodeType.name: 'ZCLINIC_SPEC'
}
@AccessControl.authorizationCheck: #MANDATORY
define root view entity ZC_CLINIC_SPEC
  provider contract transactional_query
  as projection on ZR_CLINIC_SPEC
  association [1..1] to ZR_CLINIC_SPEC as _BaseEntity on $projection.Specuuid = _BaseEntity.Specuuid
{
  key Specuuid,
  Name,
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
