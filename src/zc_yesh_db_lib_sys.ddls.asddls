@Metadata.allowExtensions: true
@Metadata.ignorePropagatedAnnotations: true
@EndUserText: {
  label: 'LIBRARY MANAGEMENT SYSTEM'
}
@ObjectModel: {
  sapObjectNodeType.name: 'ZYESH_DB_LIB_SYS'
}
@AccessControl.authorizationCheck: #MANDATORY
define root view entity ZC_YESH_DB_LIB_SYS
  provider contract transactional_query
  as projection on ZR_YESH_DB_LIB_SYS
  association [1..1] to ZR_YESH_DB_LIB_SYS as _BaseEntity on $projection.BookID = _BaseEntity.BookID
{

  key BookID,
  BookName,
  Author,

  @UI.lineItem: [{ position: 30 }]
@UI.identification: [{ position: 30 }]
@Consumption.valueHelpDefinition: [{
    entity: {
        name: 'ZC_YESH_STATUS',
        element: 'Status'
    }
}]
Status,

  @Semantics: {
    systemDateTime.createdAt: true
  }
  CreatedAt,
  @Semantics: {
    user.createdBy: true
  }
  CreatedBy,
  @Semantics: {
    systemDateTime.lastChangedAt: true
  }
  LastChangedAt,
  @Semantics: {
    user.lastChangedBy: true
  }
  LastChangedBy,
  @Semantics: {
    systemDateTime.localInstanceLastChangedAt: true
  }
  LocalLastChangedAt,
  _BaseEntity
}
