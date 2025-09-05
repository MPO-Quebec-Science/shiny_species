library(shiny)
library(bslib)
library(odbc)
library(DBI)

make_db_connection <- function() {
  ORACLE_HOST <- "NATP71.NAT.DFO-MPO.CA"
  ORACLE_PORT <- 1523
  ORACLE_SID <- "OKENP27"
  ORACLE_USER <- Sys.getenv("ORACLE_USER")
  ORACLE_PASSWORD <-  Sys.getenv("ORACLE_PASSWORD")
  connection_string <- paste(
    "Driver={Oracle in 12.2.0_Instant_x64};",
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


server <- function(input, output) {
  db_connection <- make_db_connection()
  output$search_query <- renderText({paste("Vous avez entré l'Aphia ID: ", input$user_aphia_id)})
  output$db_table_results <- renderDataTable({query_database(db_connection, input$user_aphia_id)})
}
