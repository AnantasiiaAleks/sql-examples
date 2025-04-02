/*
Задание 1: Ранжирование продуктов по средней цене
 Задание: Ранжируйте продукты в каждой категории на основе их средней цены
 (AvgPrice). Используйте таблицы OrderDetails и Products.
 Результат: В результате запроса будут следующие столбцы:
 ● CategoryID: идентификатор категории продукта,
 ● ProductID: идентификатор продукта,
 ● ProductName: название продукта,
 ● AvgPrice: средняя цена продукта,
 ● ProductRank: ранг продукта внутри своей категории на основе средней цены в
 порядке убывания.
 Подсказка:
 1. Рассчитайте среднюю цену продукта: Начните с создания подзапроса (или
 CTE), в котором будете вычислять среднюю цену (AVG(Price)) для каждого
 продукта. Объедините таблицы OrderDetails и Products с помощью JOIN.
 2. Ранжируйте продукты по средней цене: Используйте оконную функцию
 RANK() для ранжирования продуктов по средней цене внутри каждой
 категории. Убедитесь, что вы применяете PARTITION BY для разделения по
 категориям и ORDER BY для упорядочивания по убыванию средней цены.
*/
with cte as (
	select
	p."CategoryID" as categ_id,
	p."ProductID" as prod_id,
	p."ProductName" as prod_name,
	avg(p."Price") as AvgPrice
	from
	products p 
	join
	orderdetails o 
	on o."ProductID" = p."ProductID" 
	group by p."CategoryID", p."ProductID", p."ProductName" 
	)
select 
cte.categ_id,
cte.prod_id,
cte.prod_name,
c."CategoryName",
cte.AvgPrice,
rank() over (partition by cte.categ_id order by AvgPrice desc) as ProductRank
from cte
join categories c on cte.categ_id = c."CategoryID";



/*
 Задание 2: Средняя и максимальная сумма кредита по месяцам
 Задание: Рассчитайте среднюю сумму кредита (AvgCreditAmount) для каждого
 кластера в каждом месяце и сравните её с максимальной суммой кредита
 (MaxCreditAmount) за тот же месяц. Используйте таблицу Clusters.
 Подсказка:
1. Рассчитайте среднюю сумму кредита: Используйте подзапрос (или CTE) для
 вычисления средней суммы кредита (AVG(credit_amount)) для каждого
 кластера в каждом месяце.
 2. Рассчитайте максимальную сумму кредита: Создайте другой подзапрос для
 вычисления максимальной суммы кредита (MAX(credit_amount)) для каждого
 месяца.
 3. Объедините результаты: Используйте JOIN для объединения результатов
 двух подзапросов по месяцу и выведите нужные столбцы.
  Результат: В результате запроса будут следующие столбцы:
 ● month:месяц,
 ● cluster: кластер,
 ● AvgCreditAmount: средняя сумма кредита для каждого кластера в каждом
 месяце,
 ● MaxCreditAmount: максимальная сумма кредита в каждом месяце
*/

with 
cte_avg as (
	select
	"cluster",
	month,
	round(avg(credit_amount), 2) as AvgCreditAmount
	from clusters c 
	group by "month", "cluster" ),
cte_max as (
	select 
	month,
	max(credit_amount) as MaxCreditAmount
	from clusters c 
	group by month )
select
cte_avg.month,
cte_avg."cluster",
cte_avg.AvgCreditAmount,
cte_max.MaxCreditAmount
from cte_avg
join cte_max on cte_avg.month = cte_max.month
order by cte_avg.month, cte_avg.cluster;

/*
Задание 3: Разница в суммах кредита по месяцам
 Задание: Создайте таблицу с разницей (Difference) между суммой кредита и
 предыдущей суммой кредита по месяцам для каждого кластера. Используйте таблицу
 Clusters.
 Подсказка:
 1. Получите сумму кредита и сумму кредита в предыдущем месяце:
 Используйте функцию оконного анализа LAG() для получения суммы кредита в
 предыдущем месяце в рамках каждого кластера.
2. Вычислите разницу: Используйте результат предыдущего шага для
 вычисления разницы между текущей и предыдущей суммой кредита.
 COALESCE() для обработки возможных значений NULL.
 Результат: В результате запроса будут следующие столбцы:
 ● month:месяц,
 ● cluster: кластер,
 ● credit_amount: сумма кредита,
 ● PreviousCreditAmount: сумма кредита в предыдущем месяце,
 ● Difference: разница между текущей и предыдущей суммой кредита.
*/

select
"cluster",
credit_amount,
coalesce (lag(credit_amount, 1) over (order by month), 0) as previous_credit_amount,
coalesce(credit_amount - (lag(credit_amount, 1)  over (order by month)), 0) as difference
from clusters c
order by "month", "cluster" ;
