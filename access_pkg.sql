CREATE OR REPLACE PACKAGE document_access_pkg AS
    PROCEDURE grant_access(
        p_document_id documents.id%TYPE,
        p_granted_to employees.id%TYPE,
        p_granted_by employees.id%TYPE
    );

    PROCEDURE revoke_access(
        p_document_id documents.id%TYPE,
        p_granted_to employees.id%TYPE,
        p_revoking_employee employees.id%TYPE
    );
    
    PROCEDURE restrict_to_grant_access (
    	p_employee_id employees.id%TYPE,
    	p_restrict_from employees.id%TYPE,
    	p_restrict_all BOOLEAN
    );
END document_access_pkg;


CREATE OR REPLACE PACKAGE BODY document_access_pkg AS
    PROCEDURE validate_access_grant(
    	p_document_id documents.id%TYPE,
        p_granted_to employees.id%TYPE,
        p_granted_by employees.id%TYPE
    ) IS
        v_is_chief NUMBER;
        v_same_department NUMBER;
		v_is_blocked NUMBER;
		v_ows_document NUMBER;
    BEGIN
        SELECT COUNT(*) INTO v_is_chief
        FROM departments d
        WHERE d.chief_id = p_granted_by;
        
        SELECT COUNT(*) INTO v_same_department
        FROM employees e1, employees e2
        WHERE e1.id = p_granted_by 
          AND e2.id = p_granted_to
          AND e1.department_id = e2.department_id;
        
        SELECT COUNT(*) INTO v_is_blocked
    	FROM employee_access_restrictions ear
    	WHERE ear.employee_id = p_granted_to
    		AND (ear.restricted_from IS NULL OR ear.restricted_from = p_granted_by);
        
        SELECT COUNT(*) INTO v_ows_document
        FROM documents d 
        WHERE d.employee_id = p_granted_by 
        	AND d.id = p_document_id;

        -- начальник и разные департаменты 
        -- не начальник, но заблочен (он или все)
        -- не начальник и не обладает этим файлом
        IF (v_is_chief > 0 AND v_same_department = 0) 
        	OR (v_is_chief = 0 AND (v_is_blocked > 0 OR v_ows_document = 0)) THEN
            	RAISE_APPLICATION_ERROR(-20001, 'Недостаточно прав для предоставления доступа');
        END IF;
    END validate_access_grant;
    
    PROCEDURE validate_revoke (
		p_document_id documents.id%TYPE,
		p_granted_to employees.id%TYPE,
        p_revoking_employee employees.id%TYPE
	) IS
	    v_chief_id departments.chief_id%TYPE;
        v_granted_by document_access_permissions.granted_by%TYPE;
    BEGIN
        SELECT chief_id INTO v_chief_id
        FROM departments 
        WHERE id = (
            SELECT department_id 
            FROM employees 
            WHERE id = p_granted_to
        );

        SELECT granted_by INTO v_granted_by
        FROM document_access_permissions
        WHERE document_id = p_document_id 
          AND granted_to = p_granted_to;
        
        -- если начальником, но удаляет не начальник
        IF v_granted_by = v_chief_id AND p_revoking_employee != v_chief_id THEN
            RAISE_APPLICATION_ERROR(-20002, 'Недостаточно прав для отзыва доступа');
        END IF;
        
        -- не начальник, но удаляет не сам сотрудник или не тот, кто выдал права
        IF v_granted_by != v_chief_id AND p_revoking_employee != v_granted_by AND p_revoking_employee != p_granted_to THEN
            RAISE_APPLICATION_ERROR(-20002, 'Недостаточно прав для отзыва доступа');
        END IF;     
    END validate_revoke;

        
    PROCEDURE grant_access(
        p_document_id documents.id%TYPE,
        p_granted_to employees.id%TYPE,
        p_granted_by employees.id%TYPE
    ) IS
    BEGIN
        validate_access_grant(p_document_id, p_granted_to, p_granted_by);
        
        INSERT INTO document_access_permissions (
            document_id, 
            granted_to, 
            granted_by
        ) VALUES (
            p_document_id, 
            p_granted_to, 
            p_granted_by
        );
        
        action_logs_pkg.log_action(
            'GRANT_DOCUMENT_ACCESS', 
            p_granted_by, 
            'Доступ к документу ' || p_document_id || ' предоставлен сотруднику ' || p_granted_to
        );
    EXCEPTION
        WHEN OTHERS THEN
            action_logs_pkg.log_action(
                'GRANT_DOCUMENT_ACCESS_ERROR', 
                p_granted_by, 
                SQLERRM
            );
            RAISE;
    END grant_access;

    PROCEDURE revoke_access(
        p_document_id documents.id%TYPE,
        p_granted_to employees.id%TYPE,
        p_revoking_employee employees.id%TYPE
    ) IS
        v_chief_id NUMBER;
        v_granted_by NUMBER;
    BEGIN
       validate_revoke(p_document_id, p_granted_to, p_revoking_employee);
        
        DELETE FROM document_access_permissions
        WHERE document_id = p_document_id 
          AND granted_to = p_granted_to;
        
        action_logs_pkg.log_action(
            'REVOKE_DOCUMENT_ACCESS', 
            p_revoking_employee, 
            'Отозван доступ к документу ' || p_document_id || ' для сотрудника ' || p_granted_to
        );
    EXCEPTION
        WHEN OTHERS THEN
            action_logs_pkg.log_action(
                'REVOKE_DOCUMENT_ACCESS_ERROR', 
                p_revoking_employee, 
                SQLERRM
            );
            RAISE;
    END revoke_access;
        
    PROCEDURE restrict_to_grant_access (
    	p_employee_id employees.id%TYPE,
    	p_restrict_from employees.id%TYPE,
    	p_restrict_all BOOLEAN
    ) IS
    BEGIN
	    IF p_restrict_all THEN 
	    	DELETE FROM employee_access_restrictions ear
	    		WHERE ear.employee_id = p_employee_id;
    
    		INSERT INTO employee_access_restrictions ear (employee_id, restricted_from)
    			VALUES (p_employee_id, NULL);
	    ELSE 
	    	INSERT INTO employee_access_restrictions ear (employee_id, restricted_from)
    			VALUES (p_employee_id, p_restrict_from);
	    END IF;
	END restrict_to_grant_access;
        
END document_access_pkg;






