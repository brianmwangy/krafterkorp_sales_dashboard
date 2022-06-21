
#loading required libraries

library(dplyr)
library(readr)

#loading dashboard dataset

bestselling_item <- read_csv("./www/bestselling_item.csv")
map_table <- read_csv("./www/dashboard_data.csv")
top_salesstore_count <- read_csv("./www/top_salesstore_count.csv")
top5_neighborhoods_revenue <- read_csv("./www/top5_neighborhoods_revenue.csv")
top5_stores_salesqty <- read_csv("./www/top5_stores_salesqty.csv")

#creating merged app dataset for faster loading
app_data <- list(
  bestsellingitem_data = bestselling_item,
  maptable_data = map_table,
  top_salesstore_count = top_salesstore_count,
  top5_neighborhoods_revenue = top5_neighborhoods_revenue,
  top5_stores_salesqty = top5_stores_salesqty
)

#saving app data
saveRDS(app_data,"./www/app_data.rds")


