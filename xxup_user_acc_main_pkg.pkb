create or replace PACKAGE  BODY xxup_user_acc_main_pkg
AS
  PROCEDURE lock_accounts(x_errbuf OUT VARCHAR2
                           ,x_retcode OUT VARCHAR2)
  IS                         
  
    CURSOR c_acc_lock
    IS
    SELECT full_name, pps.actual_termination_date, papf.person_id
    FROM hr.per_all_people_f papf
       ,fnd_user fu
       ,per_periods_of_service pps
    WHERE fu.employee_id = papf.person_id
      AND pps.person_id = papf.person_id
      AND TRUNC(SYSDATE) BETWEEN papf.effective_start_date AND papf.effective_end_date
      AND pps.date_start = (SELECT MAX(date_start)
                            FROM per_periods_of_service pps_1
                            WHERE pps.period_of_service_id = pps_1.period_of_service_id
                            AND pps.actual_termination_date IS NOT NULL
                            )
      AND TRUNC(pps.actual_termination_date) <= TRUNC(SYSDATE);
  BEGIN
    NULL;
  END lock_accounts;

END xxup_user_acc_main_pkg;