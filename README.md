# OData by Example

These are some code-snippets and examples for OData.
The examples are implemented using [SAP CAP](https://cap.cloud.sap/docs/) (Cloud Application Programing model), and are based on various example-data, starting with OData.org services Northwind and TripPin. The examples describes below can be found in the corresponding subfolders.

Last Updated: 31.10.2022 <br>
Status: Released


For background information see:<br>
[SAP Community - Daniel Purucker: Howto OData – High level overview](https://blogs.sap.com/2022/01/22/howto-odata-high-level-overview/)<br>
[Github - SAP Samples, OData Handsonsapdev](https://github.com/SAP-samples/odata-basics-handsonsapdev)<br>
[https://www.odata.org/](https://www.odata.org/)



# Example 1 - Direct access to a sample OData service

These examples are based on the [odata.org TripPin service](https://www.odata.org/blog/trippin-new-odata-v4-sample-service/) The examples are collected in the folder "1_trippin_odata".

The calls can be directly used in the browser, via [curl](https://curl.se/) or [postman](https://www.postman.com/).


Resources:
https://www.odata.org/odata-services/service-usages/trippin-advanced-usages/
https://learn.microsoft.com/en-us/power-query/samples/trippin/readme



# Example 2 - OData service and CDS using CAP

This first example is described in the [walkthrough "Build Your First OData-Based Backend Service"](https://developers.sap.com/group.scp-8-odata-service.html).
It basically consists of CDS-views for modeling the entites ([domain modeling](https://cap.cloud.sap/docs/guides/domain-models)) and service-definition. The OData service is provided by SAPs CAP, initial data is provided by [csv-files](https://cap.cloud.sap/docs/guides/databases#providing-initial-data). It's mindblowing to see, that you actually only need to create 3 files (including the actual data in csv-format) to get an working OData service. It's a stripped-down implementation of the famous [Northwind example service](https://services.odata.org/V4/Northwind/Northwind.svc/$metadata).
The csv-files can be found at [https://github.com/neo4j-contrib/northwind-neo4j/tree/master/data](https://github.com/neo4j-contrib/northwind-neo4j/tree/master/data).


Folders:
- app/ = Frontend, eg. the UI5 application goes here (optional)
- srv/ = business logic & service definition
- db/  = entity definition and database/persistence layer

Basic service:

|File | Description | Comment |
|--|--|--|
| db/schema.cds | entity-definition | firstly only contains products |
| db/data/northwind-Products.csv| The actual data | currently for one entity products |
| srv/service.cds | service-definition | simple, as projection |

Enhanced service with relation:

|File | Description | Comment |
|--|--|--|
| db/schema.cds | entity-definition | changed: added entity categories |
| srv/service.cds | service-definition | changed: added exposure of categories |
| db/data/northwind-Products.csv| changed: added foreign key relation to categories | |
| db/data/northwind-Categories.csv| The actual data | new file for categories |
| srv/service.cds | service-definition | no change |

Relation is made via:

```cds
namespace northwind;

entity Products {
    key ProductID    : Integer;
		... rest omitted ...
        Category     : Association to Categories;

entity Categories {
    key CategoryID   : Integer;
        CategoryName : String;
        Description  : String;
        Products     : Association to many Products
                           on Products.Category = $self;
}
```

Relevant part in the medadata xml:

```xml
<NavigationProperty Name="Category" Type="Main.Categories" Partner="Products">
<ReferentialConstraint Property="Category_CategoryID" ReferencedProperty="CategoryID"/>
</NavigationProperty>
```

OData-Queries:

```
http://localhost:4004/main/Products(1)
http://localhost:4004/main/Products?$filter=ProductName eq 'Chai'
http://localhost:4004/main/Products?$count=true
http://localhost:4004/main/Products?$expand=Category
http://localhost:4004/main/Products?$filter=ProductName eq 'Chai'&$expand=Category
http://localhost:4004/main/Products?$filter=Category_CategoryID%20eq%202&$expand=Category
http://localhost:4004/main/Products?$expand=Category($filter=CategoryName eq 'Beverages')&$count=true --> currently leads to "Allowed query option expected"... tbd
```

Notes:
- Foreign key relation / association in this case is "managed"
- the Referential constraint can be seen in the metadata xml - use this property in the csv-file.
- The name of the csv-File corresponds to the namespace and entity.
- Nested filters in expand can be tricky (and only possible in OData v4 - get info using "cds env", CAP is default v4)

Resources:
[Domain modeling with CDS](https://cap.cloud.sap/docs/guides/domain-models)
[CAP on associations](https://cap.cloud.sap/docs/guides/domain-models#associations--structured-models)
[OData Querying data](https://www.odata.org/getting-started/basic-tutorial/)


# Example 3 - Added business logic with CAP

The data model is the same as in example one. However, there is some logic added by adding [event handlers](https://developers.sap.com/tutorials/odata-07-extend-custom-code.html). This is not specific to OData, but *provided by SAP CAP*.

The logic - or so called service implementation - is added in a "sibling .js files next to .cds sources" with the same name (see [SAP CAP - How to Implement Services](https://cap.cloud.sap/docs/node.js/services#srv-impls)). The file could as well be placed in a ./lib or ./handlers subfolder.

|File | Description | Comment |
|--|--|--|
| srv/service.cds | service-definition | no change |
| srv/service.js | service-implementation | added in the same folder |

There are are several **event handlers to be registered** through the [Handler Registration API](https://cap.cloud.sap/docs/node.js/services#event-handlers). Cheat-sheet on when to use which handler:

|Event | Description | use-case |
|--|--|--|
| srv.on | run in sequence  | filtering results or replace default behaviour completely |
| srv.before | runs before srv.on() and generic handlers | add custom input validation |
| srv.after | runs after generic handlers *on the results* | modify response |
| srv.reject | "automatically rejects incoming requests with a standard error message" | |
| srv.prepend | before already registered handlers | override handlers from reused services |


The general structure of the Node.js module export mechanism and the called anonymous function is:

```cap
module.exports = srv => {
    srv.event('READ','entity', items => {
        return...
    })
}
```

Example for filtering at srv.on:

```cap
module.exports = srv => {
    srv.on('READ', 'Products', async (req, next) => {
        const items = await next()
        return items.filter(item => item.UnitsInStock > 100)
    })
}
```

Be aware, when implementing this filter, the argument ?$count=true doesn't work any longer - and Fiori elements doesn't show the data - kind of not so nice!
see [answers.sap.com - CAP Custom event handlers & OData queries](https://answers.sap.com/questions/12966178/cap-custom-event-handlers-odata-queries.html): "Most query options like $filter and $sort are pushed to the database and not applied to the result set your custom handler returns. Hence, you must deal with those yourself."

```bash
http://localhost:4004/main/Products?$count=true
```


Resources:
[SAP CAP - How to Implement Services](https://cap.cloud.sap/docs/node.js/services#srv-impls)
[SAP CAP - Handler Registration API](https://cap.cloud.sap/docs/node.js/services#event-handlers)

