@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Search help posing date'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZRAP_SH_POSTING_DATE_100
  as select distinct from I_PaymentProposalPayment //ZRAP_R_PAYMENT_ROOT
{

  key PayingCompanyCode,
  PostingDate
}
where
  PayingCompanyCode = '6710'
