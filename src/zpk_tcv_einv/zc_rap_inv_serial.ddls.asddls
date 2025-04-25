@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'BO for EInvoice Form Serial'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
@Search.searchable: true
define view entity ZC_RAP_INV_SERIAL
  as projection on ZI_RAP_INV_SERIAL
{
  key Companycode,
  key Usertype,
  key Fiscalyear,
  key Etype,
      @Search.defaultSearchElement: true
      @Consumption.valueHelpDefinition:
      [{ entity: { name : 'ZC_DOMAIN_FIX_VAL_2' , element: 'low' } ,
       additionalBinding: [{ element: 'domain_name',
                            localConstant: 'ZDE_DATETYPE2', usage: #FILTER }]
                            , distinctValues: true
      }]
      Datetype,
      Form,
      Serial,
      /* Associations */
      _EInvoiceUser : redirected to parent ZC_RAP_INV_USER
}
