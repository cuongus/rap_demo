@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection View for Onetime Supplier'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZC_ONTIME_SUPP
  provider contract transactional_query
  as projection on zi_ontime_supp
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
      PayeeIsAlternativePayee,
      Supplier,
      /* Associations */
      _CompanyCode,
      _FiscalYear,
      _JournalEntry,
      _OperationalAcctgDocItem,
      _SupplierCompany
}
