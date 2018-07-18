create or replace PACKAGE  BODY xxup_user_acc_main_pkg
AS
  PROCEDURE lock_accounts(x_errbuf OUT VARCHAR2
                           ,x_retcode OUT VARCHAR2)
  IS                         
  
  
    
    ln_pad NUMBER := 35;
    
    CURSOR c_acc_lock
    IS
    SELECT fu.user_name
          ,papf.full_name
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
      AND TRUNC(pps.actual_termination_date) <= TRUNC(SYSDATE)
      AND person_type_id = 1130 -- currently ex-employee
      AND fu.end_date IS NULL; --exclude already locked employees
      
  BEGIN
    fnd_file.put_line(fnd_file.output, 'UP User Account Maintenance v1.0');
    fnd_file.put_line(fnd_file.output, 'Function: Lock account');
    fnd_file.put_line(fnd_file.output, 'Lock Date: ' || to_char(TRUNC(SYSDATE),'DD-MON-YYYY'));
    fnd_file.put_line(fnd_file.output, '');
    
    fnd_file.put(fnd_file.output, RPAD('USERNAME',ln_pad, ' '));
    fnd_file.put(fnd_file.output, RPAD('FULL NAME',ln_pad, ' '));
    fnd_file.put_line(fnd_file.output, RPAD('ACTUAL TERMINATION DATE',ln_pad, ' '));
    
    fnd_file.put(fnd_file.output, LPAD(' ',ln_pad, '-'));
    fnd_file.put(fnd_file.output, LPAD(' ',ln_pad, '-'));
    fnd_file.put_line(fnd_file.output, LPAD(' ',ln_pad, '-'));
    
    FOR r_acc_lock IN c_acc_lock
    LOOP
      BEGIN
        FND_USER_PKG.UPDATEUSER(x_user_name => r_acc_lock.user_name
                                ,x_owner => null
                                ,x_end_date => TRUNC(SYSDATE)
                                );
                        
      
--        COMMIT;
        
        
        fnd_file.put(fnd_file.output, RPAD(r_acc_lock.user_name, ln_pad, ' '));
        fnd_file.put(fnd_file.output, RPAD(r_acc_lock.full_name, ln_pad, ' '));
        fnd_file.put_line(fnd_file.output, RPAD(r_acc_lock.actual_termination_date, ln_pad, ' '));
        
        
      EXCEPTION
        WHEN OTHERS THEN
          fnd_file.put_line(fnd_file.log, SUBSTR(SQLERRM, 0, 1000));
      END;
    END LOOP;
    
  END lock_accounts;

END xxup_user_acc_main_pkg;