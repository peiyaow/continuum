library(mlbench)
library(caret)
library(glmnet)
library(pls)
source("~/Documents/GitHub/continuum/function/function.R")
# source("~/continuum/simulation/function.R")

data(BostonHousing2)
num = c("lon", "lat", "crim", "zn", "indus", "chas", "nox", "rm", "age", "dis", "tax", "ptratio", "b", "lstat")  
cat = c("town", "chas", "rad")
X.num = BostonHousing2[num]
X.cat = apply(BostonHousing2[cat], 2, as.factor)

Y = BostonHousing2["cmedv"]
X = apply(as.matrix(X.num[, -(1:2)]), 2, as.numeric)
label = X.cat[, 3]
summary(X.cat)

X = X[label %in% c("24", " 5", " 4"),]
Y = as.matrix(Y[label %in% c("24", " 5", " 4"),])
label = label[label %in% c("24", " 5", " 4")]

# X = X[Y<=46,]
# label = label[Y<=46]
# Y = as.matrix(Y[Y<=46,])

n = dim(X)[1]
p = dim(X)[2]

for (i in 1:50){
  ix.train = unlist(createDataPartition(label, times = 1, p = 3/4))
  ix.test = (1:n)[-ix.train]
  ix.list = list(ix.train, ix.test)
  Y.list = lapply(1:2, function(x) Y[ix.list[[x]],]) # train,test
  X.list = lapply(1:2, function(x) X[ix.list[[x]],])
  label.list = lapply(1:2, function(x) label[ix.list[[x]]])
  
  X.train = X.list[[1]]
  X.test = X.list[[2]]
  Y.train = Y.list[[1]]
  Y.test = Y.list[[2]]
  label.train = label.list[[1]]
  label.test = label.list[[2]]
  n.train = nrow(X.train)
  n.test = nrow(X.test)
  
  ml.pls = plsr(Y.train ~ X.train, validation = "CV", scale = T)
  ml.pls$projection
  ml.ridge = cv.glmnet(x = X.train, y = scale(Y.train), alpha = 0)
  lambda = ml.ridge$lambda.min
  lambda.vec = ml.ridge$lambda
  haha = continuum.ridge.S0(X.train, scale(Y.train), lambda)
  hehe = continuum.ridge(X.train, Y.train, 0, 1/2)
  beta.C_S0 = C2beta(X.train, Y.train, haha[,1], lambda)$coef
  beta.C_ = C2beta(X.train, Y.train, hehe[,1], lambda)$coef
  ml.ridge = cv.glmnet(x = X.train, y = Y.train, alpha = 0)
  beta.ridge = matrix(coef(ml.ridge, s = "lambda.min"))
  
  continuum.res = cv.continuum.ridge(X.train, Y.train, lambda.vec, gamma = 0)
  beta.C_cv = C2beta(X.train, Y.train, continuum.res$C, continuum.res$lam)$coef
  
  print(c(mean((Y.test - cbind(1, X.test)%*%beta.C_S0)^2), mean((Y.test - cbind(1, X.test)%*%beta.C_)^2), mean((Y.test - cbind(1, X.test)%*%beta.C_cv)^2), mean((Y.test - cbind(1, X.test)%*%beta.ridge)^2)))
#  write.table(t(c(mean((Y.test - cbind(1, X.test)%*%beta.C)^2), mean((Y.test - cbind(1, X.test)%*%beta.glmnet)^2))), file = "MSE.csv", sep = ',', append = T, col.names = F, row.names = F)
  
}
