library(readr)
library(jsonlite)
library(dplyr)
library(lubridate)

df <-read.csv('../Data/movie_franchises.csv')

to_highlight <- c("King Kong",
                  "Terminator",
                  "Mission: Impossible",
                  "Teenage Mutant Ninja Turtles")

df <- df %>%
  mutate(highlight = ifelse(franchise %in% to_highlight, 1, 0))

df <- df %>%
  mutate(date = mdy(date) - years(100 * (mdy(date) > mdy('3/1/2019')))) %>%
  arrange(highlight, franchise, date)

df_json <- jsonlite::toJSON(df)

header <- read_file("header.txt")
footer <- read_file("footer.txt")
script <- paste0(header,
                 df_json,
                 footer)

# To show in browser
fileConn <- file('index.html')
writeLines(script, fileConn)
close(fileConn)
rstudioapi::viewer('index.html')

# To show in Viewer Pane
tempDir <- tempfile() # --> this is key!
dir.create(tempDir)
htmlFile <- file.path(tempDir, "index.html")

fileConn <- file(htmlFile)
writeLines(script, fileConn)
close(fileConn)

viewer <- getOption("viewer")
viewer(htmlFile)