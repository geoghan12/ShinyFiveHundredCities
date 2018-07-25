# UI for 500 Hundred Cities App
# Sophie Geoghan
# July 17,2018
library(shiny)

shinyUI(
  navbarPage(title='Sophie Geoghan',#
             navbarMenu("About Project",
                        tabPanel(title='Intro',
                                 fluidPage(
                                   fluidRow(
                                     img(src="./header.png", style="width:100%; border:0px;")
                                   ),
                                   fluidRow(
                                     column(12, includeMarkdown("about.md"))
                                   ),
                                   fluidRow(img(src="./sponsors.png",style="width:100%; border:0px;"))
                                 )),
                        tabPanel(title='Appendix',
                                 fluidPage(fluidRow(
                                   img(src="./header.png", style="width:100%; border:0px;")
                                 ),
                                 fluidRow(
                                   column(12, includeMarkdown("measures.md"))
                                 ),
                                 fluidRow(img(src="./sponsors.png",style="width:100%; border:0px;"))
                                 ))),
             tabPanel(title='State Comparison',
                      fluidPage(
                        sidebarLayout(
                          sidebarPanel(
                            fluidRow(img(src="./16_270692_C_Thomas_500cities_webutton_FINAL_180x150.png", style="width:180px; height:150px; border:0px;")),
                            fluidRow(radioButtons(inputId="data_type", 
                                                  label="Age adjusted prevalence corrects the estimates by comparing to 'standard' population, in case of 
                                                  counties with large number of elderly, for example. \n Choose if you want to see the Crude Prevalence", 
                                                  selected = 'AgeAdjPrv',
                                                  inline = TRUE, width = NULL, choiceNames = unique(five_hundie$Data_Value_Type), 
                                                  choiceValues = unique(five_hundie$DataValueTypeID))),
                            fluidRow(
                              column(6, selectizeInput(inputId = "measure1",
                                                       label = "Choose a measure",
                                                       choices = choices_measures,
                                                       selected = choices_measures[1])),
                              column(6, selectizeInput(inputId = "measure2",
                                                       label="Choose a second measure",
                                                       choices = choices_measures,
                                                       selected = choices_measures[1]))
                            )
                          ),
                          mainPanel(
                            
                            fluidRow(
                              column(6, htmlOutput("map1")),
                              column(6, htmlOutput("map2"))
                            ),
                            fluidRow(h6("The correlation between measures is :"),
                                     textOutput("corr_statement") ),
                            fluidRow(
                              htmlOutput("corr_1")
                            )
                          ))) ),
             tabPanel(title='City Comparison',
                      fluidPage(
                        sidebarLayout(
                          sidebarPanel(fluidRow(img(src="./16_270692_C_Thomas_500cities_webutton_FINAL_180x150.png", style="width:180px; height:150px; border:0px;")),
                                       fluidRow(radioButtons(inputId="data_type2", 
                                                             label="Age adjusted prevalence corrects the estimates by comparing to 'standard' population, in case of 
                                                             counties with large number of elderly, for example. \n Choose if you want to see the Crude Prevalence", 
                                                             selected = 'AgeAdjPrv',
                                                             inline = TRUE, width = NULL, choiceNames = unique(five_hundie$Data_Value_Type), 
                                                             choiceValues = unique(five_hundie$DataValueTypeID))),
                                       fluidRow(
                                         column(6, selectizeInput(inputId = "measure_us",
                                                                  label = "Choose a measure",
                                                                  choices= choices_measures,
                                                                  selected = choices_measures[1]))
                                         
                                       )
                          ),
                          mainPanel(
                            fluidRow(
                              column(12, checkboxGroupInput(inputId = "state",
                                                            label = "Choose a state",
                                                            choices = state_choices,
                                                            selected = "NY",
                                                            inline=TRUE))
                            ),
                            fluidRow(
                              column(12,plotOutput("cities_plot"))
                            )
                          )
                        )
                      )
             ),
             tabPanel("Within City Comparison",
                      leafletOutput("map4"),
                      absolutePanel(id = "controls", class = "panel panel-default", fixed = TRUE,
                                    draggable = TRUE, top = 60, left = "auto", right = 20, bottom = "auto",
                                    width = 330, height = "auto",
                                    
                                    h2("Explore within cities"),
                                    p("Here the radius of the markers represents the relative population, and the color represents the relative negativity of the prevalence in that city/region."),
                                    selectizeInput(inputId = "measure4",
                                                   label = "Choose a measure",
                                                   choices = choices_measures,
                                                   selected = choices_measures[1])
                      )
             )
  ) # navbar page
) # shinypage
