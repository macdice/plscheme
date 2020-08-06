CREATE EXTENSION plschemeu;

-- test simple function
CREATE FUNCTION scm_pow(u int, v int)
RETURNS int AS
$$
(let loop ((v v))
  (if (< v 1) 1
      (* u (loop (- v 1)))))
$$ LANGUAGE plschemeu;
SELECT scm_pow(2, 5);
DROP FUNCTION scm_pow(u int, v int);

-- test set-of behavior
CREATE OR REPLACE FUNCTION setof_example_1(OUT foo int)
RETURNS SETOF int AS
$$
(list
  '(("foo" . 13))
  '(("foo" . 14)))
$$ LANGUAGE plschemeu;
SELECT * FROM setof_example_1();
DROP FUNCTION setof_example_1(OUT foo int);

-- test pl-shared
CREATE FUNCTION set_var(num int) RETURNS int AS
$$
(let ((oldnum pl-shared))
  (set! pl-shared num)
  oldnum)
$$ LANGUAGE plschemeu;
CREATE FUNCTION get_var()
RETURNS int AS
$$
pl-shared
$$ LANGUAGE plschemeu;
SELECT set_var(1);
SELECT set_var(2);
SELECT get_var();
DROP FUNCTION set_var(num int);
DROP FUNCTION get_var();

-- test spi
CREATE TABLE t (i int);
CREATE FUNCTION test_scheme_spi() RETURNS void AS
$$
(begin
  (let ((ret (spi-execute "INSERT INTO t VALUES (42)")))
    (report notice-level
            (simple-format #f "spi-execute affected = ~s"
                           (assoc-ref ret "affected-tuples"))))
  (let ((plan (spi-prepare "INSERT INTO t VALUES ($1)" (vector "int"))))
    (let ((ret (spi-execute-prepared plan (vector "43"))))
      (report notice-level
              (simple-format #f "spi-execute-prepared affected = ~s"
                             (assoc-ref ret "affected-tuples"))))))
$$ LANGUAGE plschemeu;
SELECT test_scheme_spi();
SELECT * FROM t ORDER BY i;
DROP TABLE t;
DROP FUNCTION test_scheme_spi();

-- test simple trigger function
CREATE OR REPLACE FUNCTION my_trigger_dump() RETURNS trigger LANGUAGE plschemeu AS
$$
(begin
  (report notice-level
          (simple-format #f "trigger ~s fired on ~s; got old = ~s, new = ~s"
                         tg-name tg-relname tg-tuple-old tg-tuple-new))
  tg-tuple-new)
$$;
CREATE TABLE my_table (id int, name text);
CREATE TRIGGER my_trigger_func
  AFTER UPDATE ON my_table
  FOR EACH ROW EXECUTE PROCEDURE my_trigger_dump();
INSERT INTO my_table VALUES (1, 'aaa');
UPDATE my_table SET name = 'bbb' WHERE id = 1;
DROP TABLE my_table;
DROP FUNCTION my_trigger_dump();

DROP EXTENSION plschemeu;
