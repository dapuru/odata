# OData Example Queries

These are sample OData requests based on the odata.org sample TripPin service. You can run the requests eg. via curl, httpie or wget:

```bash
curl --location --request GET 'http://example-request' --data-raw ''

wget --no-check-certificate --quiet \
  --method GET \
  --timeout=0 \
  --header '' \
   'http://example-request'

http  --follow --timeout 3600 GET 'http://example-request'

```


Or use this postman-collection: [postman Trippin collection](https://www.odata.org/getting-started/learning-odata-on-postman/)


## GET

| Type | Example | Description |
|--|--|--|
| get meta information | https://services.odata.org/V4/TripPinService/$metadata | information on the data model |
| get collection  | https://services.odata.org/v4/TripPinService/People  |  get the collection of entity "people" |
| select by id | https://services.odata.org/V4/TripPinService/People('scottketchum')  |  get an entity specified by id |
| get property  |  https://services.odata.org/V4/TripPinService/Airports('KSFO')/Name | request individual property |
| raw-value | https://services.odata.org/V4/TripPinService/Airports('KSFO')/Name/$value  | request raw value  |



## System query options

| Type | Example | Description |
|--|--|--|
| &count=true  | https://services.odata.org/v4/TripPinService/People?$count=true | get the number of returned records included in the result set  |
| url/entity/$count  | https://services.odata.org/v4/TripPinService/People/$count |  get the number of records as integer |
| url/entity/item/$value  | https://services.odata.org/V4/TripPinService/Airports('KSFO')/Name/$value | get the "raw" data-value   |
| $orderby | https://services.odata.org/V4/TripPinService/People('scottketchum')/Trips?$orderby=EndsAt desc | ascending or descending order, default is ascending |
| $top and $skip  | https://services.odata.org/V4/TripPinService/Airports?$top=5 | only first 5 records |
| $top and $skip  | https://services.odata.org/V4/TripPinService/Airports?$top=5&$skip=2 | server-side paging  |
| select & top  | https://services.odata.org/V4/TripPinService/People?$select=FirstName,LastName&$top=5  | get only the first 5 results and only two properties FirstName and LastName  |
| select by attribute | https://services.odata.org/V4/TripPinService/Airports?$filter=contains(Location/City/Region,%20%27California%27) | get a collection of entity "people", which match the given criteria |
| $expand  | https://services.odata.org/V4/TripPinService/People('scottketchum')?$expand=Friends| show relations inline - in the same resource representation|
| $search | https://services.odata.org/V4/TripPinService/People?$search=Boise  | Behaviour is dependent on the implementation |
| $filter | https://services.odata.org/V4/TripPinService/People?$filter=FirstName%20eq%20%27Russell%27 | query filters  |
| $filter on enum | https://services.odata.org/V4/TripPinService/People?$filter=Gender eq Microsoft.OData.SampleService.Models.TripPin.PersonGender'Female' | query filters in enum properties |


For the last example abour $filter, look at the metadata: https://services.odata.org/V4/TripPinService/$metadata to see, why the following would not work:

```bash
https://services.odata.org/V4/TripPinService/People?$filter=Gender eq 'Female'
```

This results in an error-message "A binary operator with incompatible types was detected. Found operand types 'Microsoft.OData.SampleService.Models.TripPin.PersonGender' and 'Edm.String' for operator kind 'Equal'." - but this one would work:

```bash
https://services.odata.org/V4/TripPinService/People?$filter=Gender eq Microsoft.OData.SampleService.Models.TripPin.PersonGender'Female'
```

as specifying an enum in OData filter requires to include the "type" and then the enum value. So it's required to have a look at the metadata to construct the right request:


```xml
<EnumType Name="PersonGender">
<Member Name="Male" Value="0"/>
<Member Name="Female" Value="1"/>
<Member Name="Unknown" Value="2"/>
</EnumType>

<Property Name="Gender" Type="Microsoft.OData.SampleService.Models.TripPin.PersonGender"/>
```




## POST - CRUD

These requests can not be done directly with links, as the payload needs to be provided.

### Create

Be careful, which data to put there, as they are written to the service - but will be reset on a regular basis.

```bash
POST https://services.odata.org/V4/TripPinService/People
```

```json
{
    "UserName":"hansmuster",
    "FirstName":"Hans",
    "LastName":"Mustermann",
    "Emails":[
        "hans@mustermann.com"
    ],
    "AddressInfo": [
    {
      "Address": "Hauptstrasse 23",
      "City": {
        "Name": "Berlin",
        "CountryRegion": "Germany",
        "Region": "Berlin"
      }
    }
    ]
}
```

use eg:

```bash
printf 'json-goes-here'| http  --follow --timeout 3600 POST 'https://services.odata.org/V4/TripPinService/People' Content-Type:'application/json'
```

Result:

```bash
HTTP/1.1 201 Created
Access-Control-Allow-Origin: *
Cache-Control: no-cache
Content-Length: 556
Content-Type: application/json;odata.metadata=minimal;odata.streaming=true;IEEE754Compatible=false;charset=utf-8
Date: xx GMT
ETag: W/"08DABE7B5B4C50A5"
Location: http://services.odata.org/V4/TripPinService/People('hansmuster')
OData-Version: 4.0
Server: Microsoft-IIS/10.0
X-AspNet-Version: 4.0.30319
X-Powered-By: ASP.NET

{
    "@odata.context": "http://services.odata.org/V4/TripPinService/$metadata#People/$entity",
    "@odata.editLink": "http://services.odata.org/V4/TripPinService/People('hansmuster')",
    "@odata.etag": "W/\"08DABE7B5B4C50A5\"",
    "@odata.id": "http://services.odata.org/V4/TripPinService/People('hansmuster')",
    "AddressInfo": [
        {
            "Address": "Hauptstrasse 23",
            "City": {
                "CountryRegion": "Germany",
                "Name": "Berlin",
                "Region": "Berlin"
            }
        }
    ],
    "Concurrency": 638031734248329381,
    "Emails": [
        "hans@mustermann.com"
    ],
    "FirstName": "Hans",
    "Gender": "Male",
    "LastName": "Mustermann",
    "UserName": "hansmuster"
}
```


Afterwards you can requets this record, as usual, via: https://services.odata.org/V4/TripPinService/People('hansmuster')


### Update

```json
{
    "UserName":"hansmuster",
    "FirstName": "Hansi",
    "LastName": "Musterfrau"
}
```

```bash
PATCH https://services.odata.org/V4/TripPinService/People('hansmuster')
```

use eg:

```bash
printf 'json-goes-here'| http  --follow --timeout 3600 PATCH 'https://services.odata.org/V4/TripPinService/People('\''hansmuster'\'')' Content-Type:'application/json'
```

In case you get an error message returned "HTTP/1.1 428 Precondition Required" you need to provide an "If-Match" or "If-None-Match"-Header = <ETAG> according to [OData Protocol Chapter 8.2.4](http://docs.oasis-open.org/odata/odata/v4.01/csprd04/part1-protocol/odata-v4.01-csprd04-part1-protocol.html#sec_HeaderIfMatch) and provide the ETAG from the create statement like in the enxt command (replace your [ETAG](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/ETag) accordingly).

```bash
printf 'json-goes-here'| http  --follow --timeout 3600 PATCH 'https://services.odata.org/V4/TripPinService/People('\''hansmuster'\'')' Content-Type:'application/json' If-None-Match:'W/\"08DABF112358DA68\"'
```


### Delete

```bash
DELETE https://services.odata.org/V4/TripPinService/People('hansmuster')
```

Same as above, perhaps the ETAG is required.

use eg:
```bash
http  --follow --timeout 3600 DELETE 'https://services.odata.org/V4/TripPinService/People('\''hansmuster'\'')' If-None-Match:'W/\"08DABF112358DA68\"'
```



## Functions

see [OData - Back to basics](https://blog.daniel-purucker.com/odata-back-to-basics/) and [Getting Started - Functions and Actions](https://www.odata.org/getting-started/basic-tutorial/#operation):

- Function
  read-only, quote from the sepc: "functions **MUST** return data and **MUST NOT** have observables side effects". So they are http GET-Requests.
  Types: bound vs. unbound (see: [https://cap.cloud.sap/docs/cds/cdl#actions](https://cap.cloud.sap/docs/cds/cdl#actions)) Functions are *defined* at service level.

- Action
  does something - CreateUpdateDelete on the server, quote from the spec: "Actions are operations exposed by an OData service that **MAY** have side effects when invoked. So they are http POST-Requests. Definition and Implementation same as in Functions.

The example *function* of the Trippin-Service is "GetNearestAirport":
"The function below returns the nearest airport with the input geography point.":

```bash
http  --follow --timeout 3600 GET 'https://services.odata.org/V4/TripPinService/GetNearestAirport(lat = 33, lon = -118)'
```

```bash
http  --follow --timeout 3600 GET 'https://services.odata.org/V4/TripPinService/People('\''russellwhyte'\'')/Microsoft.OData.SampleService.Models.TripPin.GetFavoriteAirline()'
```
