@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Views for EInvoice Form Serial'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_RAP_INV_SERIAL
  as select from zrap_inv_serial
  association to parent ZI_RAP_INV_USER as _EInvoiceUser on  $projection.Companycode = _EInvoiceUser.Companycode
                                                         and $projection.Usertype    = _EInvoiceUser.Usertype
{
  key companycode as Companycode,
  key usertype    as Usertype,
  key fiscalyear  as Fiscalyear,
  key etype       as Etype,
      datetype    as Datetype,
      form        as Form,
      serial      as Serial,
      /* Make association public */
      _EInvoiceUser
}
