@EndUserText.label: 'Parameters for Action Adjust'
define abstract entity zr_adjust_einv
  //  with parameters parameter_name : parameter_type
{
  @Consumption.valueHelpDefinition: [{ entity: {name: 'ZI_SH_DOCUMENRT_ADJ' , element: 'Accountingdocument' },
     additionalBinding: [{ localElement: 'Gjahrsrc', element: 'Fiscalyear' }] }
     ]
  @UI.defaultValue : #( 'ELEMENT_OF_REFERENCED_ENTITY: BELNRSRC')
  @EndUserText.label: 'Adjust Document'
  Belnrsrc : zde_ebelnrsrc;

  @UI.defaultValue : #( 'ELEMENT_OF_REFERENCED_ENTITY: GJAHRSRC')
  @EndUserText.label: 'Adjust Fiscal Year'
  Gjahrsrc : zde_egjahrsrc;

  @Consumption.valueHelpDefinition: [
  { entity : { name : 'ZC_DOMAIN_FIX_VAL_2' , element: 'low' } ,
  additionalBinding  : [{ element: 'domain_name',
                  localConstant: 'ZDE_EADJTYPE', usage: #FILTER }]
                  , distinctValues: true
  }]
  @Consumption.filter: { mandatory: true, selectionType: #SINGLE}
  @UI.defaultValue : #( 'ELEMENT_OF_REFERENCED_ENTITY: ADJTYPE')
  @EndUserText.label: 'Adjust Type'
  adjtype  : zde_eadjtype;

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
