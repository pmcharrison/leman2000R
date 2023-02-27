library(testthat)

test_that("Output formatting", {
  res <- leman_2000(
    input_file = system.file("hihat.wav", package = "leman2000", mustWork = TRUE),
    local_decay_sec = c(0.1, 0.2),
    global_decay_sec = c(1, 2),
    windows = list(
      c(0.0, 0.1),
      c(0.1, 0.2),
      c(0.2, 0.3)
    )
  )

  expect_equal(
    unique(res$local_global_comparison[c("local_decay_sec", "global_decay_sec")]),
    tibble::tibble(
      local_decay_sec = c(0.1, 0.2, 0.1, 0.2),
      global_decay_sec = c(1L, 1L, 2L, 2L)
    )
  )

  times <- unique(res$local_global_comparison$time_sec)

  expect_equal(
    times,
    seq(
      from = 0,
      to = res$audio_length_sec,
      length.out = nrow(res$local_global_comparison) / 4
    )
  )

  expect_equal(
    res$windowed_local_global_comparison[c("window_start", "window_end")] |> unique(),
    tibble::tibble(
      window_start = c(0, 0.1, 0.2),
      window_end = c(0.1, 0.2, 0.3),
    ),
    ignore_attr = TRUE
  )
})
