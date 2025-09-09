library(shiny)
library(bslib)
library(DT)

ui <- page_sidebar(
  title = "Liste d'especes de la base de données PSE (Oracle) ",
  sidebar = sidebar("Aphia ID"),
  card(
    card_header("Recherche par AphiaID"),
      "Recherche par AphiaID",
      textInput("user_aphia_id", "AphiaID", value = ""),
      submitButton("Rechercher")
    ),
  card(
    renderText("search_query"),
    DT::DTOutput("db_table_results")
  )
)
