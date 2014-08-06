module.exports =
  client: 'mysql'
  connection:
    host: '127.0.0.1'
    user: process.env.YR_MYSQL_USER
    password: process.env.YR_MYSQL_PASSWORD
    database: 'yukkuri'
    charset: 'utf8'
