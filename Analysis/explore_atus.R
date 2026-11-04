#========================================
# American Time Use Survey (ATUS) | 2003-2025
# Data Visualization Semester Project
# Maxell Taylor mct115
# Georgetown University
#
# Data Source: U.S. Breau of Labor Statistics
# https://www.bls.gov/tus/data.htm#
#
# Exploratory analysis of American time-use data
#========================================

# Load packages

library(tidyverse)
library(ggplot2)
library(plotly)

# Import data


# Import data

atus_summary <- read_csv(
  "Analysis/data/raw/atussum_0325.dat",
  col_types = cols(
    TUCASEID = col_character(),
    .default = col_guess()
  )
)

atus_resp <- read_csv(
  "Analysis/data/raw/atusresp_0325.dat",
  col_types = cols(
    TUCASEID = col_character(),
    .default = col_guess()
  )
)

atus_act <- read_csv(
  "Analysis/data/raw/atusact_0325.dat",
  col_types = cols(
    TUCASEID = col_character(),
    .default = col_guess()
  )
)

