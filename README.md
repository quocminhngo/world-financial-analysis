# Project Background
The long lasting pandemic has taken a toll on our economy with a snow ball effect that causes record high inflation, and mass lay-offs. With the looming recession, 
the goal of the project is to determine how the United States is doing financially in comparison to other countries around the world. From then, figure out if there
are factors that correlate with how well a country is doing financially, and visualize the findings. All the necessary data will be collected from the World Bank 
Group’s API.

# Data Source

The World Bank Group is a global partnership that fights poverty through sustainable solution and they have provided their data openly through their API, which will be leveraged to do this analysis.

# Data Extraction Method

Make call requests to the World Bank Group's API in R to obtain the over 100,000 data points and save them as a csv file for later visualization. The code for 
that can be found in obtain-data.R

# Data Cleaning and Visualization

Joined all the different csv files together into one data frame after cleaning with dplyr package. Afterward, create a custom reusable function to perform regression analysis and graph the data with ggplot2. The code for those can be found in data-cleaning-and-visualization.R. The rest of the analysis can be found at 
<a href="https://quocminhngo.com/world-financial-analysis">quocminhngo.com/world-financial-analysis</a>


