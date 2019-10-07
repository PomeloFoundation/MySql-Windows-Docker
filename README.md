# MySql-Windows-Docker

MySQL Windows Container

Credentials:
- Username: `root`
- Password: Value of `MYSQL_ROOT_PASSWORD` environment variable

Example:

```
docker run `
    -d `
    --name "mysql" `
    -e "MYSQL_ROOT_PASSWORD=test" `
    -p "3306:3306" `
    pomelofoundation/mysql-windows:8-ltsc2019
```
