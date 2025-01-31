INSERT INTO DEPARTMENTS (id, name) VALUES (1, 'Software Development'); 
INSERT INTO DEPARTMENTS (id, name) VALUES (2, 'Human Resources');

SELECT * FROM documents 
SELECT * FROM employees 
SELECT * FROM departments 

-- init employees
BEGIN
    employee_actions.create_employee(
        p_name => 'Иван Петров', 
        p_salary => 50000, 
        p_department_id => 1
    );
	employee_actions.create_employee(
        p_name => 'Петр Иванов', 
        p_salary => 100000, 
        p_department_id => 1
    );
	employee_actions.create_employee(
        p_name => 'Анатолий сидоров', 
        p_salary => 85000, 
        p_department_id => 2
    );
	employee_actions.create_employee(
        p_name => 'Евгений Цыганков', 
        p_salary => 92000, 
        p_department_id => 2
    );
END;

-- set departments chiefs
BEGIN
    employee_actions.set_department_chief(
        p_department_id => 1, 
        p_chief_id => 1
    );
    employee_actions.set_department_chief(
        p_department_id => 2, 
        p_chief_id => 3
    );
END;

-- create docs
BEGIN
	document_management.add_document(
		p_employee_id => 1,
        p_title => 'Title 1',
        p_content => 'Content 1'
	);
	document_management.add_document(
		p_employee_id => 2,
        p_title => 'Title 2',
        p_content => 'Content 2'
	);
	document_management.add_document(
		p_employee_id => 3,
        p_title => 'Title 3',
        p_content => 'Content 3'
	);
	document_management.add_document(
		p_employee_id => 4,
        p_title => 'Title 4',
        p_content => 'Content 4'
	);
END;

-- grant access
BEGIN
	document_access_pkg.grant_access(
		p_document_id => 2,
        p_granted_to => 1,
        p_granted_by => 2 
	);
END;

-- test access
DECLARE
    emp_documents SYS_REFCURSOR;
    document documents%ROWTYPE;
BEGIN
    emp_documents := document_management.get_employee_documents(1);

    LOOP
        FETCH emp_documents INTO document;
        EXIT WHEN emp_documents%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('Document ID: ' || document.id || ', Document Name: ' || document.title);
    END LOOP;

    CLOSE emp_documents;
END;

-- restrict access
BEGIN
	document_access_pkg.restrict_to_grant_access(
    	p_employee_id => 1,
    	p_restrict_from => 3,
    	p_restrict_all => false 
	);
END;

-- try to grant access despite restrictions
BEGIN
	document_access_pkg.grant_access(
		p_document_id => 3,
        p_granted_to => 1,
        p_granted_by => 3 
	);
END;

-- revoke access
BEGIN
	document_access_pkg.revoke_access(
	    p_document_id => 2,
        p_granted_to => 1,
        p_revoking_employee => 2
	);
END;



