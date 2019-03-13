# This is the user-interface definition of a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

ui <- fluidPage(
  titlePanel("harpMap"),
    p("In March 2019 researchers from the University of St Andrews and Canadian Department for Fisheries and Oceans deployed 10 satellite transmitters on harp seals."),
    p("These tags allow us to track the seals as they migrate north to follow the seasonal sea ice retreat."),
  leafletOutput("mymap", height = 800),
  p("This work was made possible by a UK-Canada Arctic Partnership Bursary from the NERC Arctic Office and funding from DFO.")
)
