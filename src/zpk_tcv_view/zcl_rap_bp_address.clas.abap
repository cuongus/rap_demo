CLASS zcl_rap_bp_address DEFINITION
  PUBLIC
  INHERITING FROM cx_rap_query_provider
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_range_option,
             sign   TYPE c LENGTH 1,
             option TYPE c LENGTH 2,
             low    TYPE string,
             high   TYPE string,
           END OF ty_range_option,

           tt_ranges     TYPE TABLE OF ty_range_option,
           tt_bp_address TYPE TABLE OF zrap_bp_address.

    "Custom Entities
    INTERFACES if_rap_query_provider.

    CLASS-METHODS:
      "Class Contructor
      get_Instance RETURNING VALUE(ro_instance) TYPE REF TO zcl_rap_bp_address,

      get_bp_address IMPORTING ir_partner    TYPE tt_ranges OPTIONAL
                               ir_country    TYPE tt_ranges OPTIONAL
                     EXPORTING et_bp_address TYPE tt_bp_address.

  PROTECTED SECTION.
  PRIVATE SECTION.
    CLASS-DATA: mo_instance TYPE REF TO zcl_rap_bp_address.

ENDCLASS.



CLASS ZCL_RAP_BP_ADDRESS IMPLEMENTATION.


  METHOD get_bp_address.
    DATA: lv_url     TYPE string,
          lv_parter  TYPE string,
          lv_country TYPE string,
          lv_filter  TYPE string. "&$filter

    CLEAR: lv_parter, lv_country, lv_filter.

    IF ir_partner[] IS NOT INITIAL.
      LOOP AT ir_partner INTO DATA(lr_range).
        IF lv_parter IS INITIAL.
          lv_parter = |BusinessPartner eq '{ lr_range-low }'|.
        ELSE.
          lv_parter = |{ lv_parter } or BusinessPartner eq '{ lr_range-low }'|.
        ENDIF.
      ENDLOOP.
    ENDIF.

    IF ir_country[] IS NOT INITIAL.
      LOOP AT ir_country INTO lr_range.
        IF lv_country IS INITIAL.
          lv_country = |Country eq '{ lr_range-low }'|.
        ELSE.
          lv_country = |{ lv_country } or Country eq '{ lr_range-low }'|.
        ENDIF.
      ENDLOOP.
    ENDIF.

    IF lv_parter IS NOT INITIAL AND lv_country IS NOT INITIAL.
      lv_filter = |( { lv_parter } ) and ( { lv_country } )|.
    ELSE.
      IF lv_parter IS NOT INITIAL.
        lv_filter = lv_parter.
      ELSEIF lv_country IS NOT INITIAL.
        lv_filter = lv_country.
      ENDIF.
    ENDIF.

    IF lv_filter IS NOT INITIAL.
*      lv_filter = |?&$filter={ lv_filter }|.
    ENDIF.

    TRY.
        DATA(lv_host) = cl_abap_context_info=>get_system_url( ).
      CATCH cx_abap_context_info_error.
        "handle exception
    ENDTRY.
    lv_url =  |https://{ lv_host }/sap/opu/odata/sap/API_BUSINESS_PARTNER/A_BPIntlAddressVersion?$inlinecount=allpages|.
    TRY.
        "create http destination by url; API endpoint for API sandbox
        DATA(lo_http_destination) =
             cl_http_destination_provider=>create_by_url( lv_url ).
        "alternatively create HTTP destination via destination service
        "cl_http_destination_provider=>create_by_cloud_destination( i_name = '<...>'
        "                            i_service_instance_name = '<...>' )
        "SAP Help: https://help.sap.com/viewer/65de2977205c403bbc107264b8eccf4b/Cloud/en-US/f871712b816943b0ab5e04b60799e518.html

        "create HTTP client by destination
        DATA(lo_web_http_client) = cl_web_http_client_manager=>create_by_http_destination( lo_http_destination ) .

        "adding headers
        DATA(lo_web_http_request) = lo_web_http_client->get_http_request( ).

        lo_web_http_request->set_header_fields( VALUE #(
        (  name = 'config_authType' value = 'Basic' )
        (  name = 'config_packageName' value = 'SAPS4HANACloud' )
        (  name = 'config_actualUrl' value = |{ lv_host }/sap/opu/odata/sap/API_BUSINESS_PARTNER| )
        (  name = 'config_urlPattern' value = 'https://{host}:{port}/sap/opu/odata/sap/API_BUSINESS_PARTNER' )
        (  name = 'config_apiName' value = 'API_BUSINESS_PARTNER' )
        (  name = 'DataServiceVersion' value = '2.0' )
        (  name = 'Accept' value = 'application/json' )
         ) ).

        "filter
        lo_web_http_request->set_form_field(  i_name = '$filter' i_value = lv_filter ).

        "Authorization
        lo_web_http_request->set_header_field(  i_name = 'username' i_value = 'INBOUND_COMM_USER_BTP_EXTENSION' ).
        lo_web_http_request->set_header_field(  i_name = 'password' i_value = 'Abcd@1234567890Efghijk' ).
        lo_web_http_request->set_authorization_basic( i_username = 'INBOUND_COMM_USER_BTP_EXTENSION' i_password = 'Abcd@1234567890Efghijk' ).
        lo_web_http_request->set_content_type( |application/json| ).

        "set request method and execute request
        DATA(lo_web_http_response) = lo_web_http_client->execute( if_web_http_client=>get ).
        DATA(lv_response) = lo_web_http_response->get_text( ).

        REPLACE ALL OCCURRENCES OF '__metadata' IN lv_response WITH 'metadata'.
        REPLACE ALL OCCURRENCES OF '__count' IN lv_response WITH 'count'.
        REPLACE ALL OCCURRENCES OF 'null' IN lv_response WITH `""`.

        "Read json
        DATA: ls_bp_address TYPE zst_response_bp_address.
        xco_cp_json=>data->from_string( lv_response )->write_to( EXPORTING ia_data = REF #( ls_bp_address ) ).

        MOVE-CORRESPONDING ls_bp_address-d-results TO et_bp_address.

      CATCH cx_http_dest_provider_error cx_web_http_client_error cx_web_message_error.
        "error handling
    ENDTRY.

    "uncomment the following line for console output; prerequisite: code snippet is implementation of if_oo_adt_classrun~main
    "out->write( |response:  { lv_response }| ).
  ENDMETHOD.


  METHOD get_instance.
    mo_instance = ro_instance = COND #( WHEN mo_instance IS BOUND
                                           THEN mo_instance
                                           ELSE NEW #( ) ).
  ENDMETHOD.


  METHOD if_rap_query_provider~select.

    DATA: lr_partner TYPE tt_ranges,
          lr_country TYPE tt_ranges.

    DATA: lt_bp_address TYPE TABLE OF zrap_bp_address,
          lt_bp_addr    TYPE TABLE OF zrap_bp_address.

    TRY.
        IF io_request->is_data_requested( ).

          DATA(paging)            = io_request->get_paging( ).
          DATA(page_size)         = io_request->get_paging( )->get_page_size( ).
          DATA(offset)            = io_request->get_paging( )->get_offset( ).
          DATA(requested_fields)  = io_request->get_requested_elements( ).
          DATA(sort_order)        = io_request->get_sort_elements( ).
          DATA(ro_filter)         = io_request->get_filter( ).
          DATA(lv_entity_id)      = io_request->get_entity_id( ).

          FREE: lr_partner, lr_country, lt_bp_addr, lt_bp_address.

          TRY.
              DATA(lr_ranges) = ro_filter->get_as_ranges( ).
            CATCH cx_rap_query_filter_no_range.
              "handle exception
          ENDTRY.

          LOOP AT lr_ranges INTO DATA(ls_ranges).
            CASE ls_ranges-name.
              WHEN 'BUSINESSPARTNER'.
                MOVE-CORRESPONDING ls_ranges-range TO lr_partner.
              WHEN 'COUNTRY'.
                MOVE-CORRESPONDING ls_ranges-range TO lr_country.
              WHEN OTHERS.
            ENDCASE.
          ENDLOOP.

*          LOOP AT lr_usertype INTO DATA(ls_usertype).
*            lv_usertype = ls_usertype-low.
*            AUTHORITY-CHECK OBJECT 'ZOBJREGION'
*              ID 'ACTVT' FIELD '03'
*              ID 'ZUSERTYPE' FIELD lv_usertype.
*            IF sy-subrc NE 0.
*              lv_error_authorization = 'X'.
*              RAISE EXCEPTION TYPE zcl_rap_inv_generate
*              MESSAGE ID 'ZEINV'
*              TYPE 'E'
*              NUMBER '777'
*              WITH |You aren't authority CoCd 6710 - Region { lv_usertype }|.
**              RETURN.
*            ENDIF.
*          ENDLOOP.

          IF page_size < 0.
            page_size = 50.
          ENDIF.

          CASE lv_entity_id.
            WHEN 'ZCS_RAP_BP_ADDRESS'.

              zcl_rap_bp_address=>get_instance( )->get_bp_address(
              EXPORTING
              ir_partner = lr_partner
              ir_country = lr_country
              IMPORTING
              et_bp_address = lt_bp_address
              ).

              DATA(max_rows) = COND #( WHEN page_size = if_rap_query_paging=>page_size_unlimited THEN 0
                     ELSE page_size ).

              max_rows = page_size + offset.


              SORT lt_bp_address BY businesspartner ASCENDING.

              LOOP AT lt_bp_address INTO DATA(ls_bp_address).
                IF sy-tabix > offset.
                  IF sy-tabix > max_rows.
                    EXIT.
                  ELSE.
                    APPEND ls_bp_address TO lt_bp_addr.
                  ENDIF.
                ELSE.
                ENDIF.
              ENDLOOP.

              IF io_request->is_total_numb_of_rec_requested( ).
                io_response->set_total_number_of_records( iv_total_number_of_records = lines( lt_bp_address ) ).
              ENDIF.

              IF io_request->is_data_requested( ).
                io_response->set_data( lt_bp_addr ).
              ENDIF.

            WHEN OTHERS.

          ENDCASE.

        ELSE.
          RETURN.
        ENDIF.

      CATCH cx_root INTO DATA(exception).

        DATA(exception_message) = cl_message_helper=>get_latest_t100_exception( exception )->if_message~get_longtext( ).

        DATA(exception_t100_key) = cl_message_helper=>get_latest_t100_exception( exception )->t100key.

        RAISE EXCEPTION TYPE zcl_rap_inv_generate
          EXPORTING
            textid   = VALUE scx_t100key(
            msgid = exception_t100_key-msgid
            msgno = exception_t100_key-msgno
            attr1 = exception_t100_key-attr1
            attr2 = exception_t100_key-attr2
            attr3 = exception_t100_key-attr3
            attr4 = exception_t100_key-attr4 )
            previous = exception.
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
