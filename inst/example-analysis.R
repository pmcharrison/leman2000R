# install.packages("remotes")
# remotes::install_github("pmcharrison/leman2000R")
# install.packages("tidyverse") # for plotting

library(tidyverse)
library(leman2000)

theme_set(theme_classic())

res <- leman2000(
  input_file = "inst/bVII_eGuitar_A.wav",
  local_decay_sec = c(0.1, 0.5),
  global_decay_sec = c(1, 2),
  windows = list(c(3.5, 5.225), c(5.225, 6.885))
)

res$local_global_comparison |>
  mutate(
    global_decay_sec = paste("Global decay =", global_decay_sec),
    local_decay_sec = paste("Local decay =", local_decay_sec),
  ) |>
  ggplot(aes(time_sec, running_correlation)) +
  scale_x_continuous("Time (seconds)") +
  scale_y_continuous("Local-global correlation") +
  geom_line() +
  facet_grid(global_decay_sec ~ local_decay_sec)


res$windowed_local_global_comparison |>
  mutate(
    global_decay_sec = paste("Global decay =", global_decay_sec),
    local_decay_sec = paste("Local decay =", local_decay_sec),
    window_label = sprintf("%.2fs - %.2fs", window_start, window_end)
  ) |>
  ggplot(aes(window_label, local_global_correlation)) +
  scale_x_discrete("Window") +
  scale_y_continuous("Local-global correlation") +
  geom_bar(stat = "identity") +
  facet_grid(global_decay_sec ~ local_decay_sec)

