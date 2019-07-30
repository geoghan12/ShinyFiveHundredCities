# Server for 500 Hundred Cities App
# Sophie Geoghan
# July 17,2018

#### Adding one line here to test kraken

# Define server logic required to draw a histogram
shinyServer(function(input, output,session) {

  # Tab 1 Correlation between two measures ####
  output$map1 <- renderGvis({
    gvisGeoChart(filter(state_wide_1,DataValueTypeID==input$data_type), locationvar="StateAbbr",
                 colorvar=input$measure1,
                 options=list(title="Measure 1",
                              region="US",
                              displayMode="regions",
                              resolution="provinces",
                              width=300, height=200))
  })
  output$map2 <- renderGvis({
    gvisGeoChart(filter(state_wide_1,DataValueTypeID==input$data_type), locationvar="StateAbbr",
                 colorvar=input$measure2,
                 options=list(title="Measure 2",
                              region="US",
                              displayMode="regions",
                              resolution="provinces",
                              width=300, height=200))
  })

  corr_data <- reactive({
    m1<-meas_filter(state_wide_1,input$data_type,input$measure1)
    m2<-meas_filter(state_wide_1,input$data_type,input$measure2)
    corr_data <- cbind(m1,m2)

  })
  corr_bw_measures<-reactive({
    corr_bw_measures <- cor(meas_filter(state_wide_1,input$data_type,input$measure1),
                            meas_filter(state_wide_1,input$data_type,input$measure2))
  })

  output$corr_statement <- renderText({corr_bw_measures()})

  output$corr_1 <- renderGvis({
    gvisScatterChart(corr_data(),
                     options=list(width= 800,height= 500,
                                  title="Correlation between the two measures",
                                  legend="{position:'none'}",
                                  hAxis="{title:'Measure 1'}",
                                  vAxis="{title:'Measure 2'}"
                     ))
  })

  ##### Tab Two: Compare cities to US overall #####

  tab2_plot <- reactive({
    us_to_plot <- us_only %>%
      filter(.,DataValueTypeID==input$data_type2 &
               SQT==input$measure_us) %>%
      mutate(.,CityName='US',StateAbbr="US") %>%
      select(.,StateAbbr,CityName,Data_Value,Low_Confidence_Limit,High_Confidence_Limit)

    state_cities_to_plot <- five_hundie_only_cities %>%
      filter(.,DataValueTypeID==input$data_type2 &
               StateAbbr %in% input$state &
               SQT==input$measure_us) %>%
      select(.,StateAbbr,CityName,Data_Value,Low_Confidence_Limit,High_Confidence_Limit)

    state_wide_to_plot <- state_wide_2 %>%
      filter(.,DataValueTypeID==input$data_type2 &
               StateAbbr %in% input$state &
               SQT==input$measure_us) %>%
      ungroup(.)%>%
      rename(.,CityName=StateAbbr,Data_Value=my_mean,
             Low_Confidence_Limit=LCI,High_Confidence_Limit=HCI) %>%
      mutate(.,StateAbbr=CityName) %>%
      select(.,-SQT,-DataValueTypeID)
    tab2_plot <- rbind(state_wide_to_plot,state_cities_to_plot) #us_to_plot,
  })


  output$cities_plot <- renderPlot({
    ggplot(data=tab2_plot(),aes(x=CityName,y=Data_Value)) +
      # add horizontal line for whole US - aes(ylab("Prevalence"))
      geom_point() + geom_hline(yintercept=as.numeric(select(filter(us_only,SQT==input$measure_us&DataValueTypeID==input$data_type2),Data_Value))) +
      geom_pointrange(aes(colour=factor(StateAbbr),
                          ymin=Low_Confidence_Limit,
                          ymax=High_Confidence_Limit)) +
      geom_text(aes(label=CityName),hjust=0, vjust=0)
  })

  #### Tab 3 Interactive Map ####

  # filter by User input measure
  cities_for_leaflet <- reactive({
    cities_for_leaflet <- within_cities %>%
      dplyr::filter(.,SQT==input$measure4)

  })

  # Create the map
  output$map4 <- renderLeaflet({
    print('testing')
    pal<-colorQuantile(palette=c("green","yellow","orange","red"),
                       domain=as.data.frame(dplyr::select(cities_for_leaflet(),DV)))
    print("did you get this far?")
    cities_leaflet <- leaflet(data=cities_for_leaflet()) %>%
      addProviderTiles("CartoDB.Positron") %>%
      setView(lng = -93.85, lat = 37.45, zoom = 4) %>%
      addCircleMarkers(data=cities_for_leaflet(),
                     lng= ~Longitude, lat= ~Latitude, radius=~radius,
                     color= ~pal(DV),
                     fillOpacity = 0.5,
                     popup = ~paste('<b> City:</b>',CityName,'<br>',
                                    '<b>Prevalence: </b>', DV, '<br>',
                                    '<b>Population</b>', PopulationCount,'<br>',
                                    '<b>Low CI: </b>', Low_Confidence_Limit,'<br>',
                                    '<b>High CI: </b>', High_Confidence_Limit))
    cities_leaflet
  })


})
