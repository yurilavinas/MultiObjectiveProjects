library(MOEADr)
library(emoa)
library(ggplot2)
#setwd(dirname(rstudioapi::getSourceEditorContext()$path))

source("../../functions/problems_definitions/MOON.R")

source("../../functions/updt_standard_save.R")
source("../../functions/constraint_dynamic.R")
source("../../functions/constraint_multistaged.R")
source("../../functions/constraint_selfadapting.R")
source("../../functions/constraint_unfeasible_exploration.R")

# Creating the output directory if necessary
if (!file.exists("output")){
  dir.create("output")
} 

# Characteristics of the problem
n_variables = 2
n_objectives = 3
n_constraints = 2

# Parameters for execution
n_individuals = 25 #25 -> 325
n_iterations = 100
n_runs = 21

# Creating Variable Bounds
maximum = c(1, 1)
minimum = c(0, 0)

problem.1 <- list(name       = "problem.moon",  # Function that executes the MOP
                  xmin       = minimum,    # minimum parameter value for each dimension
                  xmax       = maximum,     # maximum parameter value for each dimension
                  constraints = list(name = "my_constraints"),
                  m          = n_objectives)              # Number of objectives

## 1 - Decomposition
decomp <- list(name = "SLD",H = 23) 

## 2 - Neighbors
neighbors <- list(name    = "lambda",
                  T       = floor(300*0.2), #Size of the neighborhood
                  delta.p = 0.471) #Probability of using the neighborhood

## 3 - Aggregation function
aggfun <- list(name = "wt")

## 4 - Update strategy
update <- list(name = "standard_save")

## 5 - Scaling
scaling <- list(name = "simple")

## 6 - Stop criterion
stopcrit  <- list(list(name  = "maxiter",
                       maxiter  = n_iterations))

## 7 - Variation Operators
variation <- list(list(name  = "sbx",
                       etax  = 74, pc = 0.65),
                  list(name  = "polymut",
                       etam  = 26, pm = 0.15 ),
                  list(name  = "truncate"))

## 8 - Show
showpars  <- list(show.iters = "dots",
                  showevery  = 5)

## 9 - Constraint
constraint<- list(name = "unfeasible_exploration",
                  penalties = c(0,1,1000))

## 10 - Execution
hyper = rep(0,n_runs)
hyperteste = rep(0,n_runs)
besthyper = -1
for (i in 1:n_runs){
  file.create(sprintf("output/MyArchive%d.txt",i)) 
  results <- moead(problem  = problem.1,
                   decomp = decomp,
                   neighbors = neighbors,
                   aggfun = aggfun,
                   scaling = scaling,
                   constraint = constraint,
                   stopcrit = stopcrit,
                   update = update,
                   variation = variation,
                   showpars = showpars,
                   seed     = floor(runif(1)*1000))
  
  # Calculate the hypervolume only with feasible points
  # No feasible solutions
  if(max(results$V$v == 0) == 0){
    hyper[i] = 0
  }
  # At least one feasible solution
  else{
    hyper[i] = dominated_hypervolume(t(results$Y[which(results$V$v == 0),]), (c(1,0,1)))
    cat("Iteration: ", i,"Hyper: ", hyper[i])
  }
}