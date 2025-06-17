# Import format


#' Import and format the FWS aviation data
#'
#' @param dat_in the file path to a CSV containing FWS aviation data
#'
#' @return a data frame of formatted for the Shiny app
#'
#' @import tidyverse
#' @export
#'
#' @example
import_format <- function(dat_in = "./data/dat.csv") {

  library(tidyverse)

  read.csv(file = dat_in) |>
    mutate(date = as.Date(AUR.Start.Date, format = "%m/%d/%Y"),
           pilot = stringr::str_to_title(PIC.Name...Header),
           cost = as.numeric(gsub("[\\$,\\s]", "", Line.Net.Value))) |>
    filter(year(date) == 2023,
           REGION == "AK") |>
    rename(region = REGION,
           tail_number = Tail.Number,
           depart_airport = Departure.Airport,
           arrive_airport = Destination.Airport,
           leg_time = Leg.Time,
           take_offs = Take.offs,
           landings = Landings) %>%
    select(tail_number,
           pilot,
           depart_airport,
           arrive_airport,
           cost,
           date,
           leg_time,
           take_offs,
           landings) |>
    mutate_all(~replace(., .=="", NA))  # Replace field with "." with NA
}
