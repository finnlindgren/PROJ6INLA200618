check_if_needed <- function() {
  inla_ver <- as.character(packageVersion("INLA"))
  if (compareVersion(inla_ver, "20.7.16") >= 0) {
    warning(paste0(
      "The PROJ6INLA200618 workararound is probably not needed for your INLA version",
      "\n",
      "The problem was fixed on 20.7.16, and your version is ", inla_ver))
  }
}



#' @title Handling CRS/WKT
#' @description Get and set CRS object or WKT string properties.
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
    params <- inla.wkt_unit_params()
  }
  if (!(unit %in% names(params))) {
    warning(paste0("'inla.wkt_set_lengthunit' unit conversion to '",
                   unit,
                   "' not supported. Unit left unchanged."))
    return(wkt)
  }

  wt <- inla.as.wkt_tree.wkt(wkt)
  wt <- convert(wt, params[[unit]])
  inla.as.wkt.wkt_tree(wt)
}


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
  if (inla.has_PROJ6()) {
    x <- sp::CRS(SRS_string = inla.wkt_set_lengthunit(inla.crs_get_wkt(crs),
                                                      unit,
                                                      params = params))
  } else {
    crs_args <- inla.as.list.CRS(crs)
    crs_args[["units"]] <- unit
    x <- inla.as.CRS.list(crs_args)
  }
  if (!is.null(crs_)) {
    crs_[["crs"]] <- x
    x <- crs_
  }
  x
}
