@EndUserText.label: 'Custom View for BP Address'
@ObjectModel.query.implementedBy: 'ABAP:ZCL_RAP_BP_ADDRESS'
@Metadata.allowExtensions: true
@Search.searchable: true
define root custom entity ZCS_RAP_BP_ADDRESS
{
  key mandt                     : mandt;
      @Search.defaultSearchElement: true
      @Consumption.valueHelpDefinition: [
    { entity                    : {name: 'I_BusinessPartner', element: 'BusinessPartner' }} ]
  key businesspartner           : abap.char(10);
  key addressid                 : abap.char(10);
      addressrepresentationcode : abap.char(5);
      addresseefullname         : abap.char(150);
      addressidbyexternalsystem : abap.char(150);
      addresspersonid           : abap.char(20);
      addresssearchterm1        : abap.char(150);
      addresssearchterm2        : abap.char(150);
      addresstimezone           : abap.char(10);
      careofname                : abap.char(150);
      cityname                  : abap.char(150);
      citynumber                : abap.char(150);
      companypostalcode         : abap.char(20);
      
      @Search.defaultSearchElement: true
      @Consumption.valueHelpDefinition: [
    { entity                    : {name: 'I_Country', element: 'Country' }} ]
      country                   : abap.char(10);
      deliveryservicenumber     : abap.char(150);
      deliveryservicetypecode   : abap.char(150);
      districtname              : abap.char(150);
      formofaddress             : abap.char(150);
      housenumber               : abap.char(150);
      housenumbersupplementtext : abap.char(150);
      language                  : abap.char(5);
      organizationname1         : abap.char(150);
      organizationname2         : abap.char(150);
      organizationname3         : abap.char(150);
      organizationname4         : abap.char(150);
      personfamilyname          : abap.char(150);
      persongivenname           : abap.char(150);
      pobox                     : abap.char(150);
      poboxdeviatingcityname    : abap.char(150);
      poboxdeviatingcountry     : abap.char(150);
      poboxdeviatingregion      : abap.char(150);
      poboxiswithoutnumber      : abap.char(10);
      poboxlobbyname            : abap.char(150);
      poboxpostalcode           : abap.char(150);
      postalcode                : abap.char(20);
      prfrdcommmediumtype       : abap.char(150);
      region                    : abap.char(20);
      secondaryregion           : abap.char(30);
      secondaryregionname       : abap.char(50);
      streetname                : abap.char(150);
      streetprefixname1         : abap.char(150);
      streetprefixname2         : abap.char(150);
      streetsuffixname1         : abap.char(150);
      streetsuffixname2         : abap.char(150);
      taxjurisdiction           : abap.char(150);
      tertiaryregion            : abap.char(150);
      tertiaryregionname        : abap.char(150);
      transportzone             : abap.char(150);
      villagename               : abap.char(150);

}
