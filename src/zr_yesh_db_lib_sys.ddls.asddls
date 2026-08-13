@AccessControl.authorizationCheck: #MANDATORY
@Metadata.allowExtensions: true
@ObjectModel.sapObjectNodeType.name: 'ZYESH_DB_LIB_SYS'
@EndUserText.label: '###GENERATED Core Data Service Entity'
define root view entity ZR_YESH_DB_LIB_SYS
  as select from zyesh_db_lib_sys
{
  key book_id as BookID,
  book_name as BookName,
  author as Author,

  status as Status,
  @Semantics.systemDateTime.createdAt: true
  created_at as CreatedAt,
  @Semantics.user.createdBy: true
  created_by as CreatedBy,
  @Semantics.systemDateTime.lastChangedAt: true
  last_changed_at as LastChangedAt,
  @Semantics.user.lastChangedBy: true
  last_changed_by as LastChangedBy,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  local_last_changed_at as LocalLastChangedAt
}
