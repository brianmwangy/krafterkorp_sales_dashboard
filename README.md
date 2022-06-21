# krafterkorp_sales_dashboard
This dashboard allows cutomer to gain insights into Krafterkorp's current operations

The sales dashboard is hosted here: [Krafterkorp Sales Dashboard](https://brianmwangy.shinyapps.io/krafterkorp_sales_dashboard/)
              ![Dashboard image](https://github.com/brianmwangy/krafterkorp_sales_dashboard/blob/main/www/dashboard_image.PNG)
              ![Dashboard image](https://github.com/brianmwangy/krafterkorp_sales_dashboard/blob/main/www/dashboard_image2.PNG)

# App Structure

- `app.R` app file (UI and server logic live)
- `constants.R` data constants file
- `global.R`data loading and manipulation file
- `www/app_data.rds` app clean data
- `www/bestselling_item.csv` cleaned data for best selling item plotting
- `www/dashboard_data.csv` cleaned data for map and data table
- `www/top_salesstore_count.csv` cleaned data for store concentration plotting
- `www/top5_neighborhoods_revenue.csv` cleaned data for top 5 neighborhoods sales revenue
- `www/top5_stores_salesqty.csv` cleaned data for top stores sales quantity

# References
- [R shiny package](https://shiny.rstudio.com/) - A general guide on developing dashboards using shiny framework
- [Markdown guide](https://www.markdownguide.org/) - A reference guide on using various markdown syntaxes
- [Leaflet](https://rstudio.github.io/leaflet/) - Reference for developing interactive map for store location
- [Highcharter](https://rpubs.com/jbkunst/highcharter) - Highcharter is the library used develop the appealing bar graphs
- [R shiny gallery](https://shiny.rstudio.com/gallery/) - An inspirational guide for various shiny dashboard examples
- [Data loading in R article](https://appsilon.com/fast-data-loading-from-files-to-r/) - A reference guide for using rds function in data loading
- [Data loading in R article](https://shiny.rstudio.com/articles/caching.html) - The bindCache() function enables the app to automatically retrieve the values saved in the cache instead of having to compute them again
- [R shiny modules](https://shiny.rstudio.com/articles/modules.html)- Guide for modularizing shiny app code
