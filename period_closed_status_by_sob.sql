SELECT DISTINCT (SELECT sob.NAME
                      FROM gl_sets_of_books sob
                     WHERE sob.set_of_books_id = a.set_of_books_id)
                      "SOB_Name"
                 , a.period_name "Period_Name"
                 , a.period_num "Period_Num"
                 , a.gl_status "GL_Status"
                 , b.po_status "PO_Status"
                 , c.ap_status "AP_Status"
                 , d.ar_status "AR_Status"
                 , e.fa_status "FA_Status"
     FROM (SELECT period_name
                , period_num
                , DECODE (closing_status
                        , 'O', 'Open'
                        , 'C', 'Closed'
                        , 'F', 'Future'
                        , 'N', 'Never'
                        , closing_status)
                     gl_status
                , set_of_books_id
             FROM gl_period_statuses
            WHERE application_id = 101
              AND UPPER (period_name) = UPPER ('&period_name')
              AND set_of_books_id = '&sob') a
        , (SELECT period_name
                , DECODE (closing_status
                        , 'O', 'Open'
                        , 'C', 'Closed'
                        , 'F', 'Future'
                        , 'N', 'Never'
                        , closing_status)
                     po_status
                , set_of_books_id
             FROM gl_period_statuses
            WHERE application_id = 201
              AND UPPER (period_name) = UPPER ('&period_name')
              AND set_of_books_id = '&sob') b
        , (SELECT period_name
                , DECODE (closing_status
                        , 'O', 'Open'
                        , 'C', 'Closed'
                        , 'F', 'Future'
                        , 'N', 'Never'
                        , closing_status)
                     ap_status
                , set_of_books_id
             FROM gl_period_statuses
            WHERE application_id = 200
              AND UPPER (period_name) = UPPER ('&period_name')
              AND set_of_books_id = '&sob') c
        , (SELECT period_name
                , DECODE (closing_status
                        , 'O', 'Open'
                        , 'C', 'Closed'
                        , 'F', 'Future'
                        , 'N', 'Never'
                        , closing_status)
                     ar_status
                , set_of_books_id
             FROM gl_period_statuses
            WHERE application_id = 222
              AND UPPER (period_name) = UPPER ('&period_name')
              AND set_of_books_id = '&sob') d
        , (SELECT fdp.period_name
                , DECODE (fdp.period_close_date, NULL, 'Open', 'Closed')
                     fa_status
                , fbc.set_of_books_id
             FROM fa_book_controls fbc, fa_deprn_periods fdp
            WHERE fbc.set_of_books_id = '&sob'
              AND fbc.book_type_code = fdp.book_type_code
              AND UPPER (fdp.period_name) = UPPER ('&period_name')) e
    WHERE a.period_name = b.period_name(+)
      AND a.period_name = c.period_name(+)
      AND a.period_name = d.period_name(+)
      AND a.period_name = e.period_name(+)
      AND a.set_of_books_id = b.set_of_books_id(+)
      AND a.set_of_books_id = c.set_of_books_id(+)
      AND a.set_of_books_id = d.set_of_books_id(+)
      AND a.set_of_books_id = e.set_of_books_id(+)
 ORDER BY 1;