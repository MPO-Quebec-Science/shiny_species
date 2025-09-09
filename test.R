#Sys.setenv(ODBCSYSINI = "/etc/odbc")
#install.packages("odbc")
library(odbc)
library(DBI)


make_db_connection <- function() {
  ORACLE_HOST <- "NATP71.NAT.DFO-MPO.CA"
  ORACLE_PORT <- 1523
  ORACLE_SID <- "OKENP27"
  ORACLE_USER <- Sys.getenv("ORACLE_USER")
  ORACLE_PASSWORD <-  Sys.getenv("ORACLE_PASSWORD")
  connection_string <- paste(
    "Driver={Oracle 19 ODBC driver};",
    "DBQ=", ORACLE_HOST, ":", ORACLE_PORT, "/", ORACLE_SID, ";",
    "UID=", ORACLE_USER, ";",
    "PWD=", ORACLE_PASSWORD,
    sep = "")
  con <- DBI::dbConnect(odbc::odbc(),
            .connection_string = connection_string,
            timeout = 10)
  return(con)
}


query_database <- function(con, aphia_id = NULL){
  query <- "SELECT * FROM ESPECE_GENERAL_NORME"
  # TODO tag on other query conditions based on user input
  query <- paste(query, " WHERE APHIA_ID LIKE ", aphia_id)
  data <- DBI::dbGetQuery(con, query)
return(data)
}


print(odbcListDrivers())
con = make_db_connection()

print(con)
