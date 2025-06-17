# Import format

library(tidyverse)
library(duckdb)

import_format <- function(dat_in = "./data/dat_2023.csv") {
  dat <- read.csv(file = dat_in)

  dat <- dat %>%
    rename(region = REGION,
           tail_number = Tail.Number,
           pilot = PIC.Name...Header,
           mission = Mission.Code,
           depart_airport = Departure.Airport,
           arrive_airport = Destination.Airport,
           cost = Line.Net.Value,
           date = AUR.Start.Date,
           leg_time = Leg.Time,
           take_offs = Take.offs,
           landings = Landings) %>%
    select(region,
           tail_number,
           pilot,
           mission,
           depart_airport,
           arrive_airport,
           cost,
           date,
           leg_time,
           take_offs,
           landings)

  dat <- dat %>% mutate_all(~replace(., .=="", NA)) %>%
    mutate(cost = as.numeric(sub('.', '', dat$cost)))

  dat <- dat |>
    mutate(pilot = stringr::str_to_title(pilot))

  dat$date <- as.Date(dat$date, format = "%m/%d/%Y")

  dat <- dat |>
    filter(region == "AK")

  dat$region <- NULL
  dat$mission <- NULL

  return(dat)

}
