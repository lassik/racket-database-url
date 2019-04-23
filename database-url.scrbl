#lang scribble/manual
@(require (for-label racket))

@title{Database URL Parser}

The @hyperlink["https://12factor.net/"]{Twelve-Factor App} conventions
now followed by many web developers recommend that web applications
gets their configuration from environment variables. Database
connection parameters are usually given all in one environment
variable in the form of a URL. This variable is normally called
DATABASE_URL. This module provides procedures to translate database
URLs into a form that Racket's @racketmodname[db] module can use.

MySQL, PostgreSQL and SQLite URLs are currently supported.

@defproc[(database-url-parse [u (one-of/c url string #f)])
         (Values hash procedure)]{

Parse @racket[u] as a database URL. @racket[u] can be a @racket[url]
object, a string, or @code["#f"]. In case of @code["#f"] the URL is
read from the DATABASE_URL environment variable.

The procedure returns two values: a hash table of keyword arguments
suitable for a database connect procedure from the @racketmodname[db]
libray; and the right connect procedure to use.

For example:

@racketblock[
> (database-url-parse "mysql://user:pass@localhost/dbname")
'#hash((#:database . "dbname")
       (#:password . "pass")
       (#:server . "localhost")
       (#:user . "user"))
\#<procedure:mysql-connect>
]}

@defproc[(database-url-connector [u (one-of/c url string #f)])
         (-> any)]{

Like @racket[database-url-parse] but instead of returning a connect
procedure and its keyword arguments separately, returns a closure of
no arguments that will call the right connector with the right
arguments to connect to the database.

Most people will probably want to skip database-url-parse and use this
procedure directly.}
