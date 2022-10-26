# OData by Example

These are some code-snippets and examples for OData.
The examples are implemented using [SAP CAP](https://cap.cloud.sap/docs/) (Cloud Application Programing model),
and are based on various example-data, starting with OData.org services Northwind and TripPin.
The examples describes below can be found in the corresponding subfolders.

Last Updated: 25.10.2022
Status: Released

For background information see:<br>
[SAP Community - Daniel Purucker: Howto OData – High level overview](https://blogs.sap.com/2022/01/22/howto-odata-high-level-overview/)<br>
[Github - SAP Samples, OData Handsonsapdev](https://github.com/SAP-samples/odata-basics-handsonsapdev)<br>
[https://www.odata.org/](https://www.odata.org/)


# Example 1 - OData service and CDS using CAP

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
