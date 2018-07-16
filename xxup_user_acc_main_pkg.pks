create or replace PACKAGE xxup_user_acc_main_pkg
AS
  PROCEDURE lock_accounts(x_errbuf OUT VARCHAR2
                           ,x_retcode OUT VARCHAR2);

END xxup_user_acc_main_pkg;