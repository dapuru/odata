# Code based implementation and classical SEGW

## Disclaimer
A word of caution in advance: "While these are the valid steps for the traditional code-based OData development approach, it should be noted that at present time, other development models exist that are more suitable for development in S/4HANA." [see here](https://blogs.sap.com/2021/05/19/a-step-by-step-process-to-post-odata-services-in-sap-sap-hana-system/)

- For Netweaver >= 7.50 you shoud use "ABAP Prgraming model for Fiori".
- For S/4HANA >= 1909 use ABAP RAP

## Overview

If you still want to continue with SEGW, go ahead.

"SAP Gateway Service Builder (transaction SEGW)) is a design-time environment, which provides developers an easy-to-use set of tools for creating services. The Code-based OData Channel consumes it and supports developers throughout the development life cycle of a service." [Source](https://help.sap.com/docs/SAP_NETWEAVER_AS_ABAP_751_IP/68bf513362174d54b58cddec28794093/cddd22512c312314e10000000a44176d.html?locale=en-US)


The steps, which need to be taken, are:
(1) in SEGW create a project and eg. import a DDIC structure for the data model <br/>
(2) in SEGW generate the MPC (model provider class) and DPC (data provider class).<br/>
(3) in /IWFND/MAINT_SERVICE publish the service and test in the "SAP GAteway Client"<br/>
(4) add logic to the MPC_EXT and DPC_EXT classes by redefining the methods (see below for details)<br/>
(5) in the "SAP GAteway Client" test "EntitySets"<br/>

## (1) SEGW project initialization

This is the very first step to define the ODataservice.

- Start **transaction "SEGW"** and create a new project. <br/>
The prokect stores all the needed developer artifacts in one place. This has several advantages, like: (a) the project/service can be transported easily, (b) the design-time artifacts are separated from the runtime-artifacts (the punlished service) - so changes can be made and tested, without interferring with the published service. Be aware:  The project name in SEGW will be the name of the OData-service.
- Define the "Data Model". This can be done eg. by importing a DDIC structure: Rigth-click in the "Data Model" node and choose "Import > DDIC Strcuture". Note that there are also others ways, which are described here in more detail: 
[Data Modeling Options](https://help.sap.com/docs/SAP_NETWEAVER_AS_ABAP_751_IP/68bf513362174d54b58cddec28794093/8edc22512c312314e10000000a44176d.html?locale=en-US). 

We do:
- Choose "Entity Type", add the ABAP-strcuture name (BUT000)
- in the popup select the needed "data source parameters", that are the fields you want to use in the service.
- mark the key-fields (to be unique)
- Choose which CRUD-methods are needed

## (2) SEGW class generation

- Click the "generate" icon - note the generated classes for MPC (model provider class) and DPC (data provider class), as well as the suggested EXT-Classes (extensions). Besides that, there is the APC (annotation provider class).


## (3)publish service and test

- in **transaction /IWFND/MAINT_SERVICE** - use "Add service".
- Add the "system alias" = LOCAL
- use "SAP Gateway Client" to test the service


## (4) Service implementation: adding logic through DPC_EXT-classes

The logic of the service - what it actually does - is implemented by redefining methods of the DPC (data provider) extension class (DPC_EXT).

- in the transaction SEGW expand the folder "service implementation".
- right click on the method you need to implement and choose "Go to ABAP workbench"
- there "Redefine" the method and add the custom logic

### Read-Methods (the R in CRUD)
Example implementation for the GET_ENTITYSET (Get all entries).<br/>
Call it using http://YourSystemURL:Portnumber/sap/opu/odata/Z_DPU_DEMO1/businesspartners 

```abap
METHOD businesspartners_get_entityset. "Redefinition 
    SELECT * FROM but000 
        INTO CORRESPONDING FIELDS OF TABLE @et_entityset
        UP TO 50 rows. 
ENDMETHOD. 
```

Example implementation for the GET_ENTITY (Get single entry)<br/>
Call it using http://YourSystemURL:Portnumber/sap/opu/odata/Z_DPU_DEMO1/businesspartners('12345')​

```abap
METHOD businesspartners_get_entity. "Redefinition 

    DATA: ls_message TYPE scx_t100key.

    DATA(lv_bu_partner_raw) = CONV bu_partner(  
        |{ it_key_tab[ name = 'Partner' ]-value }| ). 

    If lv_bu_partner_raw is initial.

        ls_message = VALUE #( msgid = 'SY'
                              msgno = '002' 
                              attr1 = 'BPartner not found' ).

        RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
            EXPORTING
                textid = ls_message.
    endif.

    DATA(lv_bu_partner) = CONV bu_partner(  
        |{ lv_bu_partner_raw  ALPHA = IN }| ). 

    SELECT SINGLE * FROM but000 
        INTO CORRESPONDING FIELDS OF er_entity 
        WHERE partner = lv_bu_partner. 

ENDMETHOD. 
```

Be aware: The same way support for query-options, as well as the rest of the CRUD methods need to be implemented (even though the static methods of the **class /iwbep/cl_mgw_data_util** will do sorting, filtering and paging) [see source](https://blogs.sap.com/2018/09/12/gateway-odata-service-how-to-implement-generic-filtering-filter-sorting-orderby-and-paging-top-and-skip/#comment-437107). For details see [Conversions in SAP Gateway Foundation – Part 2](https://blogs.sap.com/2017/01/23/conversions-in-sap-gateway-foundation-part-2/) as well as [Andre Fischer - How to Develop Query Options for an OData Service Using Code-Based Implementation](https://blogs.sap.com/2013/06/20/how-to-develop-query-options-for-an-odata-service-using-code-based-implementation/). 


Adding logic for Filter, orderby and paging in the GET_ENTITYSET:

```abap
METHOD businesspartners_get_entityset. "Redefinition 

    SELECT * FROM but000 
        INTO CORRESPONDING FIELDS OF TABLE @et_entityset.

* $inlinecount query option 
     IF io_tech_request_context->has_inlinecount( ) = abap_true. 
       es_response_context-inlinecount = lines( et_entityset ). 
     ELSE. 
       CLEAR es_response_context-inlinecount. 
     ENDIF. 

* filter conditions 
     CALL METHOD /iwbep/cl_mgw_data_util=>filtering 
       EXPORTING 
         it_select_options = it_filter_select_options 
       CHANGING 
         ct_data           = et_entityset. 

* $top and $skip query options 
     CALL METHOD /iwbep/cl_mgw_data_util=>paging 
       EXPORTING 
         is_paging = is_paging 
       CHANGING 
         ct_data   = et_entityset. 

* $orderby condition 
     CALL METHOD /iwbep/cl_mgw_data_util=>orderby 
       EXPORTING 
         it_order = it_order 
       CHANGING 
         ct_data  = et_entityset. 

ENDMETHOD. 
```

Todo: Update with details from:
https://blogs.sap.com/2013/06/20/how-to-develop-query-options-for-an-odata-service-using-code-based-implementation/



### Other CRUD-Methods (CUD)

To create an entity, the method which needs to be redefined in the DPC_EXT class is: *CREATE_ENTITY*. The importing-parameter *io_data_provider* is the object, which holds the payload (as JSON or XML) of the **POST-HTTP request**. The response will be send back in the exporting parameter *ER_ENTITY*.

In the CREATE_ENTITY method the logic is as follows:
1) Declaration of payload-data
*DATA: lv_entry_data TYPE zcl_xyzsample_mpc=>ts_pos.*

2) Get the data from the payload - this is the one to be created
*io_data_provider->read_entry_data( IMPORTING es_data = lv_entry_data ).*

3) Logic using BAPIs or custom coding, eg:
*BAPI_BUPA_CREATE_FROM_DATA* to create.
*BAPI_BUPA_CENTRAL_CHANGE* to update.
*BUPA_TEST_DELETE* to delete.

4) Return
Return *er_entity*


Complete example for Create:

```abap
METHOD businesspartners_create_entity. "Redefinition 

  " 1) Declaration of payload-data
  DATA: lv_entry_data TYPE zcl_xyzsample_mpc=>ts_pos.
  
  " 2) Get the data from the payload
  io_data_provider->read_entry_data( IMPORTING es_data = lv_entry_data ).

  " Compare payload to IT_KEY_TAB parameter to be sure
  READ TABLE it_key_tab INTO DATA(ls_key_tab) INDEX 1. 
  IF ls_key_tab-value EQ lv_entry_data-partner. 
    lv_continue = abap_true.
  ELSE. 
    lv_continue = abap_false.
  ENDIF. 
  
  " 3) Logic - eg. BAPIS or custom coding
  IF lv_continue eq abap_true.
    CALL FUNCTION 'DIALOG_SET_NO_DIALOG'.
    CALL FUNCTION 'BAPI_BUPA_CREATE_FROM_DATA' 
      " add suitable parameters
  ELSE.
     " raise message: entity not found 
  ENDIF.

  * 4) Return updated data
  er_entity = lv_entry_data.

ENDMETHOD. 
```

See this blog-post for details: [Let’s code CRUDQ and Function Import operations in OData service!](https://blogs.sap.com/2014/03/06/let-s-code-crudq-and-function-import-operations-in-odata-service/)


## (5) Test

- Back in **/IWFND/MAINT_SERVICE** test the service, by:
a) the buton "Load Metadata"
b) in the "SAP Gateway Client" choose "Entity Set" - data should be returned


## Associations

- Create a second entity
- Create the association by
1) Naming-Convention: From_TO_Target
2) Cardinality: Choose, 1:1, 1:n,...
3) Referential Constraint" for the Foreign-Key relation
4) Add Logic ;-) [see here](https://blogs.sap.com/2014/09/24/lets-code-associationnavigation-and-data-provider-expand-in-odata-service/)



## Deep-Entity (in progress...)

- Prerequsuite: Create Entities, Entity-Sets and Associations
- Create an internal table within internal table (for the deep structure)
- Change the MPC_EXT class (model) -> Add a new type for the deep-entity internal table:

```abap
  types: BEGIN of ts_deep_entity,
          sid type c length 10,
          otype type c length 4,
          hdrtoitemnav type table of ts_sitem with default key,
          hdrtoshipnav type tyble if ts_sship with default key,
        END of ts_deep_entity.
```

- Redefine GET_EXPANDED_ENTITYSET in DPC_EXT class (trigger with $expand=<Navigation Property Name>), after optionally redefining the basic methods (get_entity,...), to fill the deep entity set.

```abap
METHOD ...GET_EXPANDED ENTITYSET.

  DATA: it_deep_entity type table of ...MPC_EXT=>ts_deep_entity,
        wa_deep_entity like line of it_deep_entity.

  DATA: it_sheader type table of zdpu_sales_header,
        it_sitem type table of zdpu_sales_item,
        it_sship type table of zdpu_sales_ship,
        wa_odata_item type ...MPC_EXT=>ts_sitem,
        wa_odata_ship type ...MPC_EXT=>ts_sship.
  
  " Transfer data of the entity-sets to the deep entity
  CASE IV_ENTITY_SET_NAME.
    WHEN 'SHeaderSet'. " Entity Set
      select * from zdpu_sales_header into table it_sheader.
      if sy-subrc eq 0.
        select * from zdpu_sales_item into table it_sitem
          for all entries in it_sheader
            where sid = it_sheader~sid.
        
        " same for zdpu_sales_ship
      endif.

      " transfer to deep entity-set
      loop at it_sheader into data(wa_sheader).
        move-corresponding wa_sheader to wa_deep_entity.
        loop at it_sitem into data(wa_item) where sid = wa_sheader~sid.
          move-corresponding wa_item to wa_odata_item.
          append wa_odata_item to wa_deep_entity~hdrtoitemnav.
        endloop.
        " same for zdpu_sales_ship
        
        " append
        append wa_deep_entity to it_deep_entity.
        clear wa_deep_entity.

      endloop.

      " return
      me->/iwbep/if_mgw_conv_srv_runtime~copy_data_to_ref(
        EXPORTING
          is_data = it_deep_entity
        CHANGING
          cr_data = er_entityset
      ).

    WHEN OTHERS.
  ENDCASE.

ENDMETHOD.
```

- Create the service and test in "SAP Gateway Client" using $expand=HDRTOITEMNAV (or HDRTOSHIPNAV).


Todo, meanwhile check this video:
[Just2Share: OData Service - Deep Entity Set Part 1](https://www.youtube.com/watch?v=bmzh7B8qmCY)



## FAQ

### "System alias 'LOCAL' does not exist".
[see here](https://rz10.de/sap-basis/fehler-kein-systemalias-fuer-service-und-benutzer-gefunden-beheben/)


 ## Ressources
Plenty tutorials for this method of implementing an OData service can be found at blogs.sap.com:
- [help.sap.com - SAP Gateway Foundation (SAP_GWFND)](https://help.sap.com/docs/SAP_NETWEAVER_AS_ABAP_751_IP/68bf513362174d54b58cddec28794093/cddd22512c312314e10000000a44176d.html?locale=en-US)
- [A Step by Step process to create Odata services in SAP / SAP HANA system](https://blogs.sap.com/2021/05/06/a-step-by-step-process-to-create-odata-services-in-sap-sap-hana-system/)
- [Introduction to OData and how to implement them in ABAP](https://blogs.sap.com/2020/11/24/introduction-to-odata-and-how-to-implement-them-in-abap/)
- [OData service development with SAP Gateway – code-based service development – Part I](https://blogs.sap.com/2016/05/31/odata-service-development-with-sap-gateway-code-based-service-development/)
- [Exploring/Understanding Gateway Service Builder (SEGW)](https://blogs.sap.com/2019/05/14/exploringunderstanding-segw/)
- [SAP Gateway Cookbooks - Getting Started with the Service Builder](https://help.sap.com/docs/SAP_NETWEAVER_AS_ABAP_751_IP/68bf513362174d54b58cddec28794093/36742c510e87fa50e10000000a441470.html?locale=en-US)
- [Conversions in SAP Gateway Foundation – Part 2](https://blogs.sap.com/2017/01/23/conversions-in-sap-gateway-foundation-part-2/) 
- [Andre Fischer - How to Develop Query Options for an OData Service Using Code-Based Implementation](https://blogs.sap.com/2013/06/20/how-to-develop-query-options-for-an-odata-service-using-code-based-implementation/). 
