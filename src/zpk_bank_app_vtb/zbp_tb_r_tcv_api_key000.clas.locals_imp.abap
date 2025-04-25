CLASS lhc_ZTB_R_TCV_API_KEY000 DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR ztb_r_tcv_api_key000 RESULT result.

    METHODS create FOR MODIFY
      IMPORTING entities FOR CREATE ztb_r_tcv_api_key000.

    METHODS update FOR MODIFY
      IMPORTING entities FOR UPDATE ztb_r_tcv_api_key000.

    METHODS delete FOR MODIFY
      IMPORTING keys FOR DELETE ztb_r_tcv_api_key000.

    METHODS read FOR READ
      IMPORTING keys FOR READ ztb_r_tcv_api_key000 RESULT result.

    METHODS lock FOR LOCK
      IMPORTING keys FOR LOCK ztb_r_tcv_api_key000.


ENDCLASS.

CLASS lhc_ZTB_R_TCV_API_KEY000 IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD create.
    DATA: lt_insert TYPE TABLE OF ztb_tcv_api_key,
          ls_insert TYPE ztb_tcv_api_key.

*    SELECT *
*    FROM ztb_tcv_api_key
*    INTO TABLE @DATA(lt_data).
*
*    LOOP AT lt_data INTO DATA(ls_data).
*        ls_insert = ls_data.
*        ls_insert-is_active = 'Inactive'.
*        APPEND ls_insert TO lt_insert.
*    ENDLOOP.

    LOOP AT entities INTO DATA(entitie).
      ls_insert-client = sy-mandt.
      ls_insert-x_ibm_client_id = entitie-XIbmClientId.
      ls_insert-x_ibm_client_secret = entitie-XIbmClientSecret.

      data(lv_date) = cl_abap_context_info=>get_system_date( ).

      TRY.
          CONVERT DATE lv_date TIME cl_abap_context_info=>get_system_time( ) INTO TIME STAMP ls_insert-created_at
          TIME ZONE cl_abap_context_info=>get_user_time_zone(  ).
        CATCH cx_abap_context_info_error.
          "handle exception
      ENDTRY.

      ls_insert-is_active = 'Active'.
      ls_insert-created_by = sy-uname.
      APPEND ls_insert TO lt_insert.
    ENDLOOP.


    zcl_conf_api_key=>fill_data( lt_insert ).

  ENDMETHOD.

  METHOD update.
  ENDMETHOD.

  METHOD delete.
  ENDMETHOD.

  METHOD read.
  ENDMETHOD.

  METHOD lock.
  ENDMETHOD.

ENDCLASS.

CLASS lsc_ZTB_R_TCV_API_KEY000 DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS finalize REDEFINITION.

    METHODS check_before_save REDEFINITION.

    METHODS save REDEFINITION.

    METHODS cleanup REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_ZTB_R_TCV_API_KEY000 IMPLEMENTATION.

  METHOD finalize.
  ENDMETHOD.

  METHOD check_before_save.
  ENDMETHOD.

  METHOD save.
    zcl_conf_api_key=>save_data(  ).
  ENDMETHOD.

  METHOD cleanup.
    zcl_conf_api_key=>cleanup(  ).
  ENDMETHOD.

  METHOD cleanup_finalize.
*    zcl_conf_api_key=>cleanup(  ).
  ENDMETHOD.

ENDCLASS.
