CLASS lhc_ZCE_FIS_SEND_PAYMENT_100 DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    DATA: lw_access_token TYPE string.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR zce_fis_send_payment_100 RESULT result.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR zce_fis_send_payment_100 RESULT result.

    METHODS update FOR MODIFY
      IMPORTING entities FOR UPDATE zce_fis_send_payment_100.

    METHODS read FOR READ
      IMPORTING keys FOR READ zce_fis_send_payment_100 RESULT result.

    METHODS lock FOR LOCK
      IMPORTING keys FOR LOCK zce_fis_send_payment_100.

    METHODS edit_text FOR MODIFY
      IMPORTING keys FOR ACTION zce_fis_send_payment_100~edit_text.

    METHODS request_payment FOR MODIFY
      IMPORTING keys FOR ACTION zce_fis_send_payment_100~request_payment.

ENDCLASS.

CLASS lhc_ZCE_FIS_SEND_PAYMENT_100 IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD update.
    TYPES: BEGIN OF ty_range_option,
             sign   TYPE c LENGTH 1,
             option TYPE c LENGTH 2,
             low    TYPE string,
             high   TYPE string,
           END OF ty_range_option.

    DATA: tt_ranges          TYPE TABLE OF ty_range_option.

    DATA: lr_rundate LIKE tt_ranges,
          lr_runid   LIKE tt_ranges,
          lr_comcode LIKE tt_ranges.

    DATA: lw_text TYPE c LENGTH 50.
    DATA: ls_payment TYPE ztb_fis_pm_100.
    LOOP AT entities INTO DATA(ls_entities).

      SELECT SINGLE MAX( id ) FROM ztb_fis_pm_100 INTO @DATA(lw_max_id).
      DATA: lw_id TYPE int4.
      lw_id = lw_max_id.

      DATA: ls_insert TYPE ztb_fis_pm_100.
      DATA: lt_insert TYPE TABLE OF ztb_fis_pm_100.

      SELECT SINGLE * FROM ztb_fis_pm_100
        WHERE payment_run_date = @ls_entities-PaymentRunDate
        AND payment_run_id = @ls_entities-PaymentRunId
        AND paying_company = @ls_entities-PayingCompanyCode
        AND paymentdocument = @ls_entities-paymentdocument
        INTO @DATA(ls_data).

*     Validate
      DATA(lw_check_regex) = 0.
      FIND '-' IN ls_entities-text MATCH COUNT DATA(lw_1).
      FIND '/' IN ls_entities-text MATCH COUNT DATA(lw_2).

      DATA(lv_regex) = '[^a-zA-Z0-9 ,#!&_;.+:"=%]'.

      FIND ALL OCCURRENCES OF PCRE lv_regex IN ls_entities-text
      MATCH COUNT lw_check_regex.
      lw_check_regex = lw_check_regex - lw_1 - lw_2.
      IF lw_check_regex <> 0.
        DATA(item_msg_regex_check) = new_message( id = 'Z_MESSAGE_100'  " id = Name Of message class

                     number = '008' "number of message defined in the message class
                     severity = cl_abap_behv=>ms-error "type of message
                     v1 = '&'  "First Parameter
                     v2 = ls_entities-PaymentRunDate          "Second Parameter
                     ).
        APPEND VALUE #( PaymentRunID = ls_entities-PaymentRunID PaymentRunDate = ls_entities-PaymentRunDate
         " %cid = "Content ID" in ABAP Behavior
       %msg = item_msg_regex_check "%msg  =  type ref to if_abap_behv_message / Message to be passed
       ) TO reported-zce_fis_send_payment_100.
        CONTINUE.
      ENDIF.

      IF ls_data-api_status EQ 'Posted Successfully'.
        DATA(item_msg_api) = new_message( id = 'Z_MESSAGE_100'  " id = Name Of message class

                        number = '007' "number of message defined in the message class
                        severity = cl_abap_behv=>ms-error "type of message
                        v1 = ls_entities-PaymentRunID  "First Parameter
                        v2 = ls_entities-PaymentRunDate          "Second Parameter
                        ).
        APPEND VALUE #( PaymentRunID = ls_entities-PaymentRunID PaymentRunDate = ls_entities-PaymentRunDate
       %msg = item_msg_api
       ) TO reported-zce_fis_send_payment_100.

        CONTINUE.
      ENDIF.

      IF strlen( ls_entities-text ) > 192.
        DATA(item_msg_text_length) = new_message( id = 'Z_MESSAGE_100'  " id = Name Of message class

                        number = '009' "number of message defined in the message class
                        severity = cl_abap_behv=>ms-error "type of message
                        v1 = ls_entities-PaymentRunID  "First Parameter
                        v2 = ls_entities-PaymentRunDate          "Second Parameter
                        ).
        APPEND VALUE #( PaymentRunID = ls_entities-PaymentRunID PaymentRunDate = ls_entities-PaymentRunDate
       %msg = item_msg_text_length
       ) TO reported-zce_fis_send_payment_100.

        CONTINUE.
      ENDIF.
* End validate


      IF ls_data-id IS NOT INITIAL.
        ls_insert-id = ls_data-id.
      ELSE.
        lw_id += 1.
        ls_insert-id = lw_id.
      ENDIF.
      lw_id += 1.
      ls_insert-client = sy-mandt.

      ls_insert-payment_run_id = ls_entities-PaymentRunID.
      ls_insert-payment_run_date = ls_entities-PaymentRunDate.
      ls_insert-paying_company = ls_entities-PayingCompanyCode.
      ls_insert-posting_date = ls_data-posting_date. "
      ls_insert-customer = ls_entities-customer.
      ls_insert-supplier = ls_entities-supplier.
      ls_insert-paymentdocument = ls_entities-paymentdocument.

      ls_insert-status = 'Payment Posted'.
      IF ls_entities-api_status IS INITIAL.
        ls_insert-api_status = ls_data-api_status.
      ELSE.
        ls_insert-api_status = ls_entities-api_status.
      ENDIF.
      IF ls_entities-json_body IS INITIAL.
        ls_insert-json_body = ls_data-json_body.
      ELSE.
        ls_insert-json_body = ls_entities-json_body.
      ENDIF.
      IF ls_entities-message IS INITIAL.
        ls_insert-message = ls_data-message.
      ELSE.
        ls_insert-message = ls_entities-message.
      ENDIF.
      IF ls_entities-text IS INITIAL.
        ls_insert-text = ls_data-text.
      ELSE.
        ls_insert-text = ls_entities-text.
      ENDIF.

      DATA(item_msg) = new_message( id = 'Z_MESSAGE_100'  " id = Name Of message class

                      number = '002' "number of message defined in the message class
                      severity = cl_abap_behv=>ms-success "type of message
                      v1 = ls_insert-payment_run_id  "First Parameter
                      v2 = ls_insert-payment_run_date          "Second Parameter
                      v3 = ls_insert-id           "Third Parameter
                      v4 = ls_insert-paying_company           "Fourth Parameter
                      ).
************************** Apeending the Message Response *********************************************************
      APPEND VALUE #( PayingCompanyCode = ls_payment-paying_company
         " %cid = "Content ID" in ABAP Behavior
       %msg = item_msg "%msg  =  type ref to if_abap_behv_message / Message to be passed
       ) TO reported-zce_fis_send_payment_100.

      APPEND ls_insert TO lt_insert.
    ENDLOOP.
    IF lt_insert IS NOT INITIAL.
      zcl_save_payment=>fill_data( lt_insert ).
    ENDIF.
  ENDMETHOD.

*  METHOD delete.
*  ENDMETHOD.

  METHOD read.
    TYPES: BEGIN OF ty_range_option,
             sign   TYPE c LENGTH 1,
             option TYPE c LENGTH 2,
             low    TYPE string,
             high   TYPE string,
           END OF ty_range_option.

    DATA: tt_ranges          TYPE TABLE OF ty_range_option.

    DATA: lr_rundate  LIKE tt_ranges,
          lr_runid    LIKE tt_ranges,
          lr_comcode  LIKE tt_ranges,
          lr_document LIKE tt_ranges,
          lr_cus      LIKE tt_ranges,
          lr_sup      LIKE tt_ranges.

    DATA: lw_text TYPE c LENGTH 210.
    DATA: ls_payment TYPE zce_fis_send_payment_100.
    LOOP AT keys ASSIGNING FIELD-SYMBOL(<lfs_keys>).
      ASSIGN COMPONENT '%tky-PaymentRunDate' OF STRUCTURE <lfs_keys> TO FIELD-SYMBOL(<lv_value>).
      IF sy-subrc EQ 0.
        APPEND VALUE #( sign = 'I' option = 'EQ' low = <lv_value> ) TO lr_rundate.
      ENDIF.

      ASSIGN COMPONENT '%tky-PaymentRunId' OF STRUCTURE <lfs_keys> TO <lv_value>.
      IF sy-subrc EQ 0.
        APPEND VALUE #( sign = 'I' option = 'EQ' low = <lv_value> ) TO lr_runid.
      ENDIF.

      ASSIGN COMPONENT '%tky-PayingCompanyCode' OF STRUCTURE <lfs_keys> TO <lv_value>.
      IF sy-subrc EQ 0.
        APPEND VALUE #( sign = 'I' option = 'EQ' low = <lv_value> ) TO lr_comcode.
      ENDIF.

      ASSIGN COMPONENT '%tky-PaymentDocument' OF STRUCTURE <lfs_keys> TO <lv_value>.
      IF sy-subrc EQ 0.
        APPEND VALUE #( sign = 'I' option = 'EQ' low = <lv_value> ) TO lr_document.
      ENDIF.
      ASSIGN COMPONENT '%tky-customer' OF STRUCTURE <lfs_keys> TO <lv_value>.
      IF sy-subrc EQ 0.
        APPEND VALUE #( sign = 'I' option = 'EQ' low = <lv_value> ) TO lr_cus.
      ENDIF.

      ASSIGN COMPONENT '%tky-supplier' OF STRUCTURE <lfs_keys> TO <lv_value>.
      IF sy-subrc EQ 0.
        APPEND VALUE #( sign = 'I' option = 'EQ' low = <lv_value> ) TO lr_sup.
      ENDIF.
    ENDLOOP.

    SELECT SINGLE MAX( id ) FROM ztb_fis_pm_100 INTO @DATA(lw_max_id).
    DATA: lw_id TYPE int4.
    lw_id = lw_max_id.

    DATA: ls_insert TYPE ztb_fis_pm_100.
    DATA: lt_insert TYPE TABLE OF ztb_fis_pm_100.

    SELECT FROM ztb_fis_pm_100 AS a
        RIGHT OUTER JOIN I_PaymentProposalPayment AS b ON  a~payment_run_date = b~PaymentRunDate
                                                   AND a~payment_run_id   = b~PaymentRunID
                                                   AND a~paying_company = b~PayingCompanyCode
                                                   AND a~paymentdocument = b~PaymentDocument
                                                   AND a~customer = b~Customer
                                                   AND a~supplier = b~Supplier
        FIELDS b~PaymentRunDate,b~PaymentRunID, b~PostingDate,b~PayingCompanyCode,a~text, a~status, b~AccountByShipper, b~PaymentDocument,
           a~created_by, a~created_by_fullname, b~PaymentAmountInPaytCurrency, b~BankAccountLongID, a~api_status, a~message, b~PayeeBankAccount,
           b~PayeeBankAccountHolderName, b~PayeeBankKey, b~Customer, b~Supplier, b~PayeeName, b~OrganizationBPName1, b~Bank, b~PayeeAdditionalName,
           b~OrganizationBPName2, b~OrganizationBPName3, b~OrganizationBPName4
        WHERE PaymentRunDate IN @lr_rundate
        AND PaymentRunID IN @lr_runid
        AND PayingCompanyCode IN @lr_comcode
        AND b~PaymentDocument IN @lr_document
        AND b~Customer IN @lr_cus
        AND b~Supplier IN @lr_sup
        AND b~PaymentRunIsProposal =  ''
        AND b~PaymentDocument      <> ''
        AND b~PaymentDocument      NOT LIKE 'F%'
        AND b~HouseBank LIKE 'VTB%'
        AND b~PayingCompanyCode = '6710'
        INTO TABLE @DATA(lt_data).

    SELECT DocumentReferenceID, ClearingAccountingDocument
        FROM i_accountingdocumentjournal
        FOR ALL ENTRIES IN @lt_data
        WHERE ClearingAccountingDocument = @lt_data-PaymentDocument
        AND CompanyCode = @lt_data-PayingCompanyCode
*        AND FiscalYear = @lt_data-PostingDate+0(4)
" Thay đổi logic do Fiscalyear NE PostingDate+0(4) date 12.02.2025
        AND ClearingDate = @lt_data-PostingDate
        AND Ledger = '0L'
        AND accountingdocument <> @lt_data-PaymentDocument
        INTO TABLE @DATA(lt_document_reference).

    DATA: ls_result   LIKE LINE OF result,
          ls_reported LIKE LINE OF reported-zce_fis_send_payment_100.

    LOOP AT lt_data INTO DATA(ls_data).
      ls_result-%pky-PayingCompanyCode = ls_data-PayingCompanyCode.
      ls_result-%pky-PaymentRunDate = ls_data-PaymentRunDate.
      ls_result-%pky-PaymentRunID = ls_data-PaymentRunID.
      ls_result-%pky-paymentdocument =  ls_data-PaymentRunID.
      ls_result-%pky-customer =  ls_data-customer.
      ls_result-%pky-Supplier =  ls_data-Supplier.

      ls_result-%tky-PayingCompanyCode = ls_data-PayingCompanyCode.
      ls_result-%tky-PaymentRunDate = ls_data-PaymentRunDate.
      ls_result-%tky-PaymentRunID = ls_data-PaymentRunID.
      ls_result-%tky-paymentdocument =  ls_data-PaymentRunID.
      ls_result-%tky-customer =  ls_data-customer.
      ls_result-%tky-Supplier =  ls_data-Supplier.

      ls_result-%data-PayingCompanyCode = ls_data-PayingCompanyCode.
      ls_result-%data-PaymentRunID = ls_data-PaymentRunID.
      ls_result-%data-PaymentRunDate = ls_data-PaymentRunDate.
      ls_result-%data-PostingDate = ls_data-PostingDate.
      ls_result-%data-created_by = ls_data-created_by.
      ls_result-%data-created_by_fullname = ls_data-created_by_fullname.


      ls_result-%data-bank = ls_data-Bank.

      DATA: lw_check_initial TYPE abap_bool.
      lw_check_initial = abap_false.

      LOOP AT lt_document_reference INTO DATA(ls_document_reference)
        WHERE ClearingAccountingDocument = ls_data-PaymentDocument .
        DATA(lw_payment_document) = ls_data-PaymentDocument.
        IF ls_data-text IS INITIAL.
          lw_check_initial = abap_true.
          ls_data-text = ls_document_reference-DocumentReferenceID.
*          ls_result-%data-text = ls_document_reference-DocumentReferenceID.
        ENDIF.

        IF ls_data-text IS NOT INITIAL AND lw_check_initial = abap_true.
          FIND ls_document_reference-DocumentReferenceID IN ls_data-text.
          IF sy-subrc <> 0.
            ls_data-text = ls_data-text && `, ` && ls_document_reference-DocumentReferenceID.
          ENDIF.
        ENDIF.
      ENDLOOP.

      ls_result-%data-text = ls_data-text.
      ls_result-%data-paymentdocument = ls_data-paymentdocument.
      ls_result-%data-PaymentAmountInPaytCurrency = ls_data-PaymentAmountInPaytCurrency.
      ls_result-%data-BankAccountLongID = ls_data-BankAccountLongID.
      ls_result-%data-PayeeBankAccount = ls_data-PayeeBankAccount.
      ls_result-%data-PayeeBankAccountHolderName = ls_data-PayeeBankAccountHolderName.
      ls_result-%data-PayeeBankKey = ls_data-PayeeBankKey.
      ls_result-%data-api_status = ls_data-api_status.
      ls_result-%data-message = ls_data-message.
      ls_result-%data-customer =  ls_data-customer.
      ls_result-%data-Supplier =  ls_data-Supplier.
      ls_result-%data-payeename = ls_data-PayeeName.
      ls_result-%data-payeeadditionalname = ls_data-PayeeAdditionalName.

      ls_result-%data-organizationbpname1 = ls_data-OrganizationBPName1.
      ls_result-%data-organizationbpname2 = ls_data-OrganizationBPName2.
      ls_result-%data-organizationbpname3 = ls_data-OrganizationBPName3.
      ls_result-%data-organizationbpname4 = ls_data-OrganizationBPName4.
      APPEND ls_result TO result.
    ENDLOOP.
  ENDMETHOD.

  METHOD lock.
  ENDMETHOD.

  METHOD request_payment.

    TYPES:BEGIN OF ty_status,
            code    TYPE string,
            message TYPE string,
          END OF ty_status.

    TYPES:BEGIN OF ty_record,
            record  TYPE zst_fis_api_pm_item_100,
            message TYPE string,
          END OF ty_record.

    TYPES: BEGIN OF ty_response,
             request_id  TYPE string,
             provider_id TYPE string,
             merchant_id TYPE string,
             status      TYPE ty_status,
             records     TYPE TABLE OF ty_record WITH EMPTY KEY,
           END OF ty_response.

    TYPES: BEGIN OF ty_auth,
             grant_type    TYPE string,
             username      TYPE string,
             password      TYPE string,
             client_id     TYPE string,
             client_secret TYPE string,
           END OF ty_auth.

    DATA: ls_reponse TYPE ty_response.

    DATA: lw_requestId TYPE string.
    CONSTANTS lct_modal TYPE string VALUE '2'.
    DATA: lct_ibm_client_secret TYPE string .
    DATA: lct_ibm_client_id TYPE string.

    TYPES: BEGIN OF ty_test,
             requestID TYPE string,
           END OF ty_test.

    DATA: ls_payment      TYPE zst_fis_api_payment_100,
          ls_payment_item TYPE zst_fis_api_pm_item_100,
          lt_payment_item TYPE ztt_fis_api_payment_item_100.

    DATA: lw_datetime TYPE string,
          lw_json     TYPE string.

    DATA: ls_api_log TYPE ztb_fis_log_api.
    DATA: lt_api_log TYPE TABLE OF ztb_fis_log_api.

    DATA: ls_auth TYPE ty_auth.

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<lfs_keys>).
      ls_auth-password = <lfs_keys>-%param-password.
      ls_auth-username = <lfs_keys>-%param-username.
    ENDLOOP.

    "12.02.2025 Move code for check logic
    READ ENTITIES OF zce_fis_send_payment_100 IN LOCAL MODE
    ENTITY zce_fis_send_payment_100
    FIELDS (  PayingCompanyCode PaymentRunDate PaymentRunID Text PostingDate Status  created_by created_by_fullname PayeeBankKey payeebankaccount
    payeebankaccountholdername paymentdocument supplier customer payeename organizationbpname1 bank )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_paymentlog).
    SORT lt_paymentlog BY text PaymentRunDate PaymentRunID PostingDate.

    LOOP AT lt_paymentlog INTO DATA(ls_payment_log).
      IF ls_payment_log-text IS INITIAL.
        DELETE lt_paymentlog INDEX sy-tabix.
        DATA(item_msg) = new_message( id = 'Z_MESSAGE_100'  " id = Name Of message class

                        number = '004' "number of message defined in the message class
                        severity = cl_abap_behv=>ms-error "type of message
                        v1 = ls_payment_log-PaymentRunID  "First Parameter
                        v2 = ls_payment_log-PaymentRunDate          "Second Parameter
                        ).
        APPEND VALUE #( PaymentRunID = ls_payment_log-PaymentRunID PaymentRunDate = ls_payment_log-PaymentRunDate
         " %cid = "Content ID" in ABAP Behavior
       %msg = item_msg "%msg  =  type ref to if_abap_behv_message / Message to be passed
       ) TO reported-zce_fis_send_payment_100.
      ENDIF.
      IF ls_payment_log-api_status EQ 'Posted Successfully'.
        DELETE lt_paymentlog INDEX sy-tabix.
        DATA(item_msg_api) = new_message( id = 'Z_MESSAGE_100'  " id = Name Of message class

                        number = '006' "number of message defined in the message class
                        severity = cl_abap_behv=>ms-error "type of message
                        v1 = ls_payment_log-PaymentRunID  "First Parameter
                        v2 = ls_payment_log-PaymentRunDate          "Second Parameter
                        ).
        APPEND VALUE #( PaymentRunID = ls_payment_log-PaymentRunID PaymentRunDate = ls_payment_log-PaymentRunDate
         " %cid = "Content ID" in ABAP Behavior
       %msg = item_msg_api "%msg  =  type ref to if_abap_behv_message / Message to be passed
       ) TO reported-zce_fis_send_payment_100.
      ENDIF.
    ENDLOOP.

    CHECK lt_paymentlog IS NOT INITIAL.
    "---------------------"

    "Bổ sung code Dinamic Parameter with app Config it form 11.02.2025
*    ls_auth-client_id = 'erp'.
*    ls_auth-grant_type = 'password'.
    "--------------------------------------------
*    ls_auth-client_secret = '27E134798E26BBBAF82B424675696F4B'.

    SELECT * FROM ztb_tcv_cfauthba
    INTO TABLE @DATA(lt_tcv_config_auth_bank).
    IF sy-subrc EQ 0.
      LOOP AT lt_tcv_config_auth_bank INTO DATA(ls_tcv_config_auth_bank).
        ASSIGN COMPONENT ls_tcv_config_auth_bank-param OF STRUCTURE ls_auth TO FIELD-SYMBOL(<lv_value>).
        IF <lv_value> IS ASSIGNED.
          <lv_value> = ls_tcv_config_auth_bank-value.
        ENDIF.
        UNASSIGN <lv_value>.
      ENDLOOP.
    ELSE.
      APPEND VALUE #( %msg = new_message_with_text( severity =
           if_abap_behv_message=>severity-error
           text = 'Check config parameter auth form app' )
         ) TO reported-zce_fis_send_payment_100.
    ENDIF.

    "Bổ sung check log token from date 10.02.2025
    DATA: ls_log_token TYPE ztb_log_tcvbank,
          lt_log_token TYPE TABLE OF ztb_log_tcvbank.

    DATA: lv_error TYPE char1 VALUE IS INITIAL.

    DATA(system_uuid) = cl_system_uuid=>create_uuid_c36_static( ).

    IF lw_access_token IS INITIAL.

      SELECT SINGLE *
      FROM ztb_config_route
      WHERE status = 'A'
      INTO @DATA(ls_route).
      IF sy-subrc <> 0.
        DATA(item_conf_error) = new_message( id = 'Z_MESSAGE_100'  " id = Name Of message class

                          number = '005' "number of message defined in the message class
                          severity = cl_abap_behv=>ms-error "type of message
                          v1 = 'Router API has not been configured yet'  "First Parameter
                          ).
        APPEND VALUE #( %msg = item_conf_error ) TO reported-zce_fis_send_payment_100.
      ENDIF.
      CHECK sy-subrc = 0.
      DATA(lw_route_api_auth) = ls_route-uri_auth.
      DATA(lw_route_send_bank) = ls_route-uri_send_payment.

      TRY.
          DATA(lo_destination_auth) = cl_http_destination_provider=>create_by_comm_arrangement(
                                       comm_scenario  = 'ZCS_BANK_VTP_API_AUTH'
                                       service_id     = 'ZOS_BANK_VTP_AUTH_REST'
                                     ).
        CATCH cx_http_dest_provider_error INTO DATA(lx_dest_error_auth).
          DATA(item_auth_error) = new_message( id = 'Z_MESSAGE_100'  " id = Name Of message class

                          number = '005' "number of message defined in the message class
                          severity = cl_abap_behv=>ms-error "type of message
                          v1 = lx_dest_error_auth->get_text(  )  "First Parameter
                          ).
          APPEND VALUE #( %msg = item_auth_error ) TO reported-zce_fis_send_payment_100.
      ENDTRY.
      TRY.
          DATA(lo_http_client_auth) = cl_web_http_client_manager=>create_by_http_destination( i_destination = lo_destination_auth ).
        CATCH cx_web_http_client_error INTO DATA(lx_error_auth).
          item_auth_error = new_message( id = 'Z_MESSAGE_100'  " id = Name Of message class

                          number = '005' "number of message defined in the message class
                          severity = cl_abap_behv=>ms-error "type of message
                          v1 = lx_error_auth->get_text(  )  "First Parameter
                          ).
          APPEND VALUE #( %msg = item_auth_error ) TO reported-zce_fis_send_payment_100.
      ENDTRY.

      DATA(lo_request_auth) = lo_http_client_auth->get_http_request(  ).

      lo_request_auth->set_uri_path( CONV #( lw_route_api_auth ) ).
      DATA(x) = lo_request_auth->get_text(  ).
      DATA(lw_json_body_auth) = /ui2/cl_json=>serialize(
                    data = ls_auth
                    compress = abap_true
                    pretty_name = /ui2/cl_json=>pretty_mode-user_low_case ).
*     Form field
      lo_request_auth->set_form_field( i_name = 'grant_type' i_value = ls_auth-grant_type ).
      lo_request_auth->set_form_field( i_name = 'username' i_value = ls_auth-username ).
      lo_request_auth->set_form_field( i_name = 'password' i_value = ls_auth-password ).
      lo_request_auth->set_form_field( i_name = 'client_id' i_value = ls_auth-client_id ).
*      lo_request_auth->set_form_field( i_name = 'client_secret' i_value = ls_auth-client_secret ).

      TRY.
          DATA(lo_response_auth) = lo_http_client_auth->execute( i_method = if_web_http_client=>post
                                                           i_timeout = 60 ).
        CATCH cx_web_http_client_error.
          item_auth_error = new_message( id = 'Z_MESSAGE_100'  " id = Name Of message class

                          number = '005' "number of message defined in the message class
                          severity = cl_abap_behv=>ms-error "type of message
                          v1 = lx_error_auth->get_text(  )  "First Parameter
                          ).
          APPEND VALUE #( %msg = item_auth_error ) TO reported-zce_fis_send_payment_100.
      ENDTRY.

      DATA: lw_reponse_auth TYPE string.
      lw_reponse_auth = lo_response_auth->get_text(  ).

      FIND REGEX 'access_token=([^&]+)' IN lw_reponse_auth SUBMATCHES lw_access_token.

    ENDIF.

    DATA: lv_host     TYPE string,
          lv_v1       TYPE char255,
          lv_v2       TYPE char255,
          lv_v3       TYPE char255,
          lv_v4       TYPE char255,
          lv_v5       TYPE char255,

          lv_position TYPE int4,
          lv_length   TYPE int4,
          lv_index    TYPE int4.

    lv_length = 50.
    lv_position = 0.
    lv_index = 1.

    IF lw_access_token IS INITIAL.
      "Bổ sung log check lỗi from date 10.02.2024

      lv_error = 'X'.

      ls_log_token-comm_scenario = 'ZCS_BANK_VTP_API_AUTH'.
      ls_log_token-service_id = 'ZOS_BANK_VTP_AUTH_REST'.
      ls_log_token-guid = system_uuid.
      ls_log_token-link = lw_route_api_auth.
      ls_log_token-createddat = sy-datlo.
      ls_log_token-createdtime = sy-timlo.
      ls_log_token-createdby = sy-uname.
      ls_log_token-response = lw_reponse_auth.
      ls_log_token-type = 'E'.

      REPLACE ALL OCCURRENCES OF ls_auth-username IN ls_log_token-response WITH '*********'.
      REPLACE ALL OCCURRENCES OF ls_auth-password IN ls_log_token-response WITH '*********'.

      APPEND ls_log_token TO lt_log_token.

      zcl_save_payment=>fill_api_log( lt_log_token = lt_log_token ).

      IF strlen( ls_log_token-response ) < lv_length.
        lv_v1 = ls_log_token-response.
      ELSE.
*        WHILE lv_position <= strlen( ls_log_token-response ).
*
*          IF lv_index = 1.
*            lv_v1 = ls_log_token-response+lv_position(lv_length).
*          ELSEIF lv_index = 2.
*            lv_v2 = ls_log_token-response+lv_position(lv_length).
*          ELSEIF lv_index = 3.
*            lv_v3 = ls_log_token-response+lv_position(lv_length).
*          ELSEIF lv_index = 4.
*            lv_v4 = ls_log_token-response+lv_position(lv_length).
*          ELSEIF lv_index = 5.
*            lv_v5 = ls_log_token-response+lv_position(lv_length).
*          ENDIF.
*
*          lv_position = lv_position + lv_length.
*          lv_index = lv_index + 1.
*
*        ENDWHILE.
      ENDIF.

      "-----
      item_auth_error = new_message( id = 'Z_MESSAGE_100'  " id = Name Of message class

                           number = '005' "number of message defined in the message class
*                            severity = cl_abap_behv=>ms-error "type of message
*                            v1 = 'username or password is incorrect'  "First Parameter
                             severity = cl_abap_behv=>ms-none "type of message
                             v1 = ls_log_token-response
                            ).

      APPEND VALUE #( %msg = item_auth_error ) TO reported-zce_fis_send_payment_100.

*       APPEND VALUE #( %msg = new_message_with_text( severity =
*         if_abap_behv_message=>severity-none
*         text = ls_log_token-response )
*       ) TO reported-zce_fis_send_payment_100.


      CLEAR: ls_log_token.

    ELSE.
      lv_error = ''.
    ENDIF.

    CHECK lw_access_token IS NOT INITIAL.

    SELECT SINGLE *
    FROM ztb_tcv_api_key
    WHERE is_active = 'Active'
    INTO @DATA(ls_api_key).

    lct_ibm_client_secret = ls_api_key-x_ibm_client_secret.
    lct_ibm_client_id = ls_api_key-x_ibm_client_id.

    TRY.
        DATA(lo_destination) = cl_http_destination_provider=>create_by_comm_arrangement(
                                     comm_scenario  = 'ZCS_BANK_VTP_API'
                                     service_id     = 'ZOS_BANK_VTP_API_REST'
                                   ).
      CATCH cx_http_dest_provider_error INTO DATA(lx_dest_error).
        DATA(item_msg_error) = new_message( id = 'Z_MESSAGE_100'  " id = Name Of message class

                        number = '005' "number of message defined in the message class
                        severity = cl_abap_behv=>ms-error "type of message
                        v1 = lx_dest_error->get_text(  )  "First Parameter
                        ).
        APPEND VALUE #( PaymentRunID = ls_payment_log-PaymentRunID PaymentRunDate = ls_payment_log-PaymentRunDate
         " %cid = "Content ID" in ABAP Behavior
       %msg = item_msg_error "%msg  =  type ref to if_abap_behv_message / Message to be passed
       ) TO reported-zce_fis_send_payment_100.
    ENDTRY.
    TRY.
        DATA(lo_http_client) = cl_web_http_client_manager=>create_by_http_destination( i_destination = lo_destination ).
      CATCH cx_web_http_client_error INTO DATA(lx_error).
        item_msg_error = new_message( id = 'Z_MESSAGE_100'  " id = Name Of message class

                        number = '005' "number of message defined in the message class
                        severity = cl_abap_behv=>ms-error "type of message
                        v1 = lx_error->get_text(  )  "First Parameter
                        ).
        APPEND VALUE #( PaymentRunID = ls_payment_log-PaymentRunID PaymentRunDate = ls_payment_log-PaymentRunDate
         " %cid = "Content ID" in ABAP Behavior
       %msg = item_msg_error "%msg  =  type ref to if_abap_behv_message / Message to be passed
       ) TO reported-zce_fis_send_payment_100.
    ENDTRY.
    DATA(lo_request) = lo_http_client->get_http_request( ).

    lo_request->set_uri_path( CONV #( lw_route_send_bank ) ).

    SELECT  supplier, bpbankaccountinternalid, PaymentRunID, PaymentRunDate,
            paymentdocument
    FROM i_paymentproposalitem AS a
    FOR ALL ENTRIES IN @lt_paymentlog
    WHERE  a~PaymentRunDate = @lt_paymentlog-PaymentRunDate
    AND a~PaymentRunID = @lt_paymentlog-PaymentRunId
    AND a~paymentdocument = @lt_paymentlog-PaymentDocument
    AND a~PaymentRunIsProposal = ''
    INTO TABLE @DATA(lt_item).

    LOOP AT lt_item ASSIGNING FIELD-SYMBOL(<fs_item>).
      IF <fs_item>-BPBankAccountInternalID IS INITIAL.
        <fs_item>-BPBankAccountInternalID = '0001'.
      ENDIF.
    ENDLOOP.

    IF lt_item IS NOT INITIAL.
      SELECT BankIdentification, BusinessPartner FROM i_businesspartnerbank
      FOR ALL ENTRIES IN @lt_item
      WHERE BusinessPartner = @lt_item-Supplier
      AND BankIdentification = @lt_item-BPBankAccountInternalID
      INTO TABLE @DATA(lt_bpBank).
    ENDIF.

    SELECT BankInternalID, bankname FROM I_Bank_2
    FOR ALL ENTRIES IN @lt_paymentlog
    WHERE BankInternalID = @lt_paymentlog-payeebankkey
    INTO TABLE @DATA(lt_bank).

    DATA: lw_total TYPE p LENGTH 16 DECIMALS 2.
    LOOP AT lt_paymentlog INTO DATA(ls_paymentlog).
      lw_total += ls_paymentlog-PaymentAmountInPaytCurrency.
    ENDLOOP.

    lw_datetime = cl_abap_context_info=>get_system_date(  ) && cl_abap_context_info=>get_system_time(  ).

*   Header
    lo_request->set_header_field( i_name  = 'x-ibm-client-secret' i_value = lct_ibm_client_secret ).
    lo_request->set_header_field( i_name = 'x-ibm-client-id' i_value =  lct_ibm_client_id ).
    lo_request->set_header_field( i_name = 'Content-Type' i_value =  'application/json' ).
    lo_request->set_header_field( i_name = 'Authorization' i_value = lw_access_token ).
*   Body
    lw_requestId = lt_paymentlog[ 1 ]-PaymentRunID && lt_paymentlog[ 1 ]-PaymentRunDate && cl_abap_context_info=>get_system_time(  )."&& lt_paymentlog[ 1 ]-PayingCompanyCode.
    ls_payment-request_id = lw_requestId.
    ls_payment-provider_id = 'TRANSCOSMOS'.

    IF sy-sysid = 'XCP' AND sy-mandt = '100'.
      IF ls_payment_log-bank = '01201002' .
        ls_payment-merchant_id = 'TCV_HN'.
      ELSE.
        ls_payment-merchant_id = 'TCV_HCM'.
      ENDIF.
    ELSE.

    ENDIF.

    ls_payment-priority = '3'.
    ls_payment-version = '1.0'.
    ls_payment-software_provider_id = 'SAP'.
    ls_payment-language = 'vi'.
    IF lw_total < 0.
      ls_payment-total_amount = |{ lw_total * -1 * 100 DECIMALS = 0 }|.
    ENDIF.

    ls_payment-model = '2'.
    ls_payment-fee_type = 'BEN'.
    ls_payment-trans_time = lw_datetime.
    ls_payment-channel = 'WEB'.


*    LOOP AT lt_proposal INTO ls_proposal.
    LOOP AT lt_paymentlog INTO ls_payment_log.
      ls_payment_item-trans_id = |{ ls_payment_log-PaymentDocument }{ ls_payment_log-PayingCompanyCode }{ ls_payment_log-PostingDate(4) } |.
      IF ls_payment_log-PaymentAmountInPaytCurrency < 0.
        ls_payment_item-amount = |{ ls_payment_log-PaymentAmountInPaytCurrency * -1  * 100 DECIMALS = 0 }| .
      ELSE.
        ls_payment_item-amount = |{ ls_payment_log-PaymentAmountInPaytCurrency * 100 DECIMALS = 0 }|.
      ENDIF.
      ls_payment_item-sender_acct_id = ls_payment_log-BankAccountLongID.

      ls_payment_item-sender_addr = 'senderAddr'.
      ls_payment_item-remark = lw_requestId && ` ` && ls_payment_log-text.

      IF strlen( ls_payment_item-remark ) > 210.
        ls_payment_item-remark = ls_payment_item-remark(210).
      ENDIF.


      ls_payment_item-recv_acct_id = |{ ls_paymentlog-payeebankaccount }|.
*          ls_payment_item-recv_branch_id = |{ ls_bpbank-BankNumber }|.
      ls_payment_item-recv_branch_id = |{ ls_payment_log-payeebankkey }|.
      IF ls_payment_item-recv_branch_id+2(3) = '201'.
        ls_payment_item-trans_type = 'in'.
      ELSE.
        ls_payment_item-trans_type = 'ou'.
      ENDIF.
*          ls_payment_item-recv_acct_name = |{ ls_bpbank-BankAccountHolderName }|.

      "add logic form date 23.01.2025
      SELECT SINGLE Companycode, AccountingDocument, Fiscalyear
      FROM i_accountingdocumentjournal
      WHERE AccountingDocument = @ls_payment_log-paymentdocument
      AND CompanyCode = @ls_payment_log-PayingCompanyCode
      AND ClearingDate = @ls_paymentlog-PostingDate
      INTO @DATA(ls_acctdocument).
      IF syst-subrc NE 0.
        CLEAR: ls_acctdocument.
      ENDIF.

      SELECT SINGLE AccountingDocument, supplier
      FROM I_OneTimeAccountSupplier
      "Change logic from date 23.01.2025 - FiscalYear NE PostingDate(4)
*      WHERE AccountingDocument = @ls_payment_log-paymentdocument
*      AND CompanyCode = @ls_payment_log-PayingCompanyCode
*      AND FiscalYear = @ls_paymentlog-PostingDate(4)
       WHERE AccountingDocument = @ls_acctdocument-AccountingDocument
          AND CompanyCode = @ls_acctdocument-CompanyCode
          AND FiscalYear = @ls_acctdocument-FiscalYear
      INTO @DATA(ls_acc).

      IF syst-subrc = 0.
*        IF ls_acc-Supplier CP '*E*'.
        IF ls_acc-Supplier+0(1) EQ 'E'.
          ls_payment_item-recv_acct_name = |{ ls_payment_log-payeename } { ls_payment_log-payeeadditionalname }|.
        ELSE.
          ls_payment_item-recv_acct_name = ls_payment_log-organizationbpname2 && ' ' && ls_payment_log-organizationbpname3 && ' ' && ls_payment_log-organizationbpname4.
          IF ls_payment_item-recv_acct_name IS INITIAL.
            ls_payment_item-recv_acct_name = |{ ls_payment_log-organizationbpname1 }|.
          ENDIF.
        ENDIF.
      ELSE.
        ls_payment_item-recv_acct_name = |{ ls_payment_log-payeebankaccountholdername }|.
      ENDIF.
*          ls_payment_item-recv_bank_id = |{ ls_bpbank-BankNumber }|.
      ls_payment_item-recv_bank_id = |{ ls_payment_log-payeebankkey }|.
      ls_payment_item-currency_code = 'VND'.

      READ TABLE lt_item INTO DATA(ls_item)
      WITH KEY PaymentRunID = ls_payment_log-PaymentRunID
      PaymentRunDate = ls_payment_log-PaymentRunDate
      PaymentDocument = ls_payment_log-PaymentDocument.
      IF syst-subrc = 0.
        READ TABLE lt_bpbank INTO DATA(ls_bpbank)
        WITH KEY BusinessPartner = ls_item-Supplier
        BankIdentification = ls_item-BPBankAccountInternalID.
        IF syst-subrc = 0.
*          ls_payment_item-recv_acct_id = |{ ls_bpbank-bankaccount }|.
          ls_payment_item-recv_bank_name = |{ lt_bank[ BankInternalID = ls_payment_log-payeebankkey ]-BankName }|.
        ENDIF.
      ENDIF.

      SELECT SINGLE BankName
        FROM I_Bank_2
        WHERE BankInternalID = @ls_payment_log-payeebankkey
        INTO @DATA(lw_bank_name).

      ls_payment_item-recv_bank_name = lw_bank_name.
      APPEND ls_payment_item TO lt_payment_item.
    ENDLOOP.



    IF lt_payment_item IS NOT INITIAL.
      ls_payment-records = lt_payment_item.
      TRY.

          DATA(lw_json_body) = /ui2/cl_json=>serialize(
                    data = ls_payment
                    compress = abap_true
                    pretty_name = /ui2/cl_json=>pretty_mode-camel_case ).

          lo_request->set_text( lw_json_body  ).
          DATA(lo_response) = lo_http_client->execute( i_method = if_web_http_client=>post
                                                           i_timeout = 60 ).
*-- Get the status of the response ->
          DATA: lw_response_json TYPE string.
          lw_response_json = lo_response->get_text( ).
          /ui2/cl_json=>deserialize(
           EXPORTING
              json             = lw_response_json
              pretty_name      = /ui2/cl_json=>pretty_mode-camel_case
           CHANGING
             data             = ls_reponse
         ).

          DATA: ls_update_mess TYPE ztb_fis_pm_100.

          ls_update_mess-message = ls_reponse-status-message.
          IF ls_reponse-status-code = 1.
            ls_update_mess-api_status = 'Posted Successfully'.
          ELSEIF ls_reponse-status-code = 0.
            ls_update_mess-api_status = 'Posted Fail'.
          ENDIF.
          LOOP AT ls_reponse-records INTO DATA(ls_record).
            IF ls_record-message IS NOT INITIAL.
              FIND ls_record-message IN ls_update_mess-message.
              IF sy-subrc <> 0 AND ls_reponse-status-code = 0.
                ls_update_mess-message = ls_update_mess-message && cl_abap_char_utilities=>newline && `Error reason: ` && ls_record-message.
              ELSEIF sy-subrc <> 0 AND ls_reponse-status-code = 1.
                ls_update_mess-message = ls_update_mess-message && cl_abap_char_utilities=>newline && ls_record-message.
              ENDIF.
            ENDIF.
          ENDLOOP.

          IF ls_update_mess-message IS INITIAL.
            ls_update_mess-message = lw_response_json.
          ENDIF.

          MODIFY ENTITIES OF zce_fis_send_payment_100 IN LOCAL MODE
          ENTITY zce_fis_send_payment_100
          UPDATE
          FROM VALUE #( ( PaymentRunID = ls_payment_log-PaymentRunId
          PaymentRunDate = ls_payment_log-PaymentRunDate PayingCompanyCode = ls_payment_log-PayingCompanyCode
          message = ls_update_mess-message api_status = ls_update_mess-api_status json_body = lw_json_body paymentdocument = ls_payment_log-paymentdocument
          customer = ls_payment_log-customer supplier = ls_payment_log-supplier ) )
          .

        CATCH cx_root INTO DATA(lx_exception).
          item_msg_error = new_message( id = 'Z_MESSAGE_100'  " id = Name Of message class

                          number = '005' "number of message defined in the message class
                          severity = cl_abap_behv=>ms-error "type of message
                          v1 = lx_exception->get_text(  )  "First Parameter
                          ).
          APPEND VALUE #( PaymentRunID = ls_payment_log-PaymentRunID PaymentRunDate = ls_payment_log-PaymentRunDate
         %msg = item_msg_error
         ) TO reported-zce_fis_send_payment_100.
      ENDTRY.
    ENDIF.

*   Ghi log api
    ls_api_log-client = sy-mandt.
    ls_api_log-request_id = lw_requestId.
    ls_api_log-created_by = sy-uname.
    ls_api_log-request_data = lw_json_body.
    ls_api_log-request_date = cl_abap_context_info=>get_system_date(  ).
    ls_api_log-request_time = cl_abap_context_info=>get_system_time(  ).
    ls_api_log-response_data = lw_response_json.
    ls_api_log-response_message = ls_update_mess-message.
    ls_api_log-response_status = ls_update_mess-api_status.
    APPEND ls_api_log TO lt_api_log.

    zcl_save_payment=>fill_api_log( lt_data = lt_api_log ).

  ENDMETHOD.

  METHOD edit_text.
    TYPES: BEGIN OF ty_range_option,
             sign   TYPE c LENGTH 1,
             option TYPE c LENGTH 2,
             low    TYPE string,
             high   TYPE string,
           END OF ty_range_option.

    DATA: tt_ranges          TYPE TABLE OF ty_range_option.

    DATA: lr_rundate  LIKE tt_ranges,
          lr_runid    LIKE tt_ranges,
          lr_comcode  LIKE tt_ranges,
          lr_document LIKE tt_ranges,
          lr_cus      LIKE tt_ranges,
          lr_sup      LIKE tt_ranges.

    DATA: lw_text TYPE c LENGTH 210.
    DATA: ls_payment TYPE zce_fis_send_payment_100.
    LOOP AT keys ASSIGNING FIELD-SYMBOL(<lfs_keys>).
      ASSIGN COMPONENT '%tky-PaymentRunDate' OF STRUCTURE <lfs_keys> TO FIELD-SYMBOL(<lv_value>).
      IF sy-subrc EQ 0.
        APPEND VALUE #( sign = 'I' option = 'EQ' low = <lv_value> ) TO lr_rundate.
      ENDIF.

      ASSIGN COMPONENT '%tky-PaymentRunId' OF STRUCTURE <lfs_keys> TO <lv_value>.
      IF sy-subrc EQ 0.
        APPEND VALUE #( sign = 'I' option = 'EQ' low = <lv_value> ) TO lr_runid.
      ENDIF.

      ASSIGN COMPONENT '%tky-PayingCompanyCode' OF STRUCTURE <lfs_keys> TO <lv_value>.
      IF sy-subrc EQ 0.
        APPEND VALUE #( sign = 'I' option = 'EQ' low = <lv_value> ) TO lr_comcode.
      ENDIF.

      ASSIGN COMPONENT '%tky-PaymentDocument' OF STRUCTURE <lfs_keys> TO <lv_value>.
      IF sy-subrc EQ 0.
        APPEND VALUE #( sign = 'I' option = 'EQ' low = <lv_value> ) TO lr_document.
      ENDIF.
      ASSIGN COMPONENT '%tky-customer' OF STRUCTURE <lfs_keys> TO <lv_value>.
      IF sy-subrc EQ 0.
        APPEND VALUE #( sign = 'I' option = 'EQ' low = <lv_value> ) TO lr_cus.
      ENDIF.

      ASSIGN COMPONENT '%tky-supplier' OF STRUCTURE <lfs_keys> TO <lv_value>.
      IF sy-subrc EQ 0.
        APPEND VALUE #( sign = 'I' option = 'EQ' low = <lv_value> ) TO lr_sup.
      ENDIF.
      lw_text = <lfs_keys>-%param-text.
    ENDLOOP.

    SELECT SINGLE MAX( id ) FROM ztb_fis_pm_100 INTO @DATA(lw_max_id).
    DATA: lw_id TYPE int4.
    lw_id = lw_max_id.

    DATA: ls_insert TYPE ztb_fis_pm_100.
    DATA: lt_insert TYPE TABLE OF ztb_fis_pm_100.
*    DATA: ls_result   LIKE LINE OF result,
*          ls_reported LIKE LINE OF reported-zce_fis_send_payment_100.

    SELECT FROM ztb_fis_pm_100 AS a
        RIGHT OUTER JOIN I_PaymentProposalPayment AS b
        ON  a~payment_run_date = b~PaymentRunDate
        AND a~payment_run_id   = b~PaymentRunID
        AND a~paying_company = b~PayingCompanyCode
        AND a~paymentdocument = b~PaymentDocument
        AND a~customer = b~Customer
        AND a~supplier = b~Supplier
        FIELDS b~PaymentRunDate,b~PaymentRunID, b~PostingDate,b~PayingCompanyCode,a~text, a~status, b~AccountByShipper, b~PaymentDocument,
           a~created_by,
           a~created_by_fullname,
           a~api_status,
           a~message,
           b~customer, b~supplier
        WHERE PaymentRunDate IN @lr_rundate
        AND PaymentRunID IN @lr_runid
        AND PayingCompanyCode IN @lr_comcode
        AND b~PaymentDocument IN @lr_document
        AND b~Customer IN @lr_cus
        AND b~Supplier IN @lr_sup
        AND b~PaymentRunIsProposal =  ''
        AND b~PaymentDocument      <> ''
        AND b~PaymentDocument      NOT LIKE 'F%'
        AND b~HouseBank LIKE 'VTB%'
        AND b~PayingCompanyCode = '6710'
        INTO TABLE @DATA(gt_data).

    LOOP AT gt_data INTO DATA(ls_data).
      IF ls_data-api_status EQ 'Posted Successfully'.
        DATA(item_msg_edit) = new_message( id = 'Z_MESSAGE_100'  " id = Name Of message class

                        number = '007' "number of message defined in the message class
                        severity = cl_abap_behv=>ms-error "type of message
                        v1 = ls_data-PaymentRunID  "First Parameter
                        v2 = ls_data-PaymentRunDate          "Second Parameter
                        ).
        APPEND VALUE #( PaymentRunID = ls_data-PaymentRunID PaymentRunDate = ls_data-PaymentRunDate
         " %cid = "Content ID" in ABAP Behavior
       %msg = item_msg_edit "%msg  =  type ref to if_abap_behv_message / Message to be passed
       ) TO reported-zce_fis_send_payment_100.

        CONTINUE.
      ENDIF.
      ls_insert-payment_run_id = ls_data-PaymentRunID.
      ls_insert-payment_run_date = ls_data-PaymentRunDate.
      ls_insert-paying_company = ls_data-PayingCompanyCode.
      ls_insert-text = lw_text.


*     Validate
      DATA(lw_check_regex) = 0.
      FIND '-' IN lw_text MATCH COUNT DATA(lw_1).
      FIND '/' IN lw_text MATCH COUNT DATA(lw_2).

      DATA(lv_regex) = '[^a-zA-Z0-9 ,#!&_;.+:"=%]'.

      TRY.
          FIND ALL OCCURRENCES OF PCRE lv_regex IN lw_text
          MATCH COUNT lw_check_regex.
          lw_check_regex = lw_check_regex - lw_1 - lw_2.
          IF lw_check_regex <> 0.
            DATA(item_msg_regex_check) = new_message( id = 'Z_MESSAGE_100'  " id = Name Of message class

                         number = '008' "number of message defined in the message class
                         severity = cl_abap_behv=>ms-error "type of message
                         v1 = '&'  "First Parameter          "Second Parameter
                         ).
            APPEND VALUE #(
             " %cid = "Content ID" in ABAP Behavior
           %msg = item_msg_regex_check "%msg  =  type ref to if_abap_behv_message / Message to be passed
           ) TO reported-zce_fis_send_payment_100.
            CONTINUE.
          ENDIF.
        CATCH cx_sy_regex INTO DATA(lx_error_regex).
          DATA(item_msg_error) = new_message( id = 'Z_MESSAGE_100'  " id = Name Of message class

                          number = '005' "number of message defined in the message class
                          severity = cl_abap_behv=>ms-error "type of message
                          v1 = lx_error_regex->get_text(  )  "First Parameter
                          ).
          APPEND VALUE #( %msg = item_msg_error ) TO reported-zce_fis_send_payment_100.
      ENDTRY.

      IF strlen( lw_text ) > 192.
        DATA(item_msg_text_length) = new_message( id = 'Z_MESSAGE_100'  " id = Name Of message class

                        number = '009' "number of message defined in the message class
                        severity = cl_abap_behv=>ms-error "type of message
                        ).
        APPEND VALUE #(
       %msg = item_msg_text_length
       ) TO reported-zce_fis_send_payment_100.

        CONTINUE.
      ENDIF.

      MODIFY ENTITIES OF zce_fis_send_payment_100 IN LOCAL MODE
      ENTITY zce_fis_send_payment_100
      UPDATE
      FROM VALUE #( ( PaymentRunID = ls_insert-payment_run_id text = lw_text PaymentRunDate = ls_data-PaymentRunDate PayingCompanyCode = ls_data-PayingCompanyCode
      paymentdocument = ls_data-PaymentDocument customer = ls_data-Customer supplier = ls_data-Supplier ) ).
      DATA(lw_run_date) = ls_data-PaymentRunDate+6(2) && '/' && ls_data-PaymentRunDate+4(2) && '/' && ls_data-PaymentRunDate(4).
      DATA(item_msg) = new_message( id = 'Z_MESSAGE_100'  " id = Name Of message class

                      number = '003' "number of message defined in the message class
                      severity = cl_abap_behv=>ms-success "type of message
                      v1 = ls_insert-payment_run_id  "First Parameter
                      v2 = lw_run_date          "Second Parameter
                      v3 = ls_insert-id           "Third Parameter
                      v4 = ls_insert-paying_company           "Fourth Parameter
                      ).
************************** Apeending the Message Response *********************************************************
      APPEND VALUE #( PayingCompanyCode = ls_insert-paying_company
       %msg = item_msg
       ) TO reported-zce_fis_send_payment_100.

    ENDLOOP.





  ENDMETHOD.

  METHOD get_instance_features.

    READ ENTITIES OF zce_fis_send_payment_100 IN LOCAL MODE
    ENTITY zce_fis_send_payment_100
    FIELDS (  PayingCompanyCode PaymentRunDate PaymentRunID Text PostingDate Status api_status created_by created_by_fullname )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_paymentlog).

    result = VALUE #( FOR <fs_key> IN lt_paymentlog ( %tky = <fs_key>-%tky
                                              %update = COND #( WHEN line_exists( lt_paymentlog[ api_status = 'Posted Successfully' ] )
                                                                THEN if_abap_behv=>fc-o-disabled
                                                                ELSE if_abap_behv=>fc-o-enabled )
                                              %features-%action-edit_text = COND #( WHEN <fs_key>-api_status = 'Posted Successfully'
                                                                            THEN if_abap_behv=>fc-o-disabled
                                                                            ELSE if_abap_behv=>fc-o-enabled )

                                              %features-%action-request_payment = COND #( WHEN <fs_key>-api_status = 'Posted Successfully'
                                                                            THEN if_abap_behv=>fc-o-disabled
                                                                            ELSE if_abap_behv=>fc-o-enabled )
                                                                 ) ).
  ENDMETHOD.

ENDCLASS.

CLASS lsc_ZCE_FIS_SEND_PAYMENT_100 DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS finalize REDEFINITION.

    METHODS check_before_save REDEFINITION.

    METHODS save REDEFINITION.

    METHODS cleanup REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_ZCE_FIS_SEND_PAYMENT_100 IMPLEMENTATION.

  METHOD finalize.
  ENDMETHOD.

  METHOD check_before_save.
  ENDMETHOD.

  METHOD save.
    zcl_save_payment=>save_data(  ).
  ENDMETHOD.

  METHOD cleanup.
    zcl_save_payment=>cleanup(  ).
  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.
