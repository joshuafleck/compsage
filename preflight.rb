File.open("config/database.yml", "w") do |f|
  f.syswrite(<<-EOF
development:
  adapter: mysql
  database: compsage_development
  username: root
  password:
  host: localhost
test:
  adapter: mysql
  database: compsage_test
  username: root
  password:
  host: localhost
EOF
  )
end
