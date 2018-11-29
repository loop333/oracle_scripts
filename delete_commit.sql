create or replace procedure adm.delete_commit
( p_statement                   in varchar2,
  p_commit_batch_size   in number default 10000)
is
        cid                             integer;
        changed_statement               varchar2(2000);
        finished                        boolean;
        nofrows                         integer;
        lrowid                          rowid;
        rowcnt                          integer;
        errpsn                          integer;
        sqlfcd                          integer;
        errc                            integer;
        errm                            varchar2(2000);
begin
        /* If the actual statement contains a WHERE clause, then append a
           rownum < n clause after that using AND, else use WHERE
           rownum < n clause */
        if ( upper(p_statement) like '% WHERE %') then
                changed_statement := p_statement||' AND rownum < '
                           ||to_char(p_commit_batch_size + 1);
        else
                changed_statement := p_statement||' WHERE rownum < '
                           ||to_char(p_commit_batch_size + 1);
        end if;
        begin
                cid := dbms_sql.open_cursor; -- Open a cursor for the task
                dbms_sql.parse(cid,changed_statement, dbms_sql.native);
                        -- parse the cursor. Please note that in Oracle 7.2.2
                        -- parsing does a execute too. But that does not
                        -- pose a problem here as we want that.
                rowcnt := dbms_sql.last_row_count;
                        -- store for some future reporting
        exception
                when others then
                     errpsn := dbms_sql.last_error_position;
                        -- gives the error position in the changed sql
                        -- delete statement if anything happens
                     sqlfcd := dbms_sql.last_sql_function_code;
                        -- function code can be found in the OCI manual
                     lrowid := dbms_sql.last_row_id;
                        -- store all these values for error reporting. However
                        -- all these are really useful in a stand-alone proc
                        -- execution for dbms_output to be successful, not
                        -- possible when called from a form or front-end tool.
                     errc := SQLCODE;
                     errm := SQLERRM;
                     dbms_output.put_line('Error '||to_char(errc)||
                                        ' Posn '||to_char(errpsn)||
                                        ' SQL fCode '||to_char(sqlfcd)||
                                        ' rowid '||rowidtochar(lrowid));
                     raise_application_error(-20000,errm);
                        -- this will ensure the display of atleast the error
                        -- message if someething happens, even in a frontend
                        -- tool.
        end;
        finished := FALSE;
        while not (finished)
        loop -- keep on executing the cursor till there is no more to process.
                begin
                        nofrows := dbms_sql.execute(cid);
                        rowcnt := dbms_sql.last_row_count;
                exception
                        when others then
                                errpsn := dbms_sql.last_error_position;
                                sqlfcd := dbms_sql.last_sql_function_code;
                                lrowid := dbms_sql.last_row_id;
                                errc := SQLCODE;
                                errm := SQLERRM;
                                dbms_output.put_line('Error '||to_char(errc)||
                                        ' Posn '||to_char(errpsn)||
                                        ' SQL fCode '||to_char(sqlfcd)||
                                        ' rowid '||rowidtochar(lrowid));
                                raise_application_error(-20000,errm);
                end;
                if nofrows = 0 then
                        finished := TRUE;
                else
                        finished := FALSE;
                end if;
                commit;
        end loop;
        begin
                dbms_sql.close_cursor(cid);
                        -- close the cursor for a clean finish
        exception
                when others then
                        errpsn := dbms_sql.last_error_position;
                        sqlfcd := dbms_sql.last_sql_function_code;
                        lrowid := dbms_sql.last_row_id;
                        errc := SQLCODE;
                        errm := SQLERRM;
                        dbms_output.put_line('Error '||to_char(errc)||
                                ' Posn '||to_char(errpsn)||
                                ' SQL fCode '||to_char(sqlfcd)||
                                ' rowid '||rowidtochar(lrowid));
                        raise_application_error(-20000,errm);
        end;
end;
/
