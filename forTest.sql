/*
Предварительно еще в гугл-таблице изменила формат даты, 
а также массовой заменой в столбцах со стоимостью поменяла запятую на точку,
чтобы при импорте в DBeaver можно было корректно расставить типы данных для проверки скрипта
*/


/*
1.1 Напишите SQL-запрос, чтобы вычислить количество заказов, отправленных в каждую страну.
Требование: результат запроса не нужен, требуется только сам запрос.
Ожидаемый итог запроса: Страна, Количество заказов.
*/

-- select * from fortest c 

select
"Country" "Страна",
count(distinct "Order_number") "Количество заказов"
from fortest 
group by "Country"


/*
1.2 Напишите SQL-запрос, чтобы посчитать доход за каждый месяц и абсолютный прирост дохода относительно предыдущего месяца.
Требование: результат запроса не нужен, требуется только сам запрос.
Ожидаемый итог запроса: Месяц, Доход, Прирост относительно предыдущего месяца.
*/

with montly_profit as (
	select
	extract(month from "Created_at") as month,
	sum("Total_order_cost") as profit
	from fortest c 
	group by month)
select 
*,
profit - lag(profit) over (order by month asc) as profit_growth
from montly_profit



/*
1.3 Задача: Напишите SQL-запрос для подсчета процента оплаченных (Is paid) заказов от общего количества заказов по каждому продавцу.
Требование: Результат запроса не нужен, требуется только сам запрос.
Ожидаемый итог запроса: Продавец, Процент оплаченных заказов.
*/



with true_table as (
	select
	"Seller",
	count("Is_paid") as "Paid"
	from fortest f
	where "Is_paid" = true 
	group by "Seller" ),
	all_table as (
	select
	"Seller",
	count("Is_paid") as "All"
	from fortest f
	group by "Seller")
select
p."Seller",
(p."Paid" * 100 / a."All") as percent
from true_table p
join all_table a
on a."Seller" = p."Seller"

