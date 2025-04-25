@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection View for Onetime Customer'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZC_ONETIME_CUS
  provider contract transactional_query
  as projection on zi_onetime_cus
{
  key CompanyCode,
  key AccountingDocument,
  key FiscalYear,
  key AccountingDocumentItem,
      BusinessPartnerName1,
      BusinessPartnerName2,
      BusinessPartnerName3,
      BusinessPartnerName4,
      Country,
      CityName,
      POBox,
      POBoxPostalCode,
      PostalCode,
      Region,
      TaxID1,
      TaxID2,
      TaxID3,
      TaxID4,
      TaxID5,
      StreetAddressName,
      TaxNumberType,
      AddressID,
      AccountingClerkInternetAddress,
      IsNaturalPerson,
      AuthorizationGroup,
      PayerIsAlternativePayer,
      Customer,
      /* Associations */
      _CompanyCode,
      _CustomerCompany,
      _FiscalYear,
      _JournalEntry,
      _OperationalAcctgDocItem
}
