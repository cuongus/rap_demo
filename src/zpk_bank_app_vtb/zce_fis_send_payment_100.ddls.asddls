@EndUserText.label: 'Custom entity for payment'
@ObjectModel: {
    query: {
        implementedBy: 'ABAP:ZCL_FIS_PAYMENT_100'
    }
}
@Search.searchable: true
@Metadata.allowExtensions: true
@ObjectModel.resultSet.sizeCategory: #XS
@ObjectModel.usageType.dataClass: #MIXED
@UI: {
presentationVariant: [{ sortOrder: [ { by: 'PaymentRunDate', direction: #ASC } ] , maxItems: 1000, visualizations: [{ type: #AS_LINEITEM }]}],
headerInfo: {
    typeName: 'Payment',
    typeNamePlural: 'Payments',
    description.type: #STANDARD,
    title: { type: #STANDARD , value: 'PaymentRunID', label: 'PaymentRunID' },
    description: { value: 'PaymentRunDate' }
  }
}
@ObjectModel.usageType.sizeCategory: #XXL


define root custom entity ZCE_FIS_SEND_PAYMENT_100
{

      @UI.facet                      : [
               {
                 id                  :  'payment_id',
                 purpose             :  #STANDARD,
                 type                :  #IDENTIFICATION_REFERENCE,
                 label               :  'Payment',
                 position            : 10 }
             ]
      @EndUserText.label             : 'Run Date'
      @UI.lineItem                   : [{ position: 10 } , { type: #FOR_ACTION, dataAction: 'edit_text', label: 'Edit Text' }]
      @UI.selectionField             : [{position: 10}]
      @UI.identification             : [{position: 10}]
      @Consumption.filter            : { selectionType: #INTERVAL, multipleSelections: false }
      //      @Consumption.derivation.binding: [{targetElement: 'calendardate', type: #SYSTEM_FIELD, value:'#SYSTEM_DATE'}]

  key PaymentRunDate                 : datum;

      @UI.lineItem                   : [{ position: 20 }, { type: #FOR_ACTION, dataAction: 'request_payment', label: 'Send To Bank' }]
      @UI.selectionField             : [{position: 20}]
      @UI.identification             : [{position: 20}]

      @Consumption.valueHelpDefinition:[{ entity.name: 'ZRAP_SH_PAYMENT_ID_100', entity.element: 'PaymentRunID' }]
      @EndUserText.label             : 'Identification'
  key PaymentRunID                   : abap.char( 6 );

      @UI.lineItem                   : [{ position: 30 }]
      @UI.selectionField             : [{position: 30}]
      @UI.identification             : [{position: 30}]
      @Consumption.valueHelpDefinition:[{ entity.name: 'ZRAP_SH_COM_CODE_100', entity.element: 'CompanyCode' }]
      @Consumption.filter.defaultValue:'6710'
      @Search.defaultSearchElement   : true
      @EndUserText.label             : 'Company Code'
      @Consumption.filter.mandatory  : true
  key PayingCompanyCode              : abap.char( 4 );
      @UI.identification             : [{position: 110}]
  key supplier                       : lifnr;

      @EndUserText.label             : 'Customer'
      @UI.identification             : [{position: 120}]
  key customer                       : abap.char(10);
      @EndUserText.label             : 'Payment Recipient'
      @UI.identification             : [{position: 130}]
  key paymentrecipient               : abap.char(16);
      @EndUserText.label             : 'Payment Document'
      @UI.identification             : [{position: 140}]
  key paymentdocument                : belnr_d;

      @EndUserText.label             : 'Posting Date'
      @UI.lineItem                   : [{ position: 40 }]
      @UI.selectionField             : [{position: 40}]
      @UI.identification             : [{position: 40}]
      @Consumption.valueHelpDefinition:[{ entity.name: 'ZRAP_SH_POSTING_DATE_100', entity.element: 'PostingDate' }]
      PostingDate                    : datum;

      @EndUserText.label             : 'Text'
      @UI.lineItem                   : [{ position: 50 }]
      @UI.identification             : [{position: 50}]
      text                           : abap.char(210);

      @EndUserText.label             : 'Request Status'
      @UI.lineItem                   : [{ position: 60,cssDefault.width: '8rem' }]
      @UI.identification             : [{position: 60}]
      status                         : abap.char(20);
      @EndUserText.label             : 'Created By User ID'
      @UI.identification             : [{position: 70}]
      @Search.fuzzinessThreshold     : 0.8

      @Consumption.valueHelpDefinition:[{ entity.name: 'ZCE_FIS_CREATE_BY_SH_100', entity.element: 'user_id' }]
      created_by                     : abp_creation_user;
      @EndUserText.label             : 'Created By'
      @UI.lineItem                   : [{ position: 70, cssDefault.width: '8rem'  }]
      @UI.selectionField             : [{position: 50}]
      @UI.identification             : [{position: 70}, {type: #FOR_ACTION, dataAction: 'request_payment', label: 'Send To Bank'}]
      @Consumption.valueHelpDefinition:[{ entity.name: 'ZCE_FIS_CREATE_BY_SH_100', entity.element: 'created_by' }]
      created_by_fullname            : abap.char(50);
      @EndUserText.label             : 'Status'
      @UI.identification             : [{position: 90}]
      @UI.lineItem                   : [{ position: 90, cssDefault.width: '5rem'}]
      api_status                     : abap.char( 30 );
      @EndUserText.label             : 'Message'
      @UI.lineItem                   : [{ position: 100, cssDefault.width: '13rem'  }]
      @UI.identification             : [{position: 100}]
      message                        : abap.string( 0 );
      addressid                      : ad_addrnum;

      @EndUserText.label             : 'Financial Account Type'
      @UI.identification             : [{position: 150}]
      financialaccounttype           : abap.char(1);
      @EndUserText.label             : 'Sending Company Code'
      @UI.identification             : [{position: 160}]
      sendingcompanycode             : abap.char(4);
      @UI.identification             : [{position: 170}]
      @EndUserText.label             : 'Business Area'
      businessarea                   : abap.char(4);
      @UI.identification             : [{position: 180}]
      @EndUserText.label             : 'Payment Reason'
      paymentreason                  : abap.char(4);
      @UI.identification             : [{position: 190}]
      @EndUserText.label             : 'Branch Code'
      branchcode                     : bcode;
      @UI.identification             : [{position: 200}]
      @EndUserText.label             : 'Direct Debit Type'
      directdebittype                : abap.char(4);
      @UI.identification             : [{position: 210}]
      @EndUserText.label             : 'Payment Due Date'
      paymentduedate                 : datum;
      @UI.identification             : [{position: 220}]
      @EndUserText.label             : 'Payment Request Payment Group'
      paymentrequestpaymentgroup     : abap.char(20);
      @EndUserText.label             : 'Number of Text Lines'
      numberoftextlines              : abap.dec(5,0);

      @EndUserText.label             : 'Number of Paid Items'
      numberofpaiditems              : abap.dec(5,0);
      @EndUserText.label             : 'Company Code Currency'
      companycodecountry             : land1;
      @EndUserText.label             : 'Payment Method'
      paymentmethod                  : abap.char(1);
      @EndUserText.label             : 'Payment Method Supplement'
      paymentmethodsupplement        : abap.char(2);
      @EndUserText.label             : 'Payment Reference'
      paymentreference               : abap.char(30);
      @EndUserText.label             : 'Personnel Number'
      personnelnumber                : abap.numc(8);
      @EndUserText.label             : 'Payment Order'
      paymentorder                   : abap.char(10);
      valuedate                      : valut;
      @EndUserText.label             : 'Exchange Rate'
      exchangerate                   : abap.dec(9,5);
      @EndUserText.label             : 'Payment Origin'
      paymentorigin                  : abap.char(8);
      //      swifttransactionreferenceuuid  : abap.char(36);
      @EndUserText.label             : 'Business Place'
      businessplace                  : abap.char(4);
      @EndUserText.label             : 'Accounting Clerk'
      accountingclerk                : abap.char(2);
      @EndUserText.label             : 'Account By Shipper'
      accountbyshipper               : abap.char(12);
      country                        : land1;
      region                         : regio;
      @EndUserText.label             : 'City Name'
      cityname                       : abap.char(35);
      @EndUserText.label             : 'District Name'
      streetaddressname              : abap.char(35);
      @EndUserText.label             : 'Postal Code'
      postalcode                     : abap.char(10);
      @EndUserText.label             : 'PO Box'
      pobox                          : abap.char(10);
      @EndUserText.label             : 'PO Box Postal Code'
      poboxpostalcode                : abap.char(10);
      @EndUserText.label             : 'PO Box Deviating City Name'
      poboxdeviatingcityname         : abap.char(35);
      @EndUserText.label             : 'Name 1'
      organizationbpname1            : abap.char(35);
      @EndUserText.label             : 'Name 2'
      organizationbpname2            : abap.char(35);
      @EndUserText.label             : 'Name 3'
      organizationbpname3            : abap.char(35);
      @EndUserText.label             : 'Name 4'
      organizationbpname4            : abap.char(35);
      @EndUserText.label             : 'Bank Control Key'
      bankcontrolkey                 : abap.char(2);
      @EndUserText.label             : 'Bank Country'
      bankcountry                    : abap.char(3);
      @UI.identification             : [{ position: 100 }]
      @EndUserText.label             : 'Bank'
      bank                           : abap.char(15);
      @EndUserText.label             : 'Bank Internal ID'
      bankinternalid                 : abap.char(15);
      @EndUserText.label             : 'Bank Account'
      bankaccount                    : abap.char(18);
      @EndUserText.label             : 'Bank Account Long ID'
      bankaccountlongid              : abap.char(35);
      @EndUserText.label             : 'IBAN'
      iban                           : abap.char(34);
      @UI.lineItem                   : [{ position: 80 }]
      @UI.identification             : [{position: 80}]
      housebank                      : hbkid;
      housebankaccount               : hktid;
      payeetitle                     : dzanre;
      payeelanguage                  : dzspra;
      @EndUserText.label             : 'Payee Name'
      payeename                      : dznme1;
      @EndUserText.label             : 'Payee Additional Name'
      payeeadditionalname            : dznme1;
      payeecountry                   : dzland;
      payeeregion                    : dzregi;
      payeecityname                  : dzort1;
      payeedistrictname              : ort02_z;
      payeestreet                    : dzstra;
      payeepostalcode                : dzpstl;
      payeepobox                     : dzpfac;
      payeepoboxpostalcode           : dzpst2;
      payeebankcontrolkey            : dzbkon;
      payeebankcountry               : dzbnks;
      @UI.identification             : [{position: 220}]
      payeebank                      : dzbnkl;
      @UI.identification             : [{position: 230}]
      payeebankkey                   : dzbnky;
      @UI.identification             : [{position: 240}]
      payeebankaccount               : dzbnkn;
      @UI.identification             : [{position: 250}]
      @EndUserText.label             : 'Payee Bank Account Long ID'
      payeebankaccountlongid         : abap.char(35);
      payeesepasequencetype          : sepa_seq_type;
      payeesepamandateuuid           : sepa_mguid;
      @EndUserText.label             : 'Payee IBAN'
      payeeiban                      : abap.char(34);
      payeebankdetailreference       : bkref;
      @UI.identification             : [{position: 260}]
      @EndUserText.label             : 'Payee Bank Account Holder Name'
      payeebankaccountholdername     : koinh_fi;
      @UI.identification             : [{position: 220}]
      @EndUserText.label             : 'Payment Currency'
      paymentcurrency                : abap.cuky;
      @Semantics.amount.currencyCode : 'paymentcurrency'
      @UI.identification             : [{position: 230}]
      @EndUserText.label             : 'Payment Amount'
      paymentamountinpaytcurrency    : abap.curr(23,2);
      @EndUserText.label             : 'Lost Cash Discount'
      @Semantics.amount.currencyCode : 'companycodecurrency'
      lostcashdiscountinpaytcrcy     : abap.curr(23,2);
      companycodecurrency            : waers;
      @Semantics.amount.currencyCode : 'functionalcurrency'
      cashdiscountamtincocodecrcy    : abap.curr(23,2);
      @Semantics.amount.currencyCode : 'functionalcurrency'
      paytamountincocodecurrency     : abap.curr(23,2);
      @Semantics.amount.currencyCode : 'functionalcurrency'
      lostcashdiscountincocodecrcy   : abap.curr(23,2);
      functionalcurrency             : abap.cuky;
      @Semantics.amount.currencyCode : 'additionalcurrency1'
      @EndUserText.label             : 'Payment Amount in Functional Currency'
      paymentamountinfunctionalcrcy  : abap.curr(23,2);
      @EndUserText.label             : 'CashDiscountAmountinFunctionalCurrency'
      @Semantics.amount.currencyCode : 'additionalcurrency1'
      cashdiscountamountinfuncnlcrcy : abap.curr(23,2);
      @EndUserText.label             : 'Additional Currency 1'
      additionalcurrency1            : abap.cuky;
      @Semantics.amount.currencyCode : 'additionalcurrency1'
      @EndUserText.label             : 'Payment Amount in Additional Currency 1'
      paymentamountinadditionalcrcy1 : abap.curr(23,2);
      @Semantics.amount.currencyCode : 'additionalcurrency1'
      @EndUserText.label             : 'CashDiscountAmountinAdditionalCurrency1'
      cashdiscountamtinaddlcrcy1     : abap.curr(23,2);
      @EndUserText.label             : 'Additional Currency 2'
      additionalcurrency2            : abap.cuky;
      @EndUserText.label             : 'Payment Amount in Additional Currency 2'
      @Semantics.amount.currencyCode : 'additionalcurrency2'
      paymentamountinadditionalcrcy2 : abap.curr(23,2);
      @EndUserText.label             : 'CashDiscountAmountinAdditionalCurrency2'
      @Semantics.amount.currencyCode : 'additionalcurrency2'
      cashdiscountamtinaddlcrcy2     : abap.curr(23,2);
      edipaymentorderstatus          : edibn;
      edipaymentadvicestatus         : ediav;
      @EndUserText.label             : 'Bank Chain Bank 1 Type'
      bankchainbank1type             : abap.char(1);
      @EndUserText.label             : 'Bank Chain Bank 1 Country'
      bankchainbank1country          : abap.char(3);
      @EndUserText.label             : 'Bank Chain Bank 1'
      bankchainbank1                 : abap.char(15);
      @EndUserText.label             : 'Bank Chain Bank 1 Bank Account'
      bankchainbank1bankaccount      : abap.char(18);
      @EndUserText.label             : 'Bank Chain Bank 1 Control Key'
      bankchainbank1controlkey       : abap.char(2);
      @EndUserText.label             : 'Bank Chain Bank 1 Detail Reference'
      bankchainbank1detailreference  : abap.char(20);
      @EndUserText.label             : 'Bank Chain Bank 1 IBAN'
      bankchainbank1iban             : abap.char(34);
      @EndUserText.label             : 'Bank Chain Bank 2 Type'
      bankchainbank2type             : abap.char(1);
      @EndUserText.label             : 'Bank Chain Bank 2 Country'
      bankchainbank2country          : abap.char(3);
      @EndUserText.label             : 'Bank Chain Bank 2'
      bankchainbank2                 : abap.char(15);
      @EndUserText.label             : 'Bank Chain Bank 2 Bank Account'
      bankchainbank2bankaccount      : abap.char(18);
      @EndUserText.label             : 'Bank Chain Bank 2 Control Key'
      bankchainbank2controlkey       : abap.char(2);
      @EndUserText.label             : 'Bank Chain Bank 2 Detail Reference'
      bankchainbank2detailreference  : abap.char(20);
      @EndUserText.label             : 'Bank Chain Bank 2 IBAN'
      bankchainbank2iban             : abap.char(34);
      @EndUserText.label             : 'Bank Chain Bank 3 Type'
      bankchainbank3type             : abap.char(1);
      @EndUserText.label             : 'Bank Chain Bank 3 Country'
      bankchainbank3country          : abap.char(3);
      @EndUserText.label             : 'Bank Chain Bank 3'
      bankchainbank3                 : abap.char(15);
      @EndUserText.label             : 'Bank Chain Bank 3 Bank Account'
      bankchainbank3bankaccount      : abap.char(18);
      @EndUserText.label             : 'Bank Chain Bank 3 Control Key'
      bankchainbank3controlkey       : abap.char(2);
      @EndUserText.label             : 'Bank Chain Bank 3 Detail Reference'
      bankchainbank3detailreference  : abap.char(20);
      @EndUserText.label             : 'Bank Chain Bank 3 IBAN'
      bankchainbank3iban             : abap.char(34);
      @EndUserText.label             : 'Payee Payment System'
      payeepaymentsystem             : abap.char(15);
      @EndUserText.label             : 'Payee Alias Type'
      payeealiastype                 : abap.char(15);
      @EndUserText.label             : 'Payee Alias Name'
      payeealiasname                 : abap.char(255);
      @EndUserText.label             : 'Json Body'
      json_body                      : abap.char(1000);
}
