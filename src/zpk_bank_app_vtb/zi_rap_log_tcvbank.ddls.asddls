@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Log Tích hợp TCV Bank'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZI_RAP_LOG_TCVBANK
  as select from ztb_log_tcvbank
{
  key guid          as Guid,
      createdby     as Createdby,
      createdtime   as Createdtime,
      createddat    as Createddat,
      username      as Username,
      password      as Password,
      comm_scenario as CommScenario,
      service_id    as ServiceId,
      link          as Link,
      response      as Response,
      type          as Type
}
