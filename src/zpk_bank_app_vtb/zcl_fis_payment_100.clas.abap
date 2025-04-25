CLASS zcl_fis_payment_100 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_rap_query_provider.

    TYPES: BEGIN OF ty_range_option,
             sign   TYPE c LENGTH 1,
             option TYPE c LENGTH 2,
             low    TYPE string,
             high   TYPE string,
           END OF ty_range_option,

           tt_ranges TYPE TABLE OF ty_range_option.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_FIS_PAYMENT_100 IMPLEMENTATION.


  METHOD if_rap_query_provider~select.
    DATA: lr_rundate      TYPE tt_ranges.

    IF io_request->is_data_requested( ).


      DATA(lv_search_string) = io_request->get_search_expression( ).
      DATA(lv_search_sql) = |PaymentRunDate LIKE '%{ cl_abap_dyn_prg=>escape_quotes( lv_search_string ) }%' OR PaymentRunID LIKE '%{ cl_abap_dyn_prg=>escape_quotes( lv_search_string ) }%'|.

*      DATA(lv_top)     = io_request->get_paging( )->get_page_size( ).

*      IF lv_top < 0 OR lv_top IS INITIAL.
*        lv_top = 999.
*      ENDIF.
                                                            "LZ3K901096
      DATA(ro_filter)         = io_request->get_filter( ).

      TRY.
          DATA(lr_ranges) = ro_filter->get_as_ranges( ).
        CATCH cx_rap_query_filter_no_range.
          "handle exception
      ENDTRY.

      LOOP AT lr_ranges INTO DATA(ls_ranges).
        CASE ls_ranges-name.
          WHEN 'PAYMENTRUNDATE'.
            MOVE-CORRESPONDING ls_ranges-range TO lr_rundate.
          WHEN OTHERS.

        ENDCASE.
      ENDLOOP.
      "End LZ3K901096

      DATA(lv_skip)    = io_request->get_paging( )->get_offset( ).

      DATA(lt_sort)    = io_request->get_sort_elements( ).

      DATA : lv_orderby TYPE string.
      LOOP AT lt_sort INTO DATA(ls_sort).
        IF ls_sort-descending = abap_true.
          lv_orderby = |'{ lv_orderby } { ls_sort-element_name } DESCENDING '|.
        ELSE.
          lv_orderby = |'{ lv_orderby } { ls_sort-element_name } ASCENDING '|.
        ENDIF.
      ENDLOOP.
      IF lv_orderby IS INITIAL.
        lv_orderby = 'PaymentRunDate'.
      ENDIF.

      DATA(lv_conditions) =  io_request->get_filter( )->get_as_sql_string( ).

      SELECT
      b~PaymentRunDate,b~PaymentRunID, b~PostingDate,b~PayingCompanyCode,a~text, a~status, b~AccountByShipper, b~PaymentDocument,
      b~payeepaymentsystem, b~payeealiastype, b~payeealiasname, a~created_by, a~created_by_fullname, a~message, a~api_status, a~json_body,
      b~paymentrunisproposal, b~supplier, b~customer, b~paymentrecipient, b~financialaccounttype, b~sendingcompanycode,
      b~businessarea, b~paymentreason, b~branchcode, b~directdebittype, b~paymentduedate, b~paymentrequestpaymentgroup, b~numberoftextlines,
      b~numberofpaiditems, b~companycodecountry,
      b~paymentmethod,b~paymentmethodsupplement, b~paymentreference, b~personnelnumber, b~paymentorder, b~valuedate,
           b~exchangerate,
           b~paymentsgroupingcriterion,
           b~paymentorigin,
           b~swifttransactionreferenceuuid,
           b~businessplace,
           b~accountingclerk,
           b~addressid,
           b~country,
           b~region,
           b~cityname,
           b~streetaddressname,
           b~postalcode,
           b~pobox,
           b~poboxpostalcode,
           b~poboxdeviatingcityname,
           b~organizationbpname1,
           b~organizationbpname2,
           b~organizationbpname3,
           b~organizationbpname4,
           b~bankcontrolkey,
           b~bankcountry,
           b~bank,
           b~bankinternalid,
           b~bankaccount,
           b~bankaccountlongid,
           b~iban,
           b~housebank,
           b~housebankaccount,
           b~payeetitle,
           b~payeelanguage,
           b~payeename,
           b~payeeadditionalname,
           b~payeecountry,
           b~payeeregion,
           b~payeecityname,
           b~payeedistrictname,
           b~payeestreet,
           b~payeepostalcode,
           b~payeepobox,
           b~payeepoboxpostalcode,
           b~payeebankcontrolkey,
           b~payeebankcountry,
           b~payeebank,
           b~payeebankkey,
           b~payeebankaccount,
           b~payeebankaccountlongid,
           b~payeesepasequencetype,
           b~payeesepamandateuuid,
           b~payeeiban,
           b~payeeswiftcode,
           b~payeebankdetailreference,
           b~payeebankaccountholdername,
           b~paymentcurrency,
           b~cashdiscountamountinpaytcrcy,
           b~paymentamountinpaytcurrency,
           b~lostcashdiscountinpaytcrcy,
           b~companycodecurrency,
           b~cashdiscountamtincocodecrcy,
           b~paytamountincocodecurrency,
           b~lostcashdiscountincocodecrcy,
           b~functionalcurrency,
           b~paymentamountinfunctionalcrcy,
           b~cashdiscountamountinfuncnlcrcy,
           b~additionalcurrency1,
           b~paymentamountinadditionalcrcy1,
           b~cashdiscountamtinaddlcrcy1,
           b~additionalcurrency2,
           b~paymentamountinadditionalcrcy2,
           b~cashdiscountamtinaddlcrcy2,
           b~edipaymentorderstatus,
           b~edipaymentadvicestatus, b~dataexchangeinstructionkey, b~dataexchangeinstruction1, b~dataexchangeinstruction2, b~dataexchangeinstruction3,
           b~dataexchangeinstruction4,b~billofexchangeissuedate, b~billofexchangeduedate, b~bankchainbank1type, b~bankchainbank1country, b~bankchainbank1,
           b~bankchainbank1bankaccount,b~bankchainbank1controlkey,b~bankchainbank1detailreference, b~bankchainbank1iban,b~bankchainbank2type,
           b~bankchainbank2country,b~bankchainbank2,b~bankchainbank2bankaccount,
           b~bankchainbank2controlkey,b~bankchainbank2detailreference, b~bankchainbank2iban, b~bankchainbank3type,b~bankchainbank3country,b~bankchainbank3,b~bankchainbank3bankaccount,
           b~bankchainbank3controlkey,b~bankchainbank3detailreference,b~bankchainbank3iban
      FROM ztb_fis_pm_100 AS a
      RIGHT OUTER JOIN I_PaymentProposalPayment AS b
      ON  a~payment_run_date = b~PaymentRunDate
      AND a~payment_run_id   = b~PaymentRunID
      AND a~paying_company = b~PayingCompanyCode
      AND a~paymentdocument = b~PaymentDocument
      AND a~customer = b~Customer
      AND a~supplier = b~Supplier
      WHERE b~PaymentRunIsProposal =  ''
      AND b~PaymentDocument      <> ''
      AND b~PaymentDocument      NOT LIKE 'F%'
      AND b~HouseBank LIKE 'VTB%'
      AND b~PayingCompanyCode = '6710'

      INTO TABLE @DATA(gt_data).

      CHECK gt_data IS NOT INITIAL.

      SELECT DocumentReferenceID, ClearingAccountingDocument
        FROM i_accountingdocumentjournal
        FOR ALL ENTRIES IN @gt_data
        WHERE ClearingAccountingDocument = @gt_data-PaymentDocument
        AND CompanyCode = @gt_data-PayingCompanyCode
*        AND FiscalYear = @gt_data-PostingDate+0(4)
" Thay đổi logic do Fiscalyear NE PostingDate+0(4)
        AND ClearingDate = @gt_data-PostingDate
        AND Ledger = '0L'
        AND accountingdocument <> @gt_data-PaymentDocument
        INTO TABLE @DATA(lt_document_reference).

      SELECT p~PaymentRunDate, p~PaymentRunID, p~PayingCompanyCode, i~AccountingDocument,
*      p~FiscalYear,
      i~fiscalyear,                                         "LZ3K901096
      i~AccountingDocCreatedByUser, i~IsReversed
*          FROM I_PaymentProposalItem AS p
          FROM I_PaymentProposalPayment AS p
          INNER JOIN I_JournalEntryItem AS i
          ON p~PaymentDocument = i~AccountingDocument
          AND p~PayingCompanyCode = i~CompanyCode
*          AND p~FiscalYear = i~FiscalYear "LZ3K901096
          AND p~PostingDate = i~PostingDate               "LZ3K901100
          FOR ALL ENTRIES IN @gt_data
          WHERE PaymentRunDate = @gt_data-PaymentRunDate
          AND PaymentRunID = @gt_data-PaymentRunID
          AND PayingCompanyCode = @gt_data-PayingCompanyCode
          AND IsReversed = ''
          AND p~PostingDate = @gt_data-PostingDate          "LZ3K901090
          INTO TABLE @DATA(gt_create_by).


      DATA: lw_check_initial TYPE abap_bool.

      LOOP AT gt_data ASSIGNING FIELD-SYMBOL(<fs_data>).

        lw_check_initial = abap_false.
        DATA(lw_payment_document) = <fs_data>-PaymentDocument.

        LOOP AT lt_document_reference INTO DATA(ls_document_reference)

        WHERE ClearingAccountingDocument = lw_payment_document .

          IF <fs_data>-text IS INITIAL.
            lw_check_initial = abap_true.
            <fs_data>-text = ls_document_reference-DocumentReferenceID.
          ENDIF.

          IF <fs_data>-text IS NOT INITIAL AND lw_check_initial = abap_true.
            FIND ls_document_reference-DocumentReferenceID IN <fs_data>-text.
            IF sy-subrc <> 0.
              <fs_data>-text = <fs_data>-text && `, ` && ls_document_reference-DocumentReferenceID.
            ENDIF.
          ENDIF.

        ENDLOOP.

        IF strlen( <fs_data>-text ) > 193.
          <fs_data>-text = <fs_data>-text(193).
        ENDIF.

        DATA(lv_index) = sy-tabix.
        IF <fs_data>-status IS INITIAL.
          <fs_data>-status = 'Payment Posted' .
        ENDIF.
        READ TABLE gt_create_by INTO DATA(ls_payment_item) WITH KEY PaymentRunDate = <fs_data>-PaymentRunDate
                                                                    PaymentRunID = <fs_data>-PaymentRunID
                                                                    PayingCompanyCode = <fs_data>-PayingCompanyCode
                                                                    AccountingDocument = <fs_data>-PaymentDocument.
        IF sy-subrc = 0.
          <fs_data>-created_by = ls_payment_item-AccountingDocCreatedByUser.
          SELECT SINGLE PersonFullName
          FROM I_BusinessPartner
          WHERE BusinessPartner = @<fs_data>-created_by+2(10)
          INTO @DATA(lw_name).
          IF sy-subrc = 0.
            <fs_data>-created_by_fullname = lw_name."lw_name-BusinessPartnerFullName.
          ENDIF.
        ELSE.
          DELETE gt_data INDEX lv_index.
        ENDIF.


      ENDLOOP.




      IF lv_search_string IS NOT INITIAL.
        lv_conditions = |( { lv_conditions } AND { lv_search_sql } )|.
      ENDIF.

      SELECT * FROM @gt_data AS a WHERE (lv_conditions)
       ORDER BY PaymentRunDate
       INTO TABLE @DATA(lt_filtered_data)
*       UP TO @lv_top ROWS OFFSET @lv_skip
       .

      "Bổ sung logic 16.01.2025
      DATA(paging)            = io_request->get_paging( ).
      DATA(page_size)         = io_request->get_paging( )->get_page_size( ).
      DATA(offset)            = io_request->get_paging( )->get_offset( ).

      IF page_size < 0.
        page_size = 50.
      ENDIF.

      DATA(max_rows) = COND #( WHEN page_size = if_rap_query_paging=>page_size_unlimited THEN 0
           ELSE page_size ).

      max_rows = page_size + offset.


      DATA: lt_filtered_data2  LIKE lt_filtered_data.

      LOOP AT lt_filtered_data INTO DATA(ls_filtered_data).
        IF sy-tabix > offset.
          IF sy-tabix > max_rows.
            EXIT.
          ELSE.
            APPEND ls_filtered_data TO lt_filtered_data2.
          ENDIF.
        ENDIF.
      ENDLOOP.

      IF io_request->is_total_numb_of_rec_requested( ).
        io_response->set_total_number_of_records( lines( lt_filtered_data ) ).
      ENDIF.

      IF io_request->is_data_requested( ).
        io_response->set_data( lt_filtered_data2 ).
      ENDIF.

*      IF io_request->is_total_numb_of_rec_requested(  ).
*        io_response->set_total_number_of_records( lines( lt_filtered_data ) ).
*        io_response->set_data( lt_filtered_data ).
*      ELSE.
*        io_response->set_data( lt_filtered_data ).
*        io_response->set_total_number_of_records( lines( lt_filtered_data ) ).
*      ENDIF.

    ENDIF.
  ENDMETHOD.
ENDCLASS.
