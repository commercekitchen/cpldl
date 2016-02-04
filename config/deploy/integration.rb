## INTEGRATION
## ==========

set :bundle_without, %w{production staging test}.join(" ")

set :branch, "master"

server "dl-integapp-01.do.lark-it.com",
  user: fetch(:application),
  port: 1022,
  roles: %w{web app db},
  primary: true
