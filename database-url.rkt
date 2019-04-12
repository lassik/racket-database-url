#lang racket/base

;; Copyright 2019 Lassi Kortela
;; SPDX-License-Identifier: ISC

(require
 db
 net/url
 racket/match
 racket/string)

(define (apply-kw-hash proc kw-hash)
  (let* ((keys (sort (hash-keys kw-hash) keyword<?))
         (vals (map (lambda (key) (hash-ref kw-hash key))
                    keys)))
    (keyword-apply proc keys vals '())))

(define (url-path* u)
  (and (url-path u)
       (filter non-empty-string? (map path/param-path (url-path u)))))

(define (url-path-as-file-path u)
  (let ((p (url-path* u)))
    (string-join (if (url-path-absolute? u) (cons "" p) p)
                 "/")))

(define (url-path-as-database-name u)
  (match (url-path* u)
    ((list database-name) database-name)
    (else (error "Database URL with server must have one path component"))))

(define (coerce-to-url u)
  (cond ((url? u) u)
        ((string? u) (string->url u))
        ((not u) (string->url (or (getenv "DATABASE_URL")
                                  (error "DATABASE_URL not set"))))
        (else (error "Argument is not a string or URL"))))

(define (parse-user-and-password u kw)
  (match (string-split (or (url-user u) "") ":")
    ((list) kw)
    ((list user) (hash-set kw '#:user user))
    ((list user password) (hash-set* kw '#:user user '#:password password))
    (else (error "Too many colons in user:password part of URL"))))

(define (parse-server u kw)
  (if (string? (url-host u))
      (hash-set* kw
                 '#:server (url-host u)
                 '#:port (url-port u)
                 '#:database (url-path-as-database-name u))
      (hash-set kw '#:socket (url-path-as-file-path u))))

(define (parse-sslmode u kw)
  (match (assoc 'sslmode (url-query u))
    (#f kw)
    ((cons sslmode "enable") (hash-set kw '#:ssl 'yes))
    ((cons sslmode "disable") (hash-set kw '#:ssl 'no))
    (else (error "Unknown sslmode argument in database URL"))))

(define (parse-path-only u kw)
  (when (url-host u)
    (error "URL must not have a host"))
  (when (url-port u)
    (error "URL must not have a port"))
  (let ((p (url-path-as-file-path u)))
    (unless p (error "URL must have a path"))
    (hash-set kw '#:database p)))

(define (parser connect . steps)
  (lambda (u)
    (values (foldl (lambda (step kw-hash) (step u kw-hash))
                   (hash) steps)
            connect)))

(define mysql-parser
  (parser mysql-connect
          parse-user-and-password
          parse-server))

(define postgresql-parser
  (parser postgresql-connect
          parse-user-and-password
          parse-server
          parse-sslmode))

(define sqlite-parser
  (parser sqlite3-connect
          parse-path-only))

(define schemes
  (hash
   "mysql"       mysql-parser
   "pg"          postgresql-parser
   "postgres"    postgresql-parser
   "postgresql"  postgresql-parser
   "sqlite"      sqlite-parser))

(define (database-url-parse u)
  (let* ((u (coerce-to-url u))
         (f (or (hash-ref schemes (url-scheme u) #f)
                (error "Unknown database URL scheme"))))
    (apply f (list u))))

(define (database-url-connector u)
  (let-values (((kw-hash connect) (database-url-parse u)))
    (lambda () (apply-kw-hash connect kw-hash))))

(provide
 database-url-parse
 database-url-connector)
