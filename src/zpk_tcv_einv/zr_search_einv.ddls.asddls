@EndUserText.label: 'Paramerter for Action Update Status'
define abstract entity ZR_SEARCH_EINV
  //  with parameters parameter_name : parameter_type
{
//  @Search.defaultSearchElement: true
  @Consumption.valueHelpDefinition: [
  { entity : { name : 'ZC_DOMAIN_FIX_VAL_2' , element: 'low' } ,
  additionalBinding  : [{ element: 'domain_name',
            localConstant: 'ZDE_USERTYPE2', usage: #FILTER }]
            , distinctValues: true
  }]
  @UI.defaultValue : #( 'ELEMENT_OF_REFERENCED_ENTITY: USERTYPE')
  @Consumption.filter: { mandatory: true }
  @EndUserText.label: 'User type'
  usertype : zde_usertype2;

}
