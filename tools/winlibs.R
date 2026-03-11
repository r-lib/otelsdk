if (
  !file.exists("windows/protobuf/protobuf/include/google/protobuf/descriptor.h")
) {
  unlink("windows/protobuf", recursive = TRUE, )
  url <- "https://github.com/rwinlib/protobuf/archive/v21.12.tar.gz"
  download.file(url, basename(url), quiet = TRUE)
  dir.create("windows/protobuf", showWarnings = FALSE, recursive = TRUE)
  untar(basename(url), exdir = "windows/protobuf", tar = 'internal')
  unlink(basename(url))
  setwd("windows/protobuf")
  file.rename(list.files(), 'protobuf')
  file.rename("protobuf/lib", "protobuf/lib-10.4.0")
  invisible()
}

# libcurl is not needed on R 4.2.0, because Rtools42 has it
if (
  getRversion() < "4.2.0" &&
    !file.exists("windows/libcurl/libcurl/include/curl/curl.h")
) {
  unlink("windows/libcurl", recursive = TRUE)
  url <- "https://github.com/rwinlib/libcurl/archive/v7.84.0.tar.gz"
  download.file(url, basename(url), quiet = TRUE)
  dir.create("windows/libcurl", showWarnings = FALSE, recursive = TRUE)
  untar(basename(url), exdir = "windows/libcurl", tar = 'internal')
  unlink(basename(url))
  setwd("windows/libcurl")
  file.rename(list.files(), 'libcurl')
  file.rename("libcurl/lib", "libcurl/lib-10.4.0")
  invisible()
}
