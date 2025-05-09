#' @title calcValidEmisLucGasser
#'
#' @description Returns historical LUC emissions
#'
#' @param subtype Available subtypes are:
#'  \itemize{
#'  \item historical:
#'  \itemize{
#'  \item Gasser_2020
#'  \item LUH2_GCB_2019
#'  \item FRA_2015
#'  \item bookkeeping
#'  }
#'  }
#' @return list of magpie object with data and weight
#' @author Abhijeet Mishra
calcValidEmisLucGasser <- function(subtype = "bookkeeping") {

  if (subtype %in% c("Gasser_2020", "LUH2_GCB_2019", "FRA_2015")) {
    ## Conversion from Pg to Mt and C to CO2
    out <- readSource("Gasser", subtype = "regional", convert = TRUE)[, , subtype] * 1000 * 44 / 12
    out <- add_dimension(out, dim = 3.1, add = "scenario", nm = "historical")
    out <- add_dimension(out, dim = 3.2, add = "model", nm = subtype)
    getNames(out, dim = 3) <- "Emissions|CO2|Land|+|Land-use Change (Mt CO2/yr)"
    out <- setYears(out, "y2009")
    out <- time_interpolate(dataset = out, interpolated_year = paste0("y", 2010:2018),
                            extrapolation_type = "constant", integrate_interpolated_years = TRUE)
    names(dimnames(out))[3] <- "scenario.model.variable"
  } else if (subtype %in% "bookkeeping") {
    model <- "Gasser et al 2020"
    ## Conversion from Pg to Mt and C to CO2
    out <-  readSource("Gasser", subtype = subtype, convert = TRUE) * 1000 * 44 / 12
    out1 <- out[, , c("gross_luc_emis", "regrowth_luc_emis")]
    getNames(out1) <- c("Gross LUC", "Regrowth")
    getNames(out1) <- paste0("Emissions|CO2|Land|Land-use Change|+|", getNames(out1), " (Mt CO2/yr)")
    raw1 <- out[, , c("gross_luc_emis", "regrowth_luc_emis")]
    getNames(raw1) <- c("Gross LUC", "Regrowth")
    getNames(raw1) <- paste0("Emissions|CO2|Land RAW|Land-use Change|+|", getNames(raw1), " (Mt CO2/yr)")
    out1 <- mbind(out1, raw1)
    out1 <- add_dimension(out1, dim = 3.1, add = "scenario", nm = "historical")
    out1 <- add_dimension(out1, dim = 3.2, add = "model", nm = model)
    names(dimnames(out1))[3] <- "scenario.model.variable"

    out2 <- out[, , "overall"]
    getNames(out2) <- c("Emissions|CO2|Land|+|Land-use Change")
    getNames(out2) <- paste0(getNames(out2), " (Mt CO2/yr)")
    raw2 <- out[, , "overall"]
    getNames(raw2) <- c("Emissions|CO2|Land RAW|+|Land-use Change")
    getNames(raw2) <- paste0(getNames(raw2), " (Mt CO2/yr)")
    out2 <- mbind(out2, raw2)

    out2 <- add_dimension(out2, dim = 3.1, add = "scenario", nm = "historical")
    out2 <- add_dimension(out2, dim = 3.2, add = "model", nm = model)
    names(dimnames(out2))[3] <- "scenario.model.variable"

    out <- mbind(out1, out2)
  } else {
    stop("Invalid subtype. See function description for valid subtypes.")
  }

  return(list(x = out,
              weight = NULL,
              unit = "Mt CO2/yr",
              min = -1000,
              description = "Historical land-use change CO2 emissions from different sources in Mt CO2/yr")
  )
}
