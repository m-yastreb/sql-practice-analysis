-- БАЗА ДАННЫХ: Тестирование
-- Описание создания базы данных находится в файле database_2.sql
-- Платформа: Stepik

-- ---------- ЗАПРОСЫ ----------

/*
Для разработанной базы данных ниже рассматриваются следующие запросы:

    Запросы на выборку

    - Вывести студентов, которые сдавали определенную дисциплину.
    - Вывести количество попыток и средний результат по каждой дисциплине.
    - Вывести студента (студентов), которые набрали максимальный результат при тестировании.
    - Если студент совершал несколько попыток по одной и той же дисциплине, то вывести разницу в днях между первой и последней попыткой.
    - Вывести количество студентов, которые проходили тестирование по каждой дисциплине.
    - Случайным образом отобрать 3 вопроса по определенной дисциплине.
    - Вывести вопросы, на которые отвечал определенный студент в определенной попытке, ответ студента и результат (правильно или нет).
    - Посчитать результаты тестирования для всех попыток.
    - Для каждого вопроса вывести процент успешных решений и общее количество ответов.

    Запросы корректировки

    - Добавление новой попытки для определенного студента и определенной дисциплины.
    - Формирование тестовых вопросов для этой попытки.
    - Вычисление результата тестирования.
    - Удаление неактуальных попыток.
 */

--  Запросы на выборку

/* Запрос 1
Вывести студентов, которые сдавали дисциплину «Основы баз данных», указать дату попытки и результат. Информацию вывести
по убыванию результатов тестирования. */

SELECT name_student, date_attempt, result
FROM subject
JOIN attempt USING(subject_id)
JOIN student USING(student_id)
WHERE name_subject LIKE 'Основы баз данных'
ORDER BY result DESC;

/* Запрос 2
Вывести, сколько попыток сделали студенты по каждой дисциплине, а также средний результат попыток, который округлить
до 2 знаков после запятой. Под результатом попытки понимается процент правильных ответов на вопросы теста,
который занесен в столбец result.  В результат включить название дисциплины, а также вычисляемые столбцы Количество и
Среднее. Информацию вывести по убыванию средних результатов.*/

SELECT name_subject, COUNT(attempt_id) Количество, ROUND(SUM(result)/COUNT(result),2) Среднее
FROM subject LEFT JOIN attempt USING(subject_id)
GROUP BY name_subject
ORDER BY Среднее DESC;

/* Запрос 3
Вывести студентов (различных студентов), имеющих максимальные результаты попыток. Информацию отсортировать в алфавитном
порядке по фамилии студента. Максимальный результат не обязательно будет 100%, поэтому явно это значение в запросе
не задавать. */


SELECT name_student, result
FROM student JOIN attempt ON student.student_id = attempt.student_id
WHERE result IN(
       SELECT MAX(result)
       FROM attempt)
ORDER BY name_student;


/* Запрос 4
Если студент совершал несколько попыток по одной и той же дисциплине, то вывести разницу в днях между первой и
последней попыткой. В результат включить фамилию и имя студента, название дисциплины и вычисляемый столбец Интервал.
Информацию вывести по возрастанию разницы. Студентов, сделавших одну попытку по дисциплине, не учитывать. */

SELECT name_student, name_subject, DATEDIFF(MAX(date_attempt),MIN(date_attempt)) Интервал
FROM student
JOIN attempt USING(student_id)
JOIN subject USING(subject_id)
GROUP BY name_student, name_subject
HAVING COUNT(date_attempt)>1
ORDER BY Интервал;

/* Запрос 5
Студенты могут тестироваться по одной или нескольким дисциплинам (не обязательно по всем). Вывести дисциплину и
количество уникальных студентов (столбец назвать Количество), которые по ней проходили тестирование. Информацию
отсортировать сначала по убыванию количества, а потом по названию дисциплины. В результат включить и
дисциплины, тестирование по которым студенты еще не проходили, в этом случае указать количество студентов 0. */

SELECT name_subject, COUNT(DISTINCT(student_id)) Количество
FROM subject LEFT JOIN attempt USING(subject_id)
GROUP BY name_subject
ORDER BY Количество DESC, name_subject;

/* Запрос 6
Случайным образом отберите 3 вопроса по дисциплине «Основы баз данных». В результат включите столбцы question_id и
name_question.*/

SELECT question_id, name_question
FROM subject JOIN question USING(subject_id)
WHERE name_subject LIKE 'Основы баз данных'
ORDER BY RAND()
LIMIT 3;

/* Запрос 7
Вывести вопросы, которые были включены в тест для Семенова Ивана по дисциплине «Основы SQL» 2020-05-17  (значение
attempt_id для этой попытки равно 7). Указать, какой ответ дал студент и правильный он или нет (вывести Верно или
Неверно). В результат включить вопрос, ответ и вычисляемый столбец  Результат. */

SELECT name_question, name_answer,
       IF(is_correct = 1,'Верно','Неверно') Результат
FROM question
JOIN testing USING(question_id)
JOIN answer USING(answer_id)
WHERE attempt_id = 7;


/* Запрос 8
Посчитать результаты тестирования. Результат попытки вычислить как количество правильных ответов, деленное на
3 (количество вопросов в каждой попытке) и умноженное на 100. Результат округлить до двух знаков после запятой.
Вывести фамилию студента, название предмета, дату и результат. Последний столбец назвать Результат. Информацию
отсортировать сначала по фамилии студента, потом по убыванию даты попытки. */

SELECT name_student, name_subject, date_attempt,
         ROUND(SUM(is_correct)/3*100,2) Результат
FROM student
JOIN attempt USING(student_id)
JOIN subject USING(subject_id)
JOIN testing USING(attempt_id)
JOIN answer USING(answer_id)
GROUP BY name_student, name_subject, date_attempt
ORDER BY name_student, date_attempt DESC;

/* Запрос 9
Для каждого вопроса вывести процент успешных решений, то есть отношение количества верных ответов к общему количеству
ответов, значение округлить до 2-х знаков после запятой. Также вывести название предмета, к которому относится вопрос,
и общее количество ответов на этот вопрос. В результат включить название дисциплины, вопросы по ней (столбец назвать
Вопрос), а также два вычисляемых столбца Всего_ответов и Успешность. Информацию отсортировать сначала по названию
дисциплины, потом по убыванию успешности, а потом по тексту вопроса в алфавитном порядке.*/

SELECT name_subject, CONCAT(LEFT(name_question, 30),'...') Вопрос, COUNT(answer.is_correct) Всего_ответов, ROUND(SUM(is_correct)/COUNT(answer.is_correct)*100,2) Успешность
FROM subject
    INNER JOIN question  USING(subject_id)
    INNER JOIN testing  USING(question_id)
    INNER JOIN answer  USING(answer_id)
GROUP BY name_subject, Вопрос
ORDER BY name_subject, Успешность DESC, Вопрос;


-- Запросы корректировки

/* Запрос 1
В таблицу attempt включить новую попытку для студента Баранова Павла по дисциплине «Основы баз данных». Установить
текущую дату в качестве даты выполнения попытки. */

INSERT INTO attempt (student_id, subject_id, date_attempt, result)
SELECT student_id, subject_id, NOW(), NULL
FROM subject, student
WHERE name_student LIKE 'Баранов Павел' AND name_subject LIKE 'Основы баз данных';

SELECT*FROM attempt;

/* Запрос 2
Случайным образом выбрать три вопроса (запрос) по дисциплине, тестирование по которой собирается проходить студент,
занесенный в таблицу attempt последним, и добавить их в таблицу testing. id последней попытки получить как максимальное
значение id из таблицы attempt. */

INSERT INTO testing (attempt_id, question_id)
SELECT attempt_id, question_id
FROM question JOIN attempt ON question.subject_id=attempt.subject_id
WHERE attempt_id=(SELECT MAX(attempt_id) FROM attempt)
ORDER BY RAND()
LIMIT 3;

SELECT*FROM testing;

/* Запрос 3
Студент прошел тестирование (то есть все его ответы занесены в таблицу testing), далее необходимо вычислить
результат(запрос) и занести его в таблицу attempt для соответствующей попытки.  Результат попытки вычислить как
количество правильных ответов, деленное на 3 (количество вопросов в каждой попытке) и умноженное на 100.
Результат округлить до целого. Будем считать, что мы знаем id попытки,  для которой вычисляется результат, в нашем
случае это 8. */

UPDATE attempt
JOIN testing USING(attempt_id)
SET result = (SELECT ROUND(SUM(is_correct)/3*100)
              FROM answer JOIN testing USING(answer_id)
              WHERE attempt_id  = 8
              GROUP BY attempt_id )
WHERE attempt_id = 8;

SELECT*FROM attempt;


/* Запрос 4
Удалить из таблицы attempt все попытки, выполненные раньше 1 мая 2020 года. Также удалить и все соответствующие этим
попыткам вопросы из таблицы testing, которая создавалась следующим запросом: */

CREATE TABLE testing (
    testing_id INT PRIMARY KEY AUTO_INCREMENT,
    attempt_id INT,
    question_id INT,
    answer_id INT,
    FOREIGN KEY (attempt_id)  REFERENCES attempt (attempt_id) ON DELETE CASCADE
);


DELETE FROM attempt
WHERE date_attempt < '2020-05-01';

SELECT*FROM attempt;

SELECT*FROM testing;
















