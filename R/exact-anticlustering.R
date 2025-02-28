
#' Solve balanced K-anticluster editing exactly using ILP
#'
#' @param features A N x M matrix of item features
#' @param distances A N x N matrix representing the
#'     pairwise dissimilarities between all N elements. CAN an be an
#'     object of class \code{dist}.
#' @param K How many anticlusters should be created.
#' @param solver A string identifying the solver to be used ("glpk",
#'     "gurobi", or "cplex")
#' @param standardize Boolean - should the feature values be
#'     standardized before groups are created?
#' @param preclustering Boolean, should a preclustering be conducted
#'     before anticlusters are created.
#'
#' @return A vector representing the anticluster affiliation of
#'     elements.
#'
#' @noRd

exact_anticlustering <- function(features, distances, K, solver, preclustering) {

  ## If needed, convert features to Euclidean distance
  if (argument_exists(features)) {
    distances <- dist(features)
  }
  distances <- as.matrix(distances)
  n_items <- nrow(distances)

  if (preclustering == TRUE) {
    ilp <- anticlustering_ilp(distances, n_items / K,
                              solver = solver)
    solution <- solve_ilp(ilp, solver, "min")
    preclusters <- ilp_to_groups(ilp, solution)
    ## Fix distances - ensures that the most similar items are assigned
    ## to different groups
    distances <- edit_distances(distances, preclusters)
    ## Edit ILP - objective function and group sizes
    ilp$obj_function <- vectorize_weights(distances)$costs
    ilp$rhs <- c(rep(1, choose(n_items, 3) * 3),
                 rep((n_items / K) - 1, n_items))
    ## Solve edited ILP
    solution <- solve_ilp(ilp, solver)
    assignment <- ilp_to_groups(ilp, solution)
    return(assignment)
  }

  ## Here the ILP is created without adjusting distances; i.e., true
  ## exact anticlustering
  ilp <- anticlustering_ilp(distances, K, solver = solver)
  solution <- solve_ilp(ilp, solver)
  ilp_to_groups(ilp, solution)
}
