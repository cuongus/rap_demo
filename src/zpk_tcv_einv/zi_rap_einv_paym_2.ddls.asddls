@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'View for Payment method'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZI_RAP_EINV_PAYM_2
  as select from zrap_einv_paym_2
  //composition of target_data_source_name as _association_name
{
  key zlsch              as Zlsch,
      paymtext           as Paymtext,
      locallastchangedby as Locallastchangedby,
      locallastchangedat as Locallastchangedat,
      lastchangedat      as Lastchangedat
}
