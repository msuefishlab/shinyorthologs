library(RPostgreSQL)

use_name = exists('db_name')
use_port = exists('db_port')
use_user = exists('db_user')
use_pass = exists('db_pass')
use_host = exists('db_host')
if (!exists('db_port')) db_port = NULL
if (!exists('db_host')) db_host = NULL
if (!exists('db_name')) db_name = NULL
if (!exists('db_pass')) db_pass = NULL
if (!exists('db_user')) db_user = NULL
args = c(
    PostgreSQL(),
    list(dbname = db_name)[use_name],
    list(host = db_host)[use_host],
    list(user = db_user)[use_user],
    list(password = db_pass)[use_pass],
    list(port = db_port)[use_port]
)


trim.leading = function (x)  sub("^\\s+", "", x)
trim.trailing = function (x) sub("\\s+$", "", x)
trim = function (x) gsub("^\\s+|\\s+$", "", x)
