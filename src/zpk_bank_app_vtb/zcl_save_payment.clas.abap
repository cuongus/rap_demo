CLASS zcl_save_payment DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    TYPES:
      "Views Integration E-Invoices
      tt__create   TYPE TABLE OF ztb_fis_pm_100,
      tt_log       TYPE TABLE OF ztb_fis_log_api,
      tt_log_token TYPE TABLE OF ztb_log_tcvbank.

    CLASS-METHODS:
      save_data,
      cleanup,
      fill_data
        IMPORTING
          lt_data TYPE tt__create OPTIONAL,

      fill_api_log
        IMPORTING
          lt_data      TYPE tt_log OPTIONAL
          lt_log_token TYPE tt_log_token OPTIONAL.

  PROTECTED SECTION.
  PRIVATE SECTION.
    CLASS-DATA:
      gt_data      TYPE tt__create,
      gt_api_log   TYPE tt_log,
      gt_log_token TYPE tt_log_token.

ENDCLASS.



CLASS ZCL_SAVE_PAYMENT IMPLEMENTATION.


  METHOD cleanup.
    FREE gt_data.
  ENDMETHOD.


  METHOD fill_api_log.
    IF lt_data IS NOT INITIAL.
      gt_api_log = lt_data.
    ENDIF.

    IF lt_log_token IS NOT INITIAL.
      gt_log_token = lt_log_token.
    ENDIF.

  ENDMETHOD.


  METHOD fill_data.
    gt_data = lt_data.
  ENDMETHOD.


  METHOD save_data.
    LOOP AT gt_data INTO DATA(ls_data).
      IF ls_data-created_at IS INITIAL.
        ls_data-created_at = cl_abap_context_info=>get_system_date( ).
      ENDIF.
      IF ls_data-created_by IS INITIAL.
        ls_data-created_by = sy-uname.
      ENDIF.
      IF ls_data-last_changed_at IS NOT INITIAL.
        ls_data-last_changed_at = cl_abap_context_info=>get_system_date( ).
      ENDIF.
      IF ls_data-local_last_changed_at IS NOT INITIAL.
        ls_data-last_changed_at = cl_abap_context_info=>get_system_date( ).
      ENDIF.
      IF ls_data-local_last_changed_by IS NOT INITIAL.
        ls_data-local_last_changed_by = sy-uname.
      ENDIF.
      MODIFY gt_data FROM ls_data.
    ENDLOOP.
    IF gt_data IS NOT INITIAL.
      MODIFY ztb_fis_pm_100 FROM TABLE @gt_data.
    ENDIF.


    IF gt_api_log IS NOT INITIAL.
      MODIFY ztb_fis_log_api FROM TABLE @gt_api_log.
    ENDIF.

    IF gt_log_token IS NOT INITIAL.
      MODIFY ztb_log_tcvbank FROM TABLE @gt_log_token.
    ENDIF.

  ENDMETHOD.
ENDCLASS.
