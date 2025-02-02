CREATE OR REPLACE PACKAGE document_management AS
    PROCEDURE add_document(
        p_employee_id employees.id%TYPE,
        p_title documents.title%TYPE,
        p_content documents.content%TYPE
    );
    
    PROCEDURE delete_document(
        p_document_id documents.id%TYPE
    );
    
    FUNCTION get_employee_documents(
        p_employee_id employees.id%TYPE
    ) RETURN SYS_REFCURSOR;
END document_management;


CREATE OR REPLACE PACKAGE BODY document_management AS
    PROCEDURE add_document(
        p_employee_id employees.id%TYPE,
        p_title documents.title%TYPE,
        p_content documents.content%TYPE
    ) IS
        v_document_id documents.id%TYPE;
    BEGIN
        INSERT INTO documents (title, content, employee_id) 
        VALUES (p_title, p_content, p_employee_id)
        RETURNING id INTO v_document_id;
        
        action_logs_pkg.log_action(
            'ADD_DOCUMENT', 
            p_employee_id, 
            'Added document "' || p_title || '" with ID: ' || v_document_id
        );
    EXCEPTION
        WHEN OTHERS THEN
            action_logs_pkg.log_action(
                'ADD_DOCUMENT_ERROR', 
                p_employee_id, 
                SQLERRM
            );
            RAISE;
    END add_document;
    
    PROCEDURE delete_document(
        p_document_id documents.id%TYPE
    ) IS
        v_employee_id employees.id%TYPE;
    BEGIN
        SELECT employee_id INTO v_employee_id
        FROM documents
        WHERE id = p_document_id;
        
        DELETE FROM documents WHERE id = p_document_id;
        
        action_logs_pkg.log_action(
            'DELETE_DOCUMENT', 
            v_employee_id, 
            'Deleted document with ID: ' || p_document_id
        );
    EXCEPTION
        WHEN OTHERS THEN
            action_logs_pkg.log_action(
                'DELETE_DOCUMENT_ERROR', 
                NULL, 
                SQLERRM
            );
            RAISE;
    END delete_document;
    
    FUNCTION get_employee_documents(
        p_employee_id employees.id%TYPE
    ) RETURN SYS_REFCURSOR IS
        v_result SYS_REFCURSOR;
    BEGIN
        OPEN v_result FOR
        SELECT d.id, d.title, TO_CHAR(d.content) AS content, d.employee_id
        	FROM documents d
        	WHERE d.employee_id = p_employee_id
        UNION
        SELECT d.id, d.title, TO_CHAR(d.content) AS content, d.employee_id
        	FROM documents d
        	JOIN document_access_permissions dap ON d.id = dap.document_id
        	WHERE dap.granted_to = p_employee_id;
        
        RETURN v_result;
    END get_employee_documents;
END document_management;






