declare
 v_From       varchar2(80) := 'FROM_EMAIL';
 v_Recipient  varchar2(80) := 'TO_EMAIL';
 v_Subject    varchar2(80) := 'SUBJECT';
 v_Mail_Host  varchar2(30) := 'MAIL_SERVER';
 v_Mail_Port  number       := 25;
 v_Mail_Conn  utl_smtp.Connection;
 crlf         varchar2(2)  := chr(13)||chr(10);
 text         varchar2(3000);
 cnt          number;
begin
 text := 'TEXT' || crlf;

 v_Mail_Conn := utl_smtp.Open_Connection(v_Mail_Host,v_Mail_Port);
 utl_smtp.Helo(v_Mail_Conn,v_Mail_Host);
 utl_smtp.Mail(v_Mail_Conn,v_From);
 utl_smtp.Rcpt(v_Mail_Conn,v_Recipient);
 utl_smtp.Open_Data(v_Mail_Conn);
 utl_smtp.Write_Data(v_Mail_Conn,'Date: ' || to_char(sysdate, 'Dy, DD Mon YYYY hh24:mi:ss') || crlf);
 utl_smtp.Write_Data(v_Mail_Conn,'From: ' || v_From || crlf);
 utl_smtp.Write_Raw_Data(v_Mail_Conn,utl_raw.cast_to_raw(convert('Subject: '||v_Subject||crlf,'CL8MSWIN1251')));
 utl_smtp.Write_Data(v_Mail_Conn,'To: ' || v_Recipient || crlf);
 utl_smtp.Write_Data(v_Mail_Conn,'Content-Type: text/plain; charset="windows-1251"' || crlf);
 utl_smtp.Write_Data(v_Mail_Conn,'Content-Transfer-Encoding: 8bit' || crlf);
 utl_smtp.Write_Data(v_Mail_Conn,crlf);
 utl_smtp.Write_Raw_Data(v_Mail_Conn,utl_raw.cast_to_raw(convert(text,'CL8MSWIN1251')));
 utl_smtp.Write_Data(v_Mail_Conn,crlf);

 utl_smtp.Close_Data(v_Mail_Conn);
 utl_smtp.Quit(v_Mail_Conn);
exception
 when utl_smtp.Transient_Error or utl_smtp.Permanent_Error then raise_application_error(-20000,'Unable to send mail: ' || sqlerrm);
end;
