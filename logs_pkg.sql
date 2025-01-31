CREATE OR REPLACE PACKAGE action_logs_pkg AS 
	PROCEDURE log_action(
		p_action_type action_logs.action_type%TYPE,
		p_employee_id action_logs.employee_id%TYPE,
		p_action_details action_logs.action_details%TYPE
	);
END action_logs_pkg;

CREATE OR REPLACE PACKAGE BODY action_logs_pkg AS 
	PROCEDURE log_action(
		p_action_type action_logs.action_type%TYPE,
		p_employee_id action_logs.employee_id%TYPE,
		p_action_details action_logs.action_details%TYPE
	) IS
	BEGIN 
		INSERT INTO action_logs (action_type, employee_id, action_details)
			VALUES (p_action_type, p_employee_id, p_action_details);
	END;
END action_logs_pkg;
