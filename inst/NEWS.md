
# anticlust 0.2.9-4

2019-07-23

Internal change: Optimizing the exchange method with the default 
distance objective is now much faster. This is accomplished 
by only updating the sum of distances after each exchange, instead of 
recomputing all distances (see 
  [d51e59d](https://github.com/m-Py/anticlust/commit/d51e59d56d2d4b679db6a7969f5a5c71ac0d4438))

This example illustrates the run time improvement:

```R
# For N = 20 to N = 300, test run time for old and new 
# optimization of distance criterion:

n <- seq(20, 300, by = 20)
times <- matrix(nrow = length(n), ncol = 4)
times[, 1] <- n
colnames(times) <- c("n", "old_features_input", "old_distance_input", "new_distance")

for (i in seq_along(n)) {
  start <- Sys.time()

  # Simulate 2 features as input data
  data <- matrix(rnorm(n[i] * 2), ncol = 2)

  ## Old version: feature table as input
  ac1 <- anticlustering(
    data,
    K = rep_len(1:2, nrow(data)),
    objective = anticlust:::obj_value_distance
  )
  times[i, "old_features_input"] <- difftime(Sys.time(), start, units = "s")

  ## Old version: distance matrix as input
  ac2 <- anticlustering(
    dist(data),
    K = rep_len(1:2, nrow(data)),
    objective = anticlust:::distance_objective_
  )
  times[i, "old_distance_input"] <- difftime(Sys.time(), start, units = "s")

  start <- Sys.time()
  ac3 <- anticlustering(
    data,
    K = rep_len(1:2, nrow(data)),
    objective = "distance"
  )
  times[i, "new_distance"] <- difftime(Sys.time(), start, units = "s")

  ## Ensures that all methods have the same output
  stopifnot(all(ac1 == ac2))
  stopifnot(all(ac1 == ac3))
}

round(times, 2)

#         n old_features_input old_distance_input new_distance
#  [1,]  20               0.08               0.12         0.01
#  [2,]  40               0.26               0.50         0.03
#  [3,]  60               0.72               1.36         0.10
#  [4,]  80               1.07               2.62         0.22
#  [5,] 100               1.81               4.98         0.46
#  [6,] 120               3.84              11.17         0.82
#  [7,] 140               3.72              13.17         1.33
#  [8,] 160               5.20              20.65         2.16
#  [9,] 180               7.30              31.48         2.44
# [10,] 200               8.63              37.96         3.38
# [11,] 220              10.97              53.26         4.80
# [12,] 240              13.78              74.17         6.66
# [13,] 260              17.49             106.81         8.43
# [14,] 280              20.40             149.38        12.23
# [15,] 300              27.21             178.46        15.20
```

As shown in the code and in the output table, two different 
objective functions could be called when the exchange algorithm was
employed, depending on the input: When a feature table was passed, 
the internal function `anticlust:::obj_value_distance` was called
in each iteration of the exchange algorithm; 
When a distance matrix was passed, the internal function 
`anticlust:::distance_objective_` was called
in each iteration of the exchange algorithm. The former function 
computes all between-element distances within each set and returns their sum
(using the `R` functions `by`, `dist`, `sapply` and `sum`). The latter 
function stores all distances and will index the relevant distances and
return their sum. Interestingly, this indexing approach was a lot slower
than recomputing all distances every iteration in the exchange algorithm. 

In the new version, there no longer is a difference between a feature 
and distance input; in both cases, the sum of distances is updated 
based on only the relevant columns/rows in a distance matrix (that means, 
in each iteration of the exchange method, 4 rows/columns need
to be investigated, independent of N). The new approach is 
a lot faster and especially benefial when we pass distance as input. 

# anticlust 0.2.9-3

2019-07-22

New feature:

- There is now an argument `iv` for the function `anticlustering()`. 
  It can be used for »min-max anticlustering«; `iv` then contains
  numeric features (vector, matrix or data frame) whose values are made 
  dissimilar between sets -- as opposed to the usual anticlustering 
  where all features are made similar. See `?schaper2019` for an example.

# anticlust 0.2.9-2

2019-07-18

New features: 

- In the `anticlustering()` function, the argument `K` can now be a vector that
  serves as the initiation of the anticlusters (This functionality is only 
  available when `method = "exchange"`).
    +  Subset selection is now possible. Subset selection means that 
      not all input item are assigned to a set, but from the total input
      a subset is selected that is assigned to the different sets. 
      This functionality is enabled by passing a initial cluster 
      assignment via the argument `K` that contains some `NA` (For example, 
      if N = 50 and two sets of 20 items should be created, the argument 
      `K` will contain 10 elements that are `NA`, 20 times 1, and 20 
      times 2.)
    + By using a customized `K` as input, it is now also possible to 
      create sets of different size (e.g. `K = c(1, 1, 1, 1, 2, 2)`)
    + The function `initialize_K()` can be used to generate initial 
      anticluster assignments in a user-friendly way. The 
      documentation of the function `initialize_K()` contains example
      code how to conduct subset selection and anticlustering with 
      different set sizes.
- A new objective function was added: `mean_sd_obj()`. 
  Maximizing this objective will simply make all sets similar with regard
  to the mean, median and the standard deviation of all input features.

Internal changes:

- Major internal restructuring to improve the expected maintainability in the 
  future. In the last weeks, a lot of features were added to `anticlust` and
  a restructuring seemed necessary. 
- Many test cases were added to test the features that were added in the previous weeks.
- To accommodate the possibility that the argument `K` contains `NA`, 
  the objective function to be optimized will be restructured internally. 
  In particular, before the objective is computed, all cases are removed 
  where the cluster is `NA` (i.e., cases that are currently not assigned 
  to any set). This also works for user-defined objective functions, so
  users do not need to deal with the handling of `NA` themselves.


# anticlust 0.2.9

2019-07-09

- A bug was fixed that led to an incorrect computation of the objective 
  function for anticluster editing when employing the exchange method (see 
  [243ca64](https://github.com/m-Py/anticlust/commit/243ca642be787e8c59ece4dbbb1b567fdac05656)). 
  Tests show that the exchange method now outperforms random sampling
  for anticluster editing (as well as for k-means anticlustering). 
  Therefore, the exchange method is now the default method 
  (see [b101073](https://github.com/m-Py/anticlust/commit/b101073602906b6b9bbf00c76943668f43407e0e)).
- The fast exchange method is now used when optimizing the variance 
  criterion in a call to `anticlustering()`. This improves run time by 
  a large margin for this important application. See [2f47fea](https://github.com/m-Py/anticlust/commit/2f47feaf05aee1d53b60bf78bb7c02994a4659c9).
- Two changes with regard to the functionality of arguments in `anticlustering()`
    + It is possible that the argument `objective` now takes as input a 
      function. The passed function has to take two arguments,
      the first being a cluster assignment vector (such as returned by 
      `anticlustering()`), the second being the data the objective is 
      computed on (e.g. an N x M matrix where rows are elements and 
      columns are features). Larger return values must indicate a 
      better objective as the objective is maximized with the existing 
      methods (exchange method and random sampling). This functionality 
      makes it possible for users to implement
      their own operationalization of set similarity.
    + It is possible that the argument `preclustering` now takes as input
      a preclustering vector and not only `TRUE` or `FALSE` (in the former 
      case, the preclustering vector has been computed within the 
      `anticlustering()` function). This allows for more flexibility 
      in combining preclustering and anticlustering methods. For 
      example, it is now possible to conduct optimal preclustering using 
      integer linear programming with the function `balanced_clustering()`,
      and then use a heuristic anticlustering method that incorporates this 
      preclustering.
    + Both of these changes have not yet been added to the function 
      documentation as they require some more testing.
- The `fast_anticlustering()` function has been documented more
  thoroughly and part of the `anticlustering()` docs have been reworked
  (now advocating the exchange method as the preferable option).

# anticlust 0.2.8

2019-07-05

A new exported function is available: `fast_anticlustering()`. As the 
name suggests, it is optimized for speed and particularly useful for large 
data sets (many thousand elements). It uses the k-means variance 
objective because computing all pairwise distances for the cluster 
editing objective becomes computationally infeasible for large data
sets. Additionally, it employs a speed-optimized exchange method. 
The number of exchange partners can be adjusted using the argument 
`k_neighbours`. Fewer exchange partners make it possible to apply the
`fast_anticlustering()` function to very large data sets. The default
value for `k_neighbours` is `Inf`, meaning that in the default case, 
each element is swapped with all other elements.

# anticlust 0.2.7

2019-07-01

A big update:

- A new algorithm for anticlustering is available: the exchange method.
  Building on an initial random assignment, elements are swapped between 
  anticlusters in such a way that each swap improves anticluster similarity by 
  the largest amount that is possible (cf. Späth, 1986).
  This procedure is repeated for each element; because each 
  possible swap is investigated for each element, the total number of 
  exchanges grows quadratically with input size, rendering the exchange 
  method unsuitable for large N. Setting `preclustering = TRUE` will 
  limit the legal exchange partners to very similar elements, resulting 
  in improved run time while preserving a rather good solution.
  The exchange method outperforms the random sampling heuristic for k-means 
  anticlustering. The exchange method may incorporate
  both categorical and preclustering constraints, which is not possible
  for the random sampling approach. As there are now two heuristic 
  methods (random sampling and exchange) 
  the argument `method` of the function `anticlustering()`
  now has the following three possible values: "sampling", "exchange", 
  "ilp". In earlier versions, the two options were "heuristic" and "ilp"; 
  this change does not break earlier code because using 
  `method = "heuristic"` will still refer to the random sampling method.
- A new function `generate_partitions` can be used to generate all
  partitions, making it possible to solve anticlustering via complete
  enumeration. In particular, it is now possible---for small
  problem instances---to solve k-means anticlustering optimally, which
  cannot be done with integer linear programming.  The help file 
  (`?generate_partitions`) contains example code illustrating how to do 
  this.

Minor changes:

- The "variance" criterion can now be computed when there are missing 
  values in the input data.
- In `plot_clusters`, it is now possible to adjust the size of the 
  cluster centroid using the new argument `cex_centroid`
  

# anticlust 0.2.6

2019-06-19

Minor update: `plot_clusters` now has an additional argument 
`illustrate_variance`. If this argument is set to `TRUE`, a cluster
solution is illustrated with the k-means variance criterion.

# anticlust 0.2.5

2019-05-27

The new version of anticlust now enables parallelization of the random 
sampling method, improving run time.

- The `anticlustering` function now has an additional argument 
  (`parallelize`) that can be used to activate parallel computation 
  when using the heuristic method
- For now, the default value of `parallelize` is `FALSE`
- Another argument was added (`seed`) to make the random sampling method 
  reproducible
    + Just using `set.seed()` prior to the computation does not make 
    a function call reproducible when `parallelize` is `TRUE` 
    because each core has its own random seed
    + The `seed` argument is optional

An example data set is now included with the package, courteously 
provided by Marie Lusia Schaper and Ute Bayen. For details, see 
`?schaper2019`.

# anticlust 0.2.4

2019-04-26

The new version of anticlust includes support for constraints induced 
by grouping variables. 

- The `anticlustering` function now has an optional argument (`categories`)
  that can be used to induce categorical constraints
- `categories` can be a vector if there is is one grouping variable or 
  a matrix/data if there is more than one grouping variable
- Currently, `categories` can only be used with the random sampling 
  method (`method = "heuristic"`)
- `categories` overrides the value of `preclustering`; it is not 
  possible to use categorical and preclustering constraints at the same
  time

In `anticlustering`, the default value of `preclustering` is now FALSE.
