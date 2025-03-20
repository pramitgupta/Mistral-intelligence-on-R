library(shiny)
library(shinyjs)
library(reticulate)

# Try to locate the specific Python version
py_path <- "C:\\Users\\31885\\AppData\\Local\\Programs\\Python\\Python312\\python.exe"
if (file.exists(py_path)) {
  use_python(py_path, required = TRUE)
  source_python("mistral_utils.py")
} else if (py_available(initialize = TRUE)) {
  # Fallback: use the system default Python
  message("Specified Python version not found. Using system default Python.")
  use_python(Sys.which("python"), required = TRUE)
  source_python("mistral_utils.py")
} else {
  # Define a dummy analyze_file function if no Python is available
  warning("Python is not available on this machine. The app will run in fallback mode.")
  analyze_file <- function(datapath, prompt) {
    "Error: Python is not installed on this machine. Please install Python to use this feature."
  }
}

ui <- fluidPage(
  useShinyjs(),  # Initialize shinyjs
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
    reset("file")  # Clear fileInput
    updateTextAreaInput(session, "prompt", value = "")  # Clear prompt
    output$result <- renderText({ "" })  # Clear result text
  })
}

shinyApp(ui, server)
