@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'BO for Payment method'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZC_RAP_EINV_PAYM_2
  provider contract transactional_query
  as projection on ZI_RAP_EINV_PAYM_2
{
  key Zlsch,
      Paymtext,
      @Semantics.user.localInstanceLastChangedBy: true
      Locallastchangedby,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      Locallastchangedat,
      @Semantics.systemDateTime.lastChangedAt: true
      Lastchangedat
}
