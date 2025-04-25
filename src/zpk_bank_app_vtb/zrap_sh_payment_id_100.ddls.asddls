@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Search help payment id'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZRAP_SH_PAYMENT_ID_100 as select distinct from I_PaymentProposalPayment //ZRAP_R_PAYMENT_ROOT
{
    key PayingCompanyCode,
    key PaymentRunID //PaymentRunId
}
where PayingCompanyCode = '6710'
