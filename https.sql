-- oracle 12.2.0.1
DECLARE
  p_url            VARCHAR2(256);
  l_http_request   UTL_HTTP.req;
  l_http_response  UTL_HTTP.resp;
  l_blob           BLOB;
  l_buf            RAW(32767);
BEGIN
  DBMS_OUTPUT.enable(100000);

  p_url := 'https://www.google.com';

-- orapki wallet create -wallet /ORCL/wallet -pwd WalletPass123
-- orapki wallet add -wallet /ORCL/wallet -trusted_cert -cert /ORCL/1.cer -pwd WalletPass123
-- orapki wallet display -complete -wallet /ORCL/wallet -pwd WalletPass123
  UTL_HTTP.set_wallet('file:/ORCL/wallet', 'WalletPass123');

--  UTL_HTTP.set_proxy('http://192.168.1.1:8118', '');

  DBMS_LOB.createtemporary(l_blob, true);

  -- Make a HTTP request and get the response.
  l_http_request  := UTL_HTTP.begin_request(url => p_url, https_host => 'e1.ru');

  l_http_response := UTL_HTTP.get_response(l_http_request);

  -- Loop through the response.
  BEGIN
    LOOP
      UTL_HTTP.read_raw(l_http_response, l_buf);
      DBMS_LOB.append(l_blob, l_buf);
    END LOOP;
  EXCEPTION
    WHEN UTL_HTTP.end_of_body THEN
      UTL_HTTP.end_response(l_http_response);
  END;
  
  DBMS_OUTPUT.put_line(DBMS_LOB.getlength(l_blob));
  DBMS_OUTPUT.put_line(UTL_RAW.cast_to_varchar2(DBMS_LOB.substr(l_blob, 100, 1)));
EXCEPTION
  WHEN OTHERS THEN
    UTL_HTTP.end_response(l_http_response);
    DBMS_OUTPUT.put_line('ERR: ' || UTL_HTTP.get_detailed_sqlerrm());
    RAISE;
END;
