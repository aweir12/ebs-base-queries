/* 
Depends heavily on EBS Configuration. 
Query designed to pull limited descriptive information for active employees and
contractors. Also pull's reporting hierarchy of each employee, as well as each 
employee's "Executive Level" manager 
 */
SELECT
    person_id,
    first_name,
    last_name,
    email_address,
    name,
    supervisor_id,
    sys_connect_by_path(last_name,'/'),
    CASE
            WHEN level < 3
                 AND level > 1 THEN replace(replace(sys_connect_by_path(last_name,'/'),'/'
            || last_name,''),'/','')
            WHEN level >= 3  THEN substr(sys_connect_by_path(last_name,'/'),instr(sys_connect_by_path(last_name,'/'),'/',1,2) + 1,instr(sys_connect_by_path
(last_name,'/'),'/',2,2) - instr(sys_connect_by_path(last_name,'/'),'/',1,2) - 1)
            ELSE replace(sys_connect_by_path(last_name,'/'),'/')
        END
    AS EXEC_MANAGER
FROM
    (
        SELECT
            papf.person_id,
            papf.first_name,
            papf.last_name,
            papf.email_address,
            pj.name,
            paaf.supervisor_id
        FROM
            hr.per_all_people_f papf,
            hr.per_all_assignments_f paaf,
            per_jobs pj
        WHERE
            papf.person_id = paaf.person_id
            AND   paaf.job_id = pj.job_id (+)
            AND   paaf.primary_flag = 'Y'
            AND   paaf.assignment_type = 'E'
            AND   papf.current_employee_flag = 'Y'
            AND   paaf.employment_category != 'RESTORE'
            AND   SYSDATE BETWEEN paaf.effective_start_date AND paaf.effective_end_date
            AND   SYSDATE BETWEEN papf.effective_start_date AND papf.effective_end_date
    )
START WITH
    supervisor_id IS NULL
CONNECT BY
    PRIOR person_id = supervisor_id
ORDER BY
    level ASC;
