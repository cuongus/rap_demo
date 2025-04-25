CLASS zcl_rap_inv_generate DEFINITION
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

           tt_ranges          TYPE TABLE OF ty_range_option,
           tt_rap_einv_header TYPE TABLE OF zrap_einv_entry,
           tt_rap_einv_items  TYPE TABLE OF zrap_einv_item,

           BEGIN OF ty_hrcond,
             field TYPE string,
             opera TYPE char2,
             low   TYPE string,
             high  TYPE string,
           END OF ty_hrcond,

           BEGIN OF ty_s_clause,
             line TYPE char72,
           END OF ty_s_clause,

           BEGIN OF ty_domain,
             low         TYPE string,
             description TYPE string,
           END OF ty_domain,

           tt_domain TYPE TABLE OF ty_domain,
           tt_hrcond TYPE TABLE OF ty_hrcond,
           tt_clause TYPE TABLE OF ty_s_clause.

    CLASS-DATA: mo_instance TYPE REF TO zcl_rap_inv_generate,
                gt_buyer    TYPE SORTED TABLE OF zst_e_customer_2 WITH UNIQUE KEY bcode.

    CLASS-METHODS:
      "Class Contructor
      get_Instance RETURNING VALUE(ro_instance) TYPE REF TO zcl_rap_inv_generate.

    "Custom Entities
    INTERFACES if_rap_query_provider.

    CLASS-METHODS: rh_dynamic_where_build CHANGING condtab      TYPE tt_hrcond
                                                   where_clause TYPE tt_clause,

      get_document_new IMPORTING ir_bukrs      TYPE tt_ranges
                                 ir_belnr      TYPE tt_ranges
                                 ir_gjahr      TYPE tt_ranges
                                 ir_buzei      TYPE tt_ranges OPTIONAL
                                 ir_monat      TYPE tt_ranges OPTIONAL
                                 ir_budat      TYPE tt_ranges OPTIONAL
                                 ir_bldat      TYPE tt_ranges OPTIONAL
                                 ir_kunnr      TYPE tt_ranges OPTIONAL
                                 ir_seq        TYPE tt_ranges OPTIONAL
                                 ir_serial     TYPE tt_ranges OPTIONAL
                                 ir_usertype   TYPE tt_ranges OPTIONAL
                                 ir_region     TYPE tt_ranges OPTIONAL
                                 ir_status_sap TYPE tt_ranges OPTIONAL
                                 page_size     TYPE int8 OPTIONAL
                                 offset        TYPE int8 OPTIONAL
                       EXPORTING header        TYPE tt_rap_einv_header
                                 items         TYPE tt_rap_einv_items
                                 set_header    TYPE tt_rap_einv_header
                                 set_items     TYPE tt_rap_einv_items,

      zget_buyer_new IMPORTING i_kunnr     TYPE zde_customer2
                               is_bseg     TYPE i_operationalacctgdocitem
                     EXPORTING es_customer TYPE zst_e_customer_2
                               es_return   TYPE bapiret2,

      get_region_text IMPORTING usertype   TYPE zde_usertype2
                                it_domain  TYPE tt_domain
                      EXPORTING regiontext TYPE char30.

  PROTECTED SECTION.
  PRIVATE SECTION.

ENDCLASS.



CLASS ZCL_RAP_INV_GENERATE IMPLEMENTATION.


  METHOD get_document_new.
    SELECT   a~companycode ,
             a~accountingdocument,
             a~fiscalyear,
             a~billingdocument,
             a~accountingdocumentitem,
             b~FiscalPeriod,
             a~postingdate,
             a~documentdate,
             b~AccountingDocumentCreationDate,
             a~financialaccounttype,
             a~accountingdocumenttype,
             a~postingkey,
             a~debitcreditcode,
             a~glaccount,
             a~customer,
             a~taxcode,
             a~product,
*             a~material,
*             a~documentitemtext,
*             a~baseunit,
*             a~quantity,
*             a~amountintransactioncurrency, "
*             a~amountincompanycodecurrency, "Local
             a~transactioncurrency,
*             a~PaymentMethod,
             c~seq,
             c~serial,
             c~form,
             b~absoluteexchangerate,
             b~reversedocument,
             b~reversedocumentfiscalyear,
             b~isreversal,
             b~isreversed
      FROM i_operationalacctgdocitem AS a
      INNER JOIN i_journalentry AS b
          ON  a~companycode = b~companycode
          AND a~accountingdocument = b~accountingdocument
          AND a~fiscalyear = b~fiscalyear
      LEFT OUTER JOIN zrap_einv_entry AS c
          ON  a~companycode = c~companycode
          AND a~accountingdocument = c~accountingdocument
          AND a~fiscalyear = c~fiscalyear
      WHERE a~CompanyCode IN @ir_bukrs
        AND a~AccountingDocument IN @ir_belnr
        AND a~FiscalYear IN @ir_gjahr
        AND a~FiscalPeriod IN @ir_monat
        AND a~PostingDate IN @ir_budat
        AND a~DocumentDate IN @ir_bldat
        AND a~Customer IN @ir_kunnr
        AND a~AccountingDocument NOT IN ( SELECT Accountingdocument FROM zrap_inv_delete WHERE companycode IN @ir_bukrs AND fiscalyear IN @ir_gjahr )
        AND a~FiscalYear IN @ir_gjahr
*        AND a~glaccount NOT LIKE '333%'
        AND a~GLAccount NE '0022000000'
        AND a~FinancialAccountType = 'D'
  "Trường hợp chứng từ huỷ chưa phát hành hoá đơn ko lấy lên
        AND b~IsReversal NE 'X' "--> "Loại chứng từ huỷ
        AND ( ( b~IsReversed NE 'X' ) "--> "Loại bỏ chứng từ gốc đã huỷ
  "Trường hợp huỷ chứng từ sau khi đã phát hành hoá đơn vẫn lấy lên
        OR ( b~IsReversed EQ 'X' AND c~seq NE '' ) )
        AND ( a~taxcode LIKE 'O%'
          OR a~taxcode = '**' )
      ORDER BY a~companycode, a~accountingdocument, a~fiscalyear
      INTO TABLE @DATA(lt_bkpf)
*      UP TO @iv_top ROWS OFFSET @iv_skip
      .

    "Log data EInvoice
    SELECT * FROM zrap_einv_entry
    WHERE companycode IN @ir_bukrs
      AND fiscalyear IN @ir_gjahr
      AND accountingdocument IN @ir_belnr
      AND customer IN @ir_kunnr
    INTO TABLE @DATA(lt_einv_header).

    SORT lt_bkpf BY CompanyCode AccountingDocument FiscalYear ASCENDING.

    CHECK lt_bkpf IS NOT INITIAL.

    SELECT a~companycode ,
           a~accountingdocument,
           a~fiscalyear,
           a~billingdocument,
           a~accountingdocumentitem,
           a~postingdate,
           a~documentdate,
           a~financialaccounttype,
           a~accountingdocumenttype,
           a~postingkey,
           a~debitcreditcode,
           a~glaccount,
           a~customer,
           a~taxcode,
           a~product,
           a~material,
           a~documentitemtext,
           a~baseunit,
           a~quantity,
           a~amountintransactioncurrency, "
           a~amountincompanycodecurrency, "Local
           a~transactioncurrency,
           a~PaymentMethod
*             c~seq,
*             c~serial,
*             c~form,
*             b~absoluteexchangerate,
*             b~reversedocument,
*             b~reversedocumentfiscalyear,
*             b~isreversal,
*             b~isreversed
    FROM i_operationalacctgdocitem AS a
    FOR ALL ENTRIES IN @lt_bkpf
*    WHERE a~companycode IN @ir_bukrs
*      AND a~accountingdocument IN @ir_belnr
*      AND a~fiscalyear IN @ir_gjahr
    WHERE a~companycode = @lt_bkpf-CompanyCode
      AND a~accountingdocument = @lt_bkpf-AccountingDocument
      AND a~fiscalyear = @lt_bkpf-FiscalYear
      AND a~AccountingDocument NOT IN ( SELECT Accountingdocument FROM zrap_inv_delete WHERE companycode IN @ir_bukrs AND fiscalyear IN @ir_gjahr )
*        AND a~GLAccount NOT LIKE '333%'
      AND a~GLAccount NE '0022000000'
      AND a~FinancialAccountType = 'S'
      AND a~TaxCode IS NOT INITIAL
    INTO TABLE @DATA(lt_bseg).

    TYPES: BEGIN OF lty_sum_vat,
             companycode        TYPE bukrs,
             accountingdocument TYPE belnr_d,
             fiscalyear         TYPE gjahr,
             taxcode            TYPE zde_taxcode,
             DebitCreditCode    TYPE shkzg,
             currency           TYPE waers,
             sum_vat            TYPE zde_e_amount2,
             sum_vatv           TYPE zde_e_amount2,
           END OF lty_sum_vat.

    DATA: lt_sum_vat      TYPE TABLE OF lty_sum_vat,
          lt_sum_vat_temp TYPE TABLE OF lty_sum_vat.

    SELECT companycode,
           accountingdocument,
           fiscalyear,
           taxcode,
           DebitCreditCode,
           TransactionCurrency AS currency,
           amountintransactioncurrency  AS sum_vat, "
           amountincompanycodecurrency  AS sum_vatv "Local
      FROM i_operationalacctgdocitem
      WHERE companycode IN @ir_bukrs
        AND accountingdocument IN @ir_belnr
        AND fiscalyear IN @ir_gjahr
*          AND glaccount LIKE '333%'
        AND GLAccount EQ '0022000000'
        AND ( taxcode LIKE 'O%' OR taxcode = '**' )
        INTO CORRESPONDING FIELDS OF TABLE @lt_sum_vat
        .

    SORT lt_einv_header BY companycode accountingdocument fiscalyear ASCENDING.
    SORT lt_bseg BY CompanyCode AccountingDocument fiscalyear AccountingDocumentItem ASCENDING.

    DATA: lv_index         TYPE int4 VALUE IS INITIAL,
          lv_flag          TYPE int4 VALUE IS INITIAL,
          lv_PaymentMethod TYPE zde_epaym VALUE IS INITIAL,
          lv_count         TYPE int4 VALUE IS INITIAL.

    "Customer Details
    DATA: ex_customer  TYPE zst_e_customer_2,
          ex_return    TYPE bapiret2,
          im_bseg      TYPE i_operationalacctgdocitem,
          lv_mwskz_old TYPE zde_taxcode,
          flag_mwskz   TYPE char1.

    DATA: lt_einv_log  TYPE TABLE OF zrap_einv_entry,
          ls_einv_log  TYPE zrap_einv_entry,

          lt_einv_line TYPE TABLE OF zrap_einv_item,
          ls_einv_line TYPE zrap_einv_item.

    CLEAR: lv_count.

    CAST cl_abap_elemdescr( cl_abap_typedescr=>describe_by_name( 'ZDE_EREGION' ) )->get_ddic_fixed_values(
      EXPORTING
        p_langu        = sy-langu
      RECEIVING
        p_fixed_values = DATA(fixed_values)
      EXCEPTIONS
        not_found      = 1
        no_ddic_type   = 2
        OTHERS         = 3 ).

    DATA: lt_domain TYPE tt_domain.
    FREE: lt_domain.

    LOOP AT fixed_values INTO DATA(ls_fixed_values).
      APPEND VALUE #( low = ls_fixed_values-low description = ls_fixed_values-ddtext ) TO lt_domain.
    ENDLOOP.

    LOOP AT lt_bkpf INTO DATA(ls_bkpf).

      SELECT SINGLE ProfitCenter FROM i_operationalacctgdocitem
        WHERE CompanyCode = @ls_bkpf-companycode
        AND AccountingDocument = @ls_bkpf-accountingdocument
        AND FiscalYear = @ls_bkpf-fiscalyear
        AND ProfitCenter NE ''
        INTO @DATA(lv_prctr).
      IF sy-subrc NE 0.
        CLEAR: lv_prctr.
      ENDIF.

      IF lv_prctr IS INITIAL.
        CONTINUE.
      ENDIF.

      IF lv_prctr+0(1) = 'A'.
        CASE lv_prctr+6(1).
          WHEN 'A'.
            ls_einv_log-region = '1'. "Hà Nội
          WHEN 'B'.
            ls_einv_log-region = '2'. "Hồ Chí Minh
          WHEN OTHERS.
        ENDCASE.
      ELSEIF lv_prctr+0(1) = 'B' AND strlen( lv_prctr ) = 9.
        CASE lv_prctr+8(1).
          WHEN 'A'.
            ls_einv_log-region = '1'. "Hà Nội
          WHEN 'B'.
            ls_einv_log-region = '2'. "Hồ Chí Minh
          WHEN OTHERS.
        ENDCASE.
      ELSEIF lv_prctr+0(1) = 'B' AND strlen( lv_prctr ) = 10.
        CASE lv_prctr+9(1).
          WHEN 'A'.
            ls_einv_log-region = '1'. "Hà Nội
          WHEN 'B'.
            ls_einv_log-region = '2'. "Hồ Chí Minh
          WHEN OTHERS.
        ENDCASE.
      ENDIF.

      IF ls_einv_log-region NOT IN ir_region.
        CLEAR: ls_einv_log.
        CONTINUE.
      ENDIF.

      zcl_rap_inv_generate=>get_instance( )->get_region_text(
        EXPORTING
        usertype = ls_einv_log-region
        it_domain = lt_domain
        IMPORTING
        regiontext = ls_einv_log-regiontext
        ).

      ls_einv_log-profitcenter = lv_prctr.

      READ TABLE lt_bseg TRANSPORTING NO FIELDS WITH KEY CompanyCode = ls_bkpf-CompanyCode
                                                         AccountingDocument = ls_bkpf-AccountingDocument
                                                         FiscalYear = ls_bkpf-FiscalYear BINARY SEARCH.
      IF sy-subrc EQ 0.
        lv_index = sy-tabix.
        LOOP AT lt_bseg INTO DATA(ls_bseg) FROM lv_index.
          CLEAR: ls_einv_line.
          IF ls_bseg-CompanyCode EQ ls_bkpf-CompanyCode AND
            ls_bseg-AccountingDocument EQ ls_bkpf-AccountingDocument AND
            ls_bseg-FiscalYear EQ ls_bkpf-FiscalYear .

            lv_count = lv_count + 1.
            "Buzei
            ls_einv_line-buzei = lv_count.
            "Company code
            ls_einv_line-companycode = ls_bseg-companycode.
            "Document Acounting
            ls_einv_line-accountingdocument = ls_bseg-accountingdocument.
            "Fiscal Year
            ls_einv_line-fiscalyear = ls_bseg-fiscalyear.
            "Material
            ls_einv_line-material = ls_bseg-product.
            "Tên hàng hoá
*            DATA: lv_tdobject TYPE tdobject,
*                  lv_tdname   TYPE tdobname,
*                  lv_tdid     TYPE tdid.
*            DATA: lt_text TYPE STANDARD TABLE OF tdline.
*
*            cf_reca_text=>find( id_tdobject  = lv_tdobject
*                                id_tdname    = lv_tdname
*                                id_tdid      = lv_tdid )->get_text_as_stream( IMPORTING et_text = lt_text ).
            TYPES: BEGIN OF ty_tline,
                     tdformat TYPE char2,
                     tdline   TYPE zde_char132_2,
                   END OF ty_tline.

            DATA: tt_lines TYPE TABLE OF ty_TLINE.
            DATA:
              BEGIN OF l_stxl_id,
                tdobject TYPE char10,
                tdname   TYPE char70,
                tdid     TYPE char4,
                tdspras  TYPE char1,
              END OF l_stxl_id.

*   Read normal table
*            IMPORT tline TO tt_lines
*              FROM DATABASE stxl(tx)                   "#EC DBACCESS_OK
*                   CLIENT   sy-mandt
*                   ID       l_stxl_id
*                   ACCEPTING TRUNCATION                     "important for Unicode->Nonunicode
*                   IGNORING CONVERSION ERRORS.
            TRY.
                SELECT SINGLE yy1_longtext_cob FROM i_glaccountlineitem
                WHERE CompanyCode = @ls_bseg-CompanyCode
                  AND AccountingDocument = @ls_bseg-AccountingDocument
                  AND FiscalYear = @ls_bseg-FiscalYear
                  AND AccountingDocumentItem = @ls_bseg-AccountingDocumentItem
                INTO @DATA(lv_longtext).
                IF sy-subrc EQ 0.
                  ls_einv_line-itemname = lv_longtext.
                ELSE.
                  CLEAR: lv_longtext.
                ENDIF.
              CATCH cx_root.
                CLEAR: lv_longtext.
            ENDTRY.

            IF lv_longtext IS INITIAL.
              ls_einv_line-itemname = ls_bseg-documentitemtext.
            ENDIF.
            "Quantiy
            ls_einv_line-quantity = ls_bseg-quantity.
            "Đơn vị
            ls_einv_line-baseunit = ls_bseg-baseunit.
            "Đơn vị text
            SELECT SINGLE unitofmeasurelongname FROM i_unitofmeasuretext
            WHERE unitofmeasure = @ls_bseg-baseunit INTO @ls_einv_line-unittext.
            "Taxcode
            IF lv_mwskz_old IS NOT INITIAL AND lv_mwskz_old NE ls_bseg-taxcode.
              ls_einv_log-taxcode = 'Nhiều loại'.
              flag_mwskz = 'X'.
            ELSE.
              ls_einv_log-taxcode = ls_bseg-taxcode.
            ENDIF.

            "Currency
            ls_einv_line-currency = ls_bseg-transactioncurrency.

            ls_einv_line-taxcode = ls_bseg-taxcode.
            lv_mwskz_old = ls_bseg-taxcode.

            CASE ls_bseg-taxcode.
              WHEN 'O1'.
                ls_einv_line-taxpercentage = 0.
              WHEN 'O2'.
                ls_einv_line-taxpercentage = 5.
              WHEN 'O3'.
                ls_einv_line-taxpercentage = 8.
              WHEN 'O4'.
                ls_einv_line-taxpercentage = 10.
*              WHEN 'ON'.
*                ls_einv_line-taxpercentage = -2.
*              WHEN 'OX'.
*                ls_einv_line-taxpercentage = -1.
              WHEN OTHERS.
            ENDCASE.

            ls_bseg-amountintransactioncurrency = ls_bseg-amountintransactioncurrency * ( -1 ).
            ls_bseg-amountincompanycodecurrency = ls_bseg-amountincompanycodecurrency * ( -1 ).
            "Amount
            "VAT
            IF ls_bseg-TransactionCurrency = 'VND'.
              ls_einv_line-amount  = ls_bseg-amountintransactioncurrency * 100.
              ls_einv_line-vat   = round( val = ls_bseg-amountintransactioncurrency * 100 * ls_einv_line-taxpercentage / 100 dec = 0 ).
            ELSE.
              IF ls_bseg-TransactionCurrency = 'USD' OR ls_bseg-TransactionCurrency = 'EUR' OR ls_bseg-TransactionCurrency = 'GBP'.
                ls_einv_line-amount  = ls_bseg-amountintransactioncurrency.
                ls_einv_line-vat   = ls_bseg-amountintransactioncurrency * ls_einv_line-taxpercentage / 100 .
              ELSE.
                ls_einv_line-amount  = ls_bseg-amountintransactioncurrency * 100.
                ls_einv_line-vat   = ls_bseg-amountintransactioncurrency * 100 * ls_einv_line-taxpercentage / 100 .
              ENDIF.
            ENDIF.
            "Total
            ls_einv_line-total   = ls_einv_line-amount + ls_einv_line-vat.

            "Amount Local
            ls_einv_line-amountv = ls_bseg-amountincompanycodecurrency * 100.
            "VAT Local
            IF ls_bseg-TransactionCurrency = 'VND'.
              ls_einv_line-vatv  = round( val = ls_bseg-amountincompanycodecurrency * 100 * ls_einv_line-taxpercentage / 100 dec = 0 ).
            ELSE.
              ls_einv_line-vatv  = ls_bseg-amountincompanycodecurrency * 100 * ls_einv_line-taxpercentage / 100 .
            ENDIF.
            "Total Local
            ls_einv_line-totalv   = ls_einv_line-amountv + ls_einv_line-vatv.

            IF ls_bseg-Quantity NE 0.
              "Price
              ls_einv_line-price = ls_einv_line-amount / ls_bseg-Quantity.
              "Price Local
              ls_einv_line-pricev = ls_einv_line-amountv / ls_bseg-Quantity.
            ENDIF.

            APPEND ls_einv_line TO lt_einv_line.

            "Process Total Document
            "sid
            ls_einv_log-sid = |{ sy-sysid }{ sy-mandt }{ ls_bkpf-CompanyCode }{ ls_bkpf-AccountingDocument }{ ls_bkpf-FiscalYear }|.
            "Company code
            ls_einv_log-companycode = ls_bseg-companycode.
            "Document Acounting
            ls_einv_log-accountingdocument = ls_bseg-accountingdocument.
            "Fiscal Year
            ls_einv_log-fiscalyear = ls_bseg-fiscalyear.
            "FiscalPeriod
            ls_einv_log-FiscalPeriod = ls_bkpf-FiscalPeriod.
            "Budat
            ls_einv_log-postingdate = ls_bseg-postingdate.
            "Document Date
            ls_einv_log-documentdate = ls_bseg-documentdate.
            "Entry date
            ls_einv_log-entrydate = ls_bkpf-AccountingDocumentCreationDate.
            "Doc type
            ls_einv_log-doctype = ls_bseg-accountingdocumenttype.
            "Exchange rate
            IF ls_bseg-TransactionCurrency = 'VND'.
              ls_einv_log-exchangerate = 1.
            ELSE.
              IF ls_bseg-TransactionCurrency = 'USD' OR ls_bseg-TransactionCurrency = 'EUR' OR ls_bseg-TransactionCurrency = 'GBP'.
                ls_einv_log-exchangerate = ls_bkpf-absoluteexchangerate * 1000.
              ELSE.
                ls_einv_log-exchangerate = ls_bkpf-absoluteexchangerate .
              ENDIF.
            ENDIF.
            ls_einv_log-timeiss = '090000'.
            "Currency
            ls_einv_log-currency = ls_bseg-transactioncurrency.
            "Customer
            CLEAR: im_bseg.
            im_bseg-companycode = ls_bseg-companycode.
            im_bseg-accountingdocument = ls_bseg-accountingdocument.
            im_bseg-fiscalyear = ls_bseg-fiscalyear.

            "Amount
            ls_einv_log-amount  = ls_einv_log-amount + ls_einv_line-amount.
            "VAT
            ls_einv_log-vat     = ls_einv_log-vat + ls_einv_line-vat.
            "Total
            ls_einv_log-total   = ls_einv_log-total + ls_einv_line-amount + ls_einv_line-vat.
            "Amount Local
            ls_einv_log-amountv = ls_einv_log-amountv + ls_einv_line-amountv.
            "VAT Local
            ls_einv_log-vatv    = ls_einv_log-vatv + ls_einv_line-vatv.
            "Total Local
            ls_einv_log-totalv   = ls_einv_log-totalv + ls_einv_line-amountv + ls_einv_line-vatv.

          ELSE.
            EXIT.
          ENDIF.
        ENDLOOP.
        "Header Log
        IF ls_bkpf-Customer IS NOT INITIAL.
          zcl_rap_inv_generate=>get_Instance( )->zget_buyer_new(
            EXPORTING
              i_kunnr     = ls_bkpf-Customer
              is_bseg     = im_bseg
            IMPORTING
              es_customer = ex_customer
              es_return   = ex_return
          ).
        ENDIF.

        IF ls_bseg-Customer IS NOT INITIAL.
          ls_einv_log-documentitem = ls_bseg-AccountingDocumentItem.
        ENDIF.

        ls_einv_log-customer = ls_bkpf-customer.
        ls_einv_log-bname    = ex_customer-bname.
        ls_einv_log-baddr    = ex_customer-baddr.
        ls_einv_log-btax     = ex_customer-btax.
        ls_einv_log-bmail    = ex_customer-bmail.
        ls_einv_log-btel     = ex_customer-btel.

        "Flag reverse document
        ls_einv_log-stblg      = ls_bkpf-reversedocument.
        ls_einv_log-stjah      = ls_bkpf-reversedocumentfiscalyear.
        ls_einv_log-xreversing = ls_bkpf-isreversal.
        ls_einv_log-xreversed  = ls_bkpf-isreversed.

        "
        SELECT SINGLE PaymentMethod FROM i_operationalacctgdocitem
        WHERE CompanyCode = @ls_bkpf-CompanyCode
          AND AccountingDocument = @ls_bkpf-AccountingDocument
          AND FiscalYear = @ls_bkpf-FiscalYear
          AND PaymentMethod NE ''
          INTO @lv_PaymentMethod
            .

        READ TABLE lt_einv_header INTO DATA(ls_einv_header) WITH KEY CompanyCode = ls_bkpf-CompanyCode
                                                         AccountingDocument = ls_bkpf-AccountingDocument
                                                         FiscalYear = ls_bkpf-FiscalYear BINARY SEARCH.
        IF sy-subrc EQ 0.
          ls_einv_log-Statussap         = ls_einv_header-statussap.
          ls_einv_log-Statusinv         = ls_einv_header-statusinv.
          ls_einv_log-Statuscqt         = ls_einv_header-statuscqt.
          ls_einv_log-seq               = ls_einv_header-seq.
          ls_einv_log-Serial            = ls_einv_header-serial.
          ls_einv_log-Form              = ls_einv_header-form.
          ls_einv_log-Etype             = ls_einv_header-etype.

          ls_einv_log-Usertype          = ls_einv_header-usertype.
          ls_einv_log-regiontext        = ls_einv_header-regiontext.

          ls_einv_log-Dateint           = ls_einv_header-dateint.
          ls_einv_log-Dateiss           = ls_einv_header-dateiss.
          ls_einv_log-Timeiss           = ls_einv_header-timeiss.
          ls_einv_log-Datecanc          = ls_einv_header-datecanc.
          ls_einv_log-Msgty             = ls_einv_header-msgty.
          ls_einv_log-Msgtx             = ls_einv_header-msgtx.
          ls_einv_log-Mscqt             = ls_einv_header-mscqt.
          ls_einv_log-Link              = ls_einv_header-link.
          ls_einv_log-paym              = ls_einv_header-paym.

          ls_einv_log-invdat            = ls_einv_header-invdat.

          ls_einv_log-belnrsrc          = ls_einv_header-belnrsrc.
          ls_einv_log-gjahrsrc          = ls_einv_header-gjahrsrc.
          ls_einv_log-adjtype           = ls_einv_header-adjtype.
          ls_einv_log-adjtext           = ls_einv_header-adjtext.

          ls_einv_log-datetype          = ls_einv_header-datetype.

*          IF ls_einv_header-statussap EQ '03'.
*
*          ENDIF.
        ELSE.
          ls_einv_log-iconsap = '0'. "Neutral-Grey
          ls_einv_log-Statussap = '01'.
          ls_einv_log-Timeiss   = '090000'.
          "PaymentMethod
          ls_einv_log-Paym = lv_PaymentMethod.
        ENDIF.

        CASE ls_einv_log-statussap.
          WHEN '01' OR '03'.
            "PaymentMethod
            ls_einv_log-Paym = lv_PaymentMethod.
            ls_einv_log-Timeiss   = '090000'.
          WHEN OTHERS.
        ENDCASE.

        IF lv_count NE 0.
          APPEND ls_einv_log TO lt_einv_log.
        ENDIF.
        CLEAR: ls_einv_log.
        CLEAR: lv_mwskz_old, lv_paymentmethod, lv_count.
      ENDIF.
      CLEAR: lv_index.
    ENDLOOP.

    lt_sum_vat_temp = lt_sum_vat.

    FREE: lt_sum_vat.
    LOOP AT lt_sum_vat_temp INTO DATA(ls_sum_vat).
      IF ls_sum_vat-currency = 'USD' OR ls_sum_vat-currency = 'EUR' OR ls_sum_vat-currency = 'GBP'.
        ls_sum_vat-sum_vat = ls_sum_vat-sum_vat * ( -1 ) .
      ELSE.
        ls_sum_vat-sum_vat = ls_sum_vat-sum_vat * ( -1 ) * 100.
      ENDIF.
      ls_sum_vat-sum_vatv = ls_sum_vat-sum_vatv * ( -1 ) * 100.
      COLLECT ls_sum_vat INTO lt_sum_vat.
    ENDLOOP.

    SORT lt_sum_vat BY companycode accountingdocument fiscalyear taxcode ASCENDING.

    TYPES: BEGIN OF lty_line_temp,
             companycode        TYPE bukrs,
             accountingdocument TYPE belnr_d,
             fiscalyear         TYPE gjahr,
             taxcode            TYPE zde_taxcode,
             buzei              TYPE buzei,
             material           TYPE zde_matnr2,
             itemname           TYPE zde_itemname,
             noted              TYPE zde_noted2,
             taxpercentage      TYPE zde_taxperc,
             quantity           TYPE zde_menge2,
             baseunit           TYPE meins,
             unittext           TYPE zde_msehl2,
             price              TYPE zde_e_amount2,
             currency           TYPE waers,
             amount             TYPE zde_e_amount2,
             vat                TYPE zde_e_amount2,
             total              TYPE zde_e_amount2,
             pricev             TYPE zde_e_amount2,
             amountv            TYPE zde_e_amount2,
             vatv               TYPE zde_e_amount2,
             totalv             TYPE zde_e_amount2,
           END OF lty_line_temp.

    DATA: lt_line_temp TYPE TABLE OF lty_line_temp,
          ls_line_temp TYPE lty_line_temp.

    DATA: lv_cl_vat  TYPE zde_e_amount2,
          lv_cl_vatv TYPE zde_e_amount2.

    MOVE-CORRESPONDING lt_einv_line TO lt_line_temp.

    SORT lt_line_temp BY companycode accountingdocument fiscalyear taxcode buzei ASCENDING.

    LOOP AT lt_line_temp INTO DATA(ls_templine).
      lv_index = sy-tabix.
      MOVE-CORRESPONDING ls_templine TO ls_line_temp.
      lv_cl_vat = lv_cl_vat + ls_line_temp-vat.
      lv_cl_vatv = lv_cl_vatv + ls_line_temp-vatv.

      AT END OF taxcode.
        READ TABLE lt_sum_vat INTO ls_sum_vat WITH KEY CompanyCode = ls_line_temp-CompanyCode
                                                       AccountingDocument = ls_line_temp-AccountingDocument
                                                       FiscalYear = ls_line_temp-FiscalYear
                                                       taxcode = ls_line_temp-taxcode BINARY SEARCH.
        IF sy-subrc EQ 0.
          IF ls_sum_vat-sum_vat NE 0.
            ls_line_temp-vat = ls_line_temp-vat + ls_sum_vat-sum_vat - lv_cl_vat.
            ls_line_temp-total = ls_line_temp-amount + ls_line_temp-vat.
          ENDIF.
          IF ls_sum_vat-sum_vatv NE 0.
            ls_line_temp-vatv = ls_line_temp-vatv + ls_sum_vat-sum_vatv - lv_cl_vatv.
            ls_line_temp-totalv = ls_line_temp-amountv + ls_line_temp-vatv.
          ENDIF.

          READ TABLE lt_einv_log ASSIGNING FIELD-SYMBOL(<lfs_einv_log>)
          WITH KEY CompanyCode = ls_line_temp-CompanyCode
          AccountingDocument = ls_line_temp-AccountingDocument
          FiscalYear = ls_line_temp-FiscalYear BINARY SEARCH.
          IF sy-subrc EQ 0.
            IF ls_sum_vat-sum_vat NE 0.
              <lfs_einv_log>-vat = <lfs_einv_log>-vat + ls_sum_vat-sum_vat - lv_cl_vat.
              <lfs_einv_log>-total = <lfs_einv_log>-amount + <lfs_einv_log>-vat.
            ENDIF.
            IF ls_sum_vat-sum_vatv NE 0.
              <lfs_einv_log>-vatv = <lfs_einv_log>-vatv + ls_sum_vat-sum_vatv - lv_cl_vatv.
              <lfs_einv_log>-totalv = <lfs_einv_log>-amountv + <lfs_einv_log>-vatv.
            ENDIF.
          ENDIF.
        ENDIF.

        MODIFY lt_line_temp FROM ls_line_temp INDEX lv_index.
        CLEAR: lv_cl_vat, lv_cl_vatv, ls_line_temp.
      ENDAT.
    ENDLOOP.

    CLEAR: lv_index.

    IF ir_status_sap[] IS NOT INITIAL.
      DELETE lt_einv_log WHERE statussap NOT IN ir_status_sap.
    ENDIF.
    IF ir_seq[] IS NOT INITIAL.
      DELETE lt_einv_log WHERE seq NOT IN ir_seq.
    ENDIF.

    FREE: lt_einv_line.
    MOVE-CORRESPONDING lt_line_temp TO lt_einv_line.

    SORT lt_einv_line BY Companycode Accountingdocument Fiscalyear Buzei ASCENDING.

    SORT lt_einv_line BY companycode accountingdocument fiscalyear ASCENDING.

    MOVE-CORRESPONDING lt_einv_log TO header.
    MOVE-CORRESPONDING lt_einv_line TO items.

    IF ir_buzei[] IS NOT INITIAL.
      DELETE items WHERE buzei NOT IN ir_buzei.
    ENDIF.
  ENDMETHOD.


  METHOD get_instance. "Class Contructor
    mo_instance = ro_instance = COND #( WHEN mo_instance IS BOUND
                                           THEN mo_instance
                                           ELSE NEW #( ) ).
  ENDMETHOD.


  METHOD get_region_text.
    READ TABLE it_domain INTO DATA(ls_domain) WITH KEY low = usertype.
    IF sy-subrc EQ 0.
      regiontext = ls_domain-description.
    ELSE.
      CLEAR: regiontext.
    ENDIF.
  ENDMETHOD.


  METHOD if_rap_query_provider~select.

    DATA: lr_bukrs      TYPE tt_ranges,
          lr_belnr      TYPE tt_ranges,
          lr_gjahr      TYPE tt_ranges,
          lr_budat      TYPE tt_ranges,
          lr_bldat      TYPE tt_ranges,
          lr_buzei      TYPE tt_ranges,
          lr_kunnr      TYPE tt_ranges,
          lr_seq        TYPE tt_ranges,
          lr_serial     TYPE tt_ranges,
          lr_status_sap TYPE tt_ranges,
          lr_usertype   TYPE tt_ranges,
          lr_monat      TYPE tt_ranges,
          lr_region     TYPE tt_ranges.

    DATA: lt_eheader TYPE TABLE OF zrap_einv_entry,
          lt_eitems  TYPE TABLE OF zrap_einv_item.

    DATA: lv_error_authorization TYPE char1 VALUE IS INITIAL.
    CLEAR: lv_error_authorization.

    mo_instance = NEW #(  ).

    TRY.
        IF io_request->is_data_requested( ).

          DATA(paging)            = io_request->get_paging( ).
          DATA(page_size)         = io_request->get_paging( )->get_page_size( ).
          DATA(offset)            = io_request->get_paging( )->get_offset( ).
          DATA(requested_fields)  = io_request->get_requested_elements( ).
          DATA(sort_order)        = io_request->get_sort_elements( ).
          DATA(ro_filter)         = io_request->get_filter( ).
          DATA(lv_entity_id)      = io_request->get_entity_id( ).

          FREE: lr_bukrs, lr_belnr, lr_gjahr.

*          data: lo_ref type ref to lcl_rap_query_paging.
*          lo_ref ?= lv_page.
*          ASSIGN lo_ref->('MV_HAS_PAGING') to FIELD-SYMBOL(<lfs_attr>).
*          <lfs_attr> = abap_false.

          TRY.
              DATA(lr_ranges) = ro_filter->get_as_ranges( ).
            CATCH cx_rap_query_filter_no_range.
              "handle exception
          ENDTRY.

          LOOP AT lr_ranges INTO DATA(ls_ranges).
            CASE ls_ranges-name.
              WHEN 'COMPANYCODE'.
*            MOVE-CORRESPONDING ls_ranges-range TO lr_bukrs.
              WHEN 'ACCOUNTINGDOCUMENT'.
                MOVE-CORRESPONDING ls_ranges-range TO lr_belnr.
              WHEN 'FISCALYEAR'.
                MOVE-CORRESPONDING ls_ranges-range TO lr_gjahr.
              WHEN 'BUZEI'.
                MOVE-CORRESPONDING ls_ranges-range TO lr_buzei.
              WHEN 'POSTINGDATE'.
                MOVE-CORRESPONDING ls_ranges-range TO lr_budat.
              WHEN 'DOCUMENTDATE'.
                MOVE-CORRESPONDING ls_ranges-range TO lr_bldat.
              WHEN 'CUSTOMER'.
                MOVE-CORRESPONDING ls_ranges-range TO lr_kunnr.
              WHEN 'USERTYPE'.
                MOVE-CORRESPONDING ls_ranges-range TO lr_usertype.
              WHEN 'FISCALPERIOD'.
                MOVE-CORRESPONDING ls_ranges-range TO lr_monat.
              WHEN 'STATUSSAP'.
                MOVE-CORRESPONDING ls_ranges-range TO lr_status_sap.
              WHEN 'SEQ'.
                MOVE-CORRESPONDING ls_ranges-range TO lr_seq.
              WHEN 'SERIAL'.
                MOVE-CORRESPONDING ls_ranges-range TO lr_serial.
              WHEN 'REGION'.
                MOVE-CORRESPONDING ls_ranges-range TO lr_region.
              WHEN OTHERS.
            ENDCASE.
          ENDLOOP.

          DATA: lv_usertype TYPE zde_usertype2.
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

          DATA(max_rows) = COND #( WHEN page_size = if_rap_query_paging=>page_size_unlimited THEN 0
                     ELSE page_size ).

          max_rows = page_size + offset.

          CHECK lv_error_authorization IS INITIAL.

          APPEND VALUE #( sign = 'I' option = 'EQ' low = '6710' ) TO lr_bukrs.

          CASE lv_entity_id.
            WHEN 'ZCS_RAP_EINV_ENTRY' OR 'ZCS_JSON_EINV_HEADER'.
              zcl_rap_inv_generate=>get_Instance( )->get_document_new(
                EXPORTING
                    ir_bukrs        = lr_bukrs
                    ir_belnr        = lr_belnr
                    ir_gjahr        = lr_gjahr
                    ir_buzei        = lr_buzei
                    ir_monat        = lr_monat
                    ir_budat        = lr_budat
                    ir_bldat        = lr_bldat
                    ir_kunnr        = lr_kunnr
                    ir_status_sap   = lr_status_sap
                    ir_usertype     = lr_usertype
                    ir_region       = lr_region
                    page_size       = page_size
                    offset          = offset
                IMPORTING
                    header     = DATA(lt_header)
                    items      = DATA(lt_items)
*                    set_header = DATA(lt_set_header)
*                    set_items  = DATA(lt_set_items)
              ).

              DATA: lt_set_header TYPE tt_rap_einv_header.

              LOOP AT lt_header INTO DATA(ls_header).
                IF sy-tabix > offset.
                  IF sy-tabix > max_rows.
                    EXIT.
                  ELSE.
                    APPEND ls_header TO lt_set_header.
                  ENDIF.
                ENDIF.
              ENDLOOP.

              IF io_request->is_total_numb_of_rec_requested( ).
                io_response->set_total_number_of_records( lines( lt_header ) ).
              ENDIF.

              IF io_request->is_data_requested( ).
*                io_response->set_data( lt_header ).
                io_response->set_data( lt_set_header ).
              ENDIF.


            WHEN 'ZCS_RAP_EINV_ITEM' OR 'ZCS_JSON_EINV_ITEMS'.
              zcl_rap_inv_generate=>get_Instance( )->get_document_new(
              EXPORTING
                  ir_bukrs      = lr_bukrs
                  ir_belnr      = lr_belnr
                  ir_gjahr      = lr_gjahr
                  ir_buzei      = lr_buzei
                  ir_monat      = lr_monat
                  ir_budat      = lr_budat
                  ir_bldat      = lr_bldat
                  ir_kunnr      = lr_kunnr
                  ir_status_sap = lr_status_sap
                  ir_usertype   = lr_usertype
                  ir_region     = lr_region
                  page_size     = page_size
                  offset        = offset
              IMPORTING
                  header     = lt_header
                  items      = lt_items
*                  set_header = lt_set_header
*                  set_items  = lt_set_items
            ).

              DATA: lt_set_items TYPE tt_rap_einv_items.

              LOOP AT lt_items INTO DATA(ls_items).
                IF sy-tabix > offset.
                  IF sy-tabix > max_rows.
                    EXIT.
                  ELSE.
                    APPEND ls_items TO lt_set_items.
                  ENDIF.
                ENDIF.
              ENDLOOP.

              IF io_request->is_total_numb_of_rec_requested( ).
                io_response->set_total_number_of_records( lines( lt_items ) ).
              ENDIF.

              IF io_request->is_data_requested( ).
                io_response->set_data( lt_set_items ).
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


  METHOD rh_dynamic_where_build.
    TYPES: BEGIN OF lty_eq_tab,
             field TYPE char30,
             count TYPE i,
           END OF lty_eq_tab,

           BEGIN OF lty_cond_tab,
             condition TYPE int4,
             line(72),
           END OF lty_cond_tab.

    DATA : lt_condtab TYPE TABLE OF ty_hrcond,
           ls_condtab TYPE ty_hrcond,
           eq_tab     TYPE TABLE OF lty_eq_tab,
           cond_tab   TYPE TABLE OF lty_cond_tab.

    DATA : eq_tab_lines TYPE i.

    DATA : line TYPE lty_cond_tab-line.
    DATA : rdwb_tabix LIKE sy-tabix.
    DATA : unfield TYPE tt_ranges.

    FREE: where_clause.

    LOOP AT condtab INTO DATA(wa_condtab).
      MOVE-CORRESPONDING wa_condtab TO ls_condtab .
      COLLECT ls_condtab INTO lt_condtab.
    ENDLOOP.
*    IF sy-subrc GT 0.
*      RAISE empty_condtab.
*    ENDIF.

    CLEAR unfield.
    APPEND VALUE #( sign = 'I' option = 'EQ' ) TO unfield.

    SORT lt_condtab.
    LOOP AT lt_condtab INTO ls_condtab.
      IF ls_condtab-field IN unfield OR
         ls_condtab-opera EQ 'IN'.
*        RAISE wrong_condition.
      ENDIF.
      IF ls_condtab-opera EQ 'BT' AND
         ls_condtab-high  EQ space.
*        RAISE wrong_condition.
      ENDIF.
      IF ls_condtab-opera NE 'EQ'.
        READ TABLE eq_tab INTO DATA(ls_eqtab)
             WITH KEY field = ls_condtab-field.
        IF sy-subrc EQ 0.
*          RAISE wrong_condition.
        ENDIF.
        APPEND VALUE #( sign = 'I' option = 'EQ' low = ls_condtab-field ) TO unfield.
      ELSE.
        ls_eqtab-field = ls_condtab-field.
        ls_eqtab-count = 1.
        COLLECT ls_eqtab INTO eq_tab.
      ENDIF.
    ENDLOOP.

*    DESCRIBE TABLE eq_tab LINES eq_tab_lines.
    eq_tab_lines = lines( eq_tab ).
    IF eq_tab_lines GT 0.
      LOOP AT eq_tab INTO ls_eqtab WHERE count GT 1.
        READ TABLE lt_condtab
             WITH KEY field = ls_eqtab-field
             BINARY SEARCH
             TRANSPORTING NO FIELDS.
        CHECK sy-subrc EQ 0.
        rdwb_tabix = sy-tabix.
        CONCATENATE 'AND' ls_eqtab-field 'IN (' INTO line
                                              SEPARATED BY space.
        DO.
          CONCATENATE line '''' INTO line.
          READ TABLE lt_condtab INTO ls_condtab INDEX rdwb_tabix.
          IF sy-subrc GT 0 OR ls_condtab-field NE ls_eqtab-field.
            EXIT.
          ENDIF.
          IF ls_condtab-low NE space.
            CONCATENATE line ls_condtab-low '''' INTO line.
          ELSE.
            CONCATENATE line '''' INTO line SEPARATED BY space.
          ENDIF.
          IF sy-index EQ ls_eqtab-count.
            CONCATENATE line ')' INTO line.
          ELSE.
            CONCATENATE line ',' INTO line SEPARATED BY space.
          ENDIF.
*          where_clause = line.
          APPEND line TO where_clause.
          DELETE lt_condtab INDEX rdwb_tabix.
          CLEAR line.
        ENDDO.
      ENDLOOP.
    ENDIF.
    LOOP AT lt_condtab INTO ls_condtab.
      CLEAR line.
      CASE ls_condtab-opera.
        WHEN 'BT'.
          CONCATENATE 'AND' ls_condtab-field
                      'BETWEEN' ''''  INTO line SEPARATED BY space.
          IF ls_condtab-low NE space.
            CONCATENATE line ls_condtab-low '''' INTO line.
          ELSE.
            CONCATENATE line '''' INTO line SEPARATED BY space.
          ENDIF.
          CONCATENATE line 'AND' '''' INTO line SEPARATED BY space.
          IF ls_condtab-high NE space.
            CONCATENATE line ls_condtab-high '''' INTO line.
          ELSE.
            CONCATENATE line '''' INTO line SEPARATED BY space.
          ENDIF.
        WHEN 'LK'.
          TRANSLATE ls_condtab-low USING '*%+_'.
          CONCATENATE 'AND' ls_condtab-field
                      'LIKE' ''''  INTO line SEPARATED BY space.
          IF ls_condtab-low NE space.
            CONCATENATE line ls_condtab-low '''' INTO line.
          ELSE.
            CONCATENATE line '''' INTO line SEPARATED BY space.
          ENDIF.
        WHEN OTHERS.
          CONCATENATE 'AND' ls_condtab-field
                      ls_condtab-opera ''''  INTO line SEPARATED BY space.
          IF ls_condtab-low NE space.
            CONCATENATE line ls_condtab-low '''' INTO line.
          ELSE.
            CONCATENATE line '''' INTO line SEPARATED BY space.
          ENDIF.
      ENDCASE.
*      where_clause = line.
      APPEND line TO where_clause.
    ENDLOOP.

    READ TABLE where_clause INTO DATA(ls_whereclause) INDEX 1.
    line = ls_whereclause.
    IF line(4) EQ 'AND '.
      SHIFT line BY 4 PLACES LEFT.
      ls_whereclause = line.
      MODIFY where_clause FROM ls_whereclause INDEX sy-tabix.
    ENDIF.

    CLEAR: line, ls_whereclause.

  ENDMETHOD.


  METHOD zget_buyer_new.
    DATA: lv_flag TYPE char1 VALUE IS INITIAL. "Flag mã khách lẻ
    DATA: lv_url TYPE string VALUE IS INITIAL. "API read BP Details
    DATA: lv_country TYPE land1 VALUE IS INITIAL.

    CLEAR: es_customer, lv_country, lv_url, lv_flag.

    READ TABLE gt_buyer INTO DATA(ls_buyer) WITH KEY bcode = i_kunnr BINARY SEARCH.
    IF sy-subrc EQ 0.

      MOVE-CORRESPONDING ls_buyer TO es_customer.
    ELSE.

*      SELECT SINGLE * FROM I_BusinessPartner
*      WHERE BusinessPartner = @i_kunnr
*      INTO @DATA(I_BusinessPartner).
*
*      SELECT * FROM I_Customer
*      WHERE Customer = @i_kunnr
*      INTO TABLE @DATA(I_Customer).
*
*      SELECT * FROM I_BusPartAddress
**      WHERE AddressID = @I_BusinessPartner-IndependentAddressID
*      INTO TABLE @DATA(I_BusPartAddress).
*
*      SELECT * FROM i_address_2
*      INTO TABLE @data(I_address_2).
*
*      SELECT * FROM I_PersonAddress
*      INTO TABLE @data(I_PersonAddress).
*
*      SELECT * FROM I_AddressPersonName
*      INTO TABLE @DATA(I_AddressPersonName).
*
*      SELECT * FROM I_OrganizationAddress
*      INTO TABLE @DATA(I_OrganizationAddress).

      SELECT SINGLE
      businesspartnername1 AS name1,
      businesspartnername2 AS name2,
      businesspartnername3 AS name3,
      businesspartnername4 AS name4,
      streetaddressname AS stras,
      cityname AS ort01,
      taxid1 AS stcd1,
      accountingclerkinternetaddress AS intad,
      Country AS land1
      FROM i_onetimeaccountcustomer
      WHERE accountingdocument = @is_bseg-accountingdocument AND
            companycode = @is_bseg-companycode AND
            fiscalyear = @is_bseg-fiscalyear
      INTO @DATA(ls_bsec).

      IF sy-subrc EQ 0. "Nếu Mã khách lẻ
        lv_flag = 'X'.
        es_customer-bname = |{ ls_bsec-name2 } { ls_bsec-name3 } { ls_bsec-name4 } | .
        IF ls_bsec-name2 IS INITIAL AND ls_bsec-name3 IS INITIAL AND ls_bsec-name4 IS INITIAL.
          es_customer-bname = ls_bsec-name1 .
        ENDIF.
        es_customer-baddr = |{ ls_bsec-stras }{ ls_bsec-ort01 }| .
        es_customer-btax  = ls_bsec-stcd1.
        es_customer-bmail = ls_bsec-intad.
        "Country
        lv_country = ls_bsec-land1.
      ELSE. "Trường hợp ko phải Mã khách lẻ
        CLEAR: ls_bsec.

***"{ Customer Name
        SELECT
        businesspartner AS partner,
        addressid AS addrnumber
        FROM i_buspartaddress "but020
        WHERE businesspartner = @i_kunnr
        INTO TABLE @DATA(lt_but020).
        IF sy-subrc NE 0.
          FREE: lt_but020.
        ENDIF.

        SORT lt_but020 BY addrnumber DESCENDING.
        READ TABLE lt_but020 INTO DATA(ls_but020) INDEX 1.

        TRY.
            DATA(lv_host) = cl_abap_context_info=>get_system_url( ).
          CATCH cx_abap_context_info_error.
            "handle exception
        ENDTRY.
***"{ Customer Address
        lv_url = |https://{ lv_host }/sap/opu/odata/sap/API_BUSINESS_PARTNER/A_BusinessPartnerAddress(BusinessPartner='{ i_kunnr }',AddressID='{ ls_but020-addrnumber }')/to_BPIntlAddressVersion|.
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
*            (  name = 'Authorization' value = 'Basic SU5CT1VORF9DT01NX1VTRVJfQlRQX0VYVEVOU0lPTjpBYmNkQDEyMzQ1Njc4OTBFZmdoaWpr' )
            (  name = 'DataServiceVersion' value = '2.0' )
            (  name = 'Accept' value = 'application/json' )
             ) ).
            "Authorization
            lo_web_http_request->set_header_field(  i_name = 'username' i_value = 'INBOUND_COMM_USER_BTP_EXTENSION' ).
            lo_web_http_request->set_header_field(  i_name = 'password' i_value = 'Abcd@1234567890Efghijk' ).
            lo_web_http_request->set_authorization_basic( i_username = 'INBOUND_COMM_USER_BTP_EXTENSION' i_password = 'Abcd@1234567890Efghijk' ).
            lo_web_http_request->set_content_type( |application/json| ).
            "set request method and execute request
            DATA(lo_web_http_response) = lo_web_http_client->execute( if_web_http_client=>get ).
            DATA(lv_response) = lo_web_http_response->get_text( ).
            "read json
            TYPES: BEGIN OF lty_replace_json,
                     string1 TYPE string,
                     string2 TYPE string,
                   END OF lty_replace_json.
            DATA: lt_replace_json TYPE TABLE OF lty_replace_json.

            APPEND VALUE #( string1 = '__metadata' string2 = 'metadata' ) TO lt_replace_json.
            LOOP AT lt_replace_json INTO DATA(ls_replace_json).
              IF ls_replace_json-string2 IS INITIAL.
                REPLACE ALL OCCURRENCES OF ls_replace_json-string1 IN lv_response WITH ls_replace_json-string2.
              ENDIF.
            ENDLOOP.

            DATA: ls_d TYPE zst_response_addr_bp_2.
            xco_cp_json=>data->from_string( lv_response )->write_to( EXPORTING ia_data = REF #( ls_d ) ).

            READ TABLE ls_d-d-results INTO DATA(ls_results) INDEX 1.
            IF sy-subrc EQ 0.
              "Customer name
              es_customer-bname = |{ ls_results-organizationname2 } { ls_results-organizationname3 } { ls_results-organizationname4 }|.
              IF ls_results-organizationname2 IS INITIAL AND ls_results-organizationname3 IS INITIAL AND ls_results-organizationname4 IS INITIAL.
                es_customer-bname = |{ ls_results-organizationname1 }|.
              ENDIF.
              IF es_customer-bname IS INITIAL.
                es_customer-bname = ls_results-addresseefullname.
              ENDIF.
              "Customer Address
              es_customer-baddr = |{ ls_results-housenumber } { ls_results-streetname }, { ls_results-streetprefixname1 }, { ls_results-streetprefixname2 }, { ls_results-streetsuffixname1 }, { ls_results-streetsuffixname2 }, { ls_results-districtname
}, { ls_results-cityname }|.
            ENDIF.
          CATCH cx_http_dest_provider_error cx_web_http_client_error cx_web_message_error.
            "error handling
        ENDTRY.

        "uncomment the following line for console output; prerequisite: code snippet is implementation of if_oo_adt_classrun~main
        "out->write( |response:  { lv_response }| ).
***"{ Customer tax
        lv_url = |https://{ lv_host }/sap/opu/odata/sap/API_BUSINESS_PARTNER/A_BusinessPartner('{ i_kunnr }')/to_BuPaIdentification?$inlinecount=allpages&$top=50|.
        TRY.
            "create http destination by url; API endpoint for API sandbox
            lo_http_destination =
                 cl_http_destination_provider=>create_by_url( lv_url ).
            "alternatively create HTTP destination via destination service
            "cl_http_destination_provider=>create_by_cloud_destination( i_name = '<...>'
            "                            i_service_instance_name = '<...>' )
            "SAP Help: https://help.sap.com/viewer/65de2977205c403bbc107264b8eccf4b/Cloud/en-US/f871712b816943b0ab5e04b60799e518.html

            "create HTTP client by destination
            lo_web_http_client = cl_web_http_client_manager=>create_by_http_destination( lo_http_destination ) .

            "adding headers
            lo_web_http_request = lo_web_http_client->get_http_request( ).
            lo_web_http_request->set_header_fields( VALUE #(
*            (  name = 'Authorization' value = 'Basic SU5CT1VORF9DT01NX1VTRVJfQlRQX0VYVEVOU0lPTjpBYmNkQDEyMzQ1Njc4OTBFZmdoaWpr' )
            (  name = 'DataServiceVersion' value = '2.0' )
            (  name = 'Accept' value = 'application/json' )
             ) ).
            "Authorization
            lo_web_http_request->set_header_field(  i_name = 'username' i_value = 'INBOUND_COMM_USER_BTP_EXTENSION' ).
            lo_web_http_request->set_header_field(  i_name = 'password' i_value = 'Abcd@1234567890Efghijk' ).
            lo_web_http_request->set_authorization_basic( i_username = 'INBOUND_COMM_USER_BTP_EXTENSION' i_password = 'Abcd@1234567890Efghijk' ).
            lo_web_http_request->set_content_type( |application/json| ).
            "set request method and execute request
            lo_web_http_response = lo_web_http_client->execute( if_web_http_client=>get ).
            lv_response = lo_web_http_response->get_text( ).
            "read json
            REPLACE ALL OCCURRENCES OF '__metadata' IN lv_response WITH 'metadata'.
            REPLACE ALL OCCURRENCES OF '__count' IN lv_response WITH 'count'.
            REPLACE ALL OCCURRENCES OF 'null' IN lv_response WITH `""`.

            DATA: ls_id TYPE zst_response_id_bp_2.
            xco_cp_json=>data->from_string( lv_response )->write_to( EXPORTING ia_data = REF #( ls_id ) ).

            LOOP AT ls_id-d-results INTO DATA(ls_result_id).
              es_customer-btax = |{ ls_result_id-bpidentificationnumber }|.
            ENDLOOP.
          CATCH cx_http_dest_provider_error cx_web_http_client_error cx_web_message_error.
            "error handling
        ENDTRY.

***"{ Customer Mail
        lv_url = |https://{ lv_host }/sap/opu/odata/sap/API_BUSINESS_PARTNER/A_BusinessPartnerAddress(BusinessPartner='{ i_kunnr }',AddressID='{ ls_but020-addrnumber }')/to_EmailAddress?$inlinecount=allpages&$top=50|.
        TRY.
            "create http destination by url; API endpoint for API sandbox
            lo_http_destination =
                 cl_http_destination_provider=>create_by_url( lv_url ).
            "alternatively create HTTP destination via destination service
            "cl_http_destination_provider=>create_by_cloud_destination( i_name = '<...>'
            "                            i_service_instance_name = '<...>' )
            "SAP Help: https://help.sap.com/viewer/65de2977205c403bbc107264b8eccf4b/Cloud/en-US/f871712b816943b0ab5e04b60799e518.html

            "create HTTP client by destination
            lo_web_http_client = cl_web_http_client_manager=>create_by_http_destination( lo_http_destination ) .

            "adding headers
            lo_web_http_request = lo_web_http_client->get_http_request( ).
            lo_web_http_request->set_header_fields( VALUE #(
*            (  name = 'Authorization' value = 'Basic SU5CT1VORF9DT01NX1VTRVJfQlRQX0VYVEVOU0lPTjpBYmNkQDEyMzQ1Njc4OTBFZmdoaWpr' )
            (  name = 'DataServiceVersion' value = '2.0' )
            (  name = 'Accept' value = 'application/json' )
             ) ).
            "Authorization
            lo_web_http_request->set_header_field(  i_name = 'username' i_value = 'INBOUND_COMM_USER_BTP_EXTENSION' ).
            lo_web_http_request->set_header_field(  i_name = 'password' i_value = 'Abcd@1234567890Efghijk' ).
            lo_web_http_request->set_authorization_basic( i_username = 'INBOUND_COMM_USER_BTP_EXTENSION' i_password = 'Abcd@1234567890Efghijk' ).
            lo_web_http_request->set_content_type( |application/json| ).
            "set request method and execute request
            lo_web_http_response = lo_web_http_client->execute( if_web_http_client=>get ).
            lv_response = lo_web_http_response->get_text( ).
            "read json
            REPLACE ALL OCCURRENCES OF '__metadata' IN lv_response WITH 'metadata'.
            REPLACE ALL OCCURRENCES OF '__count' IN lv_response WITH 'count'.

            DATA: ls_mail TYPE zst_response_mail_bp_2.
            xco_cp_json=>data->from_string( lv_response )->write_to( EXPORTING ia_data = REF #( ls_mail ) ).

            LOOP AT ls_mail-d-results INTO DATA(ls_result_mail).
              IF es_customer-bmail IS INITIAL.
                es_customer-bmail = |{ ls_result_mail-emailaddress }|.
              ELSE.
                es_customer-bmail = |{ es_customer-bmail }; { ls_result_mail-emailaddress }|.
              ENDIF.
            ENDLOOP.
          CATCH cx_http_dest_provider_error cx_web_http_client_error cx_web_message_error.
            "error handling
        ENDTRY.

***"{ Customer Phone
        lv_url = |https://{ lv_host }/sap/opu/odata/sap/API_BUSINESS_PARTNER/A_BusinessPartnerAddress(BusinessPartner='{ i_kunnr }',AddressID='{ ls_but020-addrnumber }')/to_PhoneNumber?$inlinecount=allpages&$top=50|.
        TRY.
            "create http destination by url; API endpoint for API sandbox
            lo_http_destination =
                 cl_http_destination_provider=>create_by_url( lv_url ).
            "alternatively create HTTP destination via destination service
            "cl_http_destination_provider=>create_by_cloud_destination( i_name = '<...>'
            "                            i_service_instance_name = '<...>' )
            "SAP Help: https://help.sap.com/viewer/65de2977205c403bbc107264b8eccf4b/Cloud/en-US/f871712b816943b0ab5e04b60799e518.html

            "create HTTP client by destination
            lo_web_http_client = cl_web_http_client_manager=>create_by_http_destination( lo_http_destination ) .

            "adding headers
            lo_web_http_request = lo_web_http_client->get_http_request( ).
            lo_web_http_request->set_header_fields( VALUE #(
*            (  name = 'Authorization' value = 'Basic SU5CT1VORF9DT01NX1VTRVJfQlRQX0VYVEVOU0lPTjpBYmNkQDEyMzQ1Njc4OTBFZmdoaWpr' )
            (  name = 'DataServiceVersion' value = '2.0' )
            (  name = 'Accept' value = 'application/json' )
             ) ).
            "Authorization
            lo_web_http_request->set_header_field(  i_name = 'username' i_value = 'INBOUND_COMM_USER_BTP_EXTENSION' ).
            lo_web_http_request->set_header_field(  i_name = 'password' i_value = 'Abcd@1234567890Efghijk' ).
            lo_web_http_request->set_authorization_basic( i_username = 'INBOUND_COMM_USER_BTP_EXTENSION' i_password = 'Abcd@1234567890Efghijk' ).
            lo_web_http_request->set_content_type( |application/json| ).
            "set request method and execute request
            lo_web_http_response = lo_web_http_client->execute( if_web_http_client=>get ).
            lv_response = lo_web_http_response->get_text( ).
            "read json
            REPLACE ALL OCCURRENCES OF '__metadata' IN lv_response WITH 'metadata'.
            REPLACE ALL OCCURRENCES OF '__count' IN lv_response WITH 'count'.

            DATA: ls_telephone TYPE zst_response_phone_bp_2.
            xco_cp_json=>data->from_string( lv_response )->write_to( EXPORTING ia_data = REF #( ls_telephone ) ).

            LOOP AT ls_telephone-d-results INTO DATA(ls_result_phone).
              IF es_customer-btel IS INITIAL.
                es_customer-btel = |{ ls_result_phone-phonenumber }|.
              ELSE.
                es_customer-btel = |{ es_customer-bmail }; { ls_result_phone-phonenumber }|.
              ENDIF.
            ENDLOOP.
          CATCH cx_http_dest_provider_error cx_web_http_client_error cx_web_message_error.
            "error handling
        ENDTRY.

      ENDIF. "End Check Mã khách lẻ

      REPLACE ALL OCCURRENCES OF ', , , , , ,' IN es_customer-baddr WITH ','.
      REPLACE ALL OCCURRENCES OF ', , , , ,' IN es_customer-baddr WITH ','.
      REPLACE ALL OCCURRENCES OF ', , , ,' IN es_customer-baddr WITH ','.
      REPLACE ALL OCCURRENCES OF ', , ,' IN es_customer-baddr WITH ','.
      REPLACE ALL OCCURRENCES OF ', ,' IN es_customer-baddr WITH ','.

      SHIFT es_customer-baddr RIGHT DELETING TRAILING space.
      SHIFT es_customer-baddr RIGHT DELETING TRAILING ','.
      SHIFT es_customer-baddr LEFT DELETING LEADING space.
      SHIFT es_customer-baddr LEFT DELETING LEADING ','.
      SHIFT es_customer-baddr LEFT DELETING LEADING space.

      "Get Country Name
      IF ls_bsec IS INITIAL.
        lv_country = ls_results-country.
      ENDIF.

      IF es_customer-baddr IS NOT INITIAL.
        IF lv_country = 'VN'.
          es_customer-baddr = |{ es_customer-baddr }, Việt Nam|.
        ELSE.
          SELECT SINGLE countryname
          FROM i_countrytext
          WHERE country = @lv_country
            AND language = @sy-langu
          INTO @DATA(lv_country_name).
          IF sy-subrc = 0.
            es_customer-baddr = |{ es_customer-baddr }, { lv_country_name }|.
          ENDIF.
        ENDIF.
      ENDIF.

    ENDIF.

    IF lv_flag IS INITIAL.
      MOVE-CORRESPONDING es_customer TO ls_buyer.
      READ TABLE gt_buyer TRANSPORTING NO FIELDS WITH KEY bcode = ls_buyer-bcode BINARY SEARCH.
      IF sy-subrc NE 0.
        INSERT ls_buyer INTO gt_buyer INDEX sy-tabix.
      ENDIF.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
