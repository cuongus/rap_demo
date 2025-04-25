@EndUserText.label: 'View EInvoice Header'
@ObjectModel: {
    query: { 
            implementedBy: 'ABAP:ZCL_RAP_INV_GENERATE' }
    }
@Metadata.allowExtensions: true
@Search.searchable: true
define root custom entity ZCS_RAP_EINV_ENTRY
{
      @Search.defaultSearchElement: true
      @Consumption.valueHelpDefinition: [
      { entity           : { name: 'I_CompanyCodeStdVH', element: 'CompanyCode' }
      }]
      @Consumption.filter: { mandatory:  true , defaultValue: '6710'}
      @ObjectModel.text.element: [ '_Companycode.CompanyCodeName' ]
  key companycode        : bukrs;
  key accountingdocument : belnr_d;
      @Consumption.filter: { mandatory:  true }
  key fiscalyear         : gjahr;
      documentitem       : abap.char(3);
      iconsap            : abap.char(5);
      FiscalPeriod       : monat;
      postingdate        : budat;
      documentdate       : bldat;
      entrydate          : zde_date2;
      doctype            : blart;
      exchangerate       : zde_exrate;
      taxcode            : zde_taxcode;
      @Consumption.valueHelpDefinition: [
      { entity           : {name: 'I_Customer', element: 'Customer' }} ]
      customer           : zde_customer2;
      bname              : abap.char(155);
      baddr              : abap.char(255);
      bbank              : abap.char(255);
      bacct              : abap.char(100);
      btax               : abap.char(100);
      bmail              : abap.char(100);
      btel               : abap.char(100);
      profitcenter       : abap.char(10);
      @Search.defaultSearchElement: true
      @Consumption.valueHelpDefinition: [
      { entity           : { name : 'ZC_DOMAIN_FIX_VAL_2' , element: 'low' } ,
      additionalBinding  : [{ element: 'domain_name',
                localConstant: 'ZDE_EREGION', usage: #FILTER }]
                , distinctValues: true
      }]
      @Consumption.filter: { mandatory: true, defaultValue: '1', selectionType: #SINGLE}
      @ObjectModel.text.element: ['regiontext']
      region             : zde_eregion;
      regiontext         : abap.char(30);
      @Search.defaultSearchElement: true
      @Consumption.valueHelpDefinition: [
      { entity           : { name : 'ZC_DOMAIN_FIX_VAL_2' , element: 'low' } ,
      additionalBinding  : [{ element: 'domain_name',
                localConstant: 'ZDE_USERTYPE2', usage: #FILTER }]
                , distinctValues: true
      }]
//      @Consumption.filter: { mandatory: true, defaultValue: '1', selectionType: #SINGLE}
      @ObjectModel.text.element: ['usertypetext']
      usertype           : zde_usertype2;
      usertypetext       : abap.char(30);
      datetype           : zde_datetype2;
      etype              : zde_etype;
      form               : zde_eform;
      serial             : zde_eserial;
      seq                : zde_eseq;
      dateint            : zde_date2;
      dateiss            : zde_date2;
      timeiss            : zde_time2;
      datecanc           : zde_date2;
      sid                : zde_esid;
      zsearch            : zde_esid;
      zreplace           : zde_esid;
      startdat           : zde_date2;
      enddat             : zde_date2;
      stax               : zde_stax;
      mscqt              : zde_emscqt;
      link               : zde_elink;
      @ObjectModel.text.element: [ 'adjtext' ]
      adjtype            : zde_eadjtype;
      adjtext            : abap.char(15);
      belnrsrc           : zde_ebelnrsrc;
      gjahrsrc           : zde_egjahrsrc;
      statussap          : zde_estatussap2;
      statusinv          : zde_estatusinv2;
      statuscqt          : zde_estatuscqt2;
      msgty              : zde_msg_ty2;
      msgtx              : zde_msg_tx2;
      paym               : zde_epaym;
      currency           : waers;
      amount             : zde_e_amount2;
      vat                : zde_e_amount2;
      total              : zde_e_amount2;
      amountv            : zde_e_amount2;
      vatv               : zde_e_amount2;
      totalv             : zde_e_amount2;
      invdat             : zde_e_invdate2;
      @Semantics.user.createdBy: true
      createdby          : syuname;
      @Semantics.systemDateTime.createdAt: true
      createdon          : timestampl;
      stblg              : abap.char(10);
      stjah              : abap.char(4);
      xreversing         : abap.char(1);
      xreversed          : abap.char(1);
       @Semantics.user.localInstanceLastChangedBy: true
      locallastchangedby : abp_locinst_lastchange_user;
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      locallastchangedat : abp_locinst_lastchange_tstmpl;
      @Semantics.systemDateTime.lastChangedAt: true
      lastchangedat      : abp_lastchange_tstmpl;

      _EInvoiceItems     : composition [0..*] of ZCS_RAP_EINV_ITEM;
      _Companycode       : association [0..1] to I_CompanyCodeStdVH on _Companycode.CompanyCode = $projection.companycode;
      _Customer          : association [0..1] to I_Customer on _Customer.Customer = $projection.customer;
}
