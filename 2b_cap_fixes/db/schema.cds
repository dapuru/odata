namespace northwind;

entity Products {
    key ProductID    : Integer;
        ProductName  : String;
        SupplierID   : Integer; // Not in use currently
        QuantityPerUnit : String;
        UnitPrice	 : Decimal;
        UnitsInStock : Integer;
        UnitsOnOrder : Integer;
        ReorderLevel : Integer;
        Discontinued : Boolean;
        Category     : Association to Categories;
}

entity Categories {
    key CategoryID   : Integer;
        CategoryName : String;
        Description  : String;
        Products     : Association to many Products
                           on Products.Category = $self;
}
