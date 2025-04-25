@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Search help payment run date'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZRAP_SH_PAYMENT_RUN_100 as select  distinct from I_PaymentProposalPayment //ZRAP_R_PAYMENT_ROOT
{
    key PaymentRunDate 
}
where PayingCompanyCode = '6710'
