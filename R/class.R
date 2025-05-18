new_object <- function(cls, ...) {
  bind_env <- new.env(parent = emptyenv())
  encl_env <- new.env(parent = parent.frame())
  encl_env[["self"]] <- bind_env
  mbs <- list(...)
  # TODO: check named
  for (i in seq_along(mbs)) {
    if (is.function(mbs[[i]])) {
      environment(mbs[[i]]) <- encl_env
    }
    bind_env[[names(mbs)[i]]] <- mbs[[i]]
  }
  class(bind_env) <- cls
  bind_env
}
