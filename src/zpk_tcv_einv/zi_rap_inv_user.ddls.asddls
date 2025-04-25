@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'View for EInvoice Username'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZI_RAP_INV_USER
  as select from zrap_inv_user
  composition [0..*] of ZI_RAP_INV_SERIAL as _EInvoiceSerial
  association [1..1] to I_CompanyCode      as _Companycode on $projection.Companycode = _Companycode.CompanyCode
{
  key companycode        as Companycode,
  key usertype           as Usertype,
      username           as Username,
      maskpassword       as Maskpassword,
      password           as Password,
      sellertax          as Sellertax,
      locallastchangedby as Locallastchangedby,
      locallastchangedat as Locallastchangedat,
      lastchangedat      as Lastchangedat,
      /* Make association public */
      _EInvoiceSerial,
      _Companycode
}
