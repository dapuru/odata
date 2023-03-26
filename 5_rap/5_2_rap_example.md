# ABAP RESTful Application Programming Model (RAP)

"The ABAP RESTful Application Programming Model (in short RAP) defines the architecture for efficient end-to-end development of intrinsically SAP HANA-optimized OData services (such as Fiori apps). It supports the development of all types of Fiori applications as well as publishing Web APIs" [Source](https://help.sap.com/docs/btp/sap-abap-restful-application-programming-model/abap-restful-application-programming-model).

> **Warning**
> This is the suggested way to implement an OData service in case you are using SAP Cloud Platform ABAP Environment starting with release 1808 and on-prem SAP S/4 HANA 1909.


# Prerequisites

- ABAP backend BTP >= 1808 and on-prem SAP S/4 HANA >= 1909 available.
- ADT installed

# Steps
<ol>
<li>Create the data model using CDS</li>
<li>Create the OData service</li>
<li>Create the Fiori Elements App</li>
</ol>

> **Note**
> These steps are similar to the ones used in the "ABAP Programing Model for Fiori". I'll indicate the differences explicitly.

Full-blown walkthroughs are available at:
<ul>
<li>[SAP BTP ABAP Environment: Create and Expose a CDS-Based Data Model](https://developers.sap.com/group.abap-env-expose-cds-travel-model.html)</li>
<li>[TechEd 2020 - DEV260](https://github.com/SAP-archive/teched2020-DEV260)</li>
<li>[Tutorial Navigator - Create a Travel App with SAP Fiori Elements Based on OData V4 RAP Service](https://developers.sap.com/group.fiori-tools-odata-v4-travel.html)</li>
</ul>

> **Note**
> Several steps can be automated using the ["RAP Generator"](https://blogs.sap.com/2020/05/17/the-rap-generator/).


# Example

## Service creation
### CDS view as data model

```js
@AbapCatalog.sqlViewName: 'ZCUSTOMERS'
@AbapCatalog.compiler.compareFilter: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Customers'

define view Z_Customers
  as select from kna1
{
  key kunnr,
  name1,
  city,
  country
}

```


### Service definition

a service definition exposes the data model as a RESTful service.
In this example, we're defining a service called "Z_CustomerService" that exposes the "Z_Customers" view we defined earlier. We're also enabling the "draft" feature, which allows for multi-step transactions and allows users to save drafts of their work.


```js
@EndUserText.label: 'Customer Service'

define service Z_CustomerService
  exposes Z_Customers
  as draft enabled
{
  create;
  update;
  delete;
}
```

### Implemetation of the CRUD methods

here is an example implementation of the methods for our Z_CustomerService service definition

```js
CLASS ZCL_CUSTOMER_SERVICE IMPLEMENTATION.
  METHOD create_entity.
    DATA(entity_name) = io_data_provider->get_entity_name( ).
    DATA(lv_kunnr) = iv_entity->get_value_set( )->get( 'kunnr' ).
    DATA(lv_name1) = iv_entity->get_value_set( )->get( 'name1' ).
    DATA(lv_city) = iv_entity->get_value_set( )->get( 'city' ).
    DATA(lv_country) = iv_entity->get_value_set( )->get( 'country' ).

    " Perform validation checks on input data
    IF lv_name1 IS INITIAL.
      RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
        EXPORTING
          text = 'Customer name is required.'.
    ENDIF.

    " Create new customer record in database
    DATA(ls_kna1) = VALUE kna1( kunnr = lv_kunnr name1 = lv_name1 city = lv_city country = lv_country ).
    INSERT ls_kna1 INTO TABLE @kna1.

    " Set the response entity key
    io_data->set_key( iv_entity_key ).

    " Return the created entity
    iv_entity->get_value_set( )->set( 'kunnr', lv_kunnr ).
    iv_entity->get_value_set( )->set( 'name1', lv_name1 ).
    iv_entity->get_value_set( )->set( 'city', lv_city ).
    iv_entity->get_value_set( )->set( 'country', lv_country ).
  ENDMETHOD.

  METHOD update_entity.
    DATA(entity_name) = io_data_provider->get_entity_name( ).
    DATA(lv_kunnr) = iv_entity->get_value_set( )->get( 'kunnr' ).
    DATA(lv_name1) = iv_entity->get_value_set( )->get( 'name1' ).
    DATA(lv_city) = iv_entity->get_value_set( )->get( 'city' ).
    DATA(lv_country) = iv_entity->get_value_set( )->get( 'country' ).

    " Perform validation checks on input data
    IF lv_name1 IS INITIAL.
      RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
        EXPORTING
          text = 'Customer name is required.'.
    ENDIF.

    " Update the customer record in database
    DATA(ls_kna1) = VALUE kna1( kunnr = lv_kunnr name1 = lv_name1 city = lv_city country = lv_country ).
    MODIFY kna1 FROM ls_kna1.

    " Return the updated entity
    iv_entity->get_value_set( )->set( 'kunnr', lv_kunnr ).
    iv_entity->get_value_set( )->set( 'name1', lv_name1 ).
    iv_entity->get_value_set( )->set( 'city', lv_city ).
    iv_entity->get_value_set( )->set( 'country', lv_country ).
  ENDMETHOD.

  METHOD delete_entity.
    DATA(entity_name) = io_data_provider->get_entity_name( ).
    DATA(lv_kunnr) = io_data->get_key_value( )->get( 'kunnr' ).

    " Delete the customer record from database
    DELETE kna1 WHERE kunnr = lv_kunnr.

    " Return the deleted entity key
    iv_entity_key->add_key_component( name = 'kunnr' value = lv_kunnr ).
  ENDMETHOD.
ENDCLASS.

```

### Implemetation of filtering and pagination


```js
@EndUserText.label: 'Customer Service'
define service Z_CustomerService {
  
  // Entity set definition
  entity Z_Customer as projection on kna1 {
    key kunnr : CustomerNumber;
    cust_name : Name;
    city : City;
    country : Country;
  };
  
  // Method to retrieve filtered data
  define view Z_CustomerFiltered
    as select from Z_Customer
    association [0..1] to Z_SalesOrders as _SalesOrders
    where cust_name like $parameters.searchString
    order by $parameters.sortBy
    limit $parameters.top skip $parameters.skip;
    
  // Method to retrieve related data
  define view Z_SalesOrders
    as select from vbak
    association [0..1] to Z_Customer as _Customer on $projection.kunnr = _Customer.kunnr;
  
  // Annotations for filtering, sorting and pagination
  @Consumption.filter: { search : ['cust_name'] }
  @Consumption.orderBy: { supportedSegments : ['cust_name', 'city', 'country'], defaultSegment : 'cust_name' }
  @Consumption.limit: { maxRows : 100, pageSize : 20 }
  
  // Method to read filtered data
  define function readFilteredData returns entity Z_Customer[];
  
  // Method to read related data
  define function readRelatedData returns association to Z_SalesOrders;
  
}

```

"In this example, we have defined a new view Z_CustomerFiltered that filters the customer data based on the cust_name property using a dynamic search string parameter. We have also defined an association between the Z_Customer and Z_SalesOrders entities to retrieve the related sales order data.

To enable filtering, sorting, and pagination, we have added the @Consumption.filter, @Consumption.orderBy, and @Consumption.limit annotations, respectively. These annotations define the filter fields, sort fields, and pagination options that the OData runtime should support.

Finally, we have added two new methods readFilteredData and readRelatedData to our service definition to expose the filtered and related data to the OData clients."

**ABAP:**


```abap
// Implementation for readFilteredData method
method Z_CustomerService~readFilteredData
  by database function for read Z_CustomerFiltered
  importing
    value(searchString) type string
    value(top) type i
    value(skip) type i
    value(sortBy) type string
  returning value(result) type Z_Customer[].
  
  // Define the select options for filtering and pagination
  data(select_options) = value rfc_db_select_options(
    select_options = value #( ( name = '$skip' option = 'EQ' low = skip )
                              ( name = '$top' option = 'EQ' low = top )
                              ( name = '$orderby' option = 'EQ' low = sortBy ) )
  ).
  
  // Define the filter criteria
  data(filter) = value #( fieldname = 'cust_name' value = searchString sign = 'I' option = 'CP' ).
  
  // Execute the database query and map the result to our entity type
  result = select from Z_CustomerFiltered( filter = filter, select_options = select_options )
            { kunnr, cust_name, city, country }->to_entity_list( ).
endmethod.


// Implementation for readRelatedData method
method Z_CustomerService~readRelatedData
  by database function for read Z_SalesOrders
  returning value(orders) type association to Z_SalesOrders.

  // Define the filter criteria to retrieve sales orders related to the current customer
  data(filter) = value #( fieldname = '_Customer.kunnr' value = $projection.kunnr sign = 'I' option = 'EQ' ).
  
  // Execute the database query and return the result as an association
  orders = select from Z_SalesOrders( filter = filter )
           association [_Customer] to Z_Customer
           { vbak.vbeln, vbak.erdat, _Customer.kunnr }->to_association( ).
endmethod.
```

### Further steps
 - Activate OData service in SEGW
 - Register the service in /IWFND/MAINT_SERVICE
 - Test using SICF
 - Add functionality for error handling and security


## Annotations and MDE

todo
- MDE
- Annotations


## Generate SAP Fiori Elements App

todo

# Sources

[Tutorial Navigator - Build an SAP Fiori App Using the ABAP RESTful Application Programming Model [RAP100]](https://developers.sap.com/group.sap-fiori-abap-rap100.html)<br/>
[Tutorial Navigator - Create a Travel App with SAP Fiori Elements Based on OData V4 RAP Service](https://developers.sap.com/group.fiori-tools-odata-v4-travel.html)<br/>
[Andre Fischer - RAP Generator Blog-Post](https://blogs.sap.com/2020/05/17/the-rap-generator/)<br/>
[github.com - RAP Generator](https://github.com/SAP-samples/cloud-abap-rap)<br/>