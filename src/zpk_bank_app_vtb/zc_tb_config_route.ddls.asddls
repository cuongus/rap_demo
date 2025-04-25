@Metadata.allowExtensions: true
@EndUserText.label: '###GENERATED Core Data Service Entity'
@AccessControl.authorizationCheck: #CHECK
define root view entity ZC_TB_CONFIG_ROUTE
  provider contract TRANSACTIONAL_QUERY
  as projection on ZR_TB_CONFIG_ROUTE
{
  key UriAuth,
  key UriSendPayment,
  Status,
  CreatedAt,
  CreatedBy,
  LastChangedAt,
  LastChangedBy,
  LocalLastChangedBy,
  LocalLastChangedAt
  
}
