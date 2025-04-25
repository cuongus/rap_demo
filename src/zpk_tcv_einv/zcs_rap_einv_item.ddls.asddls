@EndUserText.label: 'View EInvoice Items'
@ObjectModel.query.implementedBy: 'ABAP:ZCL_RAP_INV_GENERATE'
@Metadata.allowExtensions: true
define custom entity ZCS_RAP_EINV_ITEM
  // with parameters parameter_name : parameter_type
{
  key companycode        : bukrs;
  key accountingdocument : belnr_d;
  key fiscalyear         : gjahr;
  key buzei              : buzei;
      material           : zde_matnr2;
      itemname           : zde_itemname;
      noted              : zde_noted2;
      taxcode            : zde_taxcode;
      taxpercentage      : zde_taxperc;
      quantity           : zde_menge2;
      baseunit           : meins;
      unittext           : zde_msehl2;
      price              : zde_e_amount2;
      currency           : waers;
      amount             : zde_e_amount2;
      vat                : zde_e_amount2;
      total              : zde_e_amount2;
      pricev             : zde_e_amount2;
      amountv            : zde_e_amount2;
      vatv               : zde_e_amount2;
      totalv             : zde_e_amount2;
      @Semantics.user.localInstanceLastChangedBy: true
      locallastchangedby : abp_locinst_lastchange_user;
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      locallastchangedat : abp_locinst_lastchange_tstmpl;
      @Semantics.systemDateTime.lastChangedAt: true
      lastchangedat      : abp_lastchange_tstmpl;

      _EInvoicesHeader   : association to parent ZCS_RAP_EINV_ENTRY on  $projection.companycode        = _EInvoicesHeader.companycode
                                                                     and $projection.accountingdocument = _EInvoicesHeader.accountingdocument
                                                                     and $projection.fiscalyear         = _EInvoicesHeader.fiscalyear;

}
