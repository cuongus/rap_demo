CLASS lhc_EInvoiceUser DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR EInvoiceUser RESULT result.

    METHODS create FOR MODIFY
      IMPORTING entities FOR CREATE EInvoiceUser.

    METHODS update FOR MODIFY
      IMPORTING entities FOR UPDATE EInvoiceUser.

    METHODS delete FOR MODIFY
      IMPORTING keys FOR DELETE EInvoiceUser.

    METHODS read FOR READ
      IMPORTING keys FOR READ EInvoiceUser RESULT result.

    METHODS lock FOR LOCK
      IMPORTING keys FOR LOCK EInvoiceUser.

    METHODS rba_Einvoiceserial FOR READ
      IMPORTING keys_rba FOR READ EInvoiceUser\_Einvoiceserial FULL result_requested RESULT result LINK association_links.

    METHODS cba_Einvoiceserial FOR MODIFY
      IMPORTING entities_cba FOR CREATE EInvoiceUser\_Einvoiceserial.

ENDCLASS.

CLASS lhc_EInvoiceUser IMPLEMENTATION.

  METHOD get_instance_authorizations.
    LOOP AT keys INTO DATA(ls_key).
      IF ls_key-%tky-Usertype IS NOT INITIAL.
        AUTHORITY-CHECK OBJECT 'ZOBJUSERTY'
           ID 'ACTVT' FIELD '03'
           ID 'ZUSERTYPE2' FIELD ls_key-%tky-Usertype.
        IF sy-subrc NE 0.
          INSERT VALUE #(
              companycode = ls_key-%tky-Companycode
              usertype = ls_key-%tky-Usertype
              %update = if_abap_behv=>auth-unauthorized
              %delete = if_abap_behv=>auth-unauthorized
              %action-edit = if_abap_behv=>auth-unauthorized
          ) INTO TABLE result.

          INSERT VALUE #(
                 companycode = ls_key-%tky-Companycode
                 usertype = ls_key-%tky-Usertype
                 %msg        = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                           text     = |You aren't authority for CoCd { ls_key-%tky-Companycode } - Region { ls_key-%tky-Usertype }| )
                        ) INTO TABLE reported-einvoiceuser.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD create.
    DATA: lv_flag TYPE char1.
    CLEAR: lv_flag.

    LOOP AT entities INTO DATA(ls_entities).
      SELECT COUNT( * ) FROM zrap_inv_user WHERE companycode = @ls_entities-%key-Companycode
                                             AND usertype = @ls_entities-%key-Usertype
      INTO @DATA(lv_count).
      IF sy-subrc EQ 0.
        lv_flag = 'X'.
        INSERT VALUE #(
               companycode = ls_entities-%key-Companycode
               usertype = ls_entities-%key-Usertype
               %msg        = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                         text     = |Key Exist CoCd { ls_entities-%key-Companycode } - Region { ls_entities-%key-Usertype }| )
               %create = abap_false
               %update = abap_false
               %delete = abap_false
               %action-edit = abap_false
               %action-activate = abap_false
               %action-discard = abap_false
               %action-resume = abap_false
               %action-prepare = abap_false
                      ) INTO TABLE reported-einvoiceuser.
      ENDIF.

      AUTHORITY-CHECK OBJECT 'ZOBJUSERTY'
         ID 'ACTVT' FIELD '03'
         ID 'ZUSERTYPE2' FIELD ls_entities-%key-Usertype.
      IF sy-subrc NE 0.
        lv_flag = 'X'.
        INSERT VALUE #(
               companycode = ls_entities-%key-Companycode
               usertype = ls_entities-%key-Usertype
               %msg        = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                         text     = |You aren't authority for CoCd { ls_entities-%key-Companycode } - Region { ls_entities-%key-Usertype }| )
               %create = abap_false
               %update = abap_false
               %delete = abap_false
               %action-edit = abap_false
               %action-activate = abap_false
               %action-discard = abap_false
               %action-resume = abap_false
               %action-prepare = abap_false
                      ) INTO TABLE reported-einvoiceuser.
      ENDIF.
    ENDLOOP.
    IF lv_flag IS INITIAL.
      zcl_rap_einv_user_api_2=>get_instance( )->create_user(
      EXPORTING
      entities = entities
      CHANGING
      mapped = mapped
      failed = failed
      reported = reported
      ).
    ENDIF.
  ENDMETHOD.

  METHOD update.
    zcl_rap_einv_user_api_2=>get_instance( )->update_user(
    EXPORTING
    entities = entities
    CHANGING
    mapped = mapped
    failed = failed
    reported = reported
    ).
  ENDMETHOD.

  METHOD delete.
    zcl_rap_einv_user_api_2=>get_instance( )->delete_user(
    EXPORTING
    keys = keys
    CHANGING
    mapped = mapped
    failed = failed
    reported = reported
    ).
  ENDMETHOD.

  METHOD read.
    zcl_rap_einv_user_api_2=>get_instance( )->read_user(
    EXPORTING
    keys = keys
    CHANGING
    result = result
    failed = failed
    reported = reported
    ).
  ENDMETHOD.

  METHOD lock.
    TRY.
        DATA(lock) = cl_abap_lock_object_factory=>get_instance( iv_name = 'EZLOCK_INVUSER' ).
      CATCH cx_abap_lock_failure INTO DATA(exception).
        RAISE SHORTDUMP exception.
    ENDTRY.

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<lfs_keys>).
      TRY.
          lock->enqueue(
*              it_table_mode =
            it_parameter  = VALUE #( ( name = 'COMPANYCODE' value = REF #( <lfs_keys>-Companycode ) )
                                     ( name = 'USERTYPE' value = REF #( <lfs_keys>-Usertype ) )
                                   )
*              _scope        =
*              _wait         =
          ).
        CATCH cx_abap_foreign_lock INTO DATA(foreign_lock).
          APPEND VALUE #(
              companycode = keys[ 1 ]-Companycode
              usertype = keys[ 1 ]-Usertype
              %msg = new_message_with_text(
              severity = if_abap_behv_message=>severity-error
              text = 'Record is locked by ' && foreign_lock->user_name
              )
           ) TO reported-einvoiceuser.

        CATCH cx_abap_lock_failure INTO exception.
          RAISE SHORTDUMP exception.
      ENDTRY.
    ENDLOOP.
  ENDMETHOD.

  METHOD rba_Einvoiceserial.
  ENDMETHOD.

  METHOD cba_Einvoiceserial.
    zcl_rap_einv_user_api_2=>get_instance( )->cba_einvoiceserial(
    EXPORTING
    entities_cba = entities_cba
    CHANGING
    mapped = mapped
    failed = failed
    reported = reported
    ).
  ENDMETHOD.

ENDCLASS.

CLASS lhc_EInvoiceSerial DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS update FOR MODIFY
      IMPORTING entities FOR UPDATE EInvoiceSerial.

    METHODS delete FOR MODIFY
      IMPORTING keys FOR DELETE EInvoiceSerial.

    METHODS read FOR READ
      IMPORTING keys FOR READ EInvoiceSerial RESULT result.

    METHODS rba_Einvoiceuser FOR READ
      IMPORTING keys_rba FOR READ EInvoiceSerial\_Einvoiceuser FULL result_requested RESULT result LINK association_links.

ENDCLASS.

CLASS lhc_EInvoiceSerial IMPLEMENTATION.

  METHOD update.
    zcl_rap_einv_user_api_2=>get_instance( )->update_serial(
    EXPORTING
    entities = entities
    CHANGING
    mapped = mapped
    failed = failed
    reported = reported
    ).
  ENDMETHOD.

  METHOD delete.
    zcl_rap_einv_user_api_2=>get_instance( )->delete_serial(
    EXPORTING
    keys = keys
    CHANGING
    mapped = mapped
    failed = failed
    reported = reported
    ).
  ENDMETHOD.

  METHOD read.
    zcl_rap_einv_user_api_2=>get_instance( )->read_serial(
    EXPORTING
    keys = keys
    CHANGING
    result = result
    failed = failed
    reported = reported
    ).
  ENDMETHOD.

  METHOD rba_Einvoiceuser.
  ENDMETHOD.

ENDCLASS.

CLASS lsc_ZI_RAP_INV_USER DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS finalize REDEFINITION.

    METHODS check_before_save REDEFINITION.

    METHODS save REDEFINITION.

    METHODS cleanup REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_ZI_RAP_INV_USER IMPLEMENTATION.

  METHOD finalize.
  ENDMETHOD.

  METHOD check_before_save.
  ENDMETHOD.

  METHOD save.
    DATA: lv_flag TYPE char1.
    CLEAR: lv_flag.
    zcl_rap_einv_user_api_2=>get_instance( )->save(
    CHANGING
    reported = reported
    ).

    IF lv_flag IS INITIAL.
      CLEAR: reported.
    ENDIF.
  ENDMETHOD.

  METHOD cleanup.
    zcl_rap_einv_user_api_2=>get_instance( )->cleanup( ).
  ENDMETHOD.

  METHOD cleanup_finalize.
    zcl_rap_einv_user_api_2=>get_instance( )->cleanup_finalize( ).
  ENDMETHOD.

ENDCLASS.
