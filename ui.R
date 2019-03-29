# This is the user-interface definition of a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

ui <- fluidPage(
  titlePanel("Harp seals as indicators of Arctic climate change"),
  br(),
  p("In March 2019 scientists from the ",
    a("Sea Mammal Research Unit",
      href = "http://www.smru.st-andrews.ac.uk"),
    "at the University of St Andrews and the ",
    a("Marine Mammal Section",
      href = "http://www.dfo-mpo.gc.ca/science/coe-cde/cemam/index-eng.html"),
    "of the Canadian Department for Fisheries and Oceans deployed 10 satellite transmitters on harp seals in the Gulf of St Lawrence."),
  p("These tags allow the scientists to track the seals as they migrate north to follow the seasonal sea ice retreat."),
  br(),
  leafletOutput("mymap", height = 600) %>% withSpinner(type = 7),
  br(),
  p("This work was made possible by a UK-Canada Arctic Partnership Bursary from the ",
    a("NERC Arctic Office",
      href = "https://www.arctic.ac.uk"),
    "and funding from the ",
    a("DFO",
      href = "http://www.dfo-mpo.gc.ca/index-eng.htm")),
  br(),
  fluidRow(
    img(src='Arctic-Office-Logo.png', align = "centre", height = 60),
    img(src='DFO.png', align = "centre", height = 80),
    img(src='SMRU.jpg', align = "centre", height = 60),
    img(src='University-St-Andrews.png', align = "centre", height = 80)
  )
)

