-- БАЗА ДАННЫХ: «Абитуриент»
-- Описание создания базы данных находится в файле database_3.sql
-- Платформа: Stepik

-- ---------- ЗАПРОСЫ ----------

/*
Для разработанной базы данных ниже рассматриваются следующие запросы:

    Запросы на выборку

    - Вывести абитуриентов, которые хотят поступать на определенную образовательную программу.
    - Вывести образовательные программы, на которые для поступления необходим определенный предмет ЕГЭ.
    - Вывести статистическую информацию по каждому предмету  ЕГЭ.
    - Вывести образовательные программы, минимальные баллы по каждому предмету которых, превышают заданное значение.
    - Вывести образовательные программы. которые имеют самый большой план набора.
    - Посчитать, сколько дополнительных баллов получит каждый абитуриент.
    - Посчитать конкурс на каждую образовательную программу.
    - Вывести образовательные программы, на которые для поступления необходимы два определенных предмета ЕГЭ.
    - Посчитать количество баллов каждого абитуриента на каждую образовательную программу по результатам ЕГЭ.
    - Вывести абитуриентов, которые не могут быть зачислены на образовательную программу.

 */

--  Запросы на выборку

/* Запрос 1
Вывести абитуриентов, которые хотят поступать на образовательную программу «Мехатроника и робототехника» в
отсортированном по фамилиям виде. */

SELECT name_enrollee
FROM enrollee
JOIN program_enrollee USING(enrollee_id)
JOIN program USING(program_id)
WHERE name_program LIKE 'Мехатроника и робототехника'
ORDER BY name_enrollee;

/* Запрос 2
Вывести образовательные программы, на которые для поступления необходим предмет «Информатика». Программы отсортировать
в обратном алфавитном порядке. */

SELECT name_program
FROM program
JOIN program_subject USING(program_id)
JOIN subject USING(subject_id)
WHERE name_subject LIKE 'Информатика'
ORDER BY name_program DESC;

/* Запрос 3
Выведите количество абитуриентов, сдавших ЕГЭ по каждому предмету, максимальное, минимальное и среднее значение баллов
по предмету ЕГЭ. Вычисляемые столбцы назвать Количество, Максимум, Минимум, Среднее. Информацию отсортировать по
названию предмета в алфавитном порядке, среднее значение округлить до одного знака после запятой. */

SELECT name_subject, COUNT(enrollee_id) Количество, MAX(result) Максимум, MIN(result) Минимум, ROUND(SUM(result)/COUNT(result),1) Среднее
FROM subject JOIN enrollee_subject USING(subject_id)
GROUP BY name_subject
ORDER BY name_subject;

/* Запрос 4
Вывести образовательные программы, для которых минимальный балл ЕГЭ по каждому предмету больше или равен 40 баллам.
Программы вывести в отсортированном по алфавиту виде. */

SELECT name_program
FROM program JOIN program_subject USING(program_id)
GROUP BY name_program
HAVING MIN(min_result) >= 40
ORDER BY name_program;

/* Запрос 5
Вывести образовательные программы, которые имеют самый большой план набора,  вместе с этой величиной. */

SELECT name_program, plan
FROM program
WHERE plan = (SELECT MAX(plan) FROM program);

/* Запрос 6
Посчитать, сколько дополнительных баллов получит каждый абитуриент. Столбец с дополнительными баллами назвать Бонус.
Информацию вывести в отсортированном по фамилиям виде. */

SELECT name_enrollee, IF(SUM(bonus) IS NULL, 0, SUM(bonus)) Бонус
FROM enrollee
LEFT JOIN enrollee_achievement USING(enrollee_id)
LEFT JOIN achievement USING(achievement_id)
GROUP BY name_enrollee
ORDER BY name_enrollee;

/* Запрос 7
Выведите сколько человек подало заявление на каждую образовательную программу и конкурс на нее (число поданных
заявлений деленное на количество мест по плану), округленный до 2-х знаков после запятой. В запросе вывести название
факультета, к которому относится образовательная программа, название образовательной программы, план набора
абитуриентов на образовательную программу (plan), количество поданных заявлений (Количество) и Конкурс. Информацию
отсортировать в порядке убывания конкурса.*/

SELECT name_department, name_program, plan, COUNT(enrollee_id) Количество, ROUND(COUNT(enrollee_id)/plan,2) Конкурс
FROM department
JOIN program USING(department_id)
JOIN program_enrollee USING(program_id)
GROUP BY name_department, name_program, plan
ORDER BY Конкурс DESC;

/* Запрос 8
Вывести образовательные программы, на которые для поступления необходимы предмет «Информатика» и «Математика» в
отсортированном по названию программ виде. */

SELECT name_program
FROM program
JOIN program_subject USING(program_id)
JOIN subject USING(subject_id)
WHERE name_subject IN ('Математика', 'Информатика')
GROUP BY name_program
HAVING COUNT(name_subject) = 2
ORDER BY name_program;

/* Запрос 9
Посчитать количество баллов каждого абитуриента на каждую образовательную программу, на которую он подал заявление,
по результатам ЕГЭ. В результат включить название образовательной программы, фамилию и имя абитуриента, а также
столбец с суммой баллов, который назвать itog. Информацию вывести в отсортированном сначала по образовательной
программе, а потом по убыванию суммы баллов виде. */

SELECT name_program, name_enrollee, SUM(result) itog
FROM program
JOIN program_subject USING(program_id)
JOIN program_enrollee USING(program_id)
JOIN enrollee_subject ON program_enrollee.enrollee_id = enrollee_subject.enrollee_id AND program_subject.subject_id=enrollee_subject.subject_id
JOIN enrollee ON enrollee_subject.enrollee_id = enrollee.enrollee_id
GROUP BY name_program, name_enrollee
ORDER BY name_program, itog DESC;

/* Запрос 10
Вывести название образовательной программы и фамилию тех абитуриентов, которые подавали документы на эту
образовательную программу, но не могут быть зачислены на нее. Эти абитуриенты имеют результат по одному или нескольким
предметам ЕГЭ, необходимым для поступления на эту образовательную программу, меньше минимального балла. Информацию
вывести в отсортированном сначала по программам, а потом по фамилиям абитуриентов виде.

Например, Баранов Павел по «Физике» набрал 41 балл, а  для образовательной программы «Прикладная механика» минимальный
балл по этому предмету определен в 45 баллов. Следовательно, абитуриент на данную программу не может поступить. */

SELECT DISTINCT name_program, name_enrollee
FROM enrollee
JOIN program_enrollee USING(enrollee_id)
JOIN enrollee_subject USING(enrollee_id)
JOIN program_subject ON program_subject.subject_id=enrollee_subject.subject_id
JOIN program ON program_subject.program_id = program.program_id AND program_enrollee.program_id = program.program_id
WHERE result < min_result
GROUP BY name_program, name_enrollee
ORDER BY name_program, name_enrollee;


















