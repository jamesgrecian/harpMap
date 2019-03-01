# Deploy on shinyapps.io
install.packages('rsconnect')

# Authorise account
rsconnect::setAccountInfo(name='jamesgrecian',
                          token='C005CA12F32158FD157A8D417B1BA214',
                          secret='<SECRET>')

# Deploy
library(rsconnect)
rsconnect::deployApp()
