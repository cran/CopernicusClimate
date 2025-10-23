## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)
tryCatch({
  Sys.setlocale("LC_ALL", "English")
})
library(ggplot2)
theme_set(theme_light())

## ----token--------------------------------------------------------------------
library(CopernicusClimate)

message(
  "The machine that rendered this vignette ",
  ifelse(
    cds_token_works(), "has", "does not have"),
  " a working token")


## ----get-licence, message=FALSE-----------------------------------------------
library(dplyr)

licence_info <-
  cds_dataset_form("reanalysis-era5-pressure-levels") |>
    filter(name == "licences")

licence_info <- licence_info$details[[1]]$details$licences[[1]]
print(licence_info)

## ----listing------------------------------------------------------------------
cds_list_datasets()

## ----search-------------------------------------------------------------------
cds_search_datasets(search = "rain", keywords = "Temporal coverage: Future")

## ----dataset-form-------------------------------------------------------------
dataset_form <-
  cds_dataset_form("reanalysis-era5-pressure-levels")

dataset_form

## ----possible-values----------------------------------------------------------
values <-
  dataset_form |>
  filter(name == "pressure_level") |>
  pull("details")

values[[1]]$details$values |> unlist()

## ----full-request-------------------------------------------------------------
request <- cds_build_request("reanalysis-era5-pressure-levels")
summary(request)

## ----specific-request---------------------------------------------------------
request <- cds_build_request(
  "reanalysis-era5-pressure-levels",
  variable       = "temperature",
  pressure_level = "1000",
  year           = "2025",
  month          = "01",
  day            = "01",
  area           = c(n = 60, e = -5, s = 40, w = 10),
  data_format    = "netcdf")
summary(request)

## ----estimate-full------------------------------------------------------------
if (cds_token_works()) {
  cds_estimate_costs("reanalysis-era5-pressure-levels")
} else {
  message("You need a working token to estimate costs")
}

## ----estimate-detailed--------------------------------------------------------
if (cds_token_works()) {
  cds_estimate_costs(request)
} else {
  message("You need a working token to estimate costs")
}

## ----submit, message=FALSE----------------------------------------------------
if (cds_token_works()) {
  job <-
    cds_submit_job(request)
  job
} else {
  message("You need a working token to submit a request")
}

## ----job-status---------------------------------------------------------------
if (cds_token_works()) {
  cds_list_jobs(job$jobID)
} else {
  message("You need a working token to get a job status")
}

## ----download, message=FALSE--------------------------------------------------
filename <- "result.nc"
if (cds_token_works()) {
  file_result <- cds_download_jobs(job$jobID, tempdir(), filename)
} else {
  message("Downloading data only works with a valid token")
}

## ----plot, fig.width=7, fig.height=3, message = FALSE, fig.alt="Plot created from downloaded data"----
fn <- file.path(tempdir(), filename)

if (file.exists(fn)) {
  
  library(stars)
  library(ggplot2)
  
  result <- read_mdim(fn)
  
  ggplot() +
    geom_stars(data = result) +
    coord_sf() +
    facet_wrap(~strftime(valid_time, "%H:%M"), nrow = 3) +
    scale_fill_viridis_c(option = "turbo") +
    labs(x = NULL, y = NULL, fill = "Temperature [K]") +
    theme(axis.text = element_blank())

} else {
  message("File wasn't downloaded")
}

