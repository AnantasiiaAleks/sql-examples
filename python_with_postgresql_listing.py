from sqlalchemy import create_engine
import pandas as pd
import psycopg2

# Подключение к базе данных

username = 'postgres'
password = '2011'
host = 'localhost'
port = '5432'
database = 'company'

connection = psycopg2.connect(database=database,
                              user=username,
                              password=password,
                              host=host,
                              port=port)

cursor = connection.cursor()
connection_string = f'postgresql://{username}:{password}@{host}:{port}/{database}'
engine = create_engine(connection_string)

# Проверка подключения
print(connection.get_dsn_parameters(), '\n')
cursor.execute("SELECT version();")
version_ps = cursor.fetchone()
print("Вы подключены - ", version_ps, "\n")

# Выполнение тестового запроса
sql = 'SELECT * FROM company.public.jobs'
df = pd.read_sql_query(sql, engine)
print(df)


# Создание таблицы locations
cursor.execute("CREATE TABLE IF NOT EXISTS company.public.locations (location_id int PRIMARY KEY, city varchar(30), postal_code varchar(12));")
connection.commit()

# Заполнение таблицы locations значениями
cursor.execute(
    "INSERT INTO company.public.locations VALUES"
    "(1, 'Roma', '00989'),"
    "(2, 'Venice', '109934'),"
    "(3, 'Tokyo', '1689'),"
    "(4, 'Hirosima', '6823'),"
    "(5, 'Southlake', '26192'),"
    "(6, 'South San Francisco', '99236'),"
    "(7, 'South Brunswick', '50090'),"
    "(8, 'Seattle', '98199'),"
    "(9, 'Toronto', 'M5V 2L7'),"
    "(10, 'Whitehorse', 'YSW 9T2');"
)
connection.commit()

# Добавление нового столбца `location_id` в таблицу сотрудников
cursor.execute("ALTER TABLE company.public.employees ADD COLUMN location_id INT;")

# Создание внешнего ключа для связи с таблицей locations
cursor.execute("ALTER TABLE employees ADD CONSTRAINT fk_location FOREIGN KEY (location_id) REFERENCES locations(location_id);")

# Заполнение столбца `location_id` данными
cursor.execute("UPDATE employees SET location_id = 1 WHERE department_id = 1;")
cursor.execute("UPDATE employees SET location_id = 9 WHERE department_id in (2, 4);")
cursor.execute("UPDATE employees SET location_id = 4 WHERE department_id = 3;")

connection.commit()

# Запрос вывода фамилий и имен сотрудников, отдела, должности и заработной платы
# (объединение трех таблиц)
first_query = ('SELECT e.first_name, e.last_name, d.name, j.title, j.salary '
               'FROM employees e '
               'JOIN departments d ON d.id = e.department_id '
               'JOIN jobs j ON j.id = e.job_id '
               'ORDER BY j.salary DESC, last_name;')
df1 = pd.read_sql_query(first_query, engine)
print(df1)

# Запрос вывода суммарной зарплаты по отделам
# (агрегатная функция, группировка, сортировка)
second_query = ('SELECT d.name "Отдел", sum(j.salary) AS "Суммарная зарплата" '
                'FROM departments d '
                'JOIN employees e ON e.department_id = d.id '
                'JOIN jobs j ON j.id = e.job_id '
                'GROUP BY d.name '
                'ORDER BY "Суммарная зарплата";')
df2 = pd.read_sql_query(second_query, engine)
print(df2)

# Запрос на вывод количества сотрудников по городам.
# Использование агрегирующей функции, группировки, переименования столбцов
third_query = ('SELECT l.city "Город", count(e.id) AS "Количество сотрудников" '
               'FROM locations l '
               'JOIN employees e ON e.location_id = l.location_id '
               'GROUP BY l.city;')
df3 = pd.read_sql_query(third_query, engine)
print(df3)


# Вызов функции select_data из Python
cursor.callproc('select_data', [2,])
result = cursor.fetchall()
result_proc = pd.DataFrame(result)
print(result_proc)


# Создание функции select_data1, аналогичной select_data
postgresql_func = """
CREATE OR REPLACE FUNCTION select_data1(id_dept int)
RETURNS SETOF departments AS $$
BEGIN
	RETURN QUERY 
	SELECT * FROM departments
	WHERE departments.id > id_dept;
END;
$$ LANGUAGE plpgsql;
"""
cursor.execute(postgresql_func)
connection.commit()

# Вызов функции, созданной в СУБД
cursor.callproc('share_of_total')
result2 = cursor.fetchall()
result2_proc = pd.DataFrame(result2)
print(result2_proc)

#Создание аналогичной функции
postgresql_another_func = """
CREATE OR REPLACE FUNCTION another_share_of_total()
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
"""
cursor.execute(postgresql_another_func)
connection.commit()



# Закрытие соединения
engine.dispose()
cursor.close()
connection.close()
