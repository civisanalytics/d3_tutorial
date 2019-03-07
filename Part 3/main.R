# Load libraries
library(readr) # used for read_file
library(jsonlite) # to convert the R data table into a JS JSON object
library(dplyr) # for basic data manipulation
library(lubridate) # to parse movie release dates

# Read in raw data
df <-read.csv('../Data/movie_franchises.csv')

# Specify the movie franchises we want to highlight in the chart.
# These will be drawn in a darker blue color and will be visible in the default view. 
# All other franchises will only be visible if the user hovers over a dot or selects them from the dropdown menu.
to_highlight <- c("King Kong",
                  "Terminator",
                  "Mission: Impossible",
                  "Teenage Mutant Ninja Turtles")

# Add a highlight flag to the input data
df <- df %>%
  mutate(highlight = ifelse(franchise %in% to_highlight, 1, 0))

# Parse the release dates and correct cases where, for example, '1/1/66' gets parsed as '2066-01-01'
# We subtract 100 years from any date that gets parsed to a date later than today
df <- df %>%
  mutate(date = mdy(date) - years(100 * (mdy(date) > ymd(today()))))

# Sort the table to make sure our curves connect movies in ascending order of release date
df <- df %>%
  arrange(highlight, franchise, date)

# convert the R tibble to a JSON object that JavaScript can use
df_json <- jsonlite::toJSON(df)

# Concatenate the header, data and footer code
# This sandwiches the data between the header file(mostly <head></head> section) 
# and the footer file (mostly <body></body section>) and returns the full HTML script.
header <- read_file("header.txt")
footer <- read_file("footer.txt")
script <- paste0(header,
                 df_json,
                 footer)

# To show in browser
# Write the script to an .html file and open that file
# This doesn't always work for me though. 
# you may need to manually open the index.html file yourself.
fileConn <- file('index.html')
writeLines(script, fileConn)
close(fileConn)
rstudioapi::viewer('index.html')

# To show in Rstudio's Viewer Pane
# Write the script to an .html file in a temporary folder
# then open that file in RStudio's Viewer Pane
tempDir <- tempfile() # --> this is key!
dir.create(tempDir)
htmlFile <- file.path(tempDir, "index.html")

fileConn <- file(htmlFile)
writeLines(script, fileConn)
close(fileConn)

viewer <- getOption("viewer") # Set viewer option to the Viewing Pane
rstudioapi::viewer(htmlFile)