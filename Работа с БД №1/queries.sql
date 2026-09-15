-- ============================================
-- БАЗА ДАННЫХ: Интернет-магазин книг
-- Описание создания базы данных находится в файле database_1.sql
-- Платформа: Stepik
-- ============================================

-- ---------- ЗАПРОСЫ ----------

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


/* Запрос 4
Вывести города, в которых живут клиенты, оформлявшие заказы в интернет-магазине. Указать количество заказов в каждый
город, этот столбец назвать Количество. Информацию вывести по убыванию количества заказов, а затем в алфавитном порядке
по названию городов. */



/* Запрос 4
Вывести города, в которых живут клиенты, оформлявшие заказы в интернет-магазине. Указать количество заказов в каждый
город, этот столбец назвать Количество. Информацию вывести по убыванию количества заказов, а затем в алфавитном порядке
по названию городов. */



