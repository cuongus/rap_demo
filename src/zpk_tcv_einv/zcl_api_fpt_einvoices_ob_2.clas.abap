CLASS zcl_api_fpt_einvoices_ob_2 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    CLASS-METHODS:
      "Class Contructor
      get_Instance RETURNING VALUE(ro_instance) TYPE REF TO zcl_api_fpt_einvoices_ob_2,

      post_einvoices IMPORTING i_username TYPE zde_username2
                               i_password TYPE zde_password2
                               i_context  TYPE string
                               i_prefix   TYPE zde_text255_2
                     EXPORTING e_context  TYPE string
                               e_return   TYPE bapiret2
                     ,

      get_einvoices IMPORTING i_context TYPE zst_fpt_info_2
                              i_url     TYPE zde_text255_2
                    EXPORTING e_context TYPE string
                              e_return  TYPE bapiret2.
  PROTECTED SECTION.
  PRIVATE SECTION.
    CLASS-DATA: mo_instance TYPE REF TO zcl_api_fpt_einvoices_ob_2.
ENDCLASS.



CLASS ZCL_API_FPT_EINVOICES_OB_2 IMPLEMENTATION.


  METHOD get_einvoices.
    DATA: i_prefix TYPE string.
    i_prefix = |?stax={ i_context-stax }&sid={ i_context-sid }&type=json|.
*-- Create HTTP client ->
    TRY.
        DATA(lo_destination) = cl_http_destination_provider=>create_by_comm_arrangement(
                                 comm_scenario  = |Z_API_FPT_EINVOICE_CSCEN|
                                 service_id     = |Z_API_FPT_EINVOICE_OB_REST|
                               ).

        DATA(lo_http_client) = cl_web_http_client_manager=>create_by_http_destination( i_destination = lo_destination ).
*-- Add path ->
*        lo_http_client->get_http_request( )->set_uri_path( |{ i_prefix }| ).
        lo_http_client->get_http_request( )->set_header_field( i_name = |~request_uri| i_value = |{ i_url }{ i_prefix }| ).
*-- SET HTTP Header Fields
        lo_http_client->get_http_request( )->set_header_field( i_name = |Content-Type| i_value = |application/json| ).

        lo_http_client->get_http_request( )->set_header_field( i_name = |Accept| i_value = |*/*| ).

        DATA: lv_username TYPE string,
              lv_password TYPE string.

        lv_username = i_context-username.
        lv_password = i_context-password.
*-- Passing the Accept value in header which is a mandatory field
        lo_http_client->get_http_request( )->set_header_field( i_name = |username| i_value = lv_username ).
        lo_http_client->get_http_request( )->set_header_field( i_name = |password| i_value = lv_password ).
*-- Authorization
        lo_http_client->get_http_request( )->set_authorization_basic( i_username = lv_username i_password = lv_password ).
*-- GET
        lo_http_client->execute( i_method = if_web_http_client=>get
                                 i_timeout = 60 ).

        lo_http_client->get_http_request( )->set_content_type( |application/json| ).

*-- Response ->
        DATA(lo_response) = lo_http_client->execute( i_method = if_web_http_client=>get
                                                     i_timeout = 60 ).
*-- Get the status of the response ->
        e_context = lo_response->get_text( ).
        IF lo_response->get_status( )-code NE 200.
          e_return-type = 'E'.
          e_return-message = lo_response->get_status( )-code && ` ` && lo_response->get_status( )-reason
          && ` - ` && e_context.
        ENDIF.
        IF e_context = 'Không tìm thấy hóa đơn. Vui lòng kiểm tra điều kiện tìm kiếm'.
          e_return-type = 'E'.
          e_return-message = 'Không tìm thấy hóa đơn. Vui lòng kiểm tra điều kiện tìm kiếm'.
        endif.
        CATCH cx_root INTO DATA(lx_exception).

      ENDTRY.
    ENDMETHOD.


    METHOD get_instance.
      mo_instance = ro_instance = COND #( WHEN mo_instance IS BOUND
                                                 THEN mo_instance
                                                 ELSE NEW #( ) ).
    ENDMETHOD.


    METHOD post_einvoices.
      IF i_context IS INITIAL. RETURN. ENDIF.
*-- Create HTTP client ->
      TRY.
          DATA(lo_destination) = cl_http_destination_provider=>create_by_comm_arrangement(
                                   comm_scenario  = |Z_API_FPT_EINVOICE_CSCEN|
                                   service_id     = |Z_API_FPT_EINVOICE_OB_REST|
                                 ).

          DATA(lo_http_client) = cl_web_http_client_manager=>create_by_http_destination( i_destination = lo_destination ).
*-- Add path ->
*        lo_http_client->get_http_request( )->set_uri_path( |{ i_prefix }| ).
          lo_http_client->get_http_request( )->set_header_field( i_name = |~request_uri| i_value = |{ i_prefix }| ).
*-- SET HTTP Header Fields
          lo_http_client->get_http_request( )->set_header_field( i_name = |Content-Type| i_value = |application/json| ).

          lo_http_client->get_http_request( )->set_header_field( i_name = |Accept| i_value = |*/*| ).

          DATA: lv_username TYPE string,
                lv_password TYPE string.

          lv_username = i_username.
          lv_password = i_password.
*-- Passing the Accept value in header which is a mandatory field
          lo_http_client->get_http_request( )->set_header_field( i_name = |username| i_value = lv_username ).
          lo_http_client->get_http_request( )->set_header_field( i_name = |password| i_value = lv_password ).
*-- Authorization
          lo_http_client->get_http_request( )->set_authorization_basic( i_username = lv_username i_password = lv_password ).

          lo_http_client->get_http_request( )->set_content_type( |application/json| ).
*-- POST
          lo_http_client->execute( i_method = if_web_http_client=>post
                                   i_timeout = 60 ).
*-- Send request ->
          lo_http_client->get_http_request( )->set_text( i_context ).
*-- Response ->
          DATA(lo_response) = lo_http_client->execute( i_method = if_web_http_client=>post
                                                       i_timeout = 60 ).
*-- Get the status of the response ->
          e_context = lo_response->get_text( ).
          IF lo_response->get_status( )-code NE 200.
            e_return-type = 'E'.
            e_return-message = lo_response->get_status( )-code && ` ` && lo_response->get_status( )-reason
            && ` - ` && e_context.
          ENDIF.
        CATCH cx_root INTO DATA(lx_exception).

      ENDTRY.
    ENDMETHOD.
ENDCLASS.
