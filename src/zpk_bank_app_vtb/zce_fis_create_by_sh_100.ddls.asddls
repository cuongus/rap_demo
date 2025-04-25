@EndUserText.label: 'Custom entity for payment'
@ObjectModel: {
    query: {
        implementedBy: 'ABAP:ZCL_FIS_CREATEBY_100'
    }
}
@Search.searchable: true
@UI: {
  headerInfo: {
    typeName: 'Created By',
    typeNamePlural: 'Created By',
    title: { value: 'user_id' },
    description: { value: 'created_by' }
  }
}

define root custom entity ZCE_FIS_CREATE_BY_SH_100
{
      @UI.facet                      : [
               {
                 id                  :  'user_id',
                 purpose             :  #STANDARD,
                 type                :  #IDENTIFICATION_REFERENCE,
                 label               :  'Created By',
                 position            : 10 }
             ]
      @EndUserText.label             : 'User ID'
      @UI.lineItem                   : [{ position: 10 }]
      @UI.selectionField             : [{position: 10}]
      @UI.identification             : [{position: 10}]
      @Consumption.valueHelpDefinition:[{ entity.name: 'ZCE_FIS_CREATE_BY_SH_100', entity.element: 'user_id' }]
      @Search.defaultSearchElement   : true
      @Search.fuzzinessThreshold     : 0.8

  key user_id                 : abap.char(12);


      @EndUserText.label             : 'Created By'
      @UI.lineItem                   : [{ position: 20 }]
      @UI.selectionField             : [{position: 20}]
      @UI.identification             : [{position: 20}]
      @Consumption.valueHelpDefinition:[{ entity.name: 'ZCE_FIS_CREATE_BY_SH_100', entity.element: 'created_by' }]
      created_by                     : abap.char(50);
      



}
