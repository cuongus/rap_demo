@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Search Help for Adjust EInvoice'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
@Search.searchable: true
define root view entity ZI_SH_DOCUMENRT_ADJ
  //  with parameters
  //    @Consumption.valueHelpDefinition: [
  //    { entity           : { name: 'I_CompanyCodeStdVH', element: 'CompanyCode' }
  //    }]
  //    p_bukrs  : bukrs,
  //    @Consumption.valueHelpDefinition: [
  //    { entity           : { name : 'ZC_DOMAIN_FIX_VAL_2' , element: 'low' } ,
  //    additionalBinding  : [{ element: 'domain_name',
  //          localConstant: 'ZDE_EREGION', usage: #FILTER }]
  //          , distinctValues: true
  //    }]
  //    //    @Consumption.filter: { mandatory: true, selectionType: #SINGLE}
  //    p_region : zde_eregion
  as select from zrap_einv_entry as SHEInvoiceEntry
  //  composition of target_data_source_name as _association_name
{
      @Search.defaultSearchElement: true
      @Consumption.valueHelpDefinition: [
      { entity           : { name: 'I_CompanyCodeStdVH', element: 'CompanyCode' }
      }]
//      @Consumption.filter: { defaultValue: '6710'}
  key companycode        as Companycode,
//        @Consumption.filter.
  key accountingdocument as Accountingdocument,
//      @Consumption.filter: { mandatory: true }
  key fiscalyear         as Fiscalyear,
      fiscalperiod       as Fiscalperiod,
      postingdate        as Postingdate,
      documentdate       as Documentdate,
      entrydate          as Entrydate,
      doctype            as Doctype,
      exchangerate       as Exchangerate,
      taxcode            as Taxcode,
      @Consumption.valueHelpDefinition: [
      { entity           : {name: 'I_Customer', element: 'Customer' }} ]
      customer           as Customer,
      bname              as Bname,
      baddr              as Baddr,
      profitcenter       as Profitcenter,
      @Search.defaultSearchElement: true
      @Consumption.valueHelpDefinition: [
      { entity           : { name : 'ZC_DOMAIN_FIX_VAL_2' , element: 'low' } ,
      additionalBinding  : [{ element: 'domain_name',
                localConstant: 'ZDE_EREGION', usage: #FILTER }]
                , distinctValues: true
      }]
      @Consumption.filter: { selectionType: #SINGLE}
      @ObjectModel.text.element: ['regiontext']
      region             as Region,
      @UI.hidden: true
      regiontext         as Regiontext,
      @Search.defaultSearchElement: true
      @Consumption.valueHelpDefinition: [
      { entity           : { name : 'ZC_DOMAIN_FIX_VAL_2' , element: 'low' } ,
      additionalBinding  : [{ element: 'domain_name',
                localConstant: 'ZDE_USERTYPE2', usage: #FILTER }]
                , distinctValues: true
      }]
      @Consumption.filter: {  selectionType: #SINGLE}
      @ObjectModel.text.element: ['usertypetext']
      usertype           as Usertype,
      @UI.hidden: true
      usertypetext       as Usertypetext,
      @UI.hidden: true
      etype              as Etype,
      form               as Form,
      serial             as Serial,
      seq                as Seq,
      @UI.hidden: true
      dateint            as Dateint,

      dateiss            as Dateiss,

      timeiss            as Timeiss,
      @UI.hidden: true
      datecanc           as Datecanc,
      sid                as Sid,
      stax               as Stax,
      mscqt              as Mscqt,
      link               as Link,
      @ObjectModel.text.element: [ 'Adjtext' ]
      adjtype            as Adjtype,
      @UI.hidden: true
      adjtext            as Adjtext,

      belnrsrc           as Belnrsrc,

      gjahrsrc           as Gjahrsrc,
      statussap          as Statussap,
      statusinv          as Statusinv,
      statuscqt          as Statuscqt,
      msgty              as Msgty,
      msgtx              as Msgtx,
      paym               as Paym,
      currency           as Currency,

      amount             as Amount,

      vat                as Vat,

      total              as Total,

      amountv            as Amountv,

      vatv               as Vatv,

      totalv             as Totalv,
      @UI.hidden: true
      invdat             as Invdat,
      @UI.hidden: true
      createdby          as Createdby,
      @UI.hidden: true
      createdon          as Createdon,
      @UI.hidden: true
      stblg              as Stblg,
      @UI.hidden: true
      stjah              as Stjah,
      @UI.hidden: true
      xreversing         as Xreversing,
      @UI.hidden: true
      xreversed          as Xreversed,
      @UI.hidden: true
      locallastchangedby as Locallastchangedby,
      @UI.hidden: true
      lastchangedat      as Lastchangedat
}
where
      statussap <> '07'
  and statussap <> '03'
  and statussap <> '01'
  and statussap <> '02'
//  and companycode = $parameters.p_bukrs
//  and region      = $parameters.p_region
