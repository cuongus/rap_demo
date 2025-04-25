@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Search help company code'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZRAP_SH_COM_CODE_100 as select distinct from I_CompanyCode //ZRAP_R_PAYMENT_ROOT
{
    key CompanyCode //PayingCompanyCode
}
where CompanyCode = '6710'
