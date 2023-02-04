# ABAP Programming model for SAP Fiori

todo, what's that and why should i use it.

## Prerequisites

You would need an ABAP System >= Netweaver 7.50 and access to a SAP Gateway system.
BTP: [SAP BTP Trial](https://www.sap.com/products/technology-platform/trial.html)
ABAP Environment: [Create an SAP BTP ABAP Environment Trial User](https://developers.sap.com/tutorials/abap-environment-trial-onboarding.html)


## Steps for implementation

(1) Create a CDS views (Interface and Consumption) as Data Model (DDL) in ADT
(2) Generate OData Service with auto-exposure based on SADL (Service Adaptation Description Language) by adding the annotation “@OData.publish:true” to the CDS.
(see here for different possibilities: Exposing CDS Entities as OData Service – SAP Help Portal). As a result “several SAP Gateway artifacts” are being created, which need to be activated in the SAP Gateway Hub for exposure (/n/IWFND/MAINT_SERVICE).
(3) Consume data (test using the SAP Gateway Client)
(4) Create a SAP Fiori Elements application


For details see:
[SAP - ABAP Programming Model for SAP Fiori](https://help.sap.com/docs/SAP_NETWEAVER_AS_ABAP_751_IP/cc0c305d2fab47bd808adcad3ca7ee9d/32bc41261af445e08182c8532032f950.html?locale=en-US)




### Create a package and a dictionary table

> **Note**
> You can skip this step, in case you access a standard table or a nested CDS-view.

- Create a new packge *ZDPU*
- Create a table *ZSALES* with the structure like:

```js
    key Item.SalesOrder                          as SalesOrderID, 
	key Item.SalesOrderItem                      as ItemPosition, 
	Item._SalesOrder._Customer.CompanyName  	as CompanyName,
	Item.Product                            	as Product, 
	@Semantics.currencyCode: true
	Item.TransactionCurrency                	as CurrencyCode,
	@Semantics.amount.currencyCode: 'CurrencyCode'
	Item.GrossAmountInTransacCurrency       	as GrossAmount, 
	@Semantics.amount.currencyCode: 'CurrencyCode'
	Item.NetAmountInTransactionCurrency     	as NetAmount, 
	@Semantics.amount.currencyCode: 'CurrencyCode'
	Item.TaxAmountInTransactionCurrency     	as TaxAmount,
	Item.ProductAvailabilityStatus          	as ProductAvailabilityStatus
```


### CDS-View as data model


- Use ADT to create a **DDL Source** "Data Definition" named *ZDPU_DDL_BUT000* using the "Define View" Template.
  ![Core Data Services - Data Definition](img/1_CDS-DataDefinition.png) 

With the following coding, you'll get an error message.

```js
@AbapCatalog.sqlViewName: ''
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'List Report for BUT000'
define view ZDPU_DDL_BUT000 as select from BUT000 as Item
{
    contact
}
```

BUT000 is a standard SAP Table which is used to store BP: General data and is available within R/3 SAP systems. In ABAP Cloud systems (BTP) you cannot access this table directly.
Instead use the released object I_BUSINESSPARTNER. 

### Auto-expose OData service


### Test


### Consume service via SAP Fiori Elements




## more...

https://blogs.sap.com/2017/07/04/maintain-businesspartner-master-data-using-odata-apis-in-a-sap-s4hana-cloud-system/


## Resources

See [About ABAP Programming Model for SAP Fiori](https://help.sap.com/docs/SAP_NETWEAVER_750/cc0c305d2fab47bd808adcad3ca7ee9d/3b77569ca8ee4226bdab4fcebd6f6ea6.html?locale=en-US) for a detailed step-by-step guide, as well as the blog-post by Andre Fischer [How to develop a transactional app using the new ABAP Programming Model for SAP Fiori](https://blogs.sap.com/2017/09/14/how-to-develop-a-transactional-app-using-the-new-abap-programming-model-for-sap-fiori/)




