
context("Test high-level functions for equal sized clustering and anticlustering")
library("anticlust")

test_that("high level equal sized clustering function runs through", {
  conditions <- expand.grid(m = 1:4, p = 2:4)
  for (k in 1:nrow(conditions)) {
    m_features <- conditions[k, "m"]
    n_clusters <- conditions[k, "p"]
    n_elements <- n_clusters * 5 # n must be multiplier of p
    features <- matrix(rnorm(n_elements * m_features), ncol = m_features)
    clusters_exact <- balanced_clustering(features, K = n_clusters, method = "ilp",
                                          standardize = FALSE)
    clusters_heuristic <- balanced_clustering(features, K = n_clusters,
                                              method = "sampling", standardize = FALSE)
    ## Check that output is valid
    expect_equal(legal_number_of_clusters(features, clusters_exact), NULL)
    expect_equal(legal_number_of_clusters(features, clusters_heuristic), NULL)

    ## Assert that exact solution has lowest objective (for distance
    ## criterion), allowing for numeric imprecision of ILP solver
    obj_exact     <- obj_value_distance(clusters_exact, features)
    obj_heuristic <- obj_value_distance(clusters_heuristic, features)
    expect_equal(round(obj_exact, 10) <= round(obj_heuristic, 10), TRUE)
  }
})


test_that("high level anticlustering function runs through", {
  conditions <- expand.grid(m = 1:4, p = 2:3)
  for (k in 1:nrow(conditions)) {
    m_features <- conditions[k, "m"]
    n_clusters <- conditions[k, "p"]
    n_elements <- n_clusters * 3 # n must be multiplier of p
    features <- matrix(rnorm(n_elements * m_features), ncol = m_features)
    anticlusters_exact <- anticlustering(features, K = n_clusters,
                                         method = "ilp",
                                         standardize = FALSE,
                                         preclustering = FALSE)
    anticlusters_heuristic <- anticlustering(features,
                                             K = n_clusters,
                                             method = "sampling",
                                             standardize = FALSE,
                                             nrep = 5)
    ## Check that output is valid
    expect_equal(legal_number_of_clusters(features, anticlusters_exact), NULL)
    expect_equal(legal_number_of_clusters(features, anticlusters_heuristic), NULL)
    ## Assert that exact solution has highest objective (for distance
    ## criterion), allowing for numeric imprecision of ILP solver
    obj_exact     <- obj_value_distance(anticlusters_exact, features)
    obj_heuristic <- obj_value_distance(anticlusters_heuristic, features)
    expect_equal(round(obj_exact, 10) >= round(obj_heuristic, 10), TRUE)
  }
})


test_that("all argument combinations run through", {
  conditions <- expand.grid(preclustering = c(TRUE, FALSE),
                            method = c("ilp", "sampling", "exchange"))
  # Set up matrix to store the objective values obtained by different methods
  storage <- matrix(ncol = 3, nrow = 2)
  colnames(storage) <- c("ilp", "sampling", "exchange")
  rownames(storage) <- c("preclustering", "no_preclustering")

  criterion <- "distance"
  n_elements <- 12
  features <- matrix(rnorm(n_elements * 2), ncol = 2)
  n_anticlusters <- 2

  for (i in 1:nrow(conditions)) {
    method <- conditions$method[i]
    preclustering <- conditions$preclustering[i]
    anticlusters <- anticlustering(features, K = n_anticlusters,
                                   objective = criterion,
                                   method = method,
                                   preclustering = preclustering,
                                   standardize = FALSE)
    obj <- obj_value_distance(anticlusters, features)
    rowname <- ifelse(preclustering, "preclustering", "no_preclustering")
    storage[rowname, method] <- obj
  }
  ## Exact solution must be best:
  expect_equal(all(round(storage["no_preclustering", "ilp"], 10) >= round(c(storage), 10)), TRUE)
})
