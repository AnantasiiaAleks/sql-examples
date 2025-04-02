/*
 *  Задание 1: Создание таблицы и изменение данных
 Задание: Создайте таблицу EmployeeDetails для хранения информации о
 сотрудниках. Таблица должна содержать следующие столбцы:
 ● EmployeeID(INTEGER, PRIMARY KEY)
 ● EmployeeName (TEXT)
 ● Position(TEXT)
 ● HireDate(DATE)
 ● Salary(NUMERIC)
 После создания таблицы добавьте в неё три записи с произвольными данными о
 сотрудниках.
*/

create table EmployeeDetails (
	EmployeeID int primary key,
	EmployeeName text,
	position text,
	HireDate date,
	Salary numeric
);

insert into EmployeeDetails values 
	(12, 'Ivanov Ivan Ivanovich', 'first position', '2021-09-24', 54000.00),
	(183, 'Petrov Petr Petrovich', 'second position', '2022-10-23', 44500.00),
	(399, 'Merslikina Nadezhda Ignatievna', 'fifth position', '2024-12-31', 29200.00);
	

/*
 Задание 2: Создание представления
 Задание: Создайте представление HighValueOrders для отображения всех заказов,
 сумма которых превышает 10000. В представлении должны быть следующие столбцы:
 ● OrderID(идентификатор заказа),
 ● OrderDate(дата заказа),
 ● TotalAmount (общая сумма заказа, вычисленная как сумма всех Quantity *
 Price).
 Используйте таблицы Orders, OrderDetails и Products.
 Подсказки:
 1. Используйте JOIN для объединения таблиц.
 2. Используйте функцию SUM() для вычисления общей суммы заказа.
*/

create view HighValueOrders as
	select
	o."OrderID",
	o."OrderDate", 
	sum(od."Quantity" * p."Price") as TotalAmount
	from orders o
	join orderdetails od on o."OrderID" = od."OrderID"
	join products p on od."ProductID" = p."ProductID"
	group by o."OrderID", o."OrderDate"
	having sum(od."Quantity" * p."Price") > 10000;
	
select * from highvalueorders h 

/*
 Задание 3: Удаление данных и таблиц
 Задание: Удалите все записи из таблицы EmployeeDetails, где Salary меньше
 50000. Затем удалите таблицу EmployeeDetails из базы данных.
 Подсказки:
 1. Используйте команду DELETE FROM для удаления данных.
 2. Используйте команду DROP TABLE для удаления таблицы.
*/

delete from employeedetails 
where salary < 50000;

drop table employeedetails;

/*
 Задание 4: Создание хранимой процедуры
 Задание: Создайте хранимую процедуру GetProductSales с одним параметром
 ProductID. Эта процедура должна возвращать список всех заказов, в которых
 участвует продукт с заданным ProductID, включая следующие столбцы:
 ● OrderID(идентификатор заказа),
 ● OrderDate(дата заказа),
 ● CustomerID(идентификатор клиента).
 Подсказки:
 1. Используйте команду CREATE PROCEDURE для создания процедуры.
 2. Используйте JOIN для объединения таблиц и WHERE для фильтрации данных по
 ProductID.
*/

create or replace procedure GetProductSales(ProductID int) language plpgsql as $$
begin 
	perform 
	o."OrderID",
	o."OrderDate",
	o."CustomerID" 
	from Orders o
	join orderdetails od on o."OrderID" = od."OrderID" 
	join products p on od."ProductID" = p."ProductID" 
	where p."ProductID" = ProductID;
END; $$
