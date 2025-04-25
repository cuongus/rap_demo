@Metadata.allowExtensions: true
@EndUserText.label: '###GENERATED Core Data Service Entity'
@AccessControl.authorizationCheck: #CHECK
define root view entity ZC_TB_TCV_API_KEY000
  provider contract transactional_query
  as projection on ZTB_R_TCV_API_KEY000
{
  key XIbmClientSecret,
  key XIbmClientId,
  IsActive,
  CreatedBy,
  CreatedAt
}
