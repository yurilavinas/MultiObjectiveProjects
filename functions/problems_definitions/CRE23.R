#Objective1
Objective1 <- function(X){
  
  x1 = X[1]
  x2 = X[2]
  x3 = X[3]
  x4 = X[4]
  
  obj1 = matrix(4.9 * 1e-5 * (x2 * x2 - x1 * x1) * (x4 - 1.0), ncol = 1)
  obj1
}

#Objective2
Objective2 <- function(X){
  
  x1 = X[1]
  x2 = X[2]
  x3 = X[3]
  x4 = X[4]
  
  obj2 = matrix(((9.82 * 1e6) * (x2 * x2 - x1 * x1)) / (x3 * x4 * (x2 * x2 * x2 - x1 * x1 * x1)), ncol = 1)
  obj2
}

#Definition of the problem
problem.cre23 <- function(X) {
  t(apply(X, MARGIN = 1,
          FUN = function(X) { c(Objective1(X), Objective2(X)) }
  ))
}

my_constraints <- function(X)
{
  nv <- n_variables # number of variables
  # Prepare output matrix of constraint function values
  Cmatrix <- matrix(numeric(),
                    nrow = nrow(X),
                    ncol = 2 * nv + n_constraints) 
  
  colnames(Cmatrix) <- c(paste0("x",
                                rep(1:nv, times = 2),
                                rep(c("min","max"), each = nv)),
                         paste0("g",
                                rep(1:n_constraints, times = 1)))
  
  # Box limits of the feasible space
  Xmin <- matrix(minimum, ncol = n_variables, nrow = nrow(X), byrow = TRUE)
  Xmax <- matrix(maximum, ncol = n_variables, nrow = nrow(X), byrow = TRUE)
  
  # Calculate "x_i >= 0" and "x_i <= 1" constraints
  Cmatrix[, 1:nv]              <- Xmin - X
  Cmatrix[, (nv + 1):(2 * nv)] <- X - Xmax
  
  g1 <- function(X){
    constraints = matrix(0,nrow = n_individuals, ncol = n_constraints)
    
    x1 = X[,1]
    x2 = X[,2]
    x3 = X[,3]
    x4 = X[,4]
    
    constraints[,1] = (x2 - x1) - 20.0;
    constraints[,2] = 0.4 - (x3 / (3.14 * (x2^2- x1^2)));
    constraints[,3] = 1.0 - (2.22 * 1e-3 * x3 * (x2^3 - x1^3)) / ((x2^2 - x1^2)^2);
    constraints[,4] = (2.66 * 1e-2 * x3 * x4 * (x2^3 - x1^3)) / (x2^2 - x1^2) - 900.0;
    
    constraints = ifelse(constraints < 0, -constraints, 0)
    return(constraints)
  }
  
  # Calculate g1(x)
  Cmatrix[, (2*nv + 1):(2*nv + n_constraints)] <- g1(X)
  
  # Assemble matrix of *violations*
  Vmatrix <- Cmatrix
  
  # Inequality constraints
  Vmatrix[, 1:(2 * nv + n_constraints)] <- pmax(Vmatrix[, 1:(2 * nv + n_constraints)], 0)        
  
  # Scaling the violations
  v = rowSums(Vmatrix)  
  # Before the first generation when there is no incubent solutions to scale yet
  if(is.null(parent.frame(2)$iter)){
    v[which(v != 0)] = (v[which(v != 0)] - min(v))/(max(v) - min(v)) + 0.000001
  }
  # Case of all other generations
  else{
    e = parent.frame(2)
    Vtmatrix = e$Vt$Vmatrix
    vt = rowSums(Vtmatrix)
    e$Vt$v[which(vt != 0)] = (vt[which(vt != 0)] - min(v,vt))/(max(v,vt) - min(v,vt)) + 0.000001
    v[which(v != 0)] = (v[which(v != 0)] - min(v,vt))/(max(v,vt) - min(v,vt)) + 0.000001
  }
  
  # Return necessary variables
  return(list(Cmatrix = Cmatrix,
              Vmatrix = Vmatrix,
              v       = v))
}