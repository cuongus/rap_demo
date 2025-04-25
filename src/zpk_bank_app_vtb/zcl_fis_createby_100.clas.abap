CLASS zcl_fis_createby_100 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_rap_query_provider .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_FIS_CREATEBY_100 IMPLEMENTATION.


  METHOD if_rap_query_provider~select.
    IF io_request->is_data_requested( ).


      DATA(lv_top)     = io_request->get_paging( )->get_page_size( ).
      IF lv_top < 0.
        lv_top = 1.
      ENDIF.

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
      SELECT FROM ztb_fis_pm_100 AS a
        RIGHT OUTER JOIN I_PaymentProposalPayment AS b ON  a~payment_run_date = b~PaymentRunDate
                                                   AND a~payment_run_id   = b~PaymentRunID
        FIELDS b~PaymentRunDate,b~PaymentRunID, b~PostingDate,b~PayingCompanyCode,a~text, a~status, b~AccountByShipper, b~PaymentDocument,
           a~created_by
        WHERE (lv_conditions) AND b~PaymentRunIsProposal =  ''
        AND b~PaymentDocument      <> ''
        AND b~PaymentDocument      NOT LIKE 'F%'
        AND b~HouseBank LIKE 'VTB%'
        AND b~PayingCompanyCode = '6710'
        ORDER BY (lv_orderby)
        INTO TABLE @DATA(gt_data).

      CHECK gt_data IS NOT INITIAL.

      SELECT p~PaymentRunDate, p~PaymentRunID, p~PayingCompanyCode, i~AccountingDocument, p~FiscalYear, i~AccountingDocCreatedByUser, i~IsReversed
      FROM I_PaymentProposalItem AS p
      INNER JOIN I_JournalEntryItem AS i
      ON p~PaymentDocument = i~AccountingDocument
      AND p~CompanyCode = i~CompanyCode
      AND p~FiscalYear = i~FiscalYear
      FOR ALL ENTRIES IN @gt_data
      WHERE PaymentRunDate = @gt_data-PaymentRunDate
      AND PaymentRunID = @gt_data-PaymentRunID
      AND PayingCompanyCode = @gt_data-PayingCompanyCode
      AND IsReversed = ''
      INTO TABLE @DATA(gt_payment_item).



      TYPES: BEGIN OF ty_create_by,
               user_id    TYPE c LENGTH 50,
               created_by TYPE c LENGTH 50,
             END OF ty_create_by.
      DATA: ls_created_by TYPE ty_create_by.
      DATA: lt_created_by TYPE TABLE OF ty_create_by.

      LOOP AT gt_data ASSIGNING FIELD-SYMBOL(<fs_data>).
        IF <fs_data>-status IS INITIAL.
          <fs_data>-status = 'Payment Posted' .
        ENDIF.
        READ TABLE gt_payment_item INTO DATA(ls_payment_item) WITH KEY PaymentRunDate = <fs_data>-PaymentRunDate
                                                                    PaymentRunID = <fs_data>-PaymentRunID
                                                                    PayingCompanyCode = <fs_data>-PayingCompanyCode
                                                                    AccountingDocument = <fs_data>-PaymentDocument.
        IF sy-subrc = 0.
          <fs_data>-created_by = ls_payment_item-AccountingDocCreatedByUser.
          ls_created_by-user_id = ls_payment_item-AccountingDocCreatedByUser.
          SELECT SINGLE PersonFullName
          FROM I_BusinessPartner
          WHERE BusinessPartner = @<fs_data>-created_by+2(10)
          INTO @DATA(lw_name).
          IF sy-subrc = 0.
            <fs_data>-created_by = lw_name."lw_name-BusinessPartnerFullName.
            ls_created_by-created_by = lw_name.
            APPEND ls_created_by TO lt_created_by.
            CLEAR ls_created_by.
          ENDIF.
        ENDIF.

      ENDLOOP.
      CLEAR: gt_data, gt_payment_item.

      SORT lt_created_by BY user_id created_by.
      DELETE ADJACENT DUPLICATES FROM lt_created_by.


      IF io_request->is_total_numb_of_rec_requested(  ).
        io_response->set_total_number_of_records( lines( lt_created_by ) ).
        io_response->set_data( lt_created_by ).
      ENDIF.

    ENDIF.
  ENDMETHOD.
ENDCLASS.
