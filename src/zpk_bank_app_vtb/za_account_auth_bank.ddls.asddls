@EndUserText.label: 'Parameter payment custom'

define abstract entity ZA_ACCOUNT_AUTH_BANK
{
    @EndUserText.label: 'User Name'
    username                : abap.char(210);
    @EndUserText.label: 'Password'
    @UI.dataFieldDefault: [{hidden: true}]
    password                 : abap.char(210);
    
}
