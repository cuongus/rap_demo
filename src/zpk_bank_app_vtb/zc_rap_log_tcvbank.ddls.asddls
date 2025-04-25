@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Log Tích hợp TCV Bank'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
@Search.searchable: true
define root view entity ZC_RAP_LOG_TCVBANK
  provider contract transactional_query
  as projection on ZI_RAP_LOG_TCVBANK
{
  key Guid,
      @Search.defaultSearchElement: true
      Createdby,
      @Search.defaultSearchElement: true
      Createdtime,
      @Search.defaultSearchElement: true
      Createddat,
      Username,
      Password,
      CommScenario,
      ServiceId,
      Link,
      Response,
      Type
}
