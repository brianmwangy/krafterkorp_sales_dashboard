#reading app data
app_df <- readRDS("./www/app_data.rds")

product_name <- unique(app_df$maptable_data$product)
shop_location <- unique(app_df$maptable_data$shop_location)
