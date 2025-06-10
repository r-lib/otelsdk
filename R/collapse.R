collapse <- function(
  x,
  sep = ", ",
  sep2 = sub("^,", "", last),
  last = ", and ",
  trunc = Inf,
  width = Inf,
  ellipsis = "...",
  style = c("both-ends", "head")
) {
  style <- match.arg(style)
  switch(
    style,
    "both-ends" = collapse_both_ends(
      x,
      sep,
      sep2,
      last,
      trunc,
      width,
      ellipsis
    ),
    "head" = collapse_head(x, sep, sep2, last, trunc, width, ellipsis)
  )
}

collapse_head_notrim <- function(x, trunc, sep, sep2, last, ellipsis) {
  lnx <- length(x)

  if (lnx == 1L) {
    return(x)
  }
  if (lnx == 2L) {
    return(paste0(x, collapse = sep2))
  }
  if (lnx <= trunc) {
    # no truncation
    return(paste0(
      paste(x[1:(lnx - 1L)], collapse = sep),
      last,
      x[lnx]
    ))
  } else {
    # truncation, no need for 'last'
    return(paste0(
      paste(x[1:trunc], collapse = sep),
      sep,
      ellipsis
    ))
  }
}

collapse_head <- function(x, sep, sep2, last, trunc, width, ellipsis) {
  trunc <- max(trunc, 1L)
  x <- as.character(x)
  lnx <- length(x)

  # special cases that do not need trimming
  if (lnx == 0L) {
    return("")
  } else if (anyNA(x)) {
    return(NA_character_)
  }

  # easier case, no width trimming
  if (width == Inf) {
    return(collapse_head_notrim(x, trunc, sep, sep2, last, ellipsis))
  }

  # complex case, with width wrapping
  # first we truncate
  tcd <- lnx > trunc
  if (tcd) {
    x <- x[1:trunc]
  }

  # then we calculate the width w/o trimming
  wx <- nchar(x)
  wsep <- nchar(sep, "width")
  wsep2 <- nchar(sep2, "width")
  wlast <- nchar(last, "width")
  well <- nchar(ellipsis, "width")
  if (!tcd) {
    # x[1]
    # x[1] and x[2]
    # x[1], x[2], and x[3]
    nsep <- if (lnx > 2L) lnx - 2L else 0L
    nsep2 <- if (lnx == 2L) 1L else 0L
    nlast <- if (lnx > 2L) 1L else 0L
    wtot <- sum(wx) + nsep * wsep + nsep2 * wsep2 + nlast * wlast
    if (wtot <= width) {
      if (lnx == 1L) {
        return(x)
      } else if (lnx == 2L) {
        return(paste0(x, collapse = sep2))
      } else {
        return(paste0(
          paste(x[1:(lnx - 1L)], collapse = sep),
          last,
          x[lnx]
        ))
      }
    }
  } else {
    # x[1], x[2], x[trunc], ...
    wtot <- sum(wx) + trunc * wsep + well
    if (wtot <= width) {
      return(paste0(
        paste(x, collapse = sep),
        sep,
        ellipsis
      ))
    }
  }

  # we need to find the longest possible truncation for the form
  # x[1], x[2], x[trunc], ...
  # each item is wx + wsep wide, so we search how many fits, with ellipsis
  last <- function(x) if (length(x) >= 1L) x[length(x)] else x[NA_integer_]
  trunc <- last(which(cumsum(wx + wsep) + well <= width))

  # not even one element fits
  if (is.na(trunc)) {
    if (well > width) {
      return(strtrim(ellipsis, width))
    } else if (well == width) {
      return(ellipsis)
    } else if (well + wsep >= width) {
      return(paste0(strtrim(x[1L], width), ellipsis))
    } else {
      return(paste0(
        strtrim(x[1L], max(width - well - wsep, 0L)),
        sep,
        ellipsis
      ))
    }
  }

  return(paste0(
    paste(x[1:trunc], collapse = sep),
    sep,
    ellipsis
  ))
}

collapse_both_ends <- function(x, sep, sep2, last, trunc, width, ellipsis) {
  # we always list at least 5 elements
  trunc <- max(trunc, 5L)
  trunc <- min(trunc, length(x))
  if (length(x) <= 5L || length(x) <= trunc) {
    return(collapse_head(x, sep, sep2, last, trunc = trunc, width, ellipsis))
  }

  # we have at least six elements in the vector
  # 1, 2, 3, ..., 9, and 10
  x <- as.character(c(x[1:(trunc - 2L)], x[length(x) - 1L], x[length(x)]))
  paste0(
    c(x[1:(trunc - 2L)], ellipsis, paste0(x[trunc - 1L], last, x[trunc])),
    collapse = sep
  )
}

trim <- function(x) {
  has_newline <- function(x) any(grepl("\\n", x))
  if (length(x) == 0L || !has_newline(x)) {
    return(x)
  }
  ccall(trim_, x)
}
