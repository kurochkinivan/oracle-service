CREATE TABLE departments (
    id NUMBER GENERATED BY DEFAULT ON NULL AS IDENTITY,
    name NVARCHAR2 (50) NOT NULL,
    chief_id NUMBER,
    CONSTRAINT pk_departments PRIMARY KEY (id)
);

CREATE TABLE employees (
    id NUMBER GENERATED BY DEFAULT ON NULL AS IDENTITY,
    name NVARCHAR2 (50) NOT NULL,
    salary NUMBER(10, 2) NOT NULL,
    department_id NUMBER NOT NULL,
    CONSTRAINT pk_employees PRIMARY KEY (id),
    CONSTRAINT fk_departments FOREIGN KEY (department_id) REFERENCES departments (id) ON DELETE SET NULL
);

ALTER TABLE departments
ADD CONSTRAINT fk_department_chief FOREIGN KEY (chief_id) REFERENCES employees (id) ON DELETE SET NULL;

CREATE TABLE documents (
    id NUMBER GENERATED BY DEFAULT ON NULL AS IDENTITY,
    title NVARCHAR2 (100) NOT NULL,
    content NCLOB NOT NULL,
    employee_id NUMBER NOT NULL,
    CONSTRAINT pk_documents PRIMARY KEY (id),
    CONSTRAINT fk_document_employee FOREIGN KEY (employee_id) REFERENCES employees (id) ON DELETE SET NULL
);

CREATE TABLE document_access_permissions (
    document_id NUMBER NOT NULL,
    granted_to NUMBER NOT NULL,
    granted_by NUMBER NOT NULL,
    grant_date DATE DEFAULT SYSDATE,
    CONSTRAINT pk_document_access_permissions PRIMARY KEY (document_id, granted_to),
    CONSTRAINT fk_document_access_document FOREIGN KEY (document_id) REFERENCES documents (id) ON DELETE CASCADE,
    CONSTRAINT fk_document_access_granted_to FOREIGN KEY (granted_to) REFERENCES employees (id) ON DELETE CASCADE,
    CONSTRAINT fk_document_access_granted_by FOREIGN KEY (granted_by) REFERENCES employees (id) ON DELETE CASCADE
);

CREATE TABLE action_logs (
    id NUMBER GENERATED BY DEFAULT ON NULL AS IDENTITY,
    action_type VARCHAR2(50) NOT NULL,
    employee_id NUMBER,
    action_details NVARCHAR2 (500),
    action_timestamp TIMESTAMP DEFAULT SYSTIMESTAMP,
    CONSTRAINT pk_action_logs PRIMARY KEY (id),
    CONSTRAINT fk_action_logs_employee FOREIGN KEY (employee_id) REFERENCES employees (id) ON DELETE SET NULL
);

CREATE TABLE employee_access_restrictions (
    employee_id NUMBER NOT NULL,
    restricted_from NUMBER, -- NULL = блокирует всех, иначе блокирует конкретного сотрудника
    CONSTRAINT pk_employee_access_restrictions PRIMARY KEY (employee_id, restricted_from),
    CONSTRAINT fk_restriction_employee FOREIGN KEY (employee_id) REFERENCES employees (id) ON DELETE CASCADE,
    CONSTRAINT fk_restriction_from FOREIGN KEY (restricted_from) REFERENCES employees (id) ON DELETE CASCADE
);