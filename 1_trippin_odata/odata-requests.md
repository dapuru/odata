# OData Example Queries

These are sample OData requests. You can run the examples via curl, httpie or wget:

```bash
curl --location --request GET 'http://example-request' --data-raw ''

wget --no-check-certificate --quiet \
  --method GET \
  --timeout=0 \
  --header '' \
   'http://example-request'

http  --follow --timeout 3600 GET 'http://example-request'

```


Or use this postman-collection: [postman Trippin collection](https://documenter.getpostman.com/view/3967924/RW1Yq1Vn#intro)


## GET

| Type | Example | Description |
|--|--|--|
| get meta information | https://services.odata.org/V4/TripPinService/$metadata | information on the data model |
| get collection  | https://services.odata.org/v4/TripPinService/People  |  get the collection of entity "people" |
| select by id | https://services.odata.org/V4/TripPinService/People('scottketchum')  |  get an entity specified by id |
| select & top  | https://services.odata.org/V4/TripPinService/People?$select=FirstName,LastName&$top=5  | get only the first 5 results and only two properties FirstName and LastName  |
| select by attribute | https://services.odata.org/V4/TripPinService/Airports?$filter=contains(Location/City/Region,%20%27California%27) | get a collection of entity "people", which match the given criteria |
|   |   |   |
|   |   |   |
|   |   |   |
|   |   |   |
|   |   |   |
|   |   |   |


## System query options

| Type | Example | Description |
|--|--|--|
| &count=true  | https://services.odata.org/v4/TripPinService/People?$count=true | get the number of returned records included in the result set  |
| url/entity/$count  | https://services.odata.org/v4/TripPinService/People/$count |  get the number of records as integer |
| rl/entity/item/$value  | https://services.odata.org/V4/TripPinService/Airports('KSFO')/Name/$value | get the "raw" data-value   |
| $top and $skip  | https://services.odata.org/V4/TripPinService/Airports?$top=5 | only first 5 records |
| $top and $skip  | https://services.odata.org/V4/TripPinService/Airports?$top=5&$skip=2 | server-side paging  |
| $expand  | https://services.odata.org/V4/TripPinService/People('scottketchum')?$expand=Friends| show relations inline - in the same resource representation|
| $filter | https://services.odata.org/V4/TripPinService/People?$filter=FirstName%20eq%20%27Russell%27 | query filters  |
| $filter | https://services.odata.org/V4/TripPinService/People?$filter=Gender eq Microsoft.OData.SampleService.Models.TripPin.PersonGender'Female' | query filters in enum-types |


For the last example abour $filter, look at the metadata: https://services.odata.org/V4/TripPinService/$metadata to see, why the following would not work:

```bash
https://services.odata.org/V4/TripPinService/People?$filter=Gender eq 'Female'
```

results in error-message "A binary operator with incompatible types was detected. Found operand types 'Microsoft.OData.SampleService.Models.TripPin.PersonGender' and 'Edm.String' for operator kind 'Equal'." - but this one would:

```bash
https://services.odata.org/V4/TripPinService/People?$filter=Gender eq Microsoft.OData.SampleService.Models.TripPin.PersonGender'Female'
```

as specifying an enum in OData filter requires that you include the "type" and then the enum value. So it's required to habe a look at the metadata to get the right type:


```xml
<EnumType Name="PersonGender">
<Member Name="Male" Value="0"/>
<Member Name="Female" Value="1"/>
<Member Name="Unknown" Value="2"/>
</EnumType>

<Property Name="Gender" Type="Microsoft.OData.SampleService.Models.TripPin.PersonGender"/>
```




## POST


| Type | Example | Description |
|--|--|--|
|   |   |   |
|   |   |   |