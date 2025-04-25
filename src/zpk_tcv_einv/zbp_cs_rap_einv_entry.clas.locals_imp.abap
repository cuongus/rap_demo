CLASS lhc_CSEInvoiceEntry DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    TYPES: BEGIN OF ty_message,
             companycode        TYPE bukrs,
             accountingdocument TYPE belnr_d,
             fiscalyear         TYPE gjahr,
             msgtype            TYPE sy-msgty,
             msgtext            TYPE zde_text255_2,
           END OF ty_message,
           tt_message TYPE TABLE OF ty_message.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR CSEInvoiceEntry RESULT result.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR CSEInvoiceEntry RESULT result.

    METHODS create FOR MODIFY
      IMPORTING entities FOR CREATE CSEInvoiceEntry.

    METHODS update FOR MODIFY
      IMPORTING entities FOR UPDATE CSEInvoiceEntry.

    METHODS delete FOR MODIFY
      IMPORTING keys FOR DELETE CSEInvoiceEntry.

    METHODS read FOR READ
      IMPORTING keys FOR READ CSEInvoiceEntry RESULT result.

    METHODS lock FOR LOCK
      IMPORTING keys FOR LOCK CSEInvoiceEntry.

    METHODS rba_Einvoiceitems FOR READ
      IMPORTING keys_rba FOR READ CSEInvoiceEntry\_Einvoiceitems FULL result_requested RESULT result LINK association_links.

    METHODS cba_Einvoiceitems FOR MODIFY
      IMPORTING entities_cba FOR CREATE CSEInvoiceEntry\_Einvoiceitems.

    METHODS AdjustEINV FOR MODIFY
      IMPORTING keys FOR ACTION CSEInvoiceEntry~AdjustEINV RESULT result.

    METHODS CancelEINV FOR MODIFY
      IMPORTING keys FOR ACTION CSEInvoiceEntry~CancelEINV RESULT result.

    METHODS InteEINV FOR MODIFY
      IMPORTING keys FOR ACTION CSEInvoiceEntry~InteEINV RESULT result.

    METHODS ReplaceEINV FOR MODIFY
      IMPORTING keys FOR ACTION CSEInvoiceEntry~ReplaceEINV RESULT result.

    METHODS SearchEINV FOR MODIFY
      IMPORTING keys FOR ACTION CSEInvoiceEntry~SearchEINV RESULT result.

ENDCLASS.

CLASS lhc_CSEInvoiceEntry IMPLEMENTATION.

  METHOD get_instance_features.
  ENDMETHOD.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD create.
  ENDMETHOD.

  METHOD update.
    zcl_rap_cseinv_entry_api=>get_instance( )->update_entry(
    EXPORTING
    entities = entities
    CHANGING
    mapped = mapped
    failed = failed
    reported = reported
    ).
  ENDMETHOD.

  METHOD delete.
    DATA: tt_return TYPE tt_message.
    FREE: tt_return.
    zcl_rap_cseinv_entry_api=>get_instance( )->delete_header(
    EXPORTING
    keys = keys
    CHANGING
    mapped = mapped
    failed = failed
    reported = reported
    e_return = tt_return
    ).
    IF tt_return IS NOT INITIAL.
      LOOP AT tt_return INTO DATA(ls_return) WHERE msgtype = 'E'.
        INSERT VALUE #(
               companycode = ls_return-companycode
               accountingdocument = ls_return-accountingdocument
               fiscalyear  = ls_return-fiscalyear
               %msg        = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                         text     = ls_return-msgtext )
                      ) INTO TABLE reported-cseinvoiceentry.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.

  METHOD read.
    zcl_rap_cseinv_entry_api=>get_instance( )->read_header(
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
        DATA(lock) = cl_abap_lock_object_factory=>get_instance( iv_name = 'EZLOCK_EINVENTRY' ).
      CATCH cx_abap_lock_failure INTO DATA(exception).
        RAISE SHORTDUMP exception.
    ENDTRY.

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<lfs_keys>).
      TRY.
          lock->enqueue(
*              it_table_mode =
            it_parameter  = VALUE #( ( name = 'COMPANYCODE' value = REF #( <lfs_keys>-Companycode ) )
                                     ( name = 'DOCUMENT' value = REF #( <lfs_keys>-accountingdocument ) )
                                     ( name = 'FISCALYEAR' value = REF #( <lfs_keys>-fiscalyear ) )
                                   )
*              _scope        =
*              _wait         =
          ).
        CATCH cx_abap_foreign_lock INTO DATA(foreign_lock).
          APPEND VALUE #(
              companycode = keys[ 1 ]-Companycode
              accountingdocument = keys[ 1 ]-accountingdocument
              fiscalyear = keys[ 1 ]-fiscalyear
              %msg = new_message_with_text(
              severity = if_abap_behv_message=>severity-error
              text = 'Record is locked by ' && foreign_lock->user_name
              )
           ) TO reported-cseinvoiceentry.

        CATCH cx_abap_lock_failure INTO exception.
          RAISE SHORTDUMP exception.
      ENDTRY.
    ENDLOOP.
  ENDMETHOD.

  METHOD rba_Einvoiceitems.
  ENDMETHOD.

  METHOD cba_Einvoiceitems.
    zcl_rap_cseinv_entry_api=>get_instance( )->cba_einvoiceitems(
    EXPORTING
    entities_cba = entities_cba
    CHANGING
    mapped = mapped
    failed = failed
    reported = reported
    ).
  ENDMETHOD.

  METHOD AdjustEINV.
    DATA: tt_return TYPE tt_message.
    FREE: tt_return.
    zcl_rap_cseinv_entry_api=>get_instance( )->adjusteinv(
    EXPORTING
    keys = keys
    CHANGING
    result = result
    mapped = mapped
    failed = failed
    reported = reported
    e_return = tt_return
    ).
    IF tt_return IS NOT INITIAL.
      LOOP AT tt_return INTO DATA(ls_return) WHERE msgtype = 'E'.
        INSERT VALUE #(
               companycode = ls_return-companycode
               accountingdocument = ls_return-accountingdocument
               fiscalyear  = ls_return-fiscalyear
               %msg        = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                         text     = ls_return-msgtext )
                      ) INTO TABLE reported-cseinvoiceentry.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.

  METHOD CancelEINV.
    DATA: tt_return TYPE tt_message.
    FREE: tt_return.
    zcl_rap_cseinv_entry_api=>get_instance( )->canceleinv(
    EXPORTING
    keys = keys
    CHANGING
    result = result
    mapped = mapped
    failed = failed
    reported = reported
    e_return = tt_return
    ).
    IF tt_return IS NOT INITIAL.
      LOOP AT tt_return INTO DATA(ls_return) WHERE msgtype = 'E'.
        INSERT VALUE #(
               companycode = ls_return-companycode
               accountingdocument = ls_return-accountingdocument
               fiscalyear  = ls_return-fiscalyear
               %msg        = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                         text     = ls_return-msgtext )
                      ) INTO TABLE reported-cseinvoiceentry.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.

  METHOD InteEINV.
    DATA: tt_return TYPE tt_message.
    FREE: tt_return.
    zcl_rap_cseinv_entry_api=>get_instance( )->inteeinv(
    EXPORTING
    keys = keys
    CHANGING
    result = result
    mapped = mapped
    failed = failed
    reported = reported
    e_return = tt_return
    ).
    IF tt_return IS NOT INITIAL.
      LOOP AT tt_return INTO DATA(ls_return) WHERE msgtype = 'E'.
        INSERT VALUE #(
               companycode = ls_return-companycode
               accountingdocument = ls_return-accountingdocument
               fiscalyear  = ls_return-fiscalyear
               %msg        = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                         text     = ls_return-msgtext )
                      ) INTO TABLE reported-cseinvoiceentry.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.

  METHOD ReplaceEINV.
    DATA: tt_return TYPE tt_message.
    FREE: tt_return.
    zcl_rap_cseinv_entry_api=>get_instance( )->replaceeinv(
    EXPORTING
    keys = keys
    CHANGING
    result = result
    mapped = mapped
    failed = failed
    reported = reported
    e_return = tt_return
    ).
    IF tt_return IS NOT INITIAL.
      LOOP AT tt_return INTO DATA(ls_return) WHERE msgtype = 'E'.
        INSERT VALUE #(
               companycode = ls_return-companycode
               accountingdocument = ls_return-accountingdocument
               fiscalyear  = ls_return-fiscalyear
               %msg        = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                         text     = ls_return-msgtext )
                      ) INTO TABLE reported-cseinvoiceentry.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.

  METHOD SearchEINV.
    DATA: tt_return TYPE tt_message.
    FREE: tt_return.
    zcl_rap_cseinv_entry_api=>get_instance( )->searcheinv(
    EXPORTING
    keys = keys
    CHANGING
    result = result
    mapped = mapped
    failed = failed
    reported = reported
    e_return = tt_return
    ).
  ENDMETHOD.

ENDCLASS.

CLASS lhc_CSEInvoiceItem DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS update FOR MODIFY
      IMPORTING entities FOR UPDATE CSEInvoiceItem.

    METHODS delete FOR MODIFY
      IMPORTING keys FOR DELETE CSEInvoiceItem.

    METHODS read FOR READ
      IMPORTING keys FOR READ CSEInvoiceItem RESULT result.

    METHODS rba_Einvoicesheader FOR READ
      IMPORTING keys_rba FOR READ CSEInvoiceItem\_Einvoicesheader FULL result_requested RESULT result LINK association_links.

ENDCLASS.

CLASS lhc_CSEInvoiceItem IMPLEMENTATION.

  METHOD update.
  ENDMETHOD.

  METHOD delete.
  ENDMETHOD.

  METHOD read.
  ENDMETHOD.

  METHOD rba_Einvoicesheader.
  ENDMETHOD.

ENDCLASS.

CLASS lsc_ZCS_RAP_EINV_ENTRY DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS finalize REDEFINITION.

    METHODS check_before_save REDEFINITION.

    METHODS save REDEFINITION.

    METHODS cleanup REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_ZCS_RAP_EINV_ENTRY IMPLEMENTATION.

  METHOD finalize.
  ENDMETHOD.

  METHOD check_before_save.
  ENDMETHOD.

  METHOD save.
    zcl_rap_cseinv_entry_api=>get_instance( )->save_einvoices(
    CHANGING
    reported = reported
    ).
  ENDMETHOD.

  METHOD cleanup.
    zcl_rap_cseinv_entry_api=>get_instance( )->cleanup( ).
  ENDMETHOD.

  METHOD cleanup_finalize.
    zcl_rap_cseinv_entry_api=>get_instance( )->cleanup_finalize( ).
  ENDMETHOD.

ENDCLASS.
