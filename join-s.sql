/*
 Задание №1: Анализ влияния категорий продуктов на общий доход
 Описание: Вам необходимо проверить, как различные категории продуктов влияют на
 общий доход (общую сумму заказов) в таблице OrderDetails. Подсчитайте общее
 количество заказов (сумму количества) и общий доход (сумму количества * цену) для
 каждой категории продуктов. Выведите результаты, включая:
 ● CategoryID
 ● Общееколичество заказов (total_quantity)
 ● Общийдоход(total_revenue)
 Отсортируйте результаты по убыванию общего дохода (total_revenue). Используйте
 таблицы Products, OrderDetails и Categories.
 Подсказка: Используйте объединение таблиц (JOIN) и агрегатные функции SUM() и
 GROUP by
*/

select 
p."CategoryID" as category,
sum(od."Quantity") as total_quantity,
sum(p."Price" * od."Quantity") as total_revenue
from orderdetails od
join products p
on p."ProductID"  = od."ProductID" 
group by category
order by total_revenue desc;


/*
Задание №2: Анализ частоты заказа продуктов по категориям
 Описание: Напишите запрос SQL для подсчета количества заказов продуктов по
 каждой категории. Подсчитайте количество уникальных заказов (OrderID) для каждой
 категории продуктов. Выведите результаты, включая:
 ● CategoryID
 ● Количество уникальных заказов (order_count)
 Отсортируйте результаты по убыванию количества уникальных заказов
 (order_count). Используйте таблицы Products, OrderDetails и Categories.
 Подсказка: Используйте объединение таблиц (JOIN), агрегатные функции
 COUNT(DISTINCT ...) и GROUP BY.
*/

select 
p."CategoryID",
count(distinct od."OrderID") as order_count
from orderdetails od 
join products p
on p."ProductID" = od."ProductID"
group by p."CategoryID" ;

/*
 Задание №3: Вывод наиболее популярных продуктов по количеству
 заказов
 Описание: Выведите список продуктов (название ProductName), отсортированных по
 количеству заказов в порядке убывания. Подсчитайте общее количество заказов
 (Quantity) для каждого продукта. Выведите результаты, включая:
 - ProductName
 - Общее количество заказов (total_quantity)
Отсортируйте результаты по убыванию общего количества заказов (total_quantity).
 Используйте таблицы Products и OrderDetails.
 Подсказка: Используйте агрегатные функции SUM() и GROUP BY, а также сортировку
 ORDER BY.
*/

select 
p."ProductName",
sum(o."Quantity") as total_quantity
from products p
join orderdetails o 
on o."ProductID" = p."ProductID" 
group by p."ProductName" 
order by total_quantity desc;

/*
 Задание 1: Анализ прибыли по категориям продуктов
 Задание: Определите общую прибыль для каждой категории продуктов,
 используя таблицы OrderDetails, Orders и Products. Для расчета прибыли
 умножьте цену продукта на количество, а затем суммируйте результаты по
 категориям.
 Подсказка: Используйте JOIN для объединения таблиц OrderDetails,
 Orders, Products и Categories. Примените агрегацию с функцией SUM.
*/

select 
c."CategoryName",
round(sum(p."Price" * od."Quantity")::numeric, 2) as total_profit
from "Categories" c 
join "Products" p 
on p."CategoryID" = c."CategoryID" 
join "OrderDetails" od 
on od."ProductID" = p."ProductID" 
group by c."CategoryName" 
order by total_profit desc;

/*
 Задание 2: Количество заказов по регионам
 Задание:
 Определите количество заказов, размещенных клиентами из различных стран, за
 каждый месяц.
 Подсказка:
Используйте JOIN для объединения таблиц Orders и Customers. Для извлечения
 месяца и года из даты используйте функцию EXTRACT.
*/

 select
 c."Country" as Country,
 extract(month from o."OrderDate"::date) as Month,
 extract(year from o."OrderDate"::date) as Year,
 count(o."OrderID") as OrderCount
 from "Orders" o
 join "Customers" c on o."CustomerID" = c."CustomerID"
 group by c."Country", Month, Year;
 

/*
 Задание 3: Средняя продолжительность кредитного срока для
 клиентов
 Задание: Рассчитайте среднюю продолжительность кредитного срока для
 клиентов по категориям образования.
 Подсказка: Используйте таблицу Clusters и функцию AVG для вычисления
 средней продолжительности кредитного срока.
*/

select 
c.education,
avg(c.credit_term) as avg_credit_term
from "Clusters" c 
group by c.education 
order by avg_credit_term;