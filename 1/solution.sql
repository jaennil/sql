-- 1.1
SELECT
	name,
    MAX(IF(subject = 'Русский язык', marks, '-')) 'Русский язык',
    MAX(IF(subject = 'Математика', marks, '-')) 'Математика',
    MAX(IF(subject = 'Химия', marks, '-')) 'Химия',
    MAX(IF(subject = 'Физика', marks, '-')) 'Физика',
    MAX(IF(subject = 'Английский язык', marks, '-')) 'Английский язык',
    MAX(IF(subject = 'Обществознание', marks, '-')) 'Обществознание',
    MAX(IF(subject = 'География', marks, '-')) 'География',
    MAX(IF(subject = 'Информатика', marks, '-')) 'Информатика',
    MAX(IF(subject = 'Литература', marks, '-')) 'Литература'
FROM
    exams
WHERE
    DATEDIFF(date, CURDATE()) / 365 < 5
GROUP BY
    name;

-- 1.2
SELECT marks, COUNT(*)
FROM exams
WHERE subject = 'Математика'
GROUP BY marks;

-- 1.3
SELECT subject, COUNT(*)
FROM exams
GROUP BY subject;

-- 1.4
SELECT name, SUM(marks)
FROM exams
GROUP BY name;

-- 1.5
SELECT
    sum,
    COUNT(*)
FROM
    (SELECT
        SUM(marks) sum
    FROM
        exams
    GROUP BY
        name) st
GROUP BY
    sum;

-- 1.6
SELECT name,
	AVG(marks) avg,
    CEIL((NTILE(4) OVER(ORDER BY AVG(marks) DESC) + 0.1) / 2) 'status'
FROM exams
GROUP BY name
ORDER BY avg DESC;

-- 2.1
SELECT
    status,
    COUNT(*)
FROM
    (
        SELECT
            CEIL((NTILE(4) OVER(ORDER BY AVG(marks) DESC) + 0.1) / 2) 'status'
        FROM
            exams
        GROUP BY
            name
    ) st
GROUP BY
    status;

-- 2.2
SELECT combination, COUNT(*) 
FROM (
    SELECT 
        IF(COUNT(marks) = 4, REPLACE(GROUP_CONCAT(marks ORDER BY marks), CONCAT(MIN(marks), ','), ''), GROUP_CONCAT(marks ORDER BY marks)) combination 
    FROM exams 
    GROUP BY name
) comb_query 
GROUP BY combination;

-- 2.3
SELECT
    name,
    GROUP_CONCAT(subject) subjects
FROM
    exams
GROUP BY
    name
HAVING
    COUNT(*) <= 2;

-- 2.4
WITH RECURSIVE cte_count (mn, mx) 
AS (
      SELECT 281, 300
      UNION ALL
      SELECT mn - 20, mx - 20
      FROM cte_count 
      WHERE mn > 1
    )
SELECT mn,
    mx,
    COUNT(total_marks)
FROM cte_count
LEFT JOIN (
    SELECT id,
        CASE
            WHEN COUNT(*) = 4 THEN SUM(marks) - MIN(marks)
            ELSE SUM(marks)
        END AS total_marks
    FROM exams
    GROUP BY id
    HAVING COUNT(*) >= 3
) AS marks_sum
ON total_marks BETWEEN mn AND mx
GROUP BY mn, mx;

-- 2.5
DELETE FROM exams
WHERE (id, subject, marks) IN (
    SELECT id, subject, marks
    FROM (
        SELECT 
            id, 
            subject, 
            marks, 
            ROW_NUMBER() OVER (PARTITION BY id ORDER BY marks DESC) AS rn
        FROM exams
    ) AS ranked_marks
    WHERE rn > 3
);

-- 2.6
UPDATE exams
SET marks = (
    SELECT AVG(marks)
    FROM (
        SELECT marks
        FROM exams e2
        WHERE exams.subject = e2.subject
    ) AS subquery
)
WHERE marks IS NULL;

