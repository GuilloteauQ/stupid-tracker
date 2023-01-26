library(tidyverse)

args = commandArgs(trailingOnly=TRUE)

filename <- args[1]


p <- read_csv(filename, col_names = c("event", "time")) %>%
  mutate(
    session = ceiling(row_number() / 2)
  ) %>%
  pivot_wider(
    names_from = event,
    values_from = time
  ) %>%
  mutate(
    duration = stop - start,
    start = lubridate::as_datetime(start),
    stop  = lubridate::as_datetime(stop),
    cum_duration = hms::as_hms(cumsum(duration))
  ) %>%
  ggplot(aes(x = stop, y = cum_duration)) +
  geom_line() +
  geom_point() +
  # ylim(0, NA) +
  theme_bw() +
  xlab("") +
  ylab("") +
  ggtitle("Cumlative Working Time Spent on the Thesis")
  
ggsave("thesis_time.pdf", plot = p, width = 8, height = 6)
