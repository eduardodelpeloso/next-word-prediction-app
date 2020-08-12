library(shiny)

shinyUI(fluidPage(
    titlePanel("Next-Word Prediction App"),
    mainPanel(
    h4(paste('Enter a sentence in the field below ',
             'and press "Predict" to get the 5 best',
             'predictions for the next word.')),
    h4(paste('"Grade", in the table that will be presented, ',
             'is always 100.00 for the best option and ',
             'decreases proportionally to the ',
             '"certainty of correctness".')),
    h4(paste('Please be advised that the prediction may, occasionally, ',
             'take several seconds to be displayed (even though most ',
             'of the times it will be nearly instantaneous).'))),
    textInput("sentence", "",
              ""),
    submitButton('Predict'),
    tableOutput("table")
))