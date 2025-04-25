@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'View for TCV Config Auth API Bank'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZC_RAP_TCV_CFAUTH_BANK
  provider contract transactional_query
  as projection on zi_rap_tcv_cfauth_bank
{
  key Param,
      Value,
      @Semantics.user.localInstanceLastChangedBy: true
      Locallastchangedby,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      Locallastchangedat,
      @Semantics.systemDateTime.lastChangedAt: true
      Lastchangedat
}
