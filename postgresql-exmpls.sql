-- Создание базы данных
CREATE DATABASE company;


-- Создание таблицы departments
CREATE TABLE company.public.departments (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);

-- Создание таблицы jobs
CREATE TABLE company.public.jobs (
    id SERIAL PRIMARY KEY,
    title VARCHAR(100) NOT NULL,
    salary NUMERIC(10, 2) NOT NULL
);

-- Создание таблицы employees
CREATE TABLE company.public.employees (
    id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    department_id INTEGER REFERENCES company.public.departments(id),
    job_id INTEGER REFERENCES company.public.jobs(id)
);


-- Заполнение таблицы departments
INSERT INTO company.public.departments (name) VALUES
('HR'),
('IT'),
('Sales'),
('Marketing');

-- Заполнение таблицы jobs
INSERT INTO company.public.jobs (title, salary) VALUES
('Manager', 60000),
('Developer', 55000),
('Sales Associate', 45000),
('Marketing Specialist', 50000);

-- Заполнение таблицы employees
INSERT INTO company.public.employees (first_name, last_name, department_id, job_id) VALUES
('John', 'Doe', 1, 1),
('Jane', 'Smith', 2, 2),
('Mike', 'Johnson', 3, 3),
('Emily', 'Davis', 4, 4);




CREATE TABLE company.public.locations (location_id int PRIMARY KEY, city varchar(30), postal_code varchar(12));




-- Найти профессию, диапазон которой между минимальной и максимальной
-- зарплатой меньше, чем у остальных профессий.

WITH salary_ranges AS (
    SELECT title, MAX(salary) - MIN(salary) AS salary_range
    FROM jobs
    GROUP BY title
)
SELECT title
FROM salary_ranges
WHERE salary_range < (SELECT MIN(salary_range) FROM salary_ranges);

-- Вывести названия профессий(job_title) и среднюю зарплату (в диапазоне от 2000
-- до 5000) сотрудников этих профессий.


SELECT title, AVG(salary) AS average_salary
FROM jobs
WHERE salary BETWEEN 2000 AND 5000
GROUP BY title;



/*Функция select_data в PostgreSQL получает на вход код отдела и
выводит информацию из таблицы departments, фильтруя данные по коду отдела.*/

CREATE OR REPLACE FUNCTION select_data(id_dept int)
RETURNS SETOF departments AS $$
BEGIN
	RETURN QUERY 
	SELECT * FROM departments
	WHERE departments.id > id_dept;
END;
$$ LANGUAGE plpgsql;


select * from select_data(2);


-- Вызов функции, созданной в IDE
select * from select_data1(1);



--Функция подсчета доли заработной платы сотрудника в общем фонде заработной платы
CREATE OR REPLACE FUNCTION share_of_total()
RETURNS TABLE(last_name varchar, first_name varchar, salary numeric, share_of_sumsalaries numeric) AS $$
BEGIN 
  RETURN QUERY
  WITH cte AS (
    SELECT 
      e.last_name,
      e.first_name,
      j.salary::numeric, 
      SUM(j.salary) OVER () AS totalsum
    FROM employees e
    JOIN jobs j ON j.id = e.job_id
  )
  SELECT 
    cte.last_name, 
    cte.first_name, 
    cte.salary,
    ROUND((cte.salary / totalsum * 100)::numeric, 2) AS share_of_total
  FROM cte
  ORDER BY share_of_total DESC;
END;
$$ LANGUAGE plpgsql;



SELECT * FROM share_of_total();




-- Вызов функции, созданной в IDE
select * from another_share_of_total();





with cte as (
	select 
	e.last_name,
	e.first_name,
	j.salary,
	sum(j.salary) over () as totalsum
	from employees e
	join jobs j on j.id = e.job_id
)
select 
last_name "Фамилия", 
first_name "Имя", 
salary "ЗП",
round((salary / totalsum * 100)::numeric, 2) as "Доля в суммарной ЗП"
from cte
order by "Доля в суммарной ЗП" desc ;


