#lang scribble/manual
@(require (for-label racket))

@title{Database URL Parser}

The @hyperlink["https://12factor.net/"]{Twelve-Factor App} conventions
now followed by many web developers recommend that web applications
gets their configuration from environment variables. Database
connection parameters are usually given all in one environment
variable in the form of a URL. This variable is normally called
DATABASE_URL. This procedure provides procedures to translate database
URLs into a form that Racket's @racketmodname[db] module can use.

MySQL, PostgreSQL and SQLite URLs are currently supported.

@defproc[(database-url-parse [u string])
         (Values hash procedure)]{

Parse @racket[u] as a database URL. @racket[u] can be a @racket[url]
object, a string, or @code["#f"]. In case of @code["#f"] the URL is
read from the DATABASE_URL environment variable.

The procedure returns two values: a hash table of keyword arguments
suitable for a database connect procedure from the @racketmodname[db]
libray; and the correct procedure.

For example:

@racketblock[
> (database-url-parse "mysql://user:pass@localhost/dbname")
'#hash((#:database . "dbname")
       (#:password . "pass")
       (#:port . #f)
       (#:server . "localhost")
       (#:user . "user"))
\#<procedure:mysql-connect>
]}

@defproc[(database-url-connector [u (one-of/c url string #f)])
         (Values (-> any))]{

Like @racket[database-url-parse] but instead of returning a connect
procedure and its keyword arguments seprately, returns a closure of no
arguments that will call the right connector with the right arguments
to connect to the database.

Most people will probably want to use skip database-url-parse and
instead use this procedure directly.}
