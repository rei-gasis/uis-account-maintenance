create or replace PACKAGE  BODY xxup_user_acc_main_pkg
AS
  PROCEDURE lock_accounts(x_errbuf OUT VARCHAR2
                           ,x_retcode OUT VARCHAR2)
  IS                         
  
    CURSOR c_acc_lock
    IS
    SELECT fu.user_name
          ,pps.actual_termination_date
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
    
    fnd_file.put_line(fnd_file.output, LPAD('USER_NAME',20, ' '));
    fnd_file.put(fnd_file.output, LPAD('LOCK DATE',20, ' '));
    
    FOR r_acc_lock IN c_acc_lock
    LOOP
    
      BEGIN
        FND_USER_PKG.UPDATEUSER(x_user_name => r_acc_lock.user_name
                                ,x_owner => null
                                ,x_end_date => r_acc_lock.actual_termination_date
                                );
                        
      
--        COMMIT;
        
        
        fnd_file.put_line(fnd_file.output, LPAD(r_acc_lock.user_name, 20, ' '));
        fnd_file.put_line(fnd_file.output, LPAD(r_acc_lock.actual_termination_date, 20, ' '));
        
    END LOOP;
    
    
    
  END lock_accounts;

END xxup_user_acc_main_pkg;