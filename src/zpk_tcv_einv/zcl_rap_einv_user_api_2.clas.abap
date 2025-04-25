CLASS zcl_rap_einv_user_api_2 DEFINITION
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

           tt_ranges TYPE TABLE OF ty_range_option.

    TYPES: tt_create_h       TYPE TABLE FOR CREATE zi_rap_inv_user\\einvoiceuser,

           tt_entities_cba   TYPE TABLE FOR CREATE zi_rap_inv_user\\einvoiceuser\_einvoiceserial,

           tt_read_h         TYPE TABLE FOR READ IMPORT zi_rap_inv_user\\einvoiceuser,
           tt_result_readh   TYPE TABLE FOR READ RESULT zi_rap_inv_user\\einvoiceuser,

           tt_read_i         TYPE TABLE FOR READ IMPORT zi_rap_inv_user\\einvoiceserial,
           tt_result_readi   TYPE TABLE FOR READ RESULT zi_rap_inv_user\\einvoiceserial,

           tt_delete_h       TYPE TABLE FOR DELETE zi_rap_inv_user\\einvoiceuser,

           tt_delete_i       TYPE TABLE FOR DELETE zi_rap_inv_user\\einvoiceserial,

           tt_update_h       TYPE TABLE FOR UPDATE zi_rap_inv_user\\einvoiceuser,

           tt_update_i       TYPE TABLE FOR UPDATE zi_rap_inv_user\\einvoiceserial,

           tt_mapped_early   TYPE RESPONSE FOR MAPPED EARLY zi_rap_inv_user,
           tt_failed_early   TYPE RESPONSE FOR FAILED EARLY zi_rap_inv_user,
           tt_response_early TYPE RESPONSE FOR REPORTED EARLY zi_rap_inv_user,
           tt_reported_late  TYPE RESPONSE FOR REPORTED LATE zi_rap_inv_user.

    CLASS-METHODS:
      "Class Contructor
      get_Instance RETURNING VALUE(ro_instance) TYPE REF TO zcl_rap_einv_user_api_2,

      create_user
        IMPORTING entities TYPE tt_create_h "table for create zi_rap_inv_user\\einvoiceuser
        CHANGING  mapped   TYPE tt_mapped_early "response for mapped early zi_rap_inv_user
                  failed   TYPE tt_failed_early "response for failed early zi_rap_inv_user
                  reported TYPE tt_response_early, "response for reported early zi_rap_inv_user

      cba_einvoiceserial
        IMPORTING entities_cba TYPE tt_entities_cba "table for CREATE zi_rap_inv_user\\einvoiceuser\_einvoiceserial
        CHANGING  mapped       TYPE tt_mapped_early "response for mapped early zi_rap_inv_user
                  failed       TYPE tt_failed_early "response for failed early zi_rap_inv_user
                  reported     TYPE tt_response_early, "response for reported early zi_rap_inv_user
      read_user
        IMPORTING keys     TYPE tt_read_h "table for READ IMPORT zi_rap_inv_user\\einvoiceuser
        CHANGING  result   TYPE tt_result_readh "table for read result zi_rap_inv_user\\einvoiceuser
                  failed   TYPE tt_failed_early  "response for failed early zi_rap_inv_user
                  reported TYPE tt_response_early, "response for reported early zi_rap_inv_user

      read_serial
        IMPORTING keys     TYPE tt_read_i "table for read import zi_rap_inv_user\\einvoiceserial
        CHANGING  result   TYPE tt_result_readi "table for read result zi_rap_inv_user\\einvoiceserial
                  failed   TYPE tt_failed_early "response for failed early zi_rap_inv_user
                  reported TYPE tt_response_early, "response for reported early zi_rap_inv_user

      delete_user
        IMPORTING keys     TYPE tt_delete_h "table for delete zi_rap_inv_user\\einvoiceuser
        CHANGING  mapped   TYPE tt_mapped_early "response for mapped early zi_rap_inv_user
                  failed   TYPE tt_failed_early "response for failed early zi_rap_inv_user
                  reported TYPE tt_response_early, "response for reported early zi_rap_inv_user

      delete_serial
        IMPORTING keys     TYPE tt_delete_i "table for delete zi_rap_inv_user\\einvoiceserial
        CHANGING  mapped   TYPE tt_mapped_early "response for mapped early zi_rap_inv_user
                  failed   TYPE tt_failed_early "response for failed early zi_rap_inv_user
                  reported TYPE tt_response_early, "response for reported early zi_rap_inv_user

      update_user
        IMPORTING entities TYPE tt_update_h "table for update zi_rap_inv_user\\einvoiceuser
        CHANGING  mapped   TYPE tt_mapped_early "response for mapped early zi_rap_inv_user
                  failed   TYPE tt_failed_early "response for failed early zi_rap_inv_user
                  reported TYPE tt_response_early, "response for reported early zi_rap_inv_user

      update_serial
        IMPORTING entities TYPE tt_update_i "table for UPDATE zi_rap_inv_user\\einvoiceserial
        CHANGING  mapped   TYPE tt_mapped_early "response for mapped early zi_rap_inv_user
                  failed   TYPE tt_failed_early "response for failed early zi_rap_inv_user
                  reported TYPE tt_response_early, "response for reported early zi_rap_inv_user

      save
        CHANGING reported TYPE tt_reported_late, "response for reported late zi_rap_inv_user

      cleanup,

      cleanup_finalize.

  PROTECTED SECTION.
  PRIVATE SECTION.
    CLASS-DATA: mo_instance    TYPE REF TO zcl_rap_einv_user_api_2,

                gt_einv_user   TYPE TABLE OF zrap_inv_user,
                gt_einv_serial TYPE TABLE OF zrap_inv_serial,

                gt_del_user    TYPE TABLE OF zrap_inv_user,
                gt_del_serial  TYPE TABLE OF zrap_inv_serial.
ENDCLASS.



CLASS ZCL_RAP_EINV_USER_API_2 IMPLEMENTATION.


  METHOD cba_einvoiceserial.
    DATA: ls_einv_serial TYPE zrap_inv_serial.
    LOOP AT entities_cba INTO DATA(ls_entites_cba).
      LOOP AT ls_entites_cba-%target INTO DATA(ls_target).
        MOVE-CORRESPONDING ls_target TO ls_einv_serial.
        APPEND ls_einv_serial TO gt_einv_serial.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.


  METHOD cleanup.
    FREE: gt_einv_user, gt_einv_serial,
          gt_del_user, gt_del_serial.
  ENDMETHOD.


  METHOD cleanup_finalize.
    zcl_rap_einv_user_api_2=>get_instance( )->cleanup( ).
  ENDMETHOD.


  METHOD create_user.
    DATA: lv_count TYPE int4.
    CLEAR: lv_count.
    gt_einv_user = CORRESPONDING #( entities MAPPING FROM ENTITY ).
    LOOP AT gt_einv_user ASSIGNING FIELD-SYMBOL(<fs_einv_user>).

    ENDLOOP.
  ENDMETHOD.


  METHOD delete_serial.
    DATA: lr_bukrs    TYPE tt_ranges,
          lr_usertype TYPE tt_ranges,
          lr_gjahr    TYPE tt_ranges,
          lr_etype    TYPE tt_ranges.
    LOOP AT keys INTO DATA(ls_keys).
      APPEND VALUE #( sign = 'I' option = 'EQ' low = ls_keys-%tky-Companycode ) TO lr_bukrs.
      APPEND VALUE #( sign = 'I' option = 'EQ' low = ls_keys-%tky-Usertype ) TO lr_usertype.
      APPEND VALUE #( sign = 'I' option = 'EQ' low = ls_keys-%tky-Fiscalyear ) TO lr_gjahr.
      APPEND VALUE #( sign = 'I' option = 'EQ' low = ls_keys-%tky-Etype ) TO lr_etype.
    ENDLOOP.

    SELECT * FROM zrap_inv_serial
    WHERE companycode IN @lr_bukrs
    AND usertype IN @lr_usertype
    AND fiscalyear IN @lr_gjahr
    AND etype IN @lr_etype
    INTO TABLE @gt_del_serial.
  ENDMETHOD.


  METHOD delete_user.
    DATA: lr_bukrs    TYPE tt_ranges,
          lr_usertype TYPE tt_ranges.
    LOOP AT keys INTO DATA(ls_keys).
      APPEND VALUE #( sign = 'I' option = 'EQ' low = ls_keys-%tky-Companycode ) TO lr_bukrs.
      APPEND VALUE #( sign = 'I' option = 'EQ' low = ls_keys-%tky-Usertype ) TO lr_usertype.
    ENDLOOP.

    SELECT * FROM zrap_inv_user
    WHERE companycode IN @lr_bukrs
    AND usertype IN @lr_usertype
    INTO TABLE @gt_del_user.

    SELECT * FROM zrap_inv_serial
    WHERE companycode IN @lr_bukrs
    AND usertype IN @lr_usertype
    INTO TABLE @gt_del_serial.

  ENDMETHOD.


  METHOD get_instance.
    mo_instance = ro_instance = COND #( WHEN mo_instance IS BOUND
                                           THEN mo_instance
                                           ELSE NEW #( ) ).
  ENDMETHOD.


  METHOD read_serial.
    DATA: lr_bukrs    TYPE tt_ranges,
          lr_usertype TYPE tt_ranges,
          lr_gjahr    TYPE tt_ranges,
          lr_etype    TYPE tt_ranges.
    LOOP AT keys INTO DATA(ls_keys).
      APPEND VALUE #( sign = 'I' option = 'EQ' low = ls_keys-%tky-Companycode ) TO lr_bukrs.
      APPEND VALUE #( sign = 'I' option = 'EQ' low = ls_keys-%tky-Usertype ) TO lr_usertype.
      APPEND VALUE #( sign = 'I' option = 'EQ' low = ls_keys-%tky-Fiscalyear ) TO lr_gjahr.
      APPEND VALUE #( sign = 'I' option = 'EQ' low = ls_keys-%tky-Etype ) TO lr_etype.
    ENDLOOP.

    SELECT * FROM zrap_inv_serial
    WHERE companycode IN @lr_bukrs
    AND usertype IN @lr_usertype
    AND fiscalyear IN @lr_gjahr
    AND etype IN @lr_etype
    INTO TABLE @DATA(lt_einv_serial).

    DATA: ls_result LIKE LINE OF result.
    LOOP AT lt_einv_serial INTO DATA(ls_einv_serial).
      ls_result-%tky-Companycode = ls_einv_serial-companycode.
      ls_result-%tky-Usertype    = ls_einv_serial-usertype.
      ls_result-%tky-Fiscalyear  = ls_einv_serial-fiscalyear.
      ls_result-%tky-Etype       = ls_einv_serial-etype.
      MOVE-CORRESPONDING ls_einv_serial TO ls_result-%data.
      INSERT CORRESPONDING #( ls_result ) INTO TABLE result.
    ENDLOOP.

  ENDMETHOD.


  METHOD read_user.
    DATA: lr_bukrs    TYPE tt_ranges,
          lr_usertype TYPE tt_ranges.
    LOOP AT keys INTO DATA(ls_keys).
      APPEND VALUE #( sign = 'I' option = 'EQ' low = ls_keys-%tky-Companycode ) TO lr_bukrs.
      APPEND VALUE #( sign = 'I' option = 'EQ' low = ls_keys-%tky-Usertype ) TO lr_usertype.
    ENDLOOP.

    SELECT * FROM zrap_inv_user
    WHERE companycode IN @lr_bukrs
    AND usertype IN @lr_usertype
    INTO TABLE @DATA(lt_einv_user).

    DATA: ls_result LIKE LINE OF result.
    LOOP AT lt_einv_user INTO DATA(ls_einv_user).
      ls_result-%tky-Companycode = ls_einv_user-companycode.
      ls_result-%tky-Usertype    = ls_einv_user-usertype.
      MOVE-CORRESPONDING ls_einv_user TO ls_result-%data.
      INSERT CORRESPONDING #( ls_result ) INTO TABLE result.
    ENDLOOP.

  ENDMETHOD.


  METHOD save.
    DATA: lv_count TYPE int4,
          lv_flag  TYPE char1.

    DATA: ls_einvoiceuser LIKE LINE OF reported-einvoiceuser.

    CLEAR: lv_count, lv_flag.

    IF  gt_einv_user IS NOT INITIAL.
      LOOP AT gt_einv_user ASSIGNING FIELD-SYMBOL(<fs_einv_user>).
        APPEND VALUE #( companycode = <fs_einv_user>-companycode usertype = <fs_einv_user>-usertype ) TO reported-einvoiceuser.
        <fs_einv_user>-password = <fs_einv_user>-maskpassword.
        lv_count = strlen( <fs_einv_user>-password ).
        <fs_einv_user>-maskpassword = ''.
        DO lv_count TIMES.
          IF <fs_einv_user>-maskpassword IS INITIAL.
            <fs_einv_user>-maskpassword = |*|.
          ELSE.
            <fs_einv_user>-maskpassword = <fs_einv_user>-maskpassword && |*|.
          ENDIF.
        ENDDO.

*        AUTHORITY-CHECK OBJECT 'ZOBJUSERTY'
*        ID 'ACTVT' FIELD '03'
*        ID 'ZUSERTYPE2' FIELD <fs_einv_user>-Usertype.
*        IF sy-subrc NE 0.
*          lv_flag = 'X'.
*          ls_einvoiceuser-%msg        = new_message_with_text( severity = if_abap_behv_message=>severity-error
*                                                    text     = |You aren't authority for CoCd { <einvoiceuser>-Companycode } - Region { <einvoiceuser>-Usertype }| ).
*          ls_einvoiceuser-%create = abap_false.
*          ls_einvoiceuser-%update = abap_false.
*          ls_einvoiceuser-%delete = abap_false.
*          ls_einvoiceuser-%action-edit = abap_false.
*          ls_einvoiceuser-%action-activate = abap_false.
*          ls_einvoiceuser-%action-discard = abap_false.
*          ls_einvoiceuser-%action-resume = abap_false.
*          ls_einvoiceuser-%action-prepare = abap_false.
*        ENDIF.

      ENDLOOP.

      IF lv_flag IS INITIAL.
        MODIFY zrap_inv_user FROM TABLE @gt_einv_user.
      ENDIF.

    ENDIF.

    IF  gt_einv_serial IS NOT INITIAL AND lv_flag IS INITIAL..
        MODIFY zrap_inv_serial FROM TABLE @gt_einv_serial.
    ENDIF.

    IF  gt_del_user IS NOT INITIAL.
      DELETE zrap_inv_user FROM TABLE @gt_del_user.
    ENDIF.

    IF  gt_del_serial IS NOT INITIAL.
      DELETE zrap_inv_serial FROM TABLE @gt_del_serial.
    ENDIF.

*    DELETE FROM zrap_inv_user_d .
*    DELETE FROM zrap_inv_seri_d .

  ENDMETHOD.


  METHOD update_serial.
    gt_einv_serial = CORRESPONDING #( entities MAPPING FROM ENTITY ).
  ENDMETHOD.


  METHOD update_user.
    gt_einv_user = CORRESPONDING #( entities MAPPING FROM ENTITY ).
  ENDMETHOD.
ENDCLASS.
