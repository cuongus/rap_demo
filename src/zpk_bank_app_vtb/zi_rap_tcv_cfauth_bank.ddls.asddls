@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'View for TCV Config Auth API Bank'
@Metadata.ignorePropagatedAnnotations: true
define root view entity zi_rap_tcv_cfauth_bank
  as select from ztb_tcv_cfauthba
{
  key param              as Param,
      value              as Value,
      @Semantics.user.localInstanceLastChangedBy: true
      locallastchangedby as Locallastchangedby,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      locallastchangedat as Locallastchangedat,
      @Semantics.systemDateTime.lastChangedAt: true 
      lastchangedat      as Lastchangedat
}
