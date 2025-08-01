CLASS zcl_sheduling_agreement_update DEFINITION
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.
    TYPES : BEGIN OF str,
*              SerialNumber            TYPE string,
              SchedulingAgreement     TYPE string,
              SchedulingAgreementItem TYPE string,
              SchedulingAgreementLine TYPE string,
              Quantity                TYPE string,
*              Quantity                TYPE P DECIMALS 10 LENGTH 3 ,
            END OF str..


    CLASS-DATA : tab1  TYPE TABLE OF str .
    TYPES : BEGIN OF ty,
              aSelectedTableData LIKE  tab1,
            END OF ty.

    CLASS-DATA respo TYPE ty .
    INTERFACES if_http_service_extension .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_SHEDULING_AGREEMENT_UPDATE IMPLEMENTATION.


  METHOD if_http_service_extension~handle_request.
    DATA(req) = request->get_form_fields(  ).
    response->set_header_field( i_name = 'Access-Control-Allow-Origin' i_value = '*' ).
    response->set_header_field( i_name = 'Access-Control-Allow-Credentials' i_value = 'true' ).
    DATA(body) = request->get_text(  ) .
    xco_cp_json=>data->from_string( body )->write_to( REF #( respo ) ).
    DATA message11 TYPE string .


    DATA user     TYPE string VALUE 'ZSCHEDULING_AGRE'.
    DATA pass     TYPE string VALUE '9gYfyDKdPTXGyMDolRbdJLJiHMobYiifCehRr}uz'.
    DATA payload  TYPE string.
    DATA apirespo TYPE string.
    DATA apirespoError TYPE string.
    DATA desti TYPE string.
*    apiurl = |https://my420225-api.s4hana.cloud.sap/sap/opu/odata/sap/API_SCHED_AGRMT_PROCESS_SRV/A_SchAgrmtSchLine(SchedulingAgreement='5500000008',SchedulingAgreementItem='50',ScheduleLine='21')|.
    desti   =  'https://' && cl_abap_context_info=>get_system_url(  ) .
    REPLACE ALL OCCURRENCES OF '.s4hana.cloud.sap' IN desti WITH '-api.s4hana.cloud.sap'.
    LOOP AT  respo-aselectedtabledata INTO DATA(jsr).
      DATA(apiurl) = |{ desti }/sap/opu/odata/sap/API_SCHED_AGRMT_PROCESS_SRV/A_SchAgrmtSchLine(SchedulingAgreement='{ jsr-schedulingagreement }',SchedulingAgreementItem='{ jsr-schedulingagreementitem }',ScheduleLine='{ jsr-schedulingagreementline }')|.
      TRY.
          DATA(get_dest) = cl_http_destination_provider=>create_by_url( apiurl ).
          DATA(get_client) = cl_web_http_client_manager=>create_by_http_destination( get_dest ).
        CATCH cx_static_check.
      ENDTRY.
      DATA(get_req) = get_client->get_http_request( ).
      get_req->set_header_field( i_name  = 'x-csrf-token'
                                 i_value = 'fetch' ).
      get_req->set_header_field( i_name  = 'Accept'
                                 i_value = 'application/json' ).
      get_req->set_content_type( 'application/json' ).
      get_req->set_authorization_basic( i_username = user
                                        i_password = pass ).

      TRY.
          DATA(lo_web_http_response1) = get_client->execute( if_web_http_client=>get ).
          DATA(token) = lo_web_http_response1->get_header_field( i_name = 'x-csrf-token' ).
        CATCH cx_web_http_client_error cx_web_message_error INTO DATA(error). " TODO: variable is assigned but never used (ABAP cleaner)
      ENDTRY.

      DATA(mcs) = '{'.
      DATA(mce) = '}'.
*      DATA: Quantity TYPE string VALUE '10.000',
*      json_quantity TYPE string.
*
*json_quantity = |"{ Quantity }"|.

*    payLoad = '{' &&
*            |"d": { mcs } | &&
*            |"ScheduleLineOrderQuantity":"2",| &&
*            |"RoughGoodsReceiptQty":"3"| &&
*            '}}'.

      payLoad = '{' &&
     |"d": { mcs } | &&
     |"ScheduleLineOrderQuantity":"{ jsr-quantity }" | &&
*   |"RoughGoodsReceiptQty":"3"| &&
     '}}'.

      DATA(post_req) = get_client->get_http_request( ).
      post_req->set_header_field( i_name  = 'x-csrf-token'
                             i_value = token ).
      post_req->set_header_field( i_name  = 'DataServiceVersion'
                             i_value = '2.0' ).
      post_req->set_header_field( i_name  = 'Accept'
                             i_value = 'application/json' ).
      post_req->set_authorization_basic( i_username = user
                                    i_password = pass ).
      post_req->set_content_type( 'application/json' ).
      post_req->set_text( payload ).

      apirespo = get_client->execute( if_web_http_client=>patch )->get_text( ).
      IF apirespo IS NOT INITIAL.

        FIELD-SYMBOLS:
          <data>  TYPE data,
          <data2> TYPE data,
          <data3> TYPE data,
          <data4> TYPE data,
          <field> TYPE any,
          <error> TYPE any.

        DATA(lr_d1) = /ui2/cl_json=>generate( json = apirespo ).
        IF lr_d1 IS BOUND.
          ASSIGN lr_d1->* TO <data>.
          ASSIGN COMPONENT `ERROR` OF STRUCTURE <data>  TO   <data2>    .
          IF sy-subrc = 0 .
            ASSIGN <data2>->* TO <data3>  .
            IF sy-subrc = 0 .
              ASSIGN COMPONENT `MESSAGE` OF STRUCTURE <data3>  TO   <data4>.
              ASSIGN <data4>->* TO <field>.
              IF sy-subrc = 0 .
                ASSIGN COMPONENT `VALUE` OF STRUCTURE  <field> TO   <error>.
                ASSIGN <error>->* TO <error>.
                CONCATENATE 'Error :-' <error> INTO apirespoError.
*                CLEAR:wa_resp.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.
        response->set_text( apirespoError )  .
      ENDIF.
      IF apirespo IS INITIAL.
        response->set_text( apirespo )  .
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
