CLASS zcl_conf_api_key DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    TYPES:
      "Views Integration E-Invoices
      tt__create TYPE TABLE OF ztb_tcv_api_key.
    CLASS-METHODS:
      save_data,
      cleanup,
      fill_data
        IMPORTING
          lt_data TYPE tt__create.
  PROTECTED SECTION.
  PRIVATE SECTION.
    CLASS-DATA:
      gt_data    TYPE tt__create.
ENDCLASS.



CLASS ZCL_CONF_API_KEY IMPLEMENTATION.


  METHOD cleanup.
    FREE gt_data.
  ENDMETHOD.


  METHOD fill_data.
    gt_data = lt_data.
  ENDMETHOD.


  METHOD save_data.
    MODIFY ztb_tcv_api_key FROM TABLE @gt_data.
*    DELETE FROM ztb_tcv_api_key.
  ENDMETHOD.
ENDCLASS.
