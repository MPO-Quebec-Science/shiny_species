[![Deploy](https://github.com/MPO-Quebec-Science/shiny_species/actions/workflows/deploy.yaml/badge.svg?branch=prod)](https://github.com/MPO-Quebec-Science/shiny_species/actions/workflows/deploy.yaml)
# shiny_species
Shiny app to interact with the species list on the PSE database  (Oracle)

# quickstart
Create a `.Renviron` file using the example as a template `example.Renviron`, and fill with the database credentials.

# requirements

## system requirements (shiny server)
- r-base 4.5.1-1.2204.0 
- nginx 1.18.0
- shiny-server 1.5.23.1030
- Oracle client and ODBC driver

## Oracle client
You need to install the Oracle client, as a separate download on the Oracle web site https://www.oracle.com/database/technologies/instant-client/linux-x86-64-downloads.html

You can avoid the signon by using `wget` with the file target.

``` bash
wget https://download.oracle.com/otn_software/linux/instantclient/1928000/instantclient-basic-linux.x64-19.28.0.0.0dbru.zip
wget https://download.oracle.com/otn_software/linux/instantclient/1928000/instantclient-odbc-linux.x64-19.28.0.0.0dbru.zip
```
Unzip and install uzing the instructions. In my case, all libraries were place under `/opt/oracle/instantclient_19_28`.

## dynamic linking libraries
To create an entry for Oracle, create `/etc/ld.so.conf.d/oracle-instantclient.conf` that contains the path of the libaries: 
contentes of /etc/ld.so.conf.d/oracle-instantclient.conf:
```
/opt/oracle/instantclient_19_28
```
obviously change to whatever the location of the libraries and run `ldconfig`.

In my case, I also copied the odbc libary `libsqora.so.19.1` under  `/opt/oracle/instantclient_19_28` and tested if the links are ok with by running `ldd libsqora.so.19.1`
The reponse was that all linked libraries were found.
``` bash
        linux-vdso.so.1 (0x00007ffd6bd18000)
        libdl.so.2 => /lib/x86_64-linux-gnu/libdl.so.2 (0x00007fea194cb000)
        libm.so.6 => /lib/x86_64-linux-gnu/libm.so.6 (0x00007fea19119000)
        libpthread.so.0 => /lib/x86_64-linux-gnu/libpthread.so.0 (0x00007fea194c6000)
        libnsl.so.1 => /lib/x86_64-linux-gnu/libnsl.so.1 (0x00007fea190fd000)
        librt.so.1 => /lib/x86_64-linux-gnu/librt.so.1 (0x00007fea194c1000)
        libaio.so.1 => /lib/x86_64-linux-gnu/libaio.so.1 (0x00007fea194ba000)
        libresolv.so.2 => /lib/x86_64-linux-gnu/libresolv.so.2 (0x00007fea190e9000)
        libclntsh.so.19.1 => /opt/oracle/instantclient_19_28/libclntsh.so.19.1 (0x00007fea14e00000)
        libclntshcore.so.19.1 => /opt/oracle/instantclient_19_28/libclntshcore.so.19.1 (0x00007fea14800000)
        libodbcinst.so.2 => /lib/x86_64-linux-gnu/libodbcinst.so.2 (0x00007fea190d4000)
        libc.so.6 => /lib/x86_64-linux-gnu/libc.so.6 (0x00007fea145d7000)
        /lib64/ld-linux-x86-64.so.2 (0x00007fea194d9000)
        libnnz19.so => /opt/oracle/instantclient_19_28/libnnz19.so (0x00007fea13e00000)
        libltdl.so.7 => /lib/x86_64-linux-gnu/libltdl.so.7 (0x00007fea190c7000)
```

## Oracle ODBC driver
One way to check if the installation works is to run the following:
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

# dev
To develop, you need to create the same environment that is running on the shiny-server.


Install `renv` to reproduce the server environment.
Init the renv from renv.lock, or manually create it by installing:


``` R
# either load the lockfile
renv::restore()

# or install what you need
renv::install("shiny@1.11.1") 
renv::install("bslib@0.9.0") 
renv::install("DBI@1.2.3") 
renv::install("odbc@1.6.2")
renv::install("DT@0.34.0")
```

You may have to tweak the odbc driver string to work with your local setup. You will need to modify `ORACLE_DRIVER` in `.Renviron`.
For example, when installing from the software center 
`ORACLE_DRIVER="{Oracle in 12.2.0_Instant_x64}"`

