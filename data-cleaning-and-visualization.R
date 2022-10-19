library(tidyverse)
library(dplyr)
library(ggplot2)
library(tools)

#Read one of the csv file to find a list of countries that the data covers.
#All the dataset will have the same amount of countries as they are from the same source.
gdp_df <- read.csv("C:\\gdp.csv") %>% 
  rename("gdp" = "value")
unique_country <- distinct(gdp_df,country) %>% pull()

#Base directory is the folder where all the csv files are stored
base_directory <- "C:\\%s.csv"
#List of all the csv file names
file_names <- c("gdp", "deposit_interest_rate", "gdp_growth", "gni",
                "gni_per_capita", "gross_domestic_savings",
                "inflation", "labor_force_total", "population",
                "population_density")

#Loop through every file
for (file_name in file_names){
  #The directory is the based directory with the file name.
  directory <- sprintf(base_directory,file_name)
  # Open the csv file
  assign(paste0(file_name,"_df"),
         read.csv(directory) %>% 
           #Rename the "value" column with the file name, which represents the 
           #value of the dataset
           rename_with(~file_name, value) %>%
           select(country, date, file_name) %>%
           #Only include countries from the 50th position onwards as the first
           #49 represents regions instead of individual countries.
           filter(country %in% tail(unique_country, -49))
  )
  
}

df_list <- list(gdp_df, deposit_interest_rate_df, gdp_growth_df, gni_df,
                gni_per_capita_df, gross_domestic_savings_df, inflation_df,
                labor_force_total_df, population_df, population_density_df)
#Join all dataframes together
final_df <- df_list %>% reduce(left_join, by = c("country", "date"))

#Function to plot regression analysis
ggplotRegression <- function (y,x) {
  
  require(ggplot2)
  
  #Remove NA values after isolating the variables that are needed for regression
  filtered_df <-final_df %>% 
    select(country, date, paste0(y), paste0(x)) %>%
    drop_na()
  
  #Create the regression model
  fit <- lm(paste0(y, "~" ,x), data = filtered_df)
  
  #Plot the regreesion model with statistical labels
  ggplot(fit$model, aes_string(x = names(fit$model)[2], y = names(fit$model)[1])) + 
    geom_point() +
    geom_smooth(formula = y ~ x, method = "lm", col = "red") +
    labs(title = paste("R2 = ",signif(summary(fit)$r.squared, 5),
                       " Slope =",signif(fit$coef[[2]], 5),
                       " P =",summary(fit)$coef[2,4]))
}

#Plot the regression model simply by pasting in the name of 2 variables.
ggplotRegression("gdp", "population")


#Function to visualize a specific parameter in a world map
ggplotWorldMap <- function (param) {
  
  require(ggplot2)
  require(dplyr)
  require(tools)
  
  #Utilize map_data from ggplot2 to get a list of countries with their 
  #longtitude and ladtitude
  mapdata <- map_data("world")
  
  #List of country names from map_data that don't match with ours
  distinct(mapdata,region)%>%
    filter(!(region %in% unique_country)) %>% 
    View
  
  #Country dictionary to change from map_data's country name to ours.
  country_dictionary <- c(
    "Antigua" = "Antigua and Barbuda",
    "Bahamas" = "Bahamas, The",
    "Democratic Republic of the Congo" = "Congo, Dem. Rep.",
    "Republic of Congo" = "Congo, Rep.",
    "Egypt" = "Egypt, Arab Rep.",
    "Gambia" = "Gambia, The",
    "Iran" = "Iran, Islamic Rep.",
    "Ivory Coast" = "Cote d'Ivoire",
    "Kyrgyzstan" = "Kyrgyz Republic",
    "Laos" = "Lao PDR",
    "North Korea" = "Korea, Dem. People's Rep.",
    "South Korea" = "Korea, Rep.",
    "Russia" = "Russian Federation",
    "Sint Maarten" = "Sint Maarten (Dutch part)",
    "Slovakia" = "Slovak Republic",
    "Swaziland" = "Eswatini",
    "Syria" = "Syrian Arab Republic",
    "Trinidad" = "Trinidad and Tobago",
    "Turkey" = "Turkiye",
    "UK" = "United Kingdom",
    "USA" = "United States",
    "Virgin Islands" = "Virgin Islands (U.S.)",
    "Yemen" = "Yemen, Rep.",
    "Venezuela" = "Venezuela, RB"
  )
  
  #Select the latest data, which is 2021
  filtered_df <-final_df %>% 
    select(country, date, paste0(param)) %>% 
    filter(date == 2021) 
  
  #Loop through the dictionary to change the country name to the correct one
  for (country in names(country_dictionary)){
    mapdata["region"][mapdata["region"] == country] <- country_dictionary[country]
  }
  
  #The join can be used now as the countries have matched each other.
  #Left join is used as we need all the coordinates from mapdata.
  mapdata <- left_join(mapdata, filtered_df, by = c("region" = "country"))
  
  #Basic world map with ggplot
  map1 <- ggplot(mapdata, aes(long, lat, group=group)) +
    geom_polygon(aes(fill = get(param)), color = "black")
  
  map2 <- map1 + 
    #Give the basic world map a gradient to differentiate low to high values
    #Also give the legend a name
    scale_fill_gradient(name = toTitleCase(gsub('_', ' ', param)), low = "blue", high = "orange", labels = scales::comma)+
    #Remove all the unncessary elements
    theme(axis.text.x = element_blank(),
          axis.text.y = element_blank(),
          axis.ticks = element_blank(),
          axis.title.x = element_blank(),
          axis.title.y = element_blank(),
          rect = element_blank()
    )
  #View the map
  map2
}

#Call the function by using the desired csv file name
ggplotWorldMap("gdp")+
  #Add a title to the map
  ggtitle("GDP World Map")





