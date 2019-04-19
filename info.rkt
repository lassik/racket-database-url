#lang info

(define collection "database-url")

(define deps
  '("db-lib"
    "rackunit-lib"
    "base"))

(define build-deps
  '("db-doc"
    "racket-doc"
    "scribble-lib"))

(define scribblings '(("database-url.scrbl")))
