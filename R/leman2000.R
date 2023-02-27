get_full_file_path <- function(file) {
  dir_full_path <- normalizePath(dirname(file), mustWork = TRUE)
  filename <- basename(file)
  file_full_path <- file.path(dir_full_path, filename)
  file_full_path
}

#' @export
leman_2000 <- function(
    input_file,  # should have a .wav extension
    local_decay_sec,
    global_decay_sec,
    detail = 5,
    windows = NULL,
    windowing_function = mean,
    keep_auditory_nerve = FALSE,
    keep_periodicity_pitch = FALSE
) {
  if (is.null(file)) {
    file <- tempfile(fileext =".json")
  }
  input_file <- get_full_file_path(input_file)

  tmp_input_file <- tempfile(fileext = ".wav")

  if (!file.copy(input_file, tmp_input_file)) {
    stop(
      "Failed to access the input file at ",
      input_file,
      ", are you sure it exists?")
  }

  tmp_output_dir <- tempdir()
  tmp_output_file <- paste0(uuid::UUIDgenerate(), ".json")
  tmp_output_path <- file.path(tmp_output_dir, tmp_output_file)

  # message("Temporary input path: ", tmp_input_file)
  # message("Temporary output path: ", tmp_output_path)

  stopifnot(
    is.numeric(local_decay_sec),
    is.numeric(global_decay_sec),
    is.numeric(detail)
  )

  code <- sys::exec_wait(
    "docker",
    args = c(
      "run",
      "-v", sprintf("%s:/input.wav", tmp_input_file),  # glue::glue("\"{input_file}\":/input.wav"),
      "-v", sprintf("%s:/output", tmp_output_dir),  # glue::glue('{tmp_output_dir}:/output'),
      "ghcr.io/pmcharrison/leman_2000:latest",
      "input.wav",
      glue::glue("output/{tmp_output_file}"),
      paste(local_decay_sec, collapse = ","),
      paste(global_decay_sec, collapse = ","),
      detail
    )
  )
  if (code != 0) {
    stop("An unknown error occurred when calling the Docker command.")
  }

  res <- RcppSimdJson::fload(tmp_output_path, max_simplify_lvl = "data_frame")

  if (!keep_auditory_nerve) res$auditory_nerve <- NULL
  if (!keep_periodicity_pitch) res$periodicity_pitch <- NULL

  res$local_global_comparison <- format_local_global_comparison(
    res$local_global_comparison,
    res$audio_length_sec
  )

  if (!is.null(windows)) {
    res$windowed_local_global_comparison <- window_local_global_comparison(
      res$local_global_comparison,
      windows,
      windowing_function
    )
  }

  res
}

format_local_global_comparison <- function(local_global_comparison, audio_length_sec) {
  local_global_comparison[[1]] |>
    tibble::as_tibble() |>
    purrr::pmap_dfr(
      function(local_decay_sec, global_decay_sec, running_correlation) {
        tibble::tibble(
          local_decay_sec = local_decay_sec,
          global_decay_sec = global_decay_sec,
          time_sec = seq(
            from = 0,
            to = audio_length_sec,
            length.out = length(running_correlation)
          ),
          running_correlation = running_correlation
        )
      }
    )
}

window_local_global_comparison <- function(
  local_global_comparison,
  windows,
  windowing_function
) {
  stopifnot(is.list(windows))
  for (window in windows) {
    stopifnot(is.numeric(window), length(window) == 2)
  }

  df <- expand.grid(
    local_decay_sec = unique(local_global_comparison$local_decay_sec),
    global_decay_sec = unique(local_global_comparison$global_decay_sec),
    window_id = seq_along(windows)
  ) |>
    tibble::as_tibble()
  df$window_start <- purrr::map_dbl(windows[df$window_id], 1)
  df$window_end <- purrr::map_dbl(windows[df$window_id], 2)

  df$local_global_correlation <- purrr::pmap_dbl(
    df,
    function(local_decay_sec, global_decay_sec, window_id, window_start, window_end) {
      windowing_function(
        local_global_comparison$running_correlation[
          local_global_comparison$local_decay_sec == local_decay_sec &
          local_global_comparison$global_decay_sec == global_decay_sec &
          local_global_comparison$time_sec >= window_start &
          local_global_comparison$time_sec < window_end
        ]
      )
    }
  )

  df
}
