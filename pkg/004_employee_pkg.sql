CREATE OR REPLACE PACKAGE employee_actions AS
    CURSOR get_employees RETURN employees%ROWTYPE;
    
    PROCEDURE create_employee(
        p_name employees.name%TYPE, 
        p_salary employees.salary%TYPE, 
        p_department_id employees.department_id%TYPE
    );
    
    PROCEDURE delete_employee(p_employee_id employees.id%TYPE);
    
    FUNCTION get_employee_details(p_employee_id employees.id%TYPE) 
    RETURN SYS_REFCURSOR;
    
    PROCEDURE set_department_chief(
        p_department_id departments.id%TYPE, 
        p_chief_id employees.id%TYPE
    );
END employee_actions;

CREATE OR REPLACE PACKAGE BODY employee_actions AS
    CURSOR get_employees RETURN employees%ROWTYPE IS 
        SELECT * FROM employees;

    PROCEDURE create_employee(
        p_name employees.name%TYPE, 
        p_salary employees.salary%TYPE, 
        p_department_id employees.department_id%TYPE
    ) IS
    	v_employee_id employees.id%TYPE;
    BEGIN
        INSERT INTO employees (name, salary, department_id) 
        	VALUES (p_name, p_salary, p_department_id)
    		RETURNING id INTO v_employee_id;
        
        action_logs_pkg.log_action(
            p_action_type => 'CREATE_EMPLOYEE', 
            p_employee_id => v_employee_id, 
            p_action_details => 'Created employee: ' || p_name
        );
    EXCEPTION
        WHEN OTHERS THEN
            action_logs_pkg.log_action(
                p_action_type => 'CREATE_EMPLOYEE_ERROR', 
                p_employee_id => NULL, 
                p_action_details => SQLERRM
            );
            RAISE;
    END create_employee;
    
    PROCEDURE delete_employee(p_employee_id employees.id%TYPE) IS
    BEGIN
        DELETE FROM employees WHERE id = p_employee_id;
        
        action_logs_pkg.log_action(
            p_action_type => 'DELETE_EMPLOYEE', 
            p_employee_id => p_employee_id, 
            p_action_details => 'Deleted employee with ID: ' || p_employee_id
        );
    EXCEPTION
        WHEN OTHERS THEN
            action_logs_pkg.log_action(
                p_action_type => 'DELETE_EMPLOYEE_ERROR', 
                p_employee_id => p_employee_id, 
                p_action_details => SQLERRM
            );
            RAISE;
    END delete_employee;
    
    FUNCTION get_employee_details(p_employee_id employees.id%TYPE) 
    RETURN SYS_REFCURSOR IS
        v_result SYS_REFCURSOR;
    BEGIN
        OPEN v_result FOR
            SELECT e.*, d.name AS department_name
            FROM employees e
            JOIN departments d ON e.department_id = d.id
            WHERE e.id = p_employee_id;
        
        action_logs_pkg.log_action(
            p_action_type => 'GET_EMPLOYEE_DETAILS', 
            p_employee_id => p_employee_id, 
            p_action_details => 'Retrieved details for employee ID: ' || p_employee_id
        );
        
        RETURN v_result;
    EXCEPTION
        WHEN OTHERS THEN
            action_logs_pkg.log_action(
                p_action_type => 'GET_EMPLOYEE_DETAILS_ERROR', 
                p_employee_id => p_employee_id, 
                p_action_details => SQLERRM
            );
            RAISE;
    END get_employee_details;
    
    PROCEDURE set_department_chief(
        p_department_id departments.id%TYPE, 
        p_chief_id employees.id%TYPE
    ) IS
    BEGIN
        UPDATE departments 
        SET chief_id = p_chief_id 
        WHERE id = p_department_id;
        
        action_logs_pkg.log_action(
            p_action_type => 'SET_DEPARTMENT_CHIEF', 
            p_employee_id => p_chief_id, 
            p_action_details => 'Set chief for department ID: ' || p_department_id
        );
    EXCEPTION
        WHEN OTHERS THEN
            action_logs_pkg.log_action(
                p_action_type => 'SET_DEPARTMENT_CHIEF_ERROR', 
                p_employee_id => p_chief_id, 
                p_action_details => SQLERRM
            );
            RAISE;
    END set_department_chief;
END employee_actions;

