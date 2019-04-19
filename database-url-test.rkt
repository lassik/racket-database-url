#lang racket/base

;; Copyright 2019 Lassi Kortela
;; SPDX-License-Identifier: ISC

(require
 db
 rackunit
 database-url)

(define (check-database-url wanted-connect u wanted-kw-alist)
  (let-values (((kw-hash connect) (database-url-parse u)))
    (check-equal? connect wanted-connect)
    (check-equal? (sort (hash->list kw-hash) keyword<? #:key car)
                  wanted-kw-alist)))

(test-case "mysql"
  (check-database-url
   mysql-connect
   "mysql://user:pass@localhost/dbname"
   '((#:database . "dbname")
     (#:password . "pass")
     (#:server . "localhost")
     (#:user . "user")))
  (check-database-url
   mysql-connect
   "mysql:/var/run/mysqld/mysqld.sock"
   '((#:socket . "/var/run/mysqld/mysqld.sock"))))

(test-case "postgresql"
  (check-database-url
   postgresql-connect
   "pg://user:pass@localhost/dbname?sslmode=disable"
   '((#:database . "dbname")
     (#:password . "pass")
     (#:server . "localhost")
     (#:ssl . no)
     (#:user . "user")))
  (check-database-url
   postgresql-connect
   "postgres://user:pass@localhost/dbname"
   '((#:database . "dbname")
     (#:password . "pass")
     (#:server . "localhost")
     (#:user . "user")))
  (check-database-url
   postgresql-connect
   "postgresql://user:pass@localhost/mydatabase/?sslmode=disable"
   '((#:database . "mydatabase")
     (#:password . "pass")
     (#:server . "localhost")
     (#:ssl . no)
     (#:user . "user"))))

(test-case "sqlite"
  (check-database-url
   sqlite3-connect
   "sqlite:/path/to/file.db"
   '((#:database . "/path/to/file.db")))
  (check-database-url
   sqlite3-connect
   "sqlite:mydatabase.sqlite3"
   '((#:database . "mydatabase.sqlite3"))))
