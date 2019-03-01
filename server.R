
# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

server <- function(input, output, session) {
  
  data <- reactive({
    x <- harps
  })
  
  output$mymap <- renderLeaflet({
    harps <- data()
    
    m <- leaflet() %>%
      addProviderTiles(providers$Esri.WorldImagery) %>%
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
                colors = viridis_pal(option = "D")(10),
                labels = unique(harps$id))
    
    m
    })
}
