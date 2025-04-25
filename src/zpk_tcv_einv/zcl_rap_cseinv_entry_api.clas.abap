CLASS zcl_rap_cseinv_entry_api DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    "Common Variables
    TYPES: BEGIN OF ty_range_option,
             sign   TYPE c LENGTH 1,
             option TYPE c LENGTH 2,
             low    TYPE string,
             high   TYPE string,
           END OF ty_range_option,

           BEGIN OF ty_keys_document,
             companycode        TYPE bukrs,
             accountingdocument TYPE belnr_d,
             fiscalyear         TYPE gjahr,
           END OF ty_keys_document,

           BEGIN OF ty_hrcond,
             field TYPE string,
             opera TYPE char2,
             low   TYPE string,
             high  TYPE string,
           END OF ty_hrcond,

           BEGIN OF ty_s_clause,
             line TYPE char72,
           END OF ty_s_clause,

           BEGIN OF ty_message,
             companycode        TYPE bukrs,
             accountingdocument TYPE belnr_d,
             fiscalyear         TYPE gjahr,
             msgtype            TYPE sy-msgty,
             msgtext            TYPE zde_text255_2,
           END OF ty_message,

           BEGIN OF ty_accountingdocument,
             companycode            TYPE bukrs,
             accountingdocument     TYPE belnr_d,
             fiscalyer              TYPE gjahr,
             accountingdocumentitem TYPE buzei,
           END OF ty_accountingdocument,

           tt_accountingdocument TYPE TABLE OF ty_accountingdocument,

           tt_message            TYPE TABLE OF ty_message,

           tt_hrcond             TYPE TABLE OF ty_hrcond,
           tt_clause             TYPE TABLE OF ty_s_clause,

           tt_ranges             TYPE TABLE OF ty_range_option,
           tt_rap_einv_header    TYPE TABLE OF zrap_einv_entry,
           tt_rap_einv_items     TYPE TABLE OF zrap_einv_item.

    "Behavior Variables
    TYPES:

*      "Action delete
      tt_header_delete   TYPE TABLE FOR DELETE zcs_rap_einv_entry\\cseinvoiceentry,
*      tt_items_delete    TYPE TABLE FOR DELETE zcs_rap_einv_entry\\cseinvoiceitem,

      "Action Read
      tt_header_readh    TYPE TABLE FOR READ IMPORT zcs_rap_einv_entry\\cseinvoiceentry,
      tt_result_readh    TYPE TABLE FOR READ RESULT zcs_rap_einv_entry\\cseinvoiceentry,

      tt_items_readi     TYPE TABLE FOR READ IMPORT zcs_rap_einv_entry\\cseinvoiceitem,
      tt_result_readi    TYPE TABLE FOR READ RESULT zcs_rap_einv_entry\\cseinvoiceitem,
      "Action Integration
      tt_header_inteeinv TYPE TABLE FOR ACTION IMPORT zcs_rap_einv_entry\\cseinvoiceentry~inteeinv,
      tt_result_inteeinv TYPE TABLE FOR ACTION RESULT zcs_rap_einv_entry\\cseinvoiceentry~inteeinv,
      "Action Cancel
      tt_canceleinv      TYPE TABLE FOR ACTION IMPORT zcs_rap_einv_entry\\cseinvoiceentry~canceleinv,
      tt_cancel_result   TYPE TABLE FOR ACTION RESULT zcs_rap_einv_entry\\cseinvoiceentry~canceleinv,
      "Action Search
      tt_search_einv     TYPE TABLE FOR ACTION IMPORT zcs_rap_einv_entry\\cseinvoiceentry~SearchEINV,
      tt_search_result   TYPE TABLE FOR ACTION RESULT zcs_rap_einv_entry\\cseinvoiceentry~SearchEINV,
      "Action Adjust
      tt_adjust_einv     TYPE TABLE FOR ACTION IMPORT zcs_rap_einv_entry\\cseinvoiceentry~adjusteinv,
      tt_result_adjust   TYPE TABLE FOR ACTION RESULT zcs_rap_einv_entry\\cseinvoiceentry~adjusteinv,
      "Action Replace
      tt_replace_einv    TYPE TABLE FOR ACTION IMPORT zcs_rap_einv_entry\\cseinvoiceentry~replaceeinv,
      tt_result_replace  TYPE TABLE FOR ACTION RESULT zcs_rap_einv_entry\\cseinvoiceentry~replaceeinv,
      "Update
      tt_update_entry    TYPE TABLE FOR UPDATE zcs_rap_einv_entry\\cseinvoiceentry,
      "Cba entities
      tt_entities_cba    TYPE TABLE FOR CREATE zcs_rap_einv_entry\\cseinvoiceentry\_einvoiceitems,

      "Common
      tt_mapped_early    TYPE RESPONSE FOR MAPPED EARLY zcs_rap_einv_entry,
      tt_failed_early    TYPE RESPONSE FOR FAILED EARLY zcs_rap_einv_entry,
      tt_reported_early  TYPE RESPONSE FOR REPORTED EARLY zcs_rap_einv_entry,
      tt_reported_late   TYPE RESPONSE FOR REPORTED LATE zcs_rap_einv_entry
      .
    CLASS-METHODS:
      "Class Contructor
      get_Instance RETURNING VALUE(ro_instance) TYPE REF TO zcl_rap_cseinv_entry_api,

      get_document      IMPORTING keys     TYPE ANY TABLE
                        EXPORTING e_header TYPE tt_rap_einv_header
                                  e_items  TYPE tt_rap_einv_items,

      get_user_password IMPORTING i_userpass   TYPE zrap_inv_user
                                  i_formserial TYPE zrap_inv_serial
                        EXPORTING e_userpass   TYPE zrap_inv_user
                                  e_formserial TYPE zrap_inv_serial
                                  e_return     TYPE bapiret2,

      move_log          IMPORTING i_input  TYPE zrap_einv_entry
                        EXPORTING o_output TYPE zrap_einv_entry,

      Check_adjust_doc IMPORTING i_einv_header TYPE zrap_einv_entry
                                 I_datetype    TYPE zde_datetype2
                       EXPORTING e_userpass    TYPE zrap_inv_user
                                 e_formserial  TYPE zrap_inv_serial
                                 e_return      TYPE bapiret2,
*      "Class for Behavior
      delete_header IMPORTING keys     TYPE tt_header_delete"table for delete zcs_rap_einv_entry\\cseinvoiceentry
                    CHANGING  mapped   TYPE tt_mapped_early "response for mapped early zcs_rap_einv_entry
                              failed   TYPE tt_failed_early "response for failed early zcs_rap_einv_entry
                              reported TYPE tt_reported_early "response for reported early zcs_rap_einv_entry,
                              e_return TYPE tt_message, "Return message error
*
*      delete_items IMPORTING keys     TYPE tt_items_delete "table for delete zcs_rap_einv_entry\\cseinvoiceitem
*                   CHANGING  mapped   TYPE tt_mapped_early "response for mapped early zcs_rap_einv_entry
*                             failed   TYPE tt_failed_early "response for failed early zcs_rap_einv_entry
*                             reported TYPE tt_reported_early, "response for reported early zcs_rap_einv_entry

      read_header IMPORTING keys     TYPE tt_header_readh "table for read import zcs_rap_einv_entry\\cseinvoiceentry
                  CHANGING  result   TYPE tt_result_readh "table for read result zcs_rap_einv_entry\\cseinvoiceentry
                            failed   TYPE tt_failed_early "response for failed early zi_rap_einv_header
                            reported TYPE tt_reported_early, "response for reported early zi_rap_einv_header

      read_items IMPORTING keys     TYPE tt_items_readi "table for read import zcs_rap_einv_entry\\cseinvoiceitem
                 CHANGING  result   TYPE tt_result_readi "table for read result zcs_rap_einv_entry\\cseinvoiceitem
                           failed   TYPE tt_failed_early "response for failed early zcs_rap_einv_entry
                           reported TYPE tt_reported_early, "response for reported early zcs_rap_einv_entry

      update_entry IMPORTING entities TYPE tt_update_entry "table for update zcs_rap_einv_entry\\cseinvoiceentry
                   CHANGING  mapped   TYPE tt_mapped_early "response for mapped early zcs_rap_einv_entry
                             failed   TYPE tt_failed_early "response for failed early zcs_rap_einv_entry
                             reported TYPE tt_reported_early, "response for reported early zcs_rap_einv_entry

      cba_einvoiceitems IMPORTING entities_cba TYPE tt_entities_cba "table for create zcs_rap_einv_entry\\cseinvoiceentry\_einvoiceitems
                        CHANGING  mapped       TYPE tt_mapped_early "response for mapped early zcs_rap_einv_entry
                                  failed       TYPE tt_failed_early "response for failed early zcs_rap_einv_entry
                                  reported     TYPE tt_reported_early, "response for reported early zcs_rap_einv_entry

      "Action Integration EInvoices
      inteEINV
        IMPORTING keys     TYPE tt_header_inteeinv "table for action import zcs_rap_einv_entry\\cseinvoiceentry~inteeinv
        CHANGING  result   TYPE tt_result_inteeinv "table for action result zcs_rap_einv_entry\\cseinvoiceentry~inteeinv
                  mapped   TYPE tt_mapped_early "response for mapped early zcs_rap_einv_entry
                  failed   TYPE tt_failed_early "response for failed early zcs_rap_einv_entry
                  reported TYPE tt_reported_early "response for reported early zcs_rap_einv_entry
                  e_return TYPE tt_message, "Return message error

      "Action Cancel EInvoices
      canceleinv IMPORTING keys     TYPE tt_canceleinv "table for action import zcs_rap_einv_entry\\cseinvoiceentry~canceleinv
                 CHANGING  result   TYPE tt_cancel_result "table for action result zcs_rap_einv_entry\\cseinvoiceentry~canceleinv
                           mapped   TYPE tt_mapped_early "response for mapped early zcs_rap_einv_entry
                           failed   TYPE tt_failed_early "response for failed early zcs_rap_einv_entry
                           reported TYPE tt_reported_early "response for reported early zcs_rap_einv_entry
                           e_return TYPE tt_message, "Return message error

      "Action Search EInvoices
      SearchEinv IMPORTING keys     TYPE tt_search_einv "table for action import zcs_rap_einv_entry\\cseinvoiceentry~updatesteinv
                 CHANGING  result   TYPE tt_search_result "table for action result zcs_rap_einv_entry\\cseinvoiceentry~updatesteinv
                           mapped   TYPE tt_mapped_early "response for mapped early zcs_rap_einv_entry
                           failed   TYPE tt_failed_early "response for failed early zcs_rap_einv_entry
                           reported TYPE tt_reported_early "response for reported early zcs_rap_einv_entry
                           e_return TYPE tt_message, "Return message error

      "Action Adjust EInvoices
      adjusteinv IMPORTING keys     TYPE tt_adjust_einv "table for action import zcs_rap_einv_entry\\einvoicesheader~adjusteinv
                 CHANGING  result   TYPE tt_result_adjust "table for action result zcs_rap_einv_entry\\einvoicesheader~adjusteinv
                           mapped   TYPE tt_mapped_early "response for mapped early zcs_rap_einv_entry
                           failed   TYPE tt_failed_early "response for failed early zcs_rap_einv_entry
                           reported TYPE tt_reported_early "response for reported early zcs_rap_einv_entry
                           e_return TYPE tt_message, "Return message error

      "Action Replace EInvoices
      replaceeinv  IMPORTING keys     TYPE tt_replace_einv "table for action import zcs_rap_einv_entry\\cseinvoiceentry~replaceeinv
                   CHANGING  result   TYPE tt_result_replace "table for action result zcs_rap_einv_entry\\cseinvoiceentry~replaceeinv
                             mapped   TYPE tt_mapped_early "response for mapped early zcs_rap_einv_entry
                             failed   TYPE tt_failed_early "response for failed early zcs_rap_einv_entry
                             reported TYPE tt_reported_early "response for reported early zcs_rap_einv_entry
                             e_return TYPE tt_message, "Return message error

      "Common Methods
      save_einvoices
        CHANGING reported              TYPE tt_reported_late "response for reported late zcs_rap_einv_entry
                 ,

      cleanup,
      cleanup_finalize.

    CLASS-DATA: gt_accountingdocument TYPE tt_accountingdocument.

  PROTECTED SECTION.
  PRIVATE SECTION.
    CLASS-DATA: mo_instance TYPE REF TO zcl_rap_cseinv_entry_api.
    CLASS-DATA:
      gt_einv_header TYPE TABLE OF zrap_einv_entry,
      gt_einv_items  TYPE TABLE OF zrap_einv_item,
      gt_einv_docsrc TYPE TABLE OF zrap_einv_entry.

    CLASS-DATA: gt_header_del TYPE TABLE OF zrap_inv_delete,
                gt_items_del  TYPE TABLE OF zrap_einv_item.

    "Views Import
    CLASS-DATA: gt_key_document TYPE TABLE OF ty_keys_document.

ENDCLASS.



CLASS ZCL_RAP_CSEINV_ENTRY_API IMPLEMENTATION.


  METHOD adjusteinv.
    TYPES: BEGIN OF lty_dc,
             bukrs TYPE bukrs,
             belnr TYPE belnr_d,
             gjahr TYPE gjahr,
           END OF lty_dc.
    DATA: ls_dc TYPE lty_dc.

    DATA:
      lv_action     TYPE zde_eaction,
      ls_einvoice   TYPE zrap_einv_entry,
      ls_userpass   TYPE zrap_inv_user,
      ls_formserial TYPE zrap_inv_serial,
      lv_testrun    TYPE flag,
      ls_status     TYPE zrap_einv_entry,
      ls_json       TYPE string,
      ls_return     TYPE bapiret2.

    DATA: ls_docsrc TYPE zrap_einv_entry,
          lt_docsrc TYPE TABLE OF zrap_einv_entry.

    DATA: ls_result        LIKE LINE OF result,
          ls_mapped_header LIKE LINE OF mapped-cseinvoiceentry.
    DATA: ls_param TYPE zr_adjust_einv.

    zcl_rap_cseinv_entry_api=>get_instance( )->get_document(
    EXPORTING
    keys = keys
    IMPORTING
    e_header = DATA(lt_rap_einv_header)
    e_items = DATA(lt_rap_einv_items)
    ).
    LOOP AT keys INTO DATA(ls_keys).
      ls_dc-belnr = ls_param-Belnrsrc = ls_keys-%param-Belnrsrc.
      ls_dc-gjahr = ls_param-Gjahrsrc = ls_keys-%param-Gjahrsrc.
      ls_param-adjtype = ls_keys-%param-adjtype.
      "Bổ sung logic 13.01.2025
      ls_param-datetype = ls_keys-%param-datetype.
    ENDLOOP.

    LOOP AT lt_rap_einv_header ASSIGNING FIELD-SYMBOL(<lfs_rap_einv_header>).

      IF <lfs_rap_einv_header>-Statussap = '01' OR <lfs_rap_einv_header>-statussap = '03'.

        <lfs_rap_einv_header>-Belnrsrc = ls_param-Belnrsrc.
        <lfs_rap_einv_header>-Gjahrsrc = ls_param-Gjahrsrc.
        <lfs_rap_einv_header>-adjtype = ls_param-adjtype.

        CASE <lfs_rap_einv_header>-adjtype.
          WHEN '1'.
            <lfs_rap_einv_header>-adjtext = 'Increase adjustment'.
          WHEN '2'.
            <lfs_rap_einv_header>-adjtext = 'Decrease adjustment'.
          WHEN '3'.
            <lfs_rap_einv_header>-adjtext = 'Replace'.
          WHEN OTHERS.
        ENDCASE.

        zcl_rap_cseinv_entry_api=>get_instance( )->check_adjust_doc(
           EXPORTING
           i_einv_header = <lfs_rap_einv_header>
           i_datetype = ls_param-datetype
           IMPORTING
           e_userpass = ls_userpass
           e_formserial = ls_formserial
           e_return = ls_return
        ).

        IF ls_return-type EQ 'E'.
          <lfs_rap_einv_header>-Belnrsrc = ''.
          <lfs_rap_einv_header>-Gjahrsrc = ''.
          <lfs_rap_einv_header>-adjtype = ''.
          <lfs_rap_einv_header>-adjtext = ''.
          APPEND VALUE #( companycode = <lfs_rap_einv_header>-companycode
                          accountingdocument = <lfs_rap_einv_header>-accountingdocument
                          fiscalyear = <lfs_rap_einv_header>-fiscalyear
                          msgtype = ls_return-type
                          msgtext = ls_return-message ) TO e_return.
        ELSE.

          IF <lfs_rap_einv_header>-Belnrsrc IS NOT INITIAL.

            zcl_rap_cseinv_entry_api=>get_instance( )->get_user_password(
                EXPORTING
                i_userpass = ls_userpass
                i_formserial = ls_formserial
                IMPORTING
                e_userpass = ls_userpass
                e_formserial = ls_formserial
            ).

            <lfs_rap_einv_header>-usertype = ls_userpass-usertype.
            <lfs_rap_einv_header>-form = ls_formserial-form.
            <lfs_rap_einv_header>-serial = ls_formserial-serial.

            MOVE-CORRESPONDING <lfs_rap_einv_header> TO ls_einvoice.

            lv_action = 'adjust-invoice'.
            zcl_manage_fpt_einvoices_2=>get_instance( )->adjust_einvoices(
                EXPORTING
                i_action    = lv_action
                i_einvoice  = ls_einvoice
                i_items     = lt_rap_einv_items
                i_userpass  = ls_userpass
                i_testrun   = lv_testrun
                IMPORTING
                e_status    = ls_status
                e_docsrc    = ls_docsrc
                e_json      = ls_json
                e_return    = ls_return
            ).

            zcl_rap_cseinv_entry_api=>get_instance( )->move_log(
              EXPORTING
              i_input = ls_status
              IMPORTING
              o_output = <lfs_rap_einv_header>
          ).
            IF ls_return-type = 'E'.
              <lfs_rap_einv_header>-Iconsap = '@0A@'.
              <lfs_rap_einv_header>-Statussap = '03'.
              <lfs_rap_einv_header>-MsgTy = ls_return-type.
              <lfs_rap_einv_header>-MsgTx = ls_return-message.
            ENDIF.
          ELSE.
            <lfs_rap_einv_header>-Belnrsrc = ''.
            <lfs_rap_einv_header>-Gjahrsrc = ''.
            <lfs_rap_einv_header>-adjtype = ''.
            <lfs_rap_einv_header>-adjtext = ''.
          ENDIF.
        ENDIF.

      ELSE.
        "MESSAGE Error
        APPEND VALUE #( companycode = <lfs_rap_einv_header>-companycode
                          accountingdocument = <lfs_rap_einv_header>-accountingdocument
                          fiscalyear = <lfs_rap_einv_header>-fiscalyear
                          msgtype = 'E'
                          msgtext = TEXT-010 ) TO e_return.
      ENDIF.

      ls_result-%tky-Companycode = <lfs_rap_einv_header>-Companycode.
      ls_result-%tky-Accountingdocument = <lfs_rap_einv_header>-Accountingdocument.
      ls_result-%tky-Fiscalyear = <lfs_rap_einv_header>-Fiscalyear.

      ls_result-%key-Companycode = <lfs_rap_einv_header>-Companycode.
      ls_result-%key-Accountingdocument = <lfs_rap_einv_header>-Accountingdocument.
      ls_result-%key-Fiscalyear = <lfs_rap_einv_header>-Fiscalyear.

      ls_result-Companycode = <lfs_rap_einv_header>-Companycode.
      ls_result-Accountingdocument = <lfs_rap_einv_header>-Accountingdocument.
      ls_result-Fiscalyear = <lfs_rap_einv_header>-Fiscalyear.

      ls_mapped_header-%tky = ls_result-%tky.
      ls_mapped_header-Companycode = <lfs_rap_einv_header>-Companycode.
      ls_mapped_header-Accountingdocument = <lfs_rap_einv_header>-Accountingdocument.
      ls_mapped_header-Fiscalyear = <lfs_rap_einv_header>-Fiscalyear.

      MOVE-CORRESPONDING <lfs_rap_einv_header> TO ls_result-%param.
      IF ls_docsrc IS NOT INITIAL.
        APPEND ls_docsrc TO lt_docsrc.
      ENDIF.

      INSERT CORRESPONDING #( ls_result ) INTO TABLE result.
      INSERT CORRESPONDING #( ls_mapped_header ) INTO TABLE mapped-cseinvoiceentry.

      CLEAR: ls_docsrc, ls_status, ls_json, ls_return.

    ENDLOOP.

    MOVE-CORRESPONDING lt_rap_einv_header TO gt_einv_header.
    MOVE-CORRESPONDING lt_docsrc TO gt_einv_docsrc.
  ENDMETHOD.


  METHOD canceleinv.
    DATA:
      lv_action     TYPE zde_eaction,
      ls_einvoice   TYPE zrap_einv_entry,
      ls_userpass   TYPE zrap_inv_user,
      ls_formserial TYPE zrap_inv_serial,
      lv_testrun    TYPE flag,
      ls_status     TYPE zrap_einv_entry,
      ls_json       TYPE string,
      ls_return     TYPE bapiret2,
      lv_Xreversed  TYPE char1.

    DATA: ls_param  TYPE zr_cancel_einv,
          ls_result LIKE LINE OF result.

    CLEAR: lv_Xreversed.

    LOOP AT keys INTO DATA(ls_keys).
*      ls_param-usertype = ls_keys-%param-usertype.
      ls_param-noti_taxtype = ls_keys-%param-noti_taxtype.
      ls_param-noti_taxnum = ls_keys-%param-noti_taxnum.
      ls_param-place = ls_keys-%param-place.
      ls_param-noti_type = ls_keys-%param-noti_type.
    ENDLOOP.

    zcl_rap_cseinv_entry_api=>get_instance( )->get_document(
    EXPORTING
    keys = keys
    IMPORTING
    e_header = DATA(lt_rap_einv_header)
    ).
    lv_action = 'cancel-invoice'.

    LOOP AT lt_rap_einv_header ASSIGNING FIELD-SYMBOL(<lfs_rap_einv_header>).
      IF <lfs_rap_einv_header>-StatusSap = '98' OR <lfs_rap_einv_header>-StatusSap = '99'.

        MOVE-CORRESPONDING <lfs_rap_einv_header> TO ls_einvoice.

        SELECT SINGLE isreversed FROM i_journalentry WHERE companycode = @<lfs_rap_einv_header>-companycode
                                                       AND accountingdocument = @<lfs_rap_einv_header>-accountingdocument
                                                       AND fiscalyear = @<lfs_rap_einv_header>-fiscalyear
        INTO @lv_xreversed.
        IF sy-subrc NE 0.
          CLEAR: lv_xreversed.
        ENDIF.

        IF lv_Xreversed IS INITIAL.
          "Message Error
          APPEND VALUE #( companycode = <lfs_rap_einv_header>-companycode
                          accountingdocument = <lfs_rap_einv_header>-accountingdocument
                          fiscalyear = <lfs_rap_einv_header>-fiscalyear
                          msgtype = 'E'
                          msgtext = TEXT-011 ) TO e_return.
        ELSE.

          ls_userpass-companycode = <lfs_rap_einv_header>-Companycode.
          ls_userpass-usertype = <lfs_rap_einv_header>-Usertype.

          ls_formserial-companycode = <lfs_rap_einv_header>-Companycode.
          ls_formserial-fiscalyear = <lfs_rap_einv_header>-Fiscalyear.
          ls_formserial-usertype = <lfs_rap_einv_header>-Usertype.
          ls_formserial-etype = <lfs_rap_einv_header>-Etype.

          zcl_rap_cseinv_entry_api=>get_instance( )->get_user_password(
              EXPORTING
              i_userpass = ls_userpass
              i_formserial = ls_formserial
              IMPORTING
              e_userpass = ls_userpass
              e_formserial = ls_formserial
          ).

          zcl_manage_fpt_einvoices_2=>get_instance( )->cancel_einvoices(
            EXPORTING
            i_action = lv_action
            i_einvoice = ls_einvoice
            i_testrun = lv_testrun
            i_param = ls_param
            i_userpass = ls_userpass
            IMPORTING
            e_status   = ls_status
            e_return = ls_return
            e_json = ls_json
          ).

        ENDIF.
      ELSE. "End check status
        "Message Error
        APPEND VALUE #( companycode = <lfs_rap_einv_header>-companycode
                        accountingdocument = <lfs_rap_einv_header>-accountingdocument
                        fiscalyear = <lfs_rap_einv_header>-fiscalyear
                        msgtype = 'E'
                        msgtext = TEXT-010 ) TO e_return.
      ENDIF.

      IF ls_return-type EQ 'E'.
        <lfs_rap_einv_header>-Iconsap = ls_status-Iconsap.
        <lfs_rap_einv_header>-Statussap = '03'.
        <lfs_rap_einv_header>-MsgTx = ls_status-MsgTx.
      ELSE.
        zcl_rap_cseinv_entry_api=>get_instance( )->move_log(
           EXPORTING
           i_input = ls_status
           IMPORTING
           o_output = <lfs_rap_einv_header>
        ).
      ENDIF.

      ls_result-%tky-Companycode = <lfs_rap_einv_header>-Companycode.
      ls_result-%tky-Accountingdocument = <lfs_rap_einv_header>-Accountingdocument.
      ls_result-%tky-Fiscalyear = <lfs_rap_einv_header>-Fiscalyear.

      ls_result-%key-Companycode = <lfs_rap_einv_header>-Companycode.
      ls_result-%key-Accountingdocument = <lfs_rap_einv_header>-Accountingdocument.
      ls_result-%key-Fiscalyear = <lfs_rap_einv_header>-Fiscalyear.

      ls_result-Companycode = <lfs_rap_einv_header>-Companycode.
      ls_result-Accountingdocument = <lfs_rap_einv_header>-Accountingdocument.
      ls_result-Fiscalyear = <lfs_rap_einv_header>-Fiscalyear.


      MOVE-CORRESPONDING <lfs_rap_einv_header> TO ls_result-%param.
      INSERT CORRESPONDING #( ls_result ) INTO TABLE result.

    ENDLOOP.

    MOVE-CORRESPONDING lt_rap_einv_header TO gt_einv_header.
  ENDMETHOD.


  METHOD cba_einvoiceitems.

  ENDMETHOD.


  METHOD check_adjust_doc.

    DATA: lv_count TYPE int4.

    IF i_einv_header-Belnrsrc IS NOT INITIAL AND i_einv_header-Gjahrsrc IS NOT INITIAL AND i_einv_header-adjtype IS NOT INITIAL.

      SELECT SINGLE * FROM zrap_einv_entry
      WHERE Companycode = @i_einv_header-Companycode
      AND Accountingdocument = @i_einv_header-belnrsrc
      AND Fiscalyear = @i_einv_header-Gjahrsrc
      INTO @DATA(ls_check).
      IF sy-subrc EQ 0.
        IF ls_check-customer NE i_einv_header-customer.
          e_return-type = 'E'.
          e_return-message = TEXT-008.
        ENDIF.
        IF ls_check-region NE i_einv_header-region.
          e_return-type = 'E'.
          e_return-message = TEXT-009.
        ENDIF.
      ENDIF.

      lv_count = 0.

      SELECT COUNT( 1 )
      FROM zrap_einv_entry
      WHERE Companycode = @i_einv_header-Companycode
      AND Accountingdocument = @i_einv_header-belnrsrc
      AND Fiscalyear = @i_einv_header-Gjahrsrc
      AND statussap IN ('98','99','06')
      INTO @lv_count.
      IF lv_count = 0.
        e_return-type = 'E'.
        e_return-message = TEXT-003.
        REPLACE '&1' INTO e_return-message WITH i_einv_header-Belnrsrc.
        REPLACE '&2' INTO e_return-message WITH i_einv_header-Gjahrsrc.
      ELSE.
        lv_count = 0.

        "Trường hợp thay thế chứng từ.
        IF i_einv_header-adjtype = '3'.
          SELECT COUNT( 1 )
          FROM I_JournalEntry
          WHERE companycode = @i_einv_header-Companycode
            AND AccountingDocument = @i_einv_header-Belnrsrc
            AND Fiscalyear = @i_einv_header-Gjahrsrc
            AND reversedocument NE ''
            INTO @lv_count.
          IF lv_count = 0.
            e_return-type = 'E'.
            e_return-message = TEXT-007.
            REPLACE '&1' INTO e_return-message WITH i_einv_header-Belnrsrc.
            REPLACE '&2' INTO e_return-message WITH i_einv_header-Gjahrsrc.
          ENDIF.
        ENDIF.

        lv_count = 0.
        SELECT COUNT( 1 )
        FROM zrap_einv_entry
        WHERE Companycode = @i_einv_header-Companycode
        AND Accountingdocument = @i_einv_header-Belnrsrc
        AND Fiscalyear = @i_einv_header-Gjahrsrc
        AND Currency = @i_einv_header-Currency
        INTO @lv_count.
        IF lv_count = 0.
          e_return-type = 'E'.
          e_return-message = TEXT-004.
        ELSE.
        ENDIF.

        lv_count = 0.
        SELECT COUNT( 1 )
        FROM zrap_einv_entry
        WHERE Companycode = @i_einv_header-Companycode
        AND Accountingdocument = @i_einv_header-belnrsrc
        AND Fiscalyear = @i_einv_header-gjahrsrc
        AND statussap IN ('07')
        AND gjahrsrc NE ''
        INTO @lv_count.
        IF lv_count NE 0.
          e_return-type = 'E'.
          e_return-message = TEXT-005.
        ENDIF.
      ENDIF.

      DATA: lv_gjahr TYPE gjahr.

      IF e_return-type NE 'E'.
        "Bổ sung logic date type - 13.01.2025
        IF i_datetype = '3'.
          lv_gjahr = sy-datlo+0(4).
        ELSEIF i_datetype = '2'.
          lv_gjahr = i_einv_header-entrydate+0(4).
        ELSEIF i_datetype = ''.
          lv_gjahr = i_einv_header-documentdate+0(4).
        ELSEIF i_datetype = '1'.
          lv_gjahr = i_einv_header-postingdate+0(4).
        ENDIF.

        SELECT SINGLE companycode, accountingdocument, fiscalyear, usertype, etype, dateiss
        FROM zrap_einv_entry
        WHERE Companycode = @i_einv_header-Companycode
          AND Accountingdocument = @i_einv_header-Belnrsrc
          AND Fiscalyear = @i_einv_header-Gjahrsrc
        INTO @DATA(ls_userpass).
        IF sy-subrc EQ 0.
          e_userpass-companycode = ls_userpass-Companycode.
          e_userpass-usertype = ls_userpass-Usertype.

          e_formserial-companycode = ls_userpass-Companycode.
          " Bổ sung logic -- 03.01.2025
          " Lấy Year theo date phát hành hóa đơn bị điều chỉnh
*          e_formserial-fiscalyear = ls_userpass-Fiscalyear.
*          e_formserial-fiscalyear = ls_userpass-dateiss+0(4).
          " Bổ sung logic -- 13.01.2025
          "Lấy Year theo tham số
          e_formserial-fiscalyear = lv_gjahr.
          e_formserial-usertype = ls_userpass-Usertype.
          e_formserial-etype = ls_userpass-etype.
        ENDIF.
      ENDIF.

    ELSEIF i_einv_header-Belnrsrc IS INITIAL AND i_einv_header-Gjahrsrc IS INITIAL AND i_einv_header-adjtype IS INITIAL.

    ELSE.
      e_return-type = 'E'.
      e_return-message = TEXT-006.
    ENDIF.
  ENDMETHOD.


  METHOD cleanup.
    DATA: lt_einv_header TYPE TABLE OF zrap_einv_entry.

    LOOP AT gt_einv_header INTO DATA(ls_einv_header) WHERE statussap EQ '98' OR statussap EQ '99'.
      APPEND ls_einv_header TO lt_einv_header.
    ENDLOOP.

    FREE: gt_einv_header,
        gt_einv_items,
        gt_header_del,
        gt_items_del,
        gt_key_document,
        gt_einv_docsrc.

    "Call SOAP Over HTTP
    TRY.
        zsc_call_service_com_0002_V2=>get_instance( )->change_journal_entry_http(
        i_header = lt_einv_header
        i_accountingdocument = gt_accountingdocument
         ).
      CATCH cx_uuid_error cx_abap_context_info_error.
        "handle exception
    ENDTRY.

  ENDMETHOD.


  METHOD cleanup_finalize.
    zcl_rap_cseinv_entry_api=>get_instance( )->cleanup( ).
  ENDMETHOD.


  METHOD delete_header.
    LOOP AT keys INTO DATA(ls_keys).
      SELECT SINGLE * FROM zrap_einv_entry
      WHERE companycode = @ls_keys-%key-companycode
      AND accountingdocument = @ls_keys-%key-accountingdocument
      AND fiscalyear = @ls_keys-%key-fiscalyear
      AND seq NE ''
      INTO @DATA(ls_check_header).
      IF sy-subrc NE 0.
        APPEND VALUE #( companycode = ls_keys-%key-companycode accountingdocument = ls_keys-%key-accountingdocument fiscalyear = ls_keys-%key-fiscalyear )
        TO gt_header_del.
      ELSE.
        APPEND VALUE #( companycode = ls_keys-%tky-companycode
                        accountingdocument = ls_keys-%tky-accountingdocument
                        fiscalyear = ls_keys-%tky-fiscalyear
                        msgtype = 'E'
                        msgtext = TEXT-013 ) TO e_return.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.


  METHOD get_document.
    DATA: lr_bukrs TYPE tt_ranges,
          lr_belnr TYPE tt_ranges,
          lr_gjahr TYPE tt_ranges.

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<lfs_keys>).
      ASSIGN COMPONENT '%tky-Companycode' OF STRUCTURE <lfs_keys> TO FIELD-SYMBOL(<lv_value>).
      IF sy-subrc EQ 0.
        APPEND VALUE #( sign = 'I' option = 'EQ' low = <lv_value> ) TO lr_bukrs.
      ENDIF.

      ASSIGN COMPONENT '%tky-Accountingdocument' OF STRUCTURE <lfs_keys> TO <lv_value>.
      IF sy-subrc EQ 0.
        APPEND VALUE #( sign = 'I' option = 'EQ' low = <lv_value> ) TO lr_belnr.
      ENDIF.

      ASSIGN COMPONENT '%tky-Fiscalyear' OF STRUCTURE <lfs_keys> TO <lv_value>.
      IF sy-subrc EQ 0.
        APPEND VALUE #( sign = 'I' option = 'EQ' low = <lv_value> ) TO lr_gjahr.
      ENDIF.
    ENDLOOP.

*    SELECT * FROM zrap_einv_entry WHERE Companycode IN @lr_bukrs
*                                   AND Accountingdocument IN @lr_belnr
*                                   AND Fiscalyear IN @lr_gjahr
*                                   "AND seq IS INITIAL
*    INTO CORRESPONDING FIELDS OF TABLE @e_header.
*
*    SELECT * FROM zrap_einv_item WHERE Companycode IN @lr_bukrs
*                               AND Accountingdocument IN @lr_belnr
*                               AND Fiscalyear IN @lr_gjahr
*                               "AND seq IS INITIAL
*    INTO CORRESPONDING FIELDS OF TABLE @e_items.

    zcl_rap_inv_generate=>get_instance( )->get_document_new(
    EXPORTING
    ir_bukrs = lr_bukrs
    ir_belnr = lr_belnr
    ir_gjahr = lr_gjahr
    IMPORTING
    header   = e_header
    items    = e_items
    ).
  ENDMETHOD.


  METHOD get_instance. "Class Contructor
    mo_instance = ro_instance = COND #( WHEN mo_instance IS BOUND
                                           THEN mo_instance
                                           ELSE NEW #( ) ).
  ENDMETHOD.


  METHOD get_user_password.
    DATA: lv_fiscalyear TYPE gjahr.

    SELECT SINGLE * FROM zrap_inv_user WHERE Companycode = @i_userpass-companycode
                                  AND usertype = @i_userpass-usertype
    INTO CORRESPONDING FIELDS OF @e_userpass.
    IF sy-subrc NE 0.
      e_return-type = 'E'.
      e_return-message = TEXT-001.
    ENDIF.

    SELECT SINGLE * FROM zrap_inv_serial WHERE Companycode = @i_formserial-companycode
                                    AND usertype = @i_formserial-usertype
                                    AND etype = @i_formserial-etype
                                    AND Fiscalyear = @i_formserial-fiscalyear
    INTO CORRESPONDING FIELDS OF @e_formserial.
    IF sy-subrc NE 0.
      e_return-type = 'E'.
      e_return-message = TEXT-002 && ` ` && i_formserial-fiscalyear.
    ENDIF.
  ENDMETHOD.


  METHOD inteeinv.
    DATA:
      lt_docsrc TYPE TABLE OF zrap_einv_entry,
      ls_docsrc TYPE zrap_einv_entry.

    DATA: lr_bukrs TYPE tt_ranges,
          lr_belnr TYPE tt_ranges,
          lr_gjahr TYPE tt_ranges.

    DATA: ls_mapped_header   LIKE LINE OF mapped-cseinvoiceentry,
          ls_mapped_item     LIKE LINE OF mapped-cseinvoiceitem,

          ls_reported_header LIKE LINE OF reported-cseinvoiceentry,
          ls_reported_items  LIKE LINE OF reported-cseinvoiceitem.

    DATA: ls_result LIKE LINE OF result.

    DATA:
      lv_action     TYPE zde_eaction,
      ls_einvoice   TYPE zrap_einv_entry,
      ls_userpass   TYPE zrap_inv_user,
      ls_formserial TYPE zrap_inv_serial,
      lv_testrun    TYPE flag,
      ls_status     TYPE zrap_einv_entry,
      ls_json       TYPE string,
      ls_return     TYPE bapiret2.

    DATA: ls_param TYPE zr_integration_einv.

    LOOP AT keys INTO DATA(ls_keys).
*      ls_param-companycode = ls_keys-%param-companycode.
      ls_param-usertype = ls_keys-%param-usertype.
      ls_param-datetype = ls_keys-%param-datetype.
*      ls_param-etype = ls_keys-%param-etype.
*      ls_param-test_run = ls_keys-%param-test_run.
    ENDLOOP.

*    MOVE-CORRESPONDING ls_param TO ls_userpass.
*    MOVE-CORRESPONDING ls_param TO ls_formserial.

    lv_testrun = ''.

    zcl_rap_cseinv_entry_api=>get_instance( )->get_document(
        EXPORTING
        keys = keys
        IMPORTING
        e_header = DATA(lt_rap_einv_header)
        e_items = DATA(lt_rap_einv_items)
    ).

    IF lt_rap_einv_header IS INITIAL.

    ENDIF.

    LOOP AT lt_rap_einv_header ASSIGNING FIELD-SYMBOL(<lfs_rap_einv_header>).

      IF <lfs_rap_einv_header>-StatusSap = '' OR <lfs_rap_einv_header>-StatusSap = '01'
      OR <lfs_rap_einv_header>-StatusSap = '03'.
        IF <lfs_rap_einv_header>-Seq IS INITIAL.

          IF <lfs_rap_einv_header>-Xreversed IS INITIAL AND <lfs_rap_einv_header>-Xreversing IS INITIAL.
            <lfs_rap_einv_header>-usertype = ls_param-usertype.
            CASE ls_param-usertype.
              WHEN '1'.
                <lfs_rap_einv_header>-usertypetext = 'TP Hà Nội'.
              WHEN '2'.
                <lfs_rap_einv_header>-usertypetext = 'TP Hồ Chí Minh'.
              WHEN OTHERS.
            ENDCASE.

            MOVE-CORRESPONDING <lfs_rap_einv_header> TO ls_einvoice.

            ls_userpass-companycode = ls_einvoice-companycode.
            ls_userpass-usertype = ls_einvoice-usertype.

            ls_formserial-companycode = ls_einvoice-companycode.
            ls_formserial-usertype = ls_einvoice-usertype.
*            ls_formserial-etype = ls_param-etype.
            ls_formserial-etype = '01GTKT'.

            "Bổ sung logic date type - 03.01.2025
            IF ls_param-datetype = '3'.
              ls_formserial-fiscalyear = sy-datlo+0(4).
            ELSEIF ls_param-datetype = '2'.
              ls_formserial-fiscalyear = ls_einvoice-entrydate+0(4).
            ELSEIF ls_param-datetype = ''.
              ls_formserial-fiscalyear = ls_einvoice-documentdate+0(4).
            ELSEIF ls_param-datetype = '1'.
              ls_formserial-fiscalyear = ls_einvoice-postingdate+0(4).
            ENDIF.

            zcl_rap_cseinv_entry_api=>get_instance( )->get_user_password(
                EXPORTING
                i_userpass = ls_userpass
                i_formserial = ls_formserial
                IMPORTING
                e_userpass = ls_userpass
                e_formserial = ls_formserial
            ).

            ls_einvoice-Serial = ls_formserial-Serial.
            ls_einvoice-Form = ls_formserial-Form.

            IF ls_einvoice-BelnrSrc IS NOT INITIAL.
              lv_action = 'adjust-invoice'.
              zcl_manage_fpt_einvoices_2=>get_instance( )->adjust_einvoices(
                  EXPORTING
                  i_action    = lv_action
                  i_einvoice  = ls_einvoice
                  i_items     = lt_rap_einv_items
                  i_userpass  = ls_userpass
                  i_testrun   = lv_testrun
                  IMPORTING
                  e_status    = ls_status
                  e_docsrc    = ls_docsrc
                  e_json      = ls_json
                  e_return    = ls_return
              ).
            ELSE.
              lv_action = 'create-invoice'.
              zcl_manage_fpt_einvoices_2=>get_instance( )->create_einvoices(
                  EXPORTING
                  i_action    = lv_action
                  i_einvoice  = ls_einvoice
                  i_items     = lt_rap_einv_items
                  i_userpass  = ls_userpass
                  i_testrun   = lv_testrun
                  IMPORTING
                  e_status    = ls_status
                  e_docsrc    = ls_docsrc
                  e_json      = ls_json
                  e_return    = ls_return
              ).
            ENDIF.
            zcl_rap_cseinv_entry_api=>get_instance( )->move_log(
                EXPORTING
                i_input = ls_status
                IMPORTING
                o_output = <lfs_rap_einv_header>
            ).
            IF ls_return-type = 'E'.
              <lfs_rap_einv_header>-Iconsap = '@0A@'.
              <lfs_rap_einv_header>-Statussap = '03'.
              <lfs_rap_einv_header>-MsgTy = ls_return-type.
              <lfs_rap_einv_header>-MsgTx = ls_return-message.
            ENDIF.
          ELSE.  "End check reverse
            <lfs_rap_einv_header>-MsgTy = 'E'.
            <lfs_rap_einv_header>-Statussap = '03'.
            <lfs_rap_einv_header>-MsgTx = 'Document Is Reversal/Reversed'.
          ENDIF.

        ELSE. "End check seq
          <lfs_rap_einv_header>-Belnrsrc = ''.
          <lfs_rap_einv_header>-Gjahrsrc = ''.
          <lfs_rap_einv_header>-adjtype = ''.
          APPEND VALUE #( companycode = <lfs_rap_einv_header>-companycode
                          accountingdocument = <lfs_rap_einv_header>-accountingdocument
                          fiscalyear = <lfs_rap_einv_header>-fiscalyear
                          msgtype = 'E'
                          msgtext = TEXT-012 ) TO e_return.
        ENDIF.

      ELSE. "End check status
        <lfs_rap_einv_header>-Belnrsrc = ''.
        <lfs_rap_einv_header>-Gjahrsrc = ''.
        <lfs_rap_einv_header>-adjtype = ''.
        APPEND VALUE #( companycode = <lfs_rap_einv_header>-companycode
                        accountingdocument = <lfs_rap_einv_header>-accountingdocument
                        fiscalyear = <lfs_rap_einv_header>-fiscalyear
                        msgtype = 'E'
                        msgtext = TEXT-010 ) TO e_return.
      ENDIF.

      ls_result-%tky-Companycode = <lfs_rap_einv_header>-Companycode.
      ls_result-%tky-Accountingdocument = <lfs_rap_einv_header>-Accountingdocument.
      ls_result-%tky-Fiscalyear = <lfs_rap_einv_header>-Fiscalyear.

      ls_result-%key-Companycode = <lfs_rap_einv_header>-Companycode.
      ls_result-%key-Accountingdocument = <lfs_rap_einv_header>-Accountingdocument.
      ls_result-%key-Fiscalyear = <lfs_rap_einv_header>-Fiscalyear.

      ls_result-Companycode = <lfs_rap_einv_header>-Companycode.
      ls_result-Accountingdocument = <lfs_rap_einv_header>-Accountingdocument.
      ls_result-Fiscalyear = <lfs_rap_einv_header>-Fiscalyear.

      ls_mapped_header-%tky = ls_result-%tky.
      ls_mapped_header-Companycode = <lfs_rap_einv_header>-Companycode.
      ls_mapped_header-Accountingdocument = <lfs_rap_einv_header>-Accountingdocument.
      ls_mapped_header-Fiscalyear = <lfs_rap_einv_header>-Fiscalyear.

      MOVE-CORRESPONDING <lfs_rap_einv_header> TO ls_result-%param.
      IF ls_docsrc IS NOT INITIAL.
        APPEND ls_docsrc TO lt_docsrc.
      ENDIF.

      INSERT CORRESPONDING #( ls_result ) INTO TABLE result.
      INSERT CORRESPONDING #( ls_mapped_header ) INTO TABLE mapped-cseinvoiceentry.

      CLEAR: ls_docsrc, ls_status, ls_json, ls_return.
    ENDLOOP.

    MOVE-CORRESPONDING lt_rap_einv_header TO gt_einv_header.
    MOVE-CORRESPONDING lt_docsrc TO gt_einv_docsrc.
  ENDMETHOD.


  METHOD move_log.
    o_output-seq        = i_input-Seq .
    o_output-serial     = i_input-Serial .
    o_output-form       = i_input-Form .
    o_output-EType      = i_input-EType .
    o_output-mscqt      = i_input-Mscqt .
    o_output-link       = i_input-link .
    o_output-dateint    = i_input-dateint .
    o_output-dateiss    = i_input-dateiss .
    o_output-timeiss    = i_input-Timeiss .
    o_output-datecanc   = i_input-Datecanc .
    o_output-statussap  = i_input-StatusSap .
    o_output-statusinv  = i_input-StatusInv .
    o_output-statuscqt  = i_input-StatusCqt .
    o_output-msgty      = i_input-MsgTy .
    o_output-msgtx      = i_input-MsgTx .
    o_output-createdby  = i_input-createdby.
    o_output-createdon  = i_input-createdon.
  ENDMETHOD.


  METHOD read_header.

    DATA: ls_result LIKE LINE OF result,
          lr_bukrs  TYPE tt_ranges,
          lr_belnr  TYPE tt_ranges,
          lr_gjahr  TYPE tt_ranges,

          lv_skip   TYPE int8,
          lv_top    TYPE int8.

    DATA: lt_entry TYPE TABLE OF zcs_rap_einv_entry.

    LOOP AT keys INTO DATA(ls_keys).
      APPEND VALUE #( sign = 'I' option = 'EQ' low = ls_keys-%tky-companycode ) TO lr_bukrs.
      APPEND VALUE #( sign = 'I' option = 'EQ' low = ls_keys-%tky-accountingdocument ) TO lr_belnr.
      APPEND VALUE #( sign = 'I' option = 'EQ' low = ls_keys-%tky-FiscalYear ) TO lr_gjahr.
    ENDLOOP.

    zcl_rap_cseinv_entry_api=>get_instance( )->get_document(
        EXPORTING
        keys = keys
        IMPORTING
        e_header = DATA(lt_header)
        e_items = DATA(lt_items)
    ).
    LOOP AT lt_header ASSIGNING FIELD-SYMBOL(<ls_header>).
      ls_result-%tky-companycode = <ls_header>-Companycode.
      ls_result-%tky-accountingdocument = <ls_header>-Accountingdocument.
      ls_result-%tky-FiscalYear = <ls_header>-Fiscalyear.
      MOVE-CORRESPONDING <ls_header> TO ls_result-%data.
      INSERT CORRESPONDING #( ls_result ) INTO TABLE result.
    ENDLOOP.

    IF lt_header IS NOT INITIAL.
      MOVE-CORRESPONDING lt_header TO reported-cseinvoiceentry.
    ENDIF.

    IF lt_items IS NOT INITIAL.
      MOVE-CORRESPONDING lt_items TO reported-cseinvoiceitem.
    ENDIF.
  ENDMETHOD.


  METHOD read_items.
    DATA: ls_result LIKE LINE OF result,
          lr_bukrs  TYPE tt_ranges,
          lr_belnr  TYPE tt_ranges,
          lr_gjahr  TYPE tt_ranges,

          lv_skip   TYPE int8,
          lv_top    TYPE int8.

    LOOP AT keys INTO DATA(ls_keys).
      APPEND VALUE #( sign = 'I' option = 'EQ' low = ls_keys-%tky-companycode ) TO lr_bukrs.
      APPEND VALUE #( sign = 'I' option = 'EQ' low = ls_keys-%tky-accountingdocument ) TO lr_belnr.
      APPEND VALUE #( sign = 'I' option = 'EQ' low = ls_keys-%tky-FiscalYear ) TO lr_gjahr.
    ENDLOOP.

    zcl_rap_cseinv_entry_api=>get_instance( )->get_document(
        EXPORTING
        keys = keys
        IMPORTING
        e_header = DATA(lt_header)
        e_items = DATA(lt_items)
    ).
    LOOP AT lt_items INTO DATA(ls_items).
      ls_result-%tky-companycode = ls_items-Companycode.
      ls_result-%tky-accountingdocument = ls_items-Accountingdocument.
      ls_result-%tky-FiscalYear = ls_items-Fiscalyear.
      MOVE-CORRESPONDING ls_items TO ls_result-%data.
      INSERT CORRESPONDING #( ls_result ) INTO TABLE result.
    ENDLOOP.

    DATA: ls_rap_einv_header LIKE LINE OF reported-cseinvoiceentry.

    LOOP AT lt_header ASSIGNING FIELD-SYMBOL(<ls_header>).
      MOVE-CORRESPONDING <ls_header> TO ls_rap_einv_header.
*        ls_rap_einv_header-%state_area = 'VALIDATE_FIELD'.
*        ls_rap_einv_header-%element-accountingdocument = if_abap_behv=>mk-on.
*        ls_rap_einv_header-%msg = new_message(  'Import Succesfull!' ).
      INSERT CORRESPONDING #( ls_rap_einv_header ) INTO TABLE reported-cseinvoiceentry.
    ENDLOOP.

    IF lt_items IS NOT INITIAL.
      MOVE-CORRESPONDING lt_items TO reported-cseinvoiceitem.
    ENDIF.

  ENDMETHOD.


  METHOD replaceeinv.
    TYPES: BEGIN OF lty_dc,
             bukrs TYPE bukrs,
             belnr TYPE belnr_d,
             gjahr TYPE gjahr,
           END OF lty_dc.
    DATA: ls_dc TYPE lty_dc.

    DATA:
      lv_action     TYPE zde_eaction,
      ls_einvoice   TYPE zrap_einv_entry,
      ls_userpass   TYPE zrap_inv_user,
      ls_formserial TYPE zrap_inv_serial,
      lv_testrun    TYPE flag,
      ls_status     TYPE zrap_einv_entry,
      ls_json       TYPE string,
      ls_return     TYPE bapiret2.

    DATA: ls_docsrc TYPE zrap_einv_entry,
          lt_docsrc TYPE TABLE OF zrap_einv_entry.

    DATA: ls_result        LIKE LINE OF result,
          ls_mapped_header LIKE LINE OF mapped-cseinvoiceentry.
    DATA: ls_param TYPE zr_adjust_einv.

    zcl_rap_cseinv_entry_api=>get_instance( )->get_document(
    EXPORTING
    keys = keys
    IMPORTING
    e_header = DATA(lt_rap_einv_header)
    e_items = DATA(lt_rap_einv_items)
    ).
    LOOP AT keys INTO DATA(ls_keys).
      ls_dc-belnr = ls_param-Belnrsrc = ls_keys-%param-Belnrsrc.
      ls_dc-gjahr = ls_param-Gjahrsrc = ls_keys-%param-Gjahrsrc.
      ls_param-datetype = ls_keys-%param-datetype.
*      ls_param-adjtype = ls_keys-%param-adjtype.
    ENDLOOP.
    ls_param-adjtype = '3'.

    LOOP AT lt_rap_einv_header ASSIGNING FIELD-SYMBOL(<lfs_rap_einv_header>).
      IF <lfs_rap_einv_header>-Statussap = '01' OR <lfs_rap_einv_header>-Statussap = '03'.
*        IF ls_dc-belnr = ls_einvoice-Belnrsrc AND ls_dc-gjahr = ls_einvoice-Gjahrsrc.
*          CONTINUE.
*        ELSE.
        <lfs_rap_einv_header>-Belnrsrc = ls_param-Belnrsrc.
        <lfs_rap_einv_header>-Gjahrsrc = ls_param-Gjahrsrc.
        <lfs_rap_einv_header>-adjtype = ls_param-adjtype.

        CASE <lfs_rap_einv_header>-adjtype.
          WHEN '1'.
            <lfs_rap_einv_header>-adjtext = 'Increase adjustment'.
          WHEN '2'.
            <lfs_rap_einv_header>-adjtext = 'Decrease adjustment'.
          WHEN '3'.
            <lfs_rap_einv_header>-adjtext = 'Replace'.
          WHEN OTHERS.
        ENDCASE.

        zcl_rap_cseinv_entry_api=>get_instance( )->check_adjust_doc(
           EXPORTING
           i_einv_header = <lfs_rap_einv_header>
           i_datetype = ls_param-datetype
           IMPORTING
           e_userpass = ls_userpass
           e_formserial = ls_formserial
           e_return = ls_return
        ).

        IF ls_return-type EQ 'E'.
          <lfs_rap_einv_header>-Belnrsrc = ''.
          <lfs_rap_einv_header>-Gjahrsrc = ''.
          <lfs_rap_einv_header>-adjtype = ''.
          <lfs_rap_einv_header>-adjtext = ''.
          APPEND VALUE #( companycode = <lfs_rap_einv_header>-companycode
                          accountingdocument = <lfs_rap_einv_header>-accountingdocument
                          fiscalyear = <lfs_rap_einv_header>-fiscalyear
                          msgtype = ls_return-type
                          msgtext = ls_return-message ) TO e_return.
        ELSE.
          IF <lfs_rap_einv_header>-Belnrsrc IS NOT INITIAL.

            zcl_rap_cseinv_entry_api=>get_instance( )->get_user_password(
                EXPORTING
                i_userpass = ls_userpass
                i_formserial = ls_formserial
                IMPORTING
                e_userpass = ls_userpass
                e_formserial = ls_formserial
            ).

            <lfs_rap_einv_header>-usertype = ls_userpass-usertype.
            <lfs_rap_einv_header>-form = ls_formserial-form.
            <lfs_rap_einv_header>-serial = ls_formserial-serial.

            MOVE-CORRESPONDING <lfs_rap_einv_header> TO ls_einvoice.

            lv_action = 'replace-invoice'.
            zcl_manage_fpt_einvoices_2=>get_instance( )->adjust_einvoices(
                EXPORTING
                i_action    = lv_action
                i_einvoice  = ls_einvoice
                i_items     = lt_rap_einv_items
                i_userpass  = ls_userpass
                i_testrun   = lv_testrun
                IMPORTING
                e_status    = ls_status
                e_docsrc    = ls_docsrc
                e_json      = ls_json
                e_return    = ls_return
            ).

            zcl_rap_cseinv_entry_api=>get_instance( )->move_log(
              EXPORTING
              i_input = ls_status
              IMPORTING
              o_output = <lfs_rap_einv_header>
          ).
            IF ls_return-type = 'E'.
              <lfs_rap_einv_header>-Iconsap = '@0A@'.
              <lfs_rap_einv_header>-Statussap = '03'.
              <lfs_rap_einv_header>-MsgTy = ls_return-type.
              <lfs_rap_einv_header>-MsgTx = ls_return-message.
            ENDIF.
          ELSE.
            <lfs_rap_einv_header>-Belnrsrc = ''.
            <lfs_rap_einv_header>-Gjahrsrc = ''.
            <lfs_rap_einv_header>-adjtype = ''.
            <lfs_rap_einv_header>-adjtext = ''.
          ENDIF.
        ENDIF.

*        ENDIF.
      ELSE.
        "MESSAGE Error
        APPEND VALUE #( companycode = <lfs_rap_einv_header>-companycode
                        accountingdocument = <lfs_rap_einv_header>-accountingdocument
                        fiscalyear = <lfs_rap_einv_header>-fiscalyear
                        msgtype = 'E'
                        msgtext = TEXT-010 ) TO e_return.
      ENDIF.

      ls_result-%tky-Companycode = <lfs_rap_einv_header>-Companycode.
      ls_result-%tky-Accountingdocument = <lfs_rap_einv_header>-Accountingdocument.
      ls_result-%tky-Fiscalyear = <lfs_rap_einv_header>-Fiscalyear.

      ls_result-%key-Companycode = <lfs_rap_einv_header>-Companycode.
      ls_result-%key-Accountingdocument = <lfs_rap_einv_header>-Accountingdocument.
      ls_result-%key-Fiscalyear = <lfs_rap_einv_header>-Fiscalyear.

      ls_result-Companycode = <lfs_rap_einv_header>-Companycode.
      ls_result-Accountingdocument = <lfs_rap_einv_header>-Accountingdocument.
      ls_result-Fiscalyear = <lfs_rap_einv_header>-Fiscalyear.

      ls_mapped_header-%tky = ls_result-%tky.
      ls_mapped_header-Companycode = <lfs_rap_einv_header>-Companycode.
      ls_mapped_header-Accountingdocument = <lfs_rap_einv_header>-Accountingdocument.
      ls_mapped_header-Fiscalyear = <lfs_rap_einv_header>-Fiscalyear.

      MOVE-CORRESPONDING <lfs_rap_einv_header> TO ls_result-%param.
      IF ls_docsrc IS NOT INITIAL.
        APPEND ls_docsrc TO lt_docsrc.
      ENDIF.

      INSERT CORRESPONDING #( ls_result ) INTO TABLE result.
      INSERT CORRESPONDING #( ls_mapped_header ) INTO TABLE mapped-cseinvoiceentry.

      CLEAR: ls_docsrc, ls_status, ls_json, ls_return.

    ENDLOOP.

    MOVE-CORRESPONDING lt_rap_einv_header TO gt_einv_header.
    MOVE-CORRESPONDING lt_docsrc TO gt_einv_docsrc.
  ENDMETHOD.


  METHOD save_einvoices.

    SORT gt_einv_header BY companycode accountingdocument fiscalyear ASCENDING.
    SORT gt_einv_docsrc BY companycode accountingdocument fiscalyear ASCENDING.

    LOOP AT gt_einv_header INTO DATA(ls_einv_header).
      READ TABLE gt_einv_docsrc TRANSPORTING NO FIELDS WITH KEY companycode = ls_einv_header-companycode
                                                                accountingdocument = ls_einv_header-accountingdocument
                                                                fiscalyear = ls_einv_header-fiscalyear BINARY SEARCH.
      IF sy-subrc EQ 0.
        CONTINUE.
      ENDIF.

      SELECT COUNT(*) FROM zrap_einv_entry
      WHERE companycode = @ls_einv_header-companycode
        AND accountingdocument = @ls_einv_header-accountingdocument
        AND fiscalyear = @ls_einv_header-fiscalyear
        INTO @DATA(lv_count).
      IF sy-subrc NE 0.
        CLEAR: lv_count.
      ENDIF.
      IF lv_count = 0.
        MODIFY zrap_einv_entry FROM @ls_einv_header.
      ELSE.
        UPDATE zrap_einv_entry SET bname      = @ls_einv_header-bname ,
                                    baddr      = @ls_einv_header-baddr ,
                                    bmail      = @ls_einv_header-bmail ,
                                    btax       = @ls_einv_header-btax ,
                                    btel       = @ls_einv_header-btel ,
                                    bacct      = @ls_einv_header-bacct ,
                                    usertype   = @ls_einv_header-usertype ,
                                    belnrsrc   = @ls_einv_header-belnrsrc ,
                                    gjahrsrc   = @ls_einv_header-gjahrsrc ,
                                    adjtype    = @ls_einv_header-adjtype ,
                                    paym       = @ls_einv_header-paym ,
                                    seq        = @ls_einv_header-Seq ,
                                    serial     = @ls_einv_header-Serial ,
                                    form       = @ls_einv_header-Form ,
                                    etype      = @ls_einv_header-etype ,
                                    mscqt      = @ls_einv_header-Mscqt ,
                                    link       = @ls_einv_header-link ,
                                    dateint    = @ls_einv_header-dateint ,
                                    dateiss    = @ls_einv_header-dateiss ,
                                    timeiss    = @ls_einv_header-Timeiss ,
                                    datecanc   = @ls_einv_header-Datecanc ,
                                    statussap  = @ls_einv_header-StatusSap ,
                                    statusinv  = @ls_einv_header-StatusInv ,
                                    statuscqt  = @ls_einv_header-StatusCqt ,
                                    msgty      = @ls_einv_header-MsgTy ,
                                    msgtx      = @ls_einv_header-MsgTx,
                                    invdat     = @ls_einv_header-invdat ,
                                    stblg      = @ls_einv_header-stblg,
                                    stjah      = @ls_einv_header-stjah,
                                    xreversed  = @ls_einv_header-xreversed,
                                    xreversing = @ls_einv_header-xreversing
      WHERE companycode = @ls_einv_header-Companycode
        AND accountingdocument = @ls_einv_header-Accountingdocument
        AND fiscalyear = @ls_einv_header-Fiscalyear.
      ENDIF.

    ENDLOOP.

    LOOP AT gt_einv_docsrc INTO DATA(ls_einv_docsrc).
      UPDATE zrap_einv_entry SET iconsap = @ls_einv_docsrc-Iconsap ,
                                  statussap = @ls_einv_docsrc-StatusSap ,
                                  msgtx = @ls_einv_docsrc-MsgTx
      WHERE companycode = @ls_einv_docsrc-Companycode
        AND accountingdocument = @ls_einv_docsrc-Accountingdocument
        AND fiscalyear = @ls_einv_docsrc-Fiscalyear.
    ENDLOOP.

    IF gt_header_del IS NOT INITIAL.
      MODIFY zrap_inv_delete FROM TABLE @gt_header_del.
    ENDIF.

  ENDMETHOD.


  METHOD searcheinv.
    DATA:
      lv_action   TYPE zde_eaction,
      ls_einvoice TYPE zrap_einv_entry,
      ls_userpass TYPE zrap_inv_user,
      lv_testrun  TYPE flag,
      ls_status   TYPE zrap_einv_entry,
      ls_json     TYPE string,
      ls_return   TYPE bapiret2.

    DATA: ls_docsrc TYPE zrap_einv_entry,
          lt_docsrc TYPE TABLE OF zrap_einv_entry.

    DATA: ls_result LIKE LINE OF result.
    DATA: ls_param TYPE zr_search_einv.

*    LOOP AT keys INTO DATA(ls_key).
*      ls_param-usertype = ls_key-%param-usertype.
*    ENDLOOP.

    zcl_rap_cseinv_entry_api=>get_instance( )->get_document(
    EXPORTING
    keys = keys
    IMPORTING
    e_header = DATA(lt_rap_einv_header)
    ).
    LOOP AT lt_rap_einv_header ASSIGNING FIELD-SYMBOL(<lfs_rap_einv_header>).
*      IF <lfs_rap_einv_header>-statussap = '01' OR <lfs_rap_einv_header>-statussap = '03'
*      OR <lfs_rap_einv_header>-statussap = ''.
*      <lfs_rap_einv_header>-usertype = ls_param-usertype.
*      ENDIF.
      IF <lfs_rap_einv_header>-usertype IS NOT INITIAL.

        CASE <lfs_rap_einv_header>-usertype.
          WHEN '1'.
            <lfs_rap_einv_header>-usertypetext = 'TP Hà Nội'.
          WHEN '2'.
            <lfs_rap_einv_header>-usertypetext = 'TP Hồ Chí Minh'.
          WHEN OTHERS.
        ENDCASE.

        SELECT SINGLE * FROM zrap_inv_user WHERE companycode = @<lfs_rap_einv_header>-companycode
                                                               AND usertype = @<lfs_rap_einv_header>-usertype
        INTO @ls_userpass.

        MOVE-CORRESPONDING <lfs_rap_einv_header> TO ls_einvoice.

        lv_action = 'search-invoice'.
        zcl_manage_fpt_einvoices_2=>get_instance( )->search_einvoices(
            EXPORTING
            i_action      = lv_action
            i_einvoice    = ls_einvoice
            i_userpass    = ls_userpass
            i_testrun     = lv_testrun
            IMPORTING
            e_return      = ls_return
            e_status      = ls_status
            e_docsrc      = ls_docsrc
        ).

        SELECT SINGLE * FROM zrap_einv_entry
        WHERE Companycode = @<lfs_rap_einv_header>-Companycode
          AND BelnrSrc = @<lfs_rap_einv_header>-Accountingdocument
          AND GjahrSrc = @<lfs_rap_einv_header>-Fiscalyear
          AND seq NE ''
        INTO @DATA(ls_adjust).
        IF sy-subrc EQ 0 AND ls_adjust-Seq IS NOT INITIAL
        AND ( ls_adjust-statussap = '99' OR ls_adjust-statussap = '98' ).
          CASE ls_adjust-adjtype.
            WHEN '3'. "Thay thế
              <lfs_rap_einv_header>-Iconsap = '@20@'.
              <lfs_rap_einv_header>-StatusSap = '07'.
              <lfs_rap_einv_header>-MsgTx = 'Hóa đơn đã bị thay thế'.
            WHEN '1' OR '2'. "Điều chỉnh tiền
              <lfs_rap_einv_header>-Iconsap = '@4K@'.
              <lfs_rap_einv_header>-StatusSap = '06'.
              <lfs_rap_einv_header>-MsgTx = 'Hóa đơn đã bị điều chỉnh'.
            WHEN OTHERS.
          ENDCASE.
        ELSE.
          zcl_rap_cseinv_entry_api=>get_instance( )->move_log(
              EXPORTING
              i_input = ls_status
              IMPORTING
              o_output = <lfs_rap_einv_header>
          ).
        ENDIF.

        IF ls_docsrc IS NOT INITIAL.
          APPEND ls_docsrc TO lt_docsrc.
        ENDIF.

        SELECT CompanyCode,
               AccountingDocument,
               FiscalYear,
               AccountingDocumentItem
        FROM i_operationalacctgdocitem
        WHERE CompanyCode = @<lfs_rap_einv_header>-companycode
          AND AccountingDocument = @<lfs_rap_einv_header>-accountingdocument
          AND FiscalYear = @<lfs_rap_einv_header>-fiscalyear
          AND Customer = @<lfs_rap_einv_header>-customer
        INTO TABLE @DATA(lt_accountingdocumentitem).
        IF sy-subrc EQ 0.
          APPEND LINES OF lt_accountingdocumentitem TO gt_accountingdocument.
        ENDIF.

      ELSE.
        <lfs_rap_einv_header>-statussap = '01'.
        <lfs_rap_einv_header>-msgty = ''.
        <lfs_rap_einv_header>-msgtx = ''.
      ENDIF.

      ls_result-%tky-companycode = <lfs_rap_einv_header>-companycode.
      ls_result-%tky-accountingdocument = <lfs_rap_einv_header>-accountingdocument.
      ls_result-%tky-fiscalyear = <lfs_rap_einv_header>-fiscalyear.
      MOVE-CORRESPONDING <lfs_rap_einv_header> TO ls_result-%param.
      INSERT CORRESPONDING #( ls_result ) INTO TABLE result.

    ENDLOOP.

    MOVE-CORRESPONDING lt_rap_einv_header TO gt_einv_header.
    MOVE-CORRESPONDING lt_docsrc TO gt_einv_docsrc.
  ENDMETHOD.


  METHOD update_entry.

  ENDMETHOD.
ENDCLASS.
