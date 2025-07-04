% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/record.R
\name{with_otel_record}
\alias{with_otel_record}
\title{Record OpenTelemetry output, for testing purposes}
\usage{
with_otel_record(expr, provider_args = list(), what = c("traces"))
}
\arguments{
\item{expr}{Expression to evaluate.}

\item{provider_args}{A list of arguments to pass to the in-memory
OpenTelemetry trace provider.}

\item{what}{Character vector, type(s) of OpenTelemetry output to collect.
Currently only \code{"traces"} is supported.}
}
\value{
A list with the output for each output type. Currently only
contains \code{traces}.
}
\description{
You can use this function to test the OpenTelemetry output is
correctly generated for your package or application.
}
\details{
It evaluates the supplied expression, collects OpenTelemetry output
from it and returns it.
}
