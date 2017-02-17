#' Example spatial models of Tanzania mobile survey data with gridded covariates
#' M. Walsh & A. Verlinden, February 2017

# Required packages
# install.packages(c("devtools","caret","raster","glmnet","randomForest","doParallel")), dependencies=TRUE)
suppressPackageStartupMessages({
  require(devtools)
  require(caret)
  require(raster)
  require(glmnet)
  require(randomForest)
  require(doParallel)
})

# Data setup --------------------------------------------------------------
# Run this first: https://github.com/mgwalsh/Training/blob/master/TZ_training_data.R
# or run ...
# SourceURL <- "https://github.com/mgwalsh/Training/blob/master/TZ_training_data.R"
# source_url(SourceURL)

# Data setup --------------------------------------------------------------
# Select labels
PAt <- mob_cal$MZP
PAv <- mob_val$MZP

# Features
grdt <- mob_cal[8:33] ## gridded variables for model calibration
grdv <- mob_val[8:33] ## gridded variables for model validation

# Fit glmnet model --------------------------------------------------------
# Start doParallel to parallelize model fitting
mc <- makeCluster(detectCores())
registerDoParallel(mc)

# Control setup
set.seed(1385321)
tc <- trainControl(method = "repeatedcv", repeats=5, classProbs = TRUE, summaryFunction = twoClassSummary,
                   allowParallel = T)

# Fit glmnet model
mob.glm <- train(grdt, PAt,
                 preProc = c("center", "scale"),
                 method = "glmnet",
                 family = "binomial",
                 metric = "ROC",
                 trControl = tc)
print(mob.glm)
mob.imp <- varImp(mob.glm)
plot(mob.imp, top=25, col="black", cex=1.3, xlab="Variable importance", cex.lab=1.5)
mob_glm <- predict(grids, mob.glm, type="prob") ## spatial predictions
plot(1-mob_glm, axes=F) ## probaility map plot

stopCluster(mc)

# Fit randomForest model --------------------------------------------------
# Start doParallel to parallelize model fitting
mc <- makeCluster(detectCores())
registerDoParallel(mc)

# Control setup
set.seed(1385321)
tc <- trainControl(method = "cv", classProbs = TRUE, summaryFunction = twoClassSummary,
                   allowParallel = T)

# Fit randomForest model
mob.rf <- train(grdt, PAt,
                preProc = c("center", "scale"),
                method = "rf",
                family = "binomial",
                metric = "ROC",
                trControl = tc)
print(mob.rf)
mob.imp <- varImp(mob.rf)
plot(mob.imp, top=25, col="black", cex=1.3, xlab="Variable importance", cex.lab=1.5)
mob_rf <- predict(grids, mob.rf, type="prob") ## spatial predictions
plot(1-mob_rf, axes=F) ## probaility map plot
