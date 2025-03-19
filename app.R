library(shiny)
library(shinyjs)
library(reticulate)

use_python("C:\\Users\\31885\\AppData\\Local\\Programs\\Python\\Python312\\python.exe", required=TRUE)
source_python("mistral_utils.py")

ui <- fluidPage(
  useShinyjs(),  # initialize shinyjs
  titlePanel("Analysis with Mistral"),
  sidebarLayout(
    sidebarPanel(
      fileInput("file", "Upload your document (TXT, CSV, PDF, or image)"),
      textAreaInput("prompt", "Enter your prompt", placeholder = "What would you like to know about this file?", rows = 3),
      actionButton("analyze", "Analyze"),
      actionButton("reset", "Reset", class = "btn-secondary")
    ),
    mainPanel(
      verbatimTextOutput("result")
    )
  )
)

server <- function(input, output, session) {
  observeEvent(input$analyze, {
    req(input$file, input$prompt)
    output$result <- renderText({
      analyze_file(input$file$datapath, input$prompt)
    })
  })
  
  observeEvent(input$reset, {
    reset("file")                         # clear fileInput
    updateTextAreaInput(session, "prompt", value = "")  # clear prompt
    output$result <- renderText({ "" })   # clear result text
  })
}

shinyApp(ui, server)
