library(shiny)
library(bslib)
library(odbc)
library(DBI)
library(DT)


make_db_connection <- function() {
  ORACLE_HOST <- "NATP71.NAT.DFO-MPO.CA"
  ORACLE_PORT <- 1523
  ORACLE_SID <- "OKENP27"
  ORACLE_USER <- Sys.getenv("ORACLE_USER")
  ORACLE_PASSWORD <-  Sys.getenv("ORACLE_PASSWORD")
  ORACLE_DRIVER <- Sys.getenv("ORACLE_DRIVER")

  connection_string <- paste(
    "Driver=", ORACLE_DRIVER, ";",
    "DBQ=", ORACLE_HOST, ":", ORACLE_PORT, "/", ORACLE_SID, ";",
    "UID=", ORACLE_USER, ";",
    "PWD=", ORACLE_PASSWORD,
    sep = "")
  con <- DBI::dbConnect(odbc::odbc(),
            .connection_string = connection_string,
            timeout = 10)
  return(con)
}


query_database <- function(con, input_text_fields = NULL){

  query <- "SELECT * FROM ESPECE_GENERAL_NORME"
  query <- paste(query, "WHERE 1=1")

  if (nzchar(input_text_fields$APHIA_ID)) {
    query <- paste(query, "AND APHIA_ID LIKE '%", input_text_fields$APHIA_ID, "%'", sep="")
  }
  if (nzchar(input_text_fields$STRAP_CODE)) {
    query <- paste(query, "AND STRAP_CODE LIKE '%", input_text_fields$STRAP_CODE, "%'", sep="")
  }
  if (nzchar(input_text_fields$COMMUN_NAME_EN)) {
    query <- paste(query, "AND COMMUN_NAME_EN LIKE '%", input_text_fields$COMMUN_NAME_EN, "%'", sep="")
  }
  if (nzchar(input_text_fields$COMMUN_NAME_FR)) {
    query <- paste(query, "AND COMMUN_NAME_FR LIKE '%", input_text_fields$COMMUN_NAME_FR, "%'", sep="")
  }

  data <- DBI::dbGetQuery(con, query)
return(data)
}


server <- function(input, output) {
  db_connection <- make_db_connection()
  #construct a lst of legal user inputs
  # output$search_query <- renderText({paste("Vous avez entré l'Aphia ID: ", input$user_aphia_id)})

  output$db_table_results <- DT::renderDT({query_database(
    db_connection,
    list(
      APHIA_ID = input$APHIA_ID,
      COMMUN_NAME_EN = input$COMMUN_NAME_EN,
      COMMUN_NAME_FR = input$COMMUN_NAME_FR,
      STRAP_CODE = input$STRAP_CODE
    )
    )})
}
