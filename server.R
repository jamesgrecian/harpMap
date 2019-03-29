
# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

server <- function(input, output, session) {
  
  data <- reactive({
    x <- harps
  })
  
  ice_data <- reactive({
    y <- ice
  })
  
  output$mymap <- renderLeaflet({
    harps <- data()
    ice <- ice_data()
    
    m <- leaflet() %>%
      addProviderTiles(providers$Esri.WorldImagery) %>%
      addRasterImage(x = ice,
                     colors = ice_pal,
                     opacity = 0.5) %>%
      addLegend(position = 'bottomleft',
                pal = ice_pal,
                values = values(ice),
                title = "Sea Ice Concentration (%)") %>%
      addPolylines(lng = ~grouped_coords(Longitude, id, id),
                   lat = ~grouped_coords(Latitude, id, id),
                   color = ~pal(unique(id)),
                   data = harps) %>%
      addMarkers(lng = ~Longitude,
                 lat = ~Latitude,
                 popup = ~ as.character(id),
                 label = ~as.character(id),
                 data = harps %>%
                   group_by(id) %>%
                   arrange(desc(datetime_utc))
                 %>% slice(1)) %>%
      addLegend(position = 'bottomright',
                colors = viridis_pal(option = "D")(length(unique(harps$id))),
                labels = unique(harps$id)) %>%
      setView(lng = -60 , lat = 45, zoom = 6)
    
    m
    
    })
}


  
  