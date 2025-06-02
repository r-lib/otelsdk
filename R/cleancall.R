.Call <- call_with_cleanup <- function(ptr, ...) {
  base::.Call(cleancall_call, pairlist(ptr, ...), parent.frame())
}
