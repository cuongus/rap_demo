@EndUserText.label: 'Parameters for Action Cancel'
@Metadata.allowExtensions: true
define abstract entity zr_cancel_einv
  //  with parameters parameter_name : parameter_type
{
  @Consumption.valueHelpDefinition: [
  { entity     : { name : 'ZC_DOMAIN_FIX_VAL_2' , element: 'low' } ,
  additionalBinding  : [{ element: 'domain_name',
                 localConstant: 'ZDE_NOTI_TAXTYPE2', usage: #FILTER }]
                 , distinctValues: true
  }]
  @Consumption.filter: { mandatory: true, selectionType: #SINGLE}
  @EndUserText.label: 'Loại thông báo'
  noti_taxtype : abap.char(30);

  @EndUserText.label: 'Số thông báo'
  noti_taxnum  : abap.char(30);

  @EndUserText.label: 'Ngày CQT thông báo'
  noti_taxdt   : abap.char(50);

  @EndUserText.label: 'Địa danh'
  @Consumption.filter: { mandatory: true }
  place        : abap.char(100);

  @Consumption.valueHelpDefinition: [
  { entity     : { name : 'ZC_DOMAIN_FIX_VAL_2' , element: 'low' } ,
  additionalBinding  : [{ element: 'domain_name',
                  localConstant: 'ZDE_NOTI_TYPE2', usage: #FILTER }]
                  , distinctValues: true
  }]
  @Consumption.filter: { mandatory: true, selectionType: #SINGLE}
  @EndUserText.label: 'Tính chất thông báo'
  noti_type    : abap.char(30);
}
