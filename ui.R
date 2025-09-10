library(shiny)
library(bslib)
library(DT)

ui <- page_sidebar(
  title = "Liste d'especes de la base de données PSE (Oracle) ",
  sidebar = sidebar("Recherche",
    card(
      textInput("APHIA_ID", "AphiaID", value = ""),
      textInput("STRAP_CODE", "Code STRAP", value = ""),
      textInput("COMMUN_NAME_FR", "Nom commun (fr)", value = ""),
      textInput("COMMUN_NAME_EN", "Nom commun (an)", value = ""),
      textInput("SCIENTIF_NAME", "Nom scientifique", value = ""),
      submitButton("Filtrer")
    ),
),
  card(
    renderText("search_query"),
    DT::DTOutput("db_table_results")
  )
)
