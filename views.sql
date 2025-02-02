CREATE VIEW employee_access_view AS 
	SELECT e1.name AS Access_Granted_To, e2.name AS Access_Granted_By, d.title AS Document_Title	
		FROM  DOCUMENT_ACCESS_PERMISSIONS dap 
			INNER JOIN EMPLOYEES e1 ON dap.GRANTED_TO = e1.ID
			INNER JOIN EMPLOYEES e2 ON dap.GRANTED_BY = e2.ID 
			INNER JOIN DOCUMENTS d ON dap.DOCUMENT_ID = d.id
		ORDER BY Access_Granted_To ASC;

CREATE VIEW document_access_view AS 
	SELECT d.TITLE AS Document_Title, e.NAME AS Access_Granted_To
		FROM DOCUMENT_ACCESS_PERMISSIONS dap  
			INNER JOIN EMPLOYEES e ON dap.GRANTED_TO = e.ID
			INNER JOIN DOCUMENTS d ON dap.DOCUMENT_ID = d.id
		ORDER BY Document_Title ASC;

