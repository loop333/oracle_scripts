create or replace procedure owner.csv_to_email as
 v_From       varchar2(80) := 'from@email';
 v_Recipient1 varchar2(80) := 'to1@email';
 v_Recipient2 varchar2(80) := 'to2@email';
 v_Recipient3 varchar2(80) := 'to3@email';
 v_Subject    varchar2(80) := 'SUBJECT';
 v_Mail_Host  varchar2(30) := 'smtp_host';
 v_Mail_Port  number       := 25;
 v_Mail_Conn  utl_smtp.Connection;
 crlf         varchar2(2)  := chr(13)||chr(10);
 text         varchar2(3000);
 filename     varchar2(50);
 cnt          number;
begin
 filename := 'output' || to_char(trunc(sysdate)-1,'YYYYMMDD') || '.csv';
 text := 'F1;F2;F3;F4;F5;F6;F7' || crlf;

 cnt := 0; 
 for c in (select 
            f1, f2, f3, f4, f5, f6, f7
           from 
            owner.table t
           order f1) loop
  text := text || c.f1 || ';' || c.f2 || ';' || c.f3 || ';' || c.f4 || ';' || c.f5 || ';' || c.f6 || ';' || c.f7 || crlf;
  cnt := cnt + 1;
 end loop;   

 if cnt > 0 then
  v_Mail_Conn := utl_smtp.Open_Connection(v_Mail_Host,v_Mail_Port);
  utl_smtp.Helo(v_Mail_Conn,v_Mail_Host);
  utl_smtp.Mail(v_Mail_Conn,v_From);
  utl_smtp.Rcpt(v_Mail_Conn,v_Recipient1);
  utl_smtp.Rcpt(v_Mail_Conn,v_Recipient2);
  utl_smtp.Rcpt(v_Mail_Conn,v_Recipient3);
  utl_smtp.Open_Data(v_Mail_Conn);
  utl_smtp.Write_Data(v_Mail_Conn,'Date: ' || to_char(sysdate, 'Dy, DD Mon YYYY hh24:mi:ss') || crlf);
  utl_smtp.Write_Data(v_Mail_Conn,'From: ' || v_From || crlf);
  utl_smtp.Write_Data(v_Mail_Conn,'Subject: ' || v_Subject || crlf);
  utl_smtp.Write_Data(v_Mail_Conn,'To: ' || v_Recipient1 || ';' || v_Recipient2 || ';' || v_Recipient3 || ';' || crlf);
  utl_smtp.Write_Data(v_Mail_Conn,'MIME-Version: 1.0' || crlf);
  utl_smtp.Write_Data(v_Mail_Conn,'Content-Type: multipart/mixed; boundary="-----SECBOUND"' || crlf);
  utl_smtp.Write_Data(v_Mail_Conn,crlf);
  utl_smtp.Write_Data(v_Mail_Conn,'-------SECBOUND'|| crlf);
  utl_smtp.Write_Data(v_Mail_Conn,'Content-Type: text/plain; charset="windows-1251"; name="' || filename || '"' || crlf);
  utl_smtp.Write_Data(v_Mail_Conn,'Content-Transfer-Encoding: 8bit' || crlf);
--  utl_smtp.Write_Data(v_Mail_Conn,'Content-Transfer-Encoding: base64' || crlf);
  utl_smtp.Write_Data(v_Mail_Conn,'Content-Disposition: attachment; filename="' || filename || '"' || crlf);
  utl_smtp.Write_Data(v_Mail_Conn,crlf);
  utl_smtp.Write_Raw_Data(v_Mail_Conn,utl_raw.cast_to_raw(convert(text,'CL8MSWIN1251')));
-- utl_smtp.Write_Raw_Data(v_Mail_Conn,utl_encode.base64_encode(utl_raw.cast_to_raw(text)));
  utl_smtp.Write_Data(v_Mail_Conn,crlf);
  utl_smtp.Write_Data(v_Mail_Conn,'-------SECBOUND--');

  utl_smtp.Close_Data(v_Mail_Conn);
  utl_smtp.Quit(v_Mail_Conn);
 end if; 
exception
 when utl_smtp.Transient_Error or utl_smtp.Permanent_Error then raise_application_error(-20000,'Unable to send mail: ' || sqlerrm);
end;
