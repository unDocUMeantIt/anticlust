
context("Categorical constraints")
library("anticlust")

test_that("categorical constraints are met for one categorie (vector input)", {
  N <- 60
  M <- 2
  features <- matrix(rnorm(N * M), ncol = M)
  ## iterate over number of categories & number of anticlusters
  for (K in 2:4) {
    for (C in 2:4) {
      categories <- sample(rep_len(1:C, N))
      ac <- anticlustering(features, K = K, categories = categories, method = "sampling", nrep = 1)
      tab <- table(categories, ac)
      ## At most 1 deviation between categories in anticlusters
      expect_equal(all(abs(tab - tab[[1]]) <= 1), TRUE)
    }
  }
})


## The following test assumes that the categorical variables are
## balanced (otherwise testing is hard)

test_that("categorical constraints are met for two categories (data.frame or matrix input)", {
  M <- 2
  ## iterate over number of categories & number of anticlusters
  for (K in 2:3) {
    for (C1 in 2:3) {
      for (C2 in 2:3) {
        ## 1. Choose appropriate N that allows for a balanced assignment
        N <- (K * C1 * C2)^2
        features <- matrix(rnorm(N * M), ncol = M)
        ## 2. Ensure that the categories are actually balanced
        categories1 <- sort(rep_len(1:C1, N))
        categories2 <- categorical_sampling(categories1, K)
        frame_together <- ifelse(sample(2, size = 1) <= 2, data.frame, cbind)
        categories <- frame_together(categories1, categories2)
        ## Random order to cath potential problem in the implementation
        ## that might be due to a reliance on sorted input (We don't
        ## want that)
        categories <- categories[sample(nrow(categories)), ]
        vectorized_categories <- factor(do.call(paste0, as.list(categories)))
        ## Critical test: did it work to create balanced groups?
        tab <- table(vectorized_categories)
        expect_equal(all(tab == tab[[1]]), TRUE)


        ## 3. Are the categories balanced across anticlusters?
        ac <- anticlustering(features, K = K, categories = categories, method = "sampling", nrep = 10)
        tab1 <- table(categories[, 1], ac)
        tab2 <- table(categories[, 2], ac)
        tab3 <- table(categories[, 1], categories[, 2], ac)
        ## At most 1 deviation between categories in anticlusters
        expect_equal(all(abs(tab1 - tab1[[1]]) <= 1), TRUE)
        expect_equal(all(abs(tab2 - tab2[[1]]) <= 1), TRUE)
        expect_equal(all(abs(tab3 - tab3[[1]]) <= 1), TRUE)
      }
    }
  }
})
