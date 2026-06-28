# Load packages
library(tidyverse)
library(shiny)
library(bslib)
library(tools)
library(DT)


# UI
ui <- page_sidebar(
  title = "Grade Explorer",
  
  # Sidebar content
  sidebar = sidebar(
    
    # Excel file upload
    fileInput(
      inputId = "file_upload",
      label   = "Upload canvas grade export",
      accept  = c(".csv", ".xls", "xlsx")
    ),
    
    # Card with weights
    card(
      card_header("Assign Weights"),
      card_body(
        
        # Weights: Homework, Quizzes, Exams
        numericInput("w_home", "Homework", 
                     value = 0.2, min = 0, max = 1, step = 0.1),
        numericInput("w_quiz", "Quizzes", 
                     value = 0.2, min = 0, max = 1, step = 0.1),
        numericInput("w_exam", "Exams", 
                     value = 0.6, min = 0, max = 1, step = 0.1),
        
        # Calculate!
        actionButton("calc_grades", "Calculate", 
                     class = "btn-primary")
      ),
      style = "background-color:#e6f0ff; border-radius:12px; 
      padding:10px;"
    )
  ),
  
  # Main page content
  navset_card_tab(
    nav_panel("Raw Scores", dataTableOutput("table_view")),
    nav_panel("Weighted Scores", dataTableOutput("final_grades")),
    nav_panel("Bar Chart", div(
      style = "height: 400px; padding-right: 30px;",
      plotOutput("bar_chart")
    )
  ))
)


# Server
server <- function(input, output, session) {
  
  # Import the excel file and tidy
  export <- reactive({
    req(input$file_upload)
    readr::read_csv(input$file_upload$datapath) |> 
      slice(-c(1, n())) |> 
      select(!2:5) |>
      select(!matches("Final|Current")) |> 
      rename_with(~str_remove(., " \\(\\d+\\)$")) |> 
      mutate(across(where(is.numeric), ~ replace_na(.x, 0)))
  })
  
  output$table_view <- renderDataTable({
    export()
  })
  
  # Table of meta data
  meta <- bindEvent(reactive({
    tibble(
      Category = c("Homework", "Quiz", "Exam"),
      Max_points = c(10, 10, 100),
      Weight = c(input$w_home, input$w_quiz, input$w_exam)
    )
  }), input$calc_grades)
  
  #
  weighted_scores <- bindEvent(reactive({
    export() |> 
      pivot_longer(-Student,
                   names_to = "Assignment",
                   values_to = "Score") |> 
      mutate(Category = case_when(
        str_detect(Assignment, "^Ch") ~ "Homework",
        str_starts(Assignment, "Math") ~ "Homework",
        str_detect(Assignment, "^Q") ~ "Quiz",
        str_detect(Assignment, "^E") ~ "Exam"
      ),
      .after = Assignment) |> 
      left_join(meta(), by = "Category") |> 
      summarize(
        .by = c(Student, Category),
        Category_pct = sum(Score) / sum(Max_points),
        Weight = first(Weight)
      ) |> 
      summarize(
        .by = Student,
        Final_score = sum(Category_pct * Weight)
      ) |> 
      mutate(Letter_grade = case_when(
        Final_score > 0.90 ~ "A",
        Final_score >= 0.80 & Final_score < 0.90 ~ "B",
        Final_score >= 0.70 & Final_score < 0.80 ~ "C",
        Final_score >= 0.60 & Final_score < 0.70 ~ "D",
        Final_score < 0.60 ~ "F"
        
      ))
    }), input$calc_grades)
  
  # Final grades
  output$final_grades <- renderDataTable(weighted_scores())
  
  # Grade letter percentages
  grade_summary <- reactive({
    weighted_scores() |> 
      count(Letter_grade)|> 
      mutate(prop = n / sum(n))
  })
  
  # Bar chart
  output$bar_chart <- renderPlot({
    grade_summary() |> 
      ggplot(aes(y = fct_rev(Letter_grade), x = prop, fill = Letter_grade)) +
      geom_text(
        aes(label = scales::percent(prop, accuracy = 0.1)),  # show 1-decimal percent
        hjust = -0.1,                                      # a little to the right of the bar
        color = "black",
        size = 12
      ) +
      geom_col() +
      scale_fill_manual(
        values = c(
          "A" = "#33ccff",  # green
          "B" = "#8BC34A",
          "C" = "#FFC107",
          "D" = "#FF9800",
          "F" = "#F44336"   # red
        )
      ) +
      labs(
        title = "Grade Distribution",
        x = element_blank(),
        y = element_blank(),
      ) +
      theme(
        legend.position = "none",
        plot.title = element_text(size = 24, hjust = 0.5),
        axis.text.x = element_blank(),
        axis.ticks.x = element_blank(),
        axis.ticks.y = element_blank(),
        axis.text.y = element_text(size = 24)
      ) +
      coord_cartesian(clip = "off") +
      coord_cartesian(xlim = c(0, max(grade_summary()$prop) + 0.08))
    
  })
  
}

# Run the app
shinyApp(ui = ui, server = server)
