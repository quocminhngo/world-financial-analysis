library(httr)
library(jsonlite)
library(tidyverse)

URL <- "https://api.worldbank.org/v2/country/all/indicator/FR.INR.LEND"

#Store API call result in JSON format
api_call <- GET(URL, query = list(format = "json"))

#Convert JSON format into R object with fromJSON
result <- fromJSON(rawToChar(api_call$content), flatten = TRUE)

#Determine the total number of pages and the results per page
pages <- result[[1]]$pages
per_page <- result[[1]]$per_page

#Create empty arrays to store values in later
date <- c()
value <- c()
country <- c()

#Loop through every page.
for (current_page in 1:pages) {
  #Make the API call and convert it from JSON format like before
  api_call <- GET(URL, query = list(format = "json",page = current_page))
  
  result <- fromJSON(rawToChar(api_call$content), flatten = TRUE)
  
  #Append each new result to each corresponding vector
  date <- append(date, result[[2]]$date)
  value <- append(value, result[[2]]$value)
  country <- append(country, result[[2]]$country.value)
}

#Convert the vectors into dataframe and store it as a csv file
df <- data.frame(country, date, value)
write.csv(df,"C:\\lending_interest_rate.csv")
