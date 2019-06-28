# anticlust

`anticlust` is an `R` package for »anticlustering«, a method to assign
elements to sets in such a way that the sets are as similar as possible
(Späth 1986; Valev 1998). The package `anticlust` was originally
developed to assign items to experimental conditions in experimental
psychology, but it can be applied whenever sets that are similar to each
other are desired. Currently, the `anticlust` package offers the
possibility to create similar sets of equal size.

## Installation

``` r
library("devtools") # if not available: install.packages("devtools")
install_github("m-Py/anticlust")
```

## Example

In the following example, I use the function `anticlustering()` to
create three sets from the iris data set:

``` r
# load the package via
library("anticlust")

# Optimize the variance criterion (create similar feature means)
anticlusters <- anticlustering(
  iris[, -5],
  K = 3,
  objective = "variance",
  method = "exchange",
  categories = iris[, 5]
)
## Look at the output: Per element in the iris data set, I obtain 
## a group affiliation:
anticlusters
#>   [1] 3 3 3 2 3 2 3 2 1 1 2 1 1 3 1 2 1 1 2 1 2 2 3 2 2 1 2 1 3 2 2 2 1 1 1
#>  [36] 3 3 3 3 1 3 1 3 2 2 1 2 3 1 3 3 3 1 3 3 1 2 3 1 3 1 1 2 1 2 3 3 3 2 3
#>  [71] 1 2 2 1 3 3 1 1 1 2 3 2 2 2 1 3 3 2 1 1 3 1 2 2 2 2 3 1 1 2 2 2 3 1 2
#> [106] 2 3 3 1 3 2 3 3 3 1 2 1 3 1 3 3 2 2 1 1 3 3 1 1 2 2 3 3 2 1 1 2 2 3 3
#> [141] 1 1 1 1 3 2 2 2 1 2

## Compare the feature means by anticluster:
by(iris[, -5], anticlusters, function(x) round(colMeans(x), 2))
#> anticlusters: 1
#> Sepal.Length  Sepal.Width Petal.Length  Petal.Width 
#>         5.84         3.06         3.76         1.20 
#> -------------------------------------------------------- 
#> anticlusters: 2
#> Sepal.Length  Sepal.Width Petal.Length  Petal.Width 
#>         5.85         3.06         3.76         1.20 
#> -------------------------------------------------------- 
#> anticlusters: 3
#> Sepal.Length  Sepal.Width Petal.Length  Petal.Width 
#>         5.84         3.06         3.76         1.20
```

## How do I learn about anticlustering

This page contains a quick start on how to employ anticlustering using
the `anticlust` package. So, you should start by simply continuing to
read. More information is available via the following sources:

1.  The R help. The main function of the package is `anticlustering()`
    and the help page of the function (`?anticlustering`) is useful to
    learn more about anticlustering. It provides explanations of all
    function parameters and how they relate to the theoretical
    background of anticlustering.

2.  I created a repository on the [Open Science
    Framework](https://osf.io/cd5sr/) that includes materials for a
    better understanding of the anticlustering method. Currently, it
    contains the slides of a talk that I gave a the TeaP conference
    (Annual meeting of Experimental Psychologists) in London in April,
    2019. The slides can be retrieved [here](https://osf.io/jbthk/);
    they contain a visual illustration of the anticlustering method and
    example code for different applications.

3.  There is a paper in preparation that will explain the theoretical
    background of the `anticlust` package in detail.

4.  If you have any question on the anticlustering method and the
    `anticlust` package, I encourage you to contact me via email
    (<martin.papenberg@hhu.de>) or
    [Twitter](https://twitter.com/MPapenberg) or to open an issue on
    this Github repository.

## A quick start

We can use the function `anticlustering()` to create similar sets of
elements. It takes as input a data table describing the elements that
should be assigned to sets. In the data table, each row represents an
element, for example a person, word or a photo. Each column is a numeric
variable describing one of the elements’ features. The table may be an R
`matrix` or `data.frame`; a single feature can also be passed as a
`vector`. The number of groups is specified through the argument `K`.

### The anticlustering objective

To measure set similarity, `anticlust` may employ one of two measures of
set similarity that have been developed in the context of cluster
analysis:

  - the k-means “variance” objective (Späth 1986; Valev 1998)
  - the cluster editing “distance” objective (Böcker and Baumbach 2013;
    Miyauchi and Sukegawa 2015; Grötschel and Wakabayashi 1989)

The k-means objective is given by the sum of the squared errors between
cluster centers and individual data points (Jain 2010). It was maximized
in the example above, making the average of each feature similar between
groups. The cluster editing objective is the sum of pairwise distances
within anticlusters. This way, the total similarity between items in
different sets is maximized, whereas the k-means variance objective
tends to concentrate on the mean values.

Maximizing either of the cluster editing or k-means objectives leads to
similar groups, i.e., anticlusters. Minimization of the same objectives
leads to a clustering, i.e., elements are as similar as possible within
a set and as different as possible between sets. Thus, anticlustering is
generally accomplished by maximizing the spread of the data in each
group, whereas clustering minimizes the spread. The following code
illustrates maximizing and minimizing both objectives:

``` r

features <- matrix(rnorm(20), ncol = 2)
anticlusters_dist <- anticlustering(
  features, 
  K = 2,
  method = "ilp",
  objective = "distance"
)
## anticlust can also be used for cluster analysis:
clusters_dist <- balanced_clustering( 
  features, 
  K = 2,
  method = "ilp",
  objective = "distance"
)

anticlusters_var <- anticlustering(
  features, 
  K = 2,
  method = "exchange",
  objective = "variance"
)
## anticlust can also be used for cluster analysis:
clusters_var <- balanced_clustering( 
  features, 
  K = 2,
  method = "heuristic",
  objective = "variance"
)

par(mfrow = c(2, 2))
plot_clusters(features, anticlusters_dist, within_connection = TRUE, xlab = "", ylab = "")
plot_clusters(features, clusters_dist, within_connection = TRUE, xlab = "", ylab = "")
plot_clusters(features, anticlusters_var, illustrate_variance = TRUE, xlab = "", ylab = "")
plot_clusters(features, clusters_var, illustrate_variance = TRUE, xlab = "", ylab = "")
```

<img src="inst/README_files/figure-gfm/unnamed-chunk-2-1.png" style="display: block; margin: auto;" />

To vary the objective function, we may change the parameter `objective`.
To apply anticluster editing, use `objective = "distance"`, which is
also the default. To maximize the k-means variance objective, set
`objective = "variance"`.

``` r

## Example code for varying the objective:
anticlustering(
  features, 
  K = 3, 
  objective = "distance"
)

anticlustering(
  features, 
  K = 3, 
  objective = "variance"
)
```

### Exact anticluster editing

Finding an optimal assignment of elements to sets that maximizes the
anticluster editing or variance objective is computationally demanding.
For anticluster editing, the package `anticlust` still offers the
possibility to find the best possible assignment, relying on [integer
linear programming](https://en.wikipedia.org/wiki/Integer_programming).
This exact approach employs a formulation developed by Grötschel and
Wakabayashi (1989), which has been used to rather efficiently solve the
cluster editing problem (Böcker, Briesemeister, and Klau 2011). To
obtain an optimal solution, a linear programming solver must be
installed on your system; `anticlust` supports the commercial solvers
[gurobi](https://www.gurobi.com/) and
[CPLEX](https://www.ibm.com/analytics/cplex-optimizer) as well as the
open source [GNU linear programming
kit](https://www.gnu.org/software/glpk/glpk.html). The commercial
solvers are generally faster. Researchers can install a commercial
solver for free using an academic licence. To use any of the solvers
from within `R`, one of the interface packages `gurobi` (is shipped with
the software gurobi),
[Rcplex](https://CRAN.R-project.org/package=Rcplex) or
[Rglpk](https://CRAN.R-project.org/package=Rglpk) must also be
installed.

To find the optimal solution, we have to set the arguments `method =
"ilp"`:

``` r
## Code example for using integer linear programming:
anticlustering(
  features, 
  K = 2, 
  method = "ilp",
  objective = "distance" # "variance" does not work with ILP method
)
```

### Preclustering

The exact integer linear programming approach will only work for small
problem sizes (maybe \<= 30 elements). We can increase the problem size
that can be handled by setting the argument `preclustering = TRUE`. In
this case, an initial cluster editing is performed, creating small
groups of elements that are very similar. The preclustering step
identifies pairs of similar stimuli if K = 2, triplets if K = 3, and so
forth. After this preclustering, a restriction is enforced to the
integer linear program that precludes very similar elements to be
assigned to the same set.

The preclustering restrictions improve the running time of the integer
linear programming solver by a large margin (often 100x as fast) because
many possible assignment are rendered illegal; the integer linear
programming solver is smart and disregards these assignments from the
space of feasible assignments. In some occasions, these restrictions
prohibit the integer linear programming solver to find the very best
partitioning (i.e., the assignment with the maximum distance /
variance), because this may be only obtained when some of the
preclustered elements are assigned to the same group. However, in
general, the solution is still very good and often optimal. This code
can be used to employ integer linear programming under preclustering
constraints.

``` r
## Code example using ILP and preclustering:
anticlustering(
  features, 
  K = 2, 
  method = "ilp", 
  objective = "distance",
  preclustering = TRUE
)
```

### Random search

To solve larger problem instances that cannot be processed using integer
linear programming, a heuristic method based on random sampling is
available. Across a user-specified number of runs (specified via the
argument `nrep`), each element is first randomly assigned to an
anticluster and then the objective value is computed. In the end, the
best assignment is returned as output. To activate the heuristic, set
`method = "sampling"` (this is also the default argument). When we set
`preclustering = TRUE`, the random assignment is conducted under the
restriction that preclustered elements cannot be part of the same
anticluster. In my experience, the preclustering restrictions often
improve the output of the random sampling approach, because the
preclustering itself serves as a useful heuristic: when very similar
items are guaranteed to be in different sets, these different sets tend
to become similar.

``` r
## Code example using random sampling
anticlustering(
  features, 
  K = 2, 
  method = "sampling",
  objective = "distance" 
)

## Random sampling may also use preclustering (this often improves the
## solution):
anticlustering(
  features, 
  K = 2, 
  method = "sampling",
  objective = "variance",
  preclustering = TRUE
)
```

## References

<div id="refs" class="references">

<div id="ref-bocker2013">

Böcker, Sebastian, and Jan Baumbach. 2013. “Cluster Editing.” In
*Conference on Computability in Europe*, 33–44. Springer.

</div>

<div id="ref-bocker2011">

Böcker, Sebastian, Sebastian Briesemeister, and Gunnar W Klau. 2011.
“Exact Algorithms for Cluster Editing: Evaluation and Experiments.”
*Algorithmica* 60 (2). Springer: 316–34.

</div>

<div id="ref-grotschel1989">

Grötschel, Martin, and Yoshiko Wakabayashi. 1989. “A Cutting Plane
Algorithm for a Clustering Problem.” *Mathematical Programming* 45
(1-3). Springer: 59–96.

</div>

<div id="ref-jain2010">

Jain, Anil K. 2010. “Data Clustering: 50 Years Beyond K-Means.” *Pattern
Recognition Letters* 31 (8). Elsevier: 651–66.

</div>

<div id="ref-miyauchi2015">

Miyauchi, Atsushi, and Noriyoshi Sukegawa. 2015. “Redundant Constraints
in the Standard Formulation for the Clique Partitioning Problem.”
*Optimization Letters* 9 (1). Springer: 199–207.

</div>

<div id="ref-spath1986">

Späth, H. 1986. “Anticlustering: Maximizing the Variance Criterion.”
*Control and Cybernetics* 15 (2): 213–18.

</div>

<div id="ref-valev1998">

Valev, Ventzeslav. 1998. “Set Partition Principles Revisited.” In *Joint
IAPR International Workshops on Statistical Techniques in Pattern
Recognition (SPR) and Structural and Syntactic Pattern Recognition
(SSPR)*, 875–81. Springer.

</div>

</div>
