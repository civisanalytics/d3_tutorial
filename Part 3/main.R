library(dplyr)
library(readr)
library(jsonlite)

url <- "https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2019/2019-01-08/IMDb_Economist_tv_ratings.csv"

df <-read.csv(url(url))

to_highlight <- c("Law & Order",
                  "Breaking Bad",
                  "Game of Thrones",
                  "Lost",
                  "The Wire",
                  "Riverdale",
                  "The Walking Dead")

df <- df %>%
  mutate(highlight = ifelse(title %in% to_highlight, 1, 0))

df <- df %>%
  arrange(title, date)

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
viewer('index.html')

# To show in Viewer Pane
tempDir <- tempfile() # --> this is key!
dir.create(tempDir)
htmlFile <- file.path(tempDir, "index.html")

fileConn <- file(htmlFile)
writeLines(script, fileConn)
close(fileConn)

viewer <- getOption("viewer")
viewer(htmlFile)