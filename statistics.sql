-- statistics 1
SELECT e.NAME, COALESCE(COUNT(dap.GRANTED_BY), 0) ACCESS_GRANTED_COUNT
	FROM EMPLOYEES e 
		LEFT OUTER JOIN DOCUMENT_ACCESS_PERMISSIONS dap ON dap.GRANTED_BY = e.ID
	WHERE DEPARTMENT_ID = 2
	GROUP BY e.NAME
	ORDER BY ACCESS_GRANTED_COUNT ASC;

-- statistics 2
SELECT e1.name Employee_Name, d.name Department_To, COUNT(*) GRANTED_TO_DEPARTMENTS_COUNT
	FROM EMPLOYEES e1
	INNER JOIN DOCUMENT_ACCESS_PERMISSIONS dap ON e1.ID = dap.GRANTED_BY 
	INNER JOIN EMPLOYEES e2 ON dap.GRANTED_TO = e2.ID 
	INNER JOIN DEPARTMENTS d ON e2.DEPARTMENT_ID = d.ID 
	WHERE e1.DEPARTMENT_ID <> e2.DEPARTMENT_ID 
	GROUP BY e1.name, d.name

-- statistics 3
SELECT e.NAME, d.NAME, COUNT(*) Access_Granted_Count 
	FROM EMPLOYEES e 
	INNER JOIN DOCUMENT_ACCESS_PERMISSIONS dap ON e.ID = dap.GRANTED_TO 
	INNER JOIN DEPARTMENTS d ON e.DEPARTMENT_ID = d.ID 
	GROUP BY e.NAME, d.NAME
	HAVING COUNT(*) > 3
	
-- statistics 4
SELECT d.name department_name, e.name employee_name
	FROM employees e
	JOIN departments d ON e.department_id = d.id
	WHERE e.id IN (
   	SELECT employee_id
   	FROM employee_access_restrictions
	)
	GROUP BY d.name, e.name
	ORDER BY d.name, e.name;

-- statistics 5
SELECT 
   d.name department_name,
   chief.name chief_name,
   emp.name employee_name,
   COUNT(dap.granted_to) access_granted_count
FROM departments d
JOIN employees chief ON d.chief_id = chief.id  
JOIN employees emp ON d.id = emp.department_id 
LEFT JOIN document_access_permissions dap ON emp.id = dap.granted_to 
GROUP BY d.name, chief.name, emp.name
ORDER BY d.name, chief.name, emp.name;