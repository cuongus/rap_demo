CLASS lhc_zi_rap_tcv_cfauth_bank DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR zi_rap_tcv_cfauth_bank RESULT result.

ENDCLASS.

CLASS lhc_zi_rap_tcv_cfauth_bank IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

ENDCLASS.
