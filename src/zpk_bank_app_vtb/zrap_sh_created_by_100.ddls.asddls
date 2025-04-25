@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Search help created by'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
//define view entity ZRAP_SH_CREATED_BY
//  as select distinct from I_PaymentProposalItem as a
//    inner join            I_JournalEntryItem    as b on  a.AccountingDocument = b.AccountingDocument
//                                                     and a.CompanyCode        = b.CompanyCode
//                                                     and a.FiscalYear         = b.FiscalYear
//    inner join            I_BusinessPartner     as c on c.BusinessPartner = substring(
//      b.AccountingDocCreatedByUser, 2, 10
//    )
//{
//
//  key a.CompanyCode,
//      c.PersonFullName
//}
//where
//  a.CompanyCode = '6710'
define view entity ZRAP_SH_CREATED_BY_100
  as select distinct from I_BusinessPartner
{
  key BusinessPartner,
      PersonFullName
}
where
  PersonFullName is not initial
