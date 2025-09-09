# shiny_species
Shiny app to interact with the species list on the PSE database  (Oracle)

# quickstart
Create a `.Renviron` file using the example as a template `example.Renviron`, and fill with the database credentials.

# requirements

## system requirements (shiny server)
- r-base 4.5.1-1.2204.0 
- nginx 1.18.0
- shiny-server 1.5.23.1030
- Oracle ODBC driver

## Oracle client
You need to install the Oracle client, as a separate download on the Oracle web site https://www.oracle.com/database/technologies/instant-client/linux-x86-64-downloads.html

You can avoid the signon by using `wget` with the file target.

``` bash
wget --no-check-certificate -c --header "Cookie: oraclelicense=accept-securebackup-cookie" https://download.oracle.com/otn/linux/instantclient/122010/instantclient-basic-linux.x64-12.2.0.1.0.zip
```
## dynamic linking libraries
To create an entry for Oracle, create `/etc/ld.so.conf.d/oracle-instantclient.conf` that contains the path of the libaries: 
contentes of /etc/ld.so.conf.d/oracle-instantclient.conf:
```
/opt/oracle/instantclient_19_28
```
obviously change to whatever the location of the libraries.

## Oracle ODBC driver
One way to check if the isntallation works is ro run the following:
``` R
library(odbc)
odbcListDrivers()
```
If the list is empty, you have a problem.

on ubuntu there are conflictin odbc packages, `unixodbc` and `iodbc`.
Install `unixodbc` and purge anything related to `iodbc` to prenvent confusion:
``` bash
apt remove iodbc libiodbc2 libiodbc2-dev --purge
apt install unixodbc unixodbc-dev unixodbc-common 
```
Now, the `unixodbc` package creates `/etc/odbcinst.ini`, you need to fill out the Oracle driver manually.
Did you install the Oracle driver?
``` conf
[OracleODBC]
Description=Oracle ODBC driver for Oracle
Driver=/opt/oracle/instantclient_19_28/libsqora.so.19.1
FileUsage=1
```

## R packages
- shiny_1.11.1
- bslib_0.9.0
- DBI_1.2.3
- odbc_1.6.2

When you intall the R odbc package, make sure you let it know where to find the `odbcinst.ini` file
``` R
Sys.setenv(ODBCSYSINI = "/etc/")
install.packages("odbc")
```

### configuration
ths shiny-server configuration is stored in `/etc/shiny-server/shiny-server.conf`

``` conf
# Instruct Shiny Server to run applications as the user "shiny"
run_as shiny;

# Define a server that listens on port 3838
server {
  listen 3838;

  # add a user-app
  location /espece {
    app_dir /home/seanfortind/shiny_species;
    log_dir /var/log/shiny-server;
    directory_index off;
    run_as seanfortind;
  }

  # Define a location at the base URL
  location / {
    # Host the directory of Shiny Apps stored in this directory
    site_dir /srv/shiny-server;
    # Log all Shiny output to files in this directory
    log_dir /var/log/shiny-server;

    # When a user visits the base URL rather than a particular application,
    # an index of the applications available in this directory will be shown.
    #directory_index on;
  }
}
```

If you want, you can create a proxy to this port using nginx. Make sure the `proxy_pass` directive uses the port specified in the `shiny-server.conf` (i.e., `proxy_pass http://localhost:3838;`). The full configuration (`/etc/nginx/sites-available/default`) can look like this:
``` conf
server {
        listen 80 default_server;
        listen [::]:80 default_server;

        root /var/www/html;
        index index.html index.htm index.nginx-debian.html;
        server_name _;

        location / {
                proxy_pass http://localhost:3838;
                proxy_set_header Host $host;
                proxy_set_header X-Real-IP $remote_addr;
                proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                proxy_set_header X-Forwarded-Proto $scheme;
        }
```

# notes
Container currently running on host `iml-science-1`

To test, source both `ui.R` and `server.R` and run `shinyApp(ui = ui, server = server)`
``` R
source("ui.R")
source("server.R")
shinyApp(ui = ui, server = server)
```

