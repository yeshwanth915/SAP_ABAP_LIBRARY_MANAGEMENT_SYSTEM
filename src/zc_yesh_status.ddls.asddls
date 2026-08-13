@Metadata.ignorePropagatedAnnotations: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Status dropdown'

define view entity ZC_YESH_STATUS
  as select from ZR_YESH_DB_LIB_SYS
{
  key cast( 'AVAILABLE' as abap.char(20) ) as Status
}
where BookID is not null

union select from ZR_YESH_DB_LIB_SYS
{
  key cast( 'ISSUED'    as abap.char(20) ) as Status
}
where BookID is not null
