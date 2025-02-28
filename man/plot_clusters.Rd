% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/plotting.R
\name{plot_clusters}
\alias{plot_clusters}
\title{Visualize a cluster analysis}
\usage{
plot_clusters(features, clustering, within_connection = FALSE,
  between_connection = FALSE, illustrate_variance = FALSE,
  show_axes = FALSE, xlab = NULL, ylab = NULL, xlim = NULL,
  ylim = NULL, col = NULL, pch = 19, main = "", cex = 1.2,
  cex.axis = 1.2, cex.lab = 1.2, lwd = 1.5, lty = 2,
  frame.plot = FALSE, cex_centroid = 2)
}
\arguments{
\item{features}{A data.frame or matrix representing the features that
are plotted. Must have two columns.}

\item{clustering}{A vector representing the clustering}

\item{within_connection}{Boolean. Connect the elements within each
clusters through lines? Useful to illustrate a graph structure.}

\item{between_connection}{Boolean. Connect the elements between each
clusters through lines? Useful to illustrate a graph structure.
(This argument only works for two clusters).}

\item{illustrate_variance}{Boolean. Illustrate the variance criterion
in the plot?}

\item{show_axes}{Boolean, display values on the x and y-axis? Defaults
to `FALSE`.}

\item{xlab}{The label for the x-axis}

\item{ylab}{The label for the y-axis}

\item{xlim}{The limits for the x-axis}

\item{ylim}{The limits for the y-axis}

\item{col}{The coloring of the groups, optional argument. If this
argument is passed, it needs to be a #' character vector of the
same length as there are clusters, and each element of the vector
is a color.}

\item{pch}{A numeric vector representing the symbol used to plot
data points (see \code{\link{par}}). Should either be of length 1,
then the same symbol is used for all plots, or should have the
same length as there are different clusters. In the latter case,
each cluster has a different plotting symbol.}

\item{main}{The title of the plot}

\item{cex}{The size of the plotting symbols, see \code{\link{par}}}

\item{cex.axis}{The size of the values on the axes}

\item{cex.lab}{The size of the labels of the axes}

\item{lwd}{The width of the lines connecting elements.}

\item{lty}{The line type of the lines connecting elements
(see \code{\link{par}}).}

\item{frame.plot}{a logical indicating whether a box should be drawn
around the plot.}

\item{cex_centroid}{The size of the cluster center symbol (has an
effect only if \code{illustrate_variance} is \code{TRUE})}
}
\description{
Visualize a cluster analysis
}
\details{
In most cases, the argument `clustering` is a vector
  returned by one of the functions \code{\link{anticlustering}} or
  \code{\link{balanced_clustering}}. However, the plotting function
  can also be used to plot the results of other cluster functions
  such as \code{\link{kmeans}}.
}
\examples{

n_elements <- 9
features <- matrix(runif(n_elements * 2), ncol = 2)
n_groups <- 3
clusters <- balanced_clustering(features, K = n_groups)
anticlusters <- anticlustering(features, K = n_groups, method = "sampling")
par(mfrow = c(1, 2))
plot_clusters(features, clusters, pch = c(15, 16, 17), main = "Cluster editing")
plot_clusters(features, anticlusters, pch = c(15, 16, 17), main = "Anticluster editing")

}
