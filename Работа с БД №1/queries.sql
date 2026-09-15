-- ============================================
-- БАЗА ДАННЫХ: Интернет-магазин книг
-- Описание создания базы данных находится в файле database_1.sql
-- Платформа: Stepik
-- ============================================

-- ---------- ЗАПРОСЫ ----------

/*
Для разработанной базы данных ниже рассматриваются следующие запросы:

    Запросы на выборку

   - Вывести фамилии всех клиентов, которые заказали определенную книгу.
   - Посчитать, сколько раз была заказана каждая книга.
   - Вывести города, в которых живут клиенты магазина.
   - Вывести информацию об оплате каждого заказа.
   - Вывести подробную информацию о каждом заказе.
   - Вывести информацию о движении каждого заказа.
   - Вывести заказы, доставленные с опозданием.
   - Вывести клиентов, которые заказывали книги определенного автора.
   - Вывести самый популярный жанр.
   - Сравнить ежемесячную выручку за текущий и прошлый год.

    Запросы корректировки

   - Включение нового клиента в базу данных.
   - Формирование нового заказа некоторым пользователем.
   - Включение в заказ одной или нескольких книг с указанием их количества;
   - Уменьшение количества книг на складе
   - Создание счета на оплату (полный счет, итоговый счет)
   - Добавление этапов продвижения заказа
   - Фиксация дат прохождения каждого этапа заказа (начало этапа, завершение этапа)
 */


--  Запросы на выборку

/* Запрос 1
Вывести все заказы Баранова Павла (id заказа, какие книги, по какой цене и в каком количестве он заказал) в
отсортированном по номеру заказа и названиям книг виде. */

SELECT buy_book.buy_id, title, price, buy_book.amount
FROM client
JOIN buy ON client.client_id = buy.client_id
JOIN buy_book ON buy.buy_id = buy_book.buy_id
JOIN book ON buy_book.book_id = book.book_id
WHERE name_client LIKE ("Баранов Павел")
ORDER BY  buy_book.buy_id, title;

/* Запрос 2
Посчитать, сколько раз была заказана каждая книга, для книги вывести ее автора (нужно посчитать, в каком количестве
заказов фигурирует каждая книга).  Вывести фамилию и инициалы автора, название книги, последний столбец назвать
Количество. Результат отсортировать сначала  по фамилиям авторов, а потом по названиям книг. */

SELECT name_author, title, COUNT(buy_book.buy_id) AS Количество
FROM author
JOIN book ON author.author_id = book.author_id
LEFT JOIN buy_book ON book.book_id = buy_book.book_id
LEFT JOIN buy ON buy_book.buy_id = buy.buy_id
GROUP BY name_author, title
ORDER BY name_author, title;

/* Запрос 3
Вывести города, в которых живут клиенты, оформлявшие заказы в интернет-магазине. Указать количество заказов в каждый
город, этот столбец назвать Количество. Информацию вывести по убыванию количества заказов, а затем в алфавитном порядке
по названию городов. */

SELECT name_city, COUNT(buy_id) AS Количество
FROM city
JOIN client ON city.city_id = client.city_id
JOIN buy ON client.client_id = buy.client_id
GROUP BY name_city
ORDER BY Количество DESC, name_city;

/* Запрос 4
Вывести города, в которых живут клиенты, оформлявшие заказы в интернет-магазине. Указать количество заказов в каждый
город, этот столбец назвать Количество. Информацию вывести по убыванию количества заказов, а затем в алфавитном порядке
по названию городов. */

SELECT name_city, COUNT(buy_id) AS Количество
FROM city
JOIN client ON city.city_id = client.city_id
JOIN buy ON client.client_id = buy.client_id
GROUP BY name_city
ORDER BY Количество DESC, name_city;

/* Запрос 5
Вывести номера всех оплаченных заказов и даты, когда они были оплачены. */

SELECT buy_step.buy_id, date_step_end
FROM buy
JOIN buy_step ON buy.buy_id = buy_step.buy_id
JOIN step ON buy_step.step_id = step.step_id
WHERE step.name_step LIKE "Оплата" AND date_step_end IS NOT NULL;

/* Запрос 6
Вывести информацию о каждом заказе: его номер, кто его сформировал (фамилия пользователя) и его стоимость (сумма
произведений количества заказанных книг и их цены), в отсортированном по номеру заказа виде. Последний столбец
назвать Стоимость.*/

SELECT buy_book.buy_id, client.name_client, SUM(book.price*buy_book.amount) AS Стоимость
FROM client
JOIN buy ON client.client_id = buy.client_id
JOIN buy_book ON buy.buy_id = buy_book.buy_id
JOIN book ON book.book_id = buy_book.book_id
GROUP BY buy_book.buy_id, client.name_client
ORDER BY buy_book.buy_id;


/* Запрос 7
Вывести номера заказов (buy_id) и названия этапов,  на которых они в данный момент находятся. Если заказ доставлен –
информацию о нем не выводить. Информацию отсортировать по возрастанию buy_id. */

SELECT buy_step.buy_id, name_step
FROM step
JOIN buy_step ON step.step_id = buy_step.step_id
WHERE date_step_beg IS NOT NULL AND date_step_end IS NULL
ORDER BY buy_id;


/* Запрос 8
В таблице city для каждого города указано количество дней, за которые заказ может быть доставлен в этот город
(рассматривается только этап Транспортировка). Для тех заказов, которые прошли этап транспортировки, вывести
количество дней за которое заказ реально доставлен в город. А также, если заказ доставлен с опозданием, указать
количество дней задержки, в противном случае вывести 0. В результат включить номер заказа (buy_id), а также
вычисляемые столбцы Количество_дней и Опоздание. Информацию вывести в отсортированном по номеру заказа виде. */

SELECT buy.buy_id,
              DATEDIFF(date_step_end, date_step_beg) AS Количество_дней,
              IF(DATEDIFF(date_step_end, date_step_beg)>days_delivery,
                 ABS(days_delivery - DATEDIFF(date_step_end, date_step_beg)), 0) AS Опоздание
FROM city
JOIN client ON city.city_id = client.city_id
JOIN buy ON client.client_id = buy.client_id
JOIN buy_step ON buy.buy_id = buy_step.buy_id
JOIN step ON buy_step.step_id = step.step_id
WHERE name_step LIKE "Транспортировка" AND date_step_end IS NOT NULL
ORDER BY buy_id;


/* Запрос 9
Выбрать всех клиентов, которые заказывали книги Достоевского, информацию вывести в отсортированном по алфавиту виде.
   В решении используйте фамилию автора, а не его id. */

SELECT name_client
FROM author
JOIN book ON author.author_id = book.author_id
JOIN buy_book ON book.book_id = buy_book.book_id
JOIN buy ON buy_book.buy_id = buy.buy_id
JOIN client ON buy.client_id = client.client_id
WHERE name_author LIKE "Достоевский Ф.М."
GROUP BY name_client
ORDER BY name_client;

/* Запрос 10
Вывести жанр (или жанры), в котором было заказано больше всего экземпляров книг, указать это количество.
Последний столбец назвать Количество. */

SELECT query_1.name_genre, query_1.Количество
FROM
(SELECT name_genre, SUM(buy_book.amount) AS Количество
 FROM genre
 JOIN book ON genre.genre_id = book.genre_id
 JOIN buy_book ON book.book_id = buy_book.book_id
 GROUP BY name_genre) AS query_1
JOIN
(SELECT name_genre,SUM(buy_book.amount) AS Макс_колво
 FROM genre
 JOIN book ON genre.genre_id = book.genre_id
 JOIN buy_book ON book.book_id = buy_book.book_id
 GROUP BY name_genre
 ORDER BY Макс_колво DESC
 LIMIT 1) AS query_2
ON query_1.Количество = query_2.Макс_колво;



/* Запрос 11
Сравнить ежемесячную выручку от продажи книг за текущий и предыдущий годы. Для этого вывести год, месяц,
сумму выручки в отсортированном сначала по возрастанию месяцев, затем по возрастанию лет виде.
Название столбцов: Год, Месяц, Сумма. */

SELECT YEAR(date_payment) AS Год, MONTHNAME(date_payment) AS Месяц, SUM(amount*price) AS Сумма
FROM buy_archive
GROUP BY YEAR(date_payment), MONTHNAME(date_payment)
UNION ALL
SELECT YEAR(date_step_end), MONTHNAME(date_step_end), SUM(buy_book.amount*price)
FROM
    book
    INNER JOIN buy_book USING(book_id)
    INNER JOIN buy USING(buy_id)
    INNER JOIN buy_step USING(buy_id)
    INNER JOIN step USING(step_id)
WHERE date_step_end IS NOT NULL AND name_step LIKE "Оплата"
GROUP BY YEAR(date_step_end), MONTHNAME(date_step_end)
ORDER BY 2,1;


/* Запрос 12
Для каждой отдельной книги необходимо вывести информацию о количестве проданных экземпляров и их стоимости за 2020 и
2019 год . За 2020 год проданными считать те экземпляры, которые уже оплачены. Вычисляемые столбцы назвать
Количество и Сумма. Информацию отсортировать по убыванию стоимости. */

SELECT title, SUM(Количество) Количество, SUM(Сумма) Сумма
FROM
(SELECT title, SUM(buy_archive.amount) Количество, SUM(buy_archive.amount*buy_archive.price) Сумма
FROM buy_archive
JOIN book USING(book_id)
GROUP BY title
UNION ALL
SELECT title, SUM(buy_book.amount) Количество, SUM(buy_book.amount*price) AS Сумма
FROM
    book
    INNER JOIN buy_book USING(book_id)
    INNER JOIN buy USING(buy_id)
    INNER JOIN buy_step USING(buy_id)
    INNER JOIN step USING(step_id)
WHERE date_step_end IS NOT NULL AND name_step LIKE "Оплата"
GROUP BY title) q_1
GROUP BY title
ORDER BY 3 DESC;


-- Запросы корректировки

/* Запрос 1
Включить нового человека в таблицу с клиентами. Его имя Попов Илья, его email popov@test, проживает он в Москве. */

INSERT INTO client (name_client, city_id, email)
SELECT 'Попов Илья', city_id, 'popov@test'
FROM city
WHERE name_city = "Москва";

SELECT * FROM client;

/* Запрос 2
Создать новый заказ для Попова Ильи. Его комментарий для заказа: «Связаться со мной по вопросу доставки». */

INSERT INTO buy (buy_description, client_id)
SELECT "Связаться со мной по вопросу доставки", client_id
FROM client
WHERE name_client = "Попов Илья";

SELECT * FROM buy;

/* Запрос 3
В таблицу buy_book добавить заказ с номером 5. Этот заказ должен содержать книгу Пастернака «Лирика» в количестве двух
экземпляров и книгу Булгакова «Белая гвардия» в одном экземпляре. */

INSERT INTO buy_book (buy_id, book_id, amount)
SELECT 5, book_id, 2
FROM book
JOIN author USING(author_id)
WHERE name_author = "Пастернак Б.Л." AND title = "Лирика";

INSERT INTO buy_book (buy_id, book_id, amount)
SELECT 5, book_id, 1
FROM book
JOIN author USING(author_id)
WHERE name_author = "Булгаков М.А." AND title = "Белая гвардия";

SELECT * FROM buy_book;

/* Запрос 4
Количество тех книг на складе, которые были включены в заказ с номером 5, уменьшить на то количество,
которое в заказе с номером 5 указано.*/

UPDATE buy_book
JOIN book USING(book_id)
SET book.amount = book.amount - buy_book.amount
WHERE buy_book.buy_id = 5;

SELECT * FROM book;

/* Запрос 5
Создать счет (таблицу buy_pay) на оплату заказа с номером 5, в который включить название книг, их автора, цену,
количество заказанных книг и  стоимость. Последний столбец назвать Стоимость. Информацию в таблицу занести в
отсортированном по названиям книг виде. */

CREATE TABLE buy_pay AS
SELECT book.title, name_author, book.price, buy_book.amount, buy_book.amount*book.price AS Стоимость
FROM author
JOIN book USING(author_id)
JOIN buy_book USING(book_id)
WHERE buy_book.buy_id = 5
ORDER BY book.title;

SELECT * FROM buy_pay;

/* Запрос 6
Создать новый заказ для Попова Ильи. Его комментарий для заказа: «Связаться со мной по вопросу доставки». */
Создать общий счет (таблицу buy_pay) на оплату заказа с номером 5. Куда включить номер заказа, количество книг в заказе (название столбца Количество) и его общую стоимость (название столбца Итого). Для решения используйте ОДИН запрос.

CREATE TABLE buy_pay AS
SELECT buy_id, SUM(buy_book.amount) Количество, SUM(buy_book.amount*book.price) Итого
FROM book
JOIN buy_book USING(book_id)
WHERE buy_book.buy_id = 5;

SELECT * FROM buy_pay;

/* Запрос 2
Создать новый заказ для Попова Ильи. Его комментарий для заказа: «Связаться со мной по вопросу доставки». */
В таблицу buy_step для заказа с номером 5 включить все этапы из таблицы step, которые должен пройти этот заказ. В столбцы date_step_beg и date_step_end всех записей занести Null.

INSERT INTO buy_step (buy_id, step_id, date_step_beg, date_step_end)
SELECT buy_id, step_id, NULL, NULL
FROM buy, step
WHERE buy.buy_id = 5;

SELECT*FROM buy_step;

/* Запрос 2
Создать новый заказ для Попова Ильи. Его комментарий для заказа: «Связаться со мной по вопросу доставки». */
В таблицу buy_step занести дату 12.04.2020 выставления счета на оплату заказа с номером 5.
Правильнее было бы занести не конкретную, а текущую дату. Это можно сделать с помощью функции Now(). Но при этом в разные дни будут вставляться разная дата, и задание нельзя будет проверить, поэтому  вставим дату 12.04.2020.

UPDATE buy_step JOIN step USING(step_id)
SET date_step_beg = '2020-04-12'
WHERE buy_id = 5 AND name_step = 'Оплата';

SELECT*FROM buy_step
WHERE buy_id = 5;

/* Запрос 2
Создать новый заказ для Попова Ильи. Его комментарий для заказа: «Связаться со мной по вопросу доставки». */
Завершить этап «Оплата» для заказа с номером 5, вставив в столбец date_step_end дату 13.04.2020, и начать следующий этап («Упаковка»), задав в столбце date_step_beg для этого этапа ту же дату.

Реализовать два запроса для завершения этапа и начала следующего. Они должны быть записаны в общем виде, чтобы его можно было применять для любых этапов, изменив только текущий этап. Для примера пусть это будет этап «Оплата».

UPDATE buy_step JOIN step USING(step_id)
SET date_step_end = '2020-04-13'
WHERE buy_id = 5 AND name_step = 'Оплата';

UPDATE buy_step
SET date_step_beg = '2020-04-13'
WHERE buy_id = 5 AND step_id =
(SELECT step_id + 1
FROM step
WHERE name_step = 'Оплата');

SELECT*FROM buy_step
WHERE buy_id = 5;
























