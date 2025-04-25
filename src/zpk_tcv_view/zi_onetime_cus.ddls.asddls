@AbapCatalog.sqlViewName: 'ZONETIMECUSTOMER'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'View for Onetime Customer'
@Metadata.ignorePropagatedAnnotations: true
define root view zi_onetime_cus 
  as select from I_OneTimeAccountCustomer
  
  association [1..1] to I_CompanyCode              as _CompanyCode             on  $projection.CompanyCode = _CompanyCode.CompanyCode

  association [1..1] to I_JournalEntry             as _JournalEntry            on  $projection.CompanyCode        = _JournalEntry.CompanyCode
                                                                               and $projection.AccountingDocument = _JournalEntry.AccountingDocument
                                                                               and $projection.FiscalYear         = _JournalEntry.FiscalYear

  association [0..1] to I_FiscalYearForCompanyCode as _FiscalYear              on  $projection.FiscalYear  = _FiscalYear.FiscalYear
                                                                               and $projection.CompanyCode = _FiscalYear.CompanyCode

  association [1..1] to I_OperationalAcctgDocItem  as _OperationalAcctgDocItem on  _OperationalAcctgDocItem.CompanyCode            = $projection.CompanyCode
                                                                               and _OperationalAcctgDocItem.AccountingDocument     = $projection.AccountingDocument
                                                                               and _OperationalAcctgDocItem.FiscalYear             = $projection.FiscalYear
                                                                               and _OperationalAcctgDocItem.AccountingDocumentItem = $projection.AccountingDocumentItem

  association [1..1] to I_CustomerCompany          as _CustomerCompany         on  _CustomerCompany.CompanyCode = $projection.CompanyCode
                                                                               and _CustomerCompany.Customer    = $projection.Customer
{
      @ObjectModel.foreignKey.association: '_CompanyCode'
  key CompanyCode                    as CompanyCode,
      @ObjectModel.foreignKey.association: '_JournalEntry'
  key AccountingDocument             as AccountingDocument,
      @ObjectModel.foreignKey.association: '_FiscalYear'
  key FiscalYear                     as FiscalYear,
  key AccountingDocumentItem         as AccountingDocumentItem,
      BusinessPartnerName1           as BusinessPartnerName1,
      BusinessPartnerName2           as BusinessPartnerName2,
      BusinessPartnerName3           as BusinessPartnerName3,
      BusinessPartnerName4           as BusinessPartnerName4,
      Country                        as Country,
      CityName                       as CityName,
      POBox                          as POBox,
      POBoxPostalCode                as POBoxPostalCode,
      PostalCode                     as PostalCode,
      Region                         as Region,
      TaxID1                         as TaxID1,
      TaxID2                         as TaxID2,
      TaxID3                         as TaxID3,
      TaxID4                         as TaxID4,
      TaxID5                         as TaxID5,
      StreetAddressName              as StreetAddressName,
      TaxNumberType                  as TaxNumberType,
      AddressID                      as AddressID,
      AccountingClerkInternetAddress as AccountingClerkInternetAddress,
      IsNaturalPerson                as IsNaturalPerson,
      AuthorizationGroup             as AuthorizationGroup,
      PayerIsAlternativePayer        as PayerIsAlternativePayer,

      Customer                       as Customer,

      _CompanyCode,
      _JournalEntry,
      _FiscalYear,

      _OperationalAcctgDocItem,
      _CustomerCompany
}
