@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@EndUserText.label: '###GENERATED Core Data Service Entity'
define root view entity ZTB_R_TCV_API_KEY000
  as select from ztb_tcv_api_key
{
  key x_ibm_client_secret as XIbmClientSecret,
  key x_ibm_client_id as XIbmClientId,
  is_active as IsActive,
  @Semantics.user.createdBy: true
  created_by as CreatedBy,
  @Semantics.systemDateTime.createdAt: true
  created_at as CreatedAt
}
