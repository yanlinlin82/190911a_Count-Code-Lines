library(tidyverse)
library(lubridate)

a <- read_tsv("lines.txt.gz")
g <- a %>%
  mutate(year = year(date)) %>%
  group_by(year, date, ext) %>%
  summarize(line = sum(line)) %>%
  ungroup %>%
  filter(year >= 2016, line > 0, grepl("\\.[a-zA-Z]+$", ext)) %>%
  filter(ext %in% c(".h", ".c", ".cpp", ".pl", ".R", ".sh"), abs(line) < 10000) %>%
  group_by(ext) %>%
  mutate(mean_line = mean(line)) %>%
  ggplot(aes(x = year, y = line, group = year, fill = ext)) +
  geom_violin() +
  geom_point(position = "jitter", size = 1, alpha = .5) +
  facet_wrap(~ ext, nrow = 1) +
  scale_y_continuous(trans = "log10",
                     breaks = c(1:5,
		                seq(10,50,by=10),
                                seq(100,500,by=100),
				seq(1000,5000,by=1000))) +
  geom_hline(aes(yintercept = mean_line), color = "blue")
g %>% ggsave(filename = "plot.png", width = 12, height = 8)
