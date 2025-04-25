@EndUserText.label: 'Parameters for Action Replace'
define abstract entity zr_replace_einv
//  with parameters parameter_name : parameter_type
{
@Consumption.valueHelpDefinition: [{ entity: {name: 'ZI_SH_DOCUMENRT_ADJ' , element: 'Accountingdocument' },
   additionalBinding: [{ localElement: 'Gjahrsrc', element: 'Fiscalyear' }] }
   ]
@EndUserText.label: 'Replace Document'
@UI.defaultValue: #( 'ELEMENT_OF_REFERENCED_ENTITY: BELNRSRC' )
Belnrsrc : zde_ebelnrsrc;
@EndUserText.label: 'Replace Fiscal Year'
@UI.defaultValue: #( 'ELEMENT_OF_REFERENCED_ENTITY: GJAHRSRC' )
Gjahrsrc : zde_egjahrsrc;  
  @Consumption.valueHelpDefinition: [
  { entity : { name : 'ZC_DOMAIN_FIX_VAL_2' , element: 'low' } ,
  additionalBinding  : [{ element: 'domain_name',
            localConstant: 'ZDE_DATETYPE2', usage: #FILTER }]
            , distinctValues: true
  }]
  @Consumption.filter: { mandatory: true }
  @EndUserText.label: 'Date type'
  datetype : zde_datetype2;
}
