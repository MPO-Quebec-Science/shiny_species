print("starting dev server")

source("ui.R")
source("server.R")

shinyApp(ui = ui, server = server)
