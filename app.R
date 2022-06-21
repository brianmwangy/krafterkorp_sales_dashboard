
###############loading libraries################
library(shiny)
library(shinythemes)
library(shinydashboard)
library(dplyr)
library(ggplot2)
library(plotly)
library(leaflet)
library(RColorBrewer)
library(highcharter)
library(shiny.semantic)
source("global.R")
source("constants.R")

################Overview UI module#########
uioverview<-function(id){
  ns<-NS(id)
  tabPanel("Overview",
           fluidRow(
             column(6,
                    includeMarkdown("about.md")
             ),
             column(6,
                    
                    h3(tags$b("Dashboard Guide")),
                    h4(tags$b("Filters")),
                    h4(tags$p("The shop location and product filters allows the user to customize the data selection based on the store location and 
                              either of the products i.e. bobs, bits or widgets.")),
                    h4(tags$b("Data Table")),
                    h4(tags$p("The data table provides an overview of the raw sales data. 
                              The table interface allows user to sort the data based on either the sales quantity or revenue,
                              filter rows based on store location or product type.")),
                    h4(tags$b("Map")),
                    h4(tags$p("The map is a source of insights on the store location. Users can hover over the circle markers to obtain
                              the store details, change base map to have an overview of the store environment (infrastructure, population).")),
                    h4(tags$b("Charts")),
                    h4(tags$p("The static charts provide insights on the four key business questions for Krafter Korp."))
                    
             )
           )
           
  )
}#end module


#####################visualization UI module##########
visualizationui<-function(id){
  ns<-NS(id)
    tabPanel("Visualization",
             fluidRow(
               column(6,
                      selectizeInput(ns("location"),label = h5(tags$b("Shop Location")),choices =shop_location) 
               ),
               column(6,
                      selectizeInput(ns("product"),label = h5(tags$b("Products")),
                                     choices = product_name )
               )
             ),
             
             ###end fluidRow###
             fluidRow(
                  column(6,
                    h5(tags$b("Sales Data")),
                    dataTableOutput(ns("table")),height=450
                  ),
                  column(6,
                     h5(tags$b("Map")),
                    leafletOutput(ns("map"),height=670)
                    )
             ),
             ###end fluidRow###
             
             
             fluidRow(
               column(6,
                 highchartOutput(ns('top_revenue')),height=450
               ),
               column(6,
                 highchartOutput(ns('store_count')),height=450
               )
             ),
             ###end fluidRow###
             
             fluidRow(
               column(6,
                 highchartOutput(ns('top_sales')),height=450
               ),
               column(6,
                 highchartOutput(ns('best_selling')),height=450
               )
             )
             ###end fluidRow###
             
    )#end visualization module
  
}


##############chart server module###########
visualizationserver<-function(id){
  moduleServer(id,function(input,output,session){
    
    
    #reactive function for shop location
    location<-reactive({
      app_df$maptable_data %>% filter(shop_location==input$location)
    }) %>% bindCache(input$location)
    
    
    #server side selectizeinput
    updateSelectizeInput(session,"location",choices =shop_location)
    
    #reactive function for product
    product_reactive<-reactive({
      location() %>% filter(product==input$product)
    })
    
    #data table rendering
    output$table<-renderDataTable(
      product_reactive(),
      options = list(dom = 'ft', deferRender = TRUE,
                     scrollY = "55vh",scrollX = "55vh", 
                     scroller = TRUE)
    )
    
    #color function for product types
    pal=colorFactor(c("green3","#ffc000","#002060"),domain = app_df$maptable_data$product)
    
    
    #map rendering
    output$map<-renderLeaflet(
      leaflet() %>%
        addTiles(group ="OSM (default)") %>%
        addProviderTiles(providers$Stamen.TonerLite, group = "Toner") %>% 
        addProviderTiles(providers$Esri.WorldStreetMap, group = "WorldStreetMap") %>% 
        addProviderTiles(providers$Esri.WorldImagery, group = "WorldImagery") %>% 
        addProviderTiles(providers$Esri.NatGeoWorldMap, group = "NatGeoWorldMap") %>% 
        addCircleMarkers(
          data = product_reactive(),
          fillOpacity = 1,
          fillColor = ~pal(product),
          radius = 8,
          stroke = FALSE,
          lat = ~lat,
          lng = ~lon,
          label=paste(
            "<strong>Shop location: </strong>",location()$shop_location,"<br>",
            "<strong>Shop name: </strong>",location()$shop_name,"<br>",
            "<strong>Sales quantity: </strong>",location()$sales_qty,"<br>",
            "<strong>Sales revenue: </strong>",location()$sales_revenue,"<br>"
          ) %>% lapply(htmltools::HTML), labelOptions = labelOptions( style = list("font-weight" = "normal", 
                                                                                   padding = "3px 8px"), 
                                                                      textsize = "10px", direction = "auto")
        ) %>%
        addLayersControl(baseGroups = c("OSM (default)", "Toner", "WorldStreetMap", 
                                        "WorldImagery", "NatGeoWorldMap"),
                         position = "topright") %>%
        addLegend(
          pal = pal,
          position = "bottomright",
          values =product_reactive()$product,
          opacity = 1.0,
          title = "Product Type"
        )
    ) #end renderleaflet
    
    #top 5 neighborhood (revenue) rendering
    output$top_revenue <- renderHighchart({
        hchart(app_df$top5_neighborhoods_revenue, "bar",
                 hcaes(x = shop_location, y = neighborhood_revenue),
                 color = "#ffc107") %>%
        hc_exporting(enabled = TRUE) %>%
        hc_title(text="Top 5 neighborhoods by revenue") %>%
        hc_xAxis(title = list(text = "Neighborhood")) %>% 
        hc_yAxis(title = list(text = "Revenue")) %>%
        hc_tooltip(table = TRUE,
                   sort = TRUE,
                   pointFormat = paste0( '<br> <span style="color:{point.color}">\u25CF</span>',
                                         " Revenue: Kes{point.y}"),
                   headerFormat = '<span style="font-size: 13px"> {point.key}</span>'
        ) 
    })
    
    #Areas with highest store concentration rendering
    output$store_count <- renderHighchart({
      hchart(app_df$top_salesstore_count, "bar",
             hcaes(x = shop_location, y = shop_count),
             color = "#ffc107") %>%
        hc_exporting(enabled = TRUE) %>%
        hc_title(text="Parts of Nairobi with the highest concentration of stores") %>%
        hc_xAxis(title = list(text = "Neighborhood")) %>% 
        hc_yAxis(title = list(text = "Store count")) %>%
        hc_tooltip(table = TRUE,
                   sort = TRUE,
                   pointFormat = paste0( '<br> <span style="color:{point.color}">\u25CF</span>',
                                         " Store count: {point.y}"),
                   headerFormat = '<span style="font-size: 13px"> {point.key}</span>'
        ) 
    })
    
    #top 5 stores (sales quantinty) rendering
    output$top_sales <- renderHighchart({
      hchart(app_df$top5_stores_salesqty, "bar",
             hcaes(x = shop_name, y = total_sales),
             color = "#ffc107") %>%
        hc_exporting(enabled = TRUE) %>%
        hc_title(text="Top 5 stores by sales quantity (bits + bobs + widgets)") %>%
        hc_xAxis(title = list(text = "Shop name")) %>% 
        hc_yAxis(title = list(text = "Total sales quantity")) %>%
        hc_tooltip(table = TRUE,
                   sort = TRUE,
                   pointFormat = paste0( '<br> <span style="color:{point.color}">\u25CF</span>',
                                         " Sales volume: {point.y}"),
                   headerFormat = '<span style="font-size: 13px"> {point.key}</span>'
        ) 
    })
    
    #best-selling item (sales quantity and revenue) rendering
    output$best_selling <- renderHighchart({
      hchart(app_df$bestsellingitem_data, "bar",
             hcaes(x = product, y = total_amount,group=type),
             color = c("#ffc000","#002060")) %>%
        hc_exporting(enabled = TRUE) %>%
        hc_title(text="Best-selling item in terms of both sales quantity and revenue") %>%
        hc_xAxis(title = list(text = "Product")) %>% 
        hc_yAxis(title = list(text = "Total amount")) %>%
        hc_tooltip(table = TRUE, crosshairs = TRUE, shared = TRUE,
                   sort = TRUE,
                   pointFormat = paste0( '<br> <span style="color:{point.color}">\u25CF</span>',
                                         "{point.y}"
                                         
                                         ),
                   headerFormat = '<span style="font-size: 13px"> {point.key}</span>'
        ) 
        
    })
    
  })
}

##############overview server module##############
serveroverview<-function(id){
  moduleServer(id, function(input,output,session){
  }
    )
}

# Define UI for application 
ui <- navbarPage(
    title = "Krafter Korp Sales Dashboard",
    theme = shinytheme("flatly"),
    uioverview("intro"),
    visualizationui("visualization")
   
    
    
   
)

# Define server logic required to draw a histogram
server <- function(input, output) {
 serveroverview("intro")
 visualizationserver("visualization")
  
}

# Run the application 
shinyApp(ui = ui, server = server)
