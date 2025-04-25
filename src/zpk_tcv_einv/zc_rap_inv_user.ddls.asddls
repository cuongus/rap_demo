@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'BO for EInvoice Username'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
@Search.searchable: true
define root view entity ZC_RAP_INV_USER
  provider contract transactional_query
  as projection on ZI_RAP_INV_USER
{
      @Search.defaultSearchElement: true
      @Consumption.valueHelpDefinition: [
       { entity:  { name:    'I_CompanyCodeStdVH',
                    element: 'CompanyCode' }
       }]
  key Companycode,
      @Search.defaultSearchElement: true
      @Consumption.valueHelpDefinition:
      [{ entity: { name : 'ZC_DOMAIN_FIX_VAL_2' , element: 'low' } ,
       additionalBinding: [{ element: 'domain_name',
                            localConstant: 'ZDE_USERTYPE2', usage: #FILTER }]
                            , distinctValues: true
      }]
  key Usertype,
      Username,
      Maskpassword,
      Password,
      Sellertax,
      @Semantics.user.localInstanceLastChangedBy: true
      Locallastchangedby,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      Locallastchangedat,
      @Semantics.systemDateTime.lastChangedAt: true
      Lastchangedat,
      /* Associations */
      _Companycode,
      _EInvoiceSerial : redirected to composition child ZC_RAP_INV_SERIAL
}
