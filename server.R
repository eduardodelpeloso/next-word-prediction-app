options(shiny.maxRequestSize=100*1024^2, shiny.trace = FALSE)

library(shiny)
library(quanteda)
library(stringr)

bigrams_cut <- readRDS("data/bigrams_cut_2_char.Rds")
trigrams_cut <- readRDS("data/trigrams_cut_2_char.Rds")
tetragrams_cut <- readRDS("data/tetragrams_cut_2_char.Rds")

source('predict_word.R', local = TRUE)

shinyServer(function(input, output) {
    output$table <- renderTable({ predict_next(input$sentence) })
})
      
