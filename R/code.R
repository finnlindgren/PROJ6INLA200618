check_if_needed <- function() {
  inla_ver <- as.character(utils::packageVersion("INLA"))
  if (utils::compareVersion(inla_ver, "20.7.16") >= 0) {
    warning(paste0(
      "The PROJ6INLA200618 workararound is probably not needed for your INLA version",
      "\n",
      "The problem was fixed on 20.7.16, and your version is ", inla_ver))
    return(FALSE)
  }
  TRUE
}



#' @title Handling CRS/WKT
#' @description Get and set CRS object or WKT string properties.
#' @param wkt A WKT2 character string
#' @param unit character, name of a unit. Supported names are
#' "metre", "kilometre", and the aliases "meter", "m", International metre",
#' "kilometer", and "km", as defined by \code{inla.wkt_unit_params} or the
#' \code{params} argument. (For legacy PROJ4 use, only "m" and "km" are
#' supported)
#' @param params Length unit definitions, in the list format produced by
#' \code{inla.wkt_unit_params()}, Default: NULL, which invokes
#' \code{inla.wkt_unit_params()}
#' @export
#' @rdname crs_wkt
#' @return For \code{inla.wkt_set_lengthunit}, a
#' WKT2 string with altered length units.
#' Note that the length unit for the ellipsoid radius is unchanged.

inla.wkt_set_lengthunit <- function(wkt, unit, params = NULL) {
  convert <- function(wt, unit) {
    # 1. Recursively find LENGTHUNIT, except within ELLIPSOID
    # 2. Change unit

    if (wt[["label"]] == "LENGTHUNIT") {
      wt[["params"]] <- unit
    } else if (wt[["label"]] != "ELLIPSOID") {
      for (k in seq_along(wt$param)) {
        if (is.list(wt[["params"]][[k]])) {
          wt[["params"]][[k]] <- convert(wt[["params"]][[k]], unit)
        }
      }
    }
    wt
  }

  if (is.null(params)) {
    params <- INLA::inla.wkt_unit_params()
  }
  if (!(unit %in% names(params))) {
    warning(paste0("'inla.wkt_set_lengthunit' unit conversion to '",
                   unit,
                   "' not supported. Unit left unchanged."))
    return(wkt)
  }

  wt <- INLA::inla.as.wkt_tree.wkt(wkt)
  wt <- convert(wt, params[[unit]])
  INLA::inla.as.wkt.wkt_tree(wt)
}


#' @param crs A \code{sp::CRS} or \code{inla.CRS} object
#' @return For \code{inla.crs_set_lengthunit}, a \code{sp::CRS} object with
#' altered length units.
#' Note that the length unit for the ellipsoid radius is unchanged.
#' @export
#' @rdname crs_wkt

inla.crs_set_lengthunit <- function(crs, unit, params = NULL) {
  check_if_needed()
  if (inherits(crs, "inla.CRS")) {
    crs_ <- crs
    crs <- crs[["crs"]]
  } else {
    crs_ <- NULL
  }
  if (INLA::inla.has_PROJ6()) {
    x <- sp::CRS(SRS_string = inla.wkt_set_lengthunit(INLA::inla.crs_get_wkt(crs),
                                                      unit,
                                                      params = params))
  } else {
    crs_args <- INLA::inla.as.list.CRS(crs)
    crs_args[["units"]] <- unit
    x <- INLA::inla.as.CRS.list(crs_args)
  }
  if (!is.null(crs_)) {
    crs_[["crs"]] <- x
    x <- crs_
  }
  x
}
