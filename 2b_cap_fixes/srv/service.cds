using northwind from '../db/schema';

service Main {
    entity Products as projection on northwind.Products;
    entity Categories as projection on northwind.Categories;
    function TotalStockCount() returns Integer;
}