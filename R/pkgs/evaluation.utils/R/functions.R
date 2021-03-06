evaluation.utils.data_frame.sample <- NULL


#' A function that takes a data source, and runs a function on a sample of the data
#'
#' A dummy function to test package creation
#' @param data_frame
#' @param function the function to run on the sampled data frame
#' @param sample_ratio the sample to take out of the data
#' @param seed the seed for the sample
#' @keywords  evaluation
#' @export
#' @examples
#' run_on_sample(data_frame, str)
run_on_sample <- function(data_frame,
                          func,
                          sample_ratio = 0.6,
                          seed = 12239) {
  if(is.null(evaluation.utils.data_frame.sample)) {
    evaluation.utils.data_frame.sample <<- split_data(data_frame, sample_ratio, seed)
  }
  func(evaluation.utils.data_frame.sample)
}



#' A function that splits the data to training and test
#'
#' @param data_frame
#' @param training_ratio the sample to take out of the data. If an integer is passed, this will be the number of samples taken
#' @param seed the seed for the sample
#' @keywords  partitioning data
#' @export
#' @examples
#' split_data(data_frame)$train
#' split_data(data_frame)$test
split_data <- function(data_frame, training_ratio = 0.6, seed = 12239) {
  set.seed(seed)
  N = nrow(data_frame)
  data_frame$original_index = 1:N
  if(floor(training_ratio) == training_ratio) {
    indexes = sample(N, training_ratio)
  } else {
    indexes = sample(N, as.integer(N*training_ratio))
  }
  train = data_frame[ indexes, ]
  test = data_frame[ -indexes, ]
  list(train = train, test = test)
}

#' A function that removes constant features
#'
#' @param data_frame
#' @keywords  cleaning data
#' @export
#' @examples
#' remove_zero_variance(data_frame)
remove_zero_variance <- function(data_frame) {
  col_ct = sapply(data_frame, function(x) length(unique(x)))
  cat("Constant feature count:", length(col_ct[col_ct==1]))
  data_frame = data_frame[, !names(data_frame) %in% names(col_ct[col_ct==1])]
  data_frame
}

#' A function that counts NAs in a dataframe
#'
#' @param df
#' @keywords  cleaning data
#' @export
#' @examples
#' count.na(df)
count.na <- function(df) {
  length(df[is.na(df)])
}

#' A function that removes NAs from a dataframe
#'
#' @param df
#' @param threshold the highest allowed percentage of NAs in a column, columns with more NAs than this threshold will be removed
#' @param navals a vector containing all values to consider as NAs
#' @keywords  cleaning data
#' @export
#' @examples
#' remove.na(df)
remove.na <- function(df, threshold = 10) {
  for (v in navals) {
    df[df == v] = NA
  }
  na.percent.per.column = sapply(df, function(col) as.integer(length(col[is.na(col)])/(nrow(df)) * 100))
  na.percent.threshold = threshold
  df.no.na = df[, na.percent.per.column <= na.percent.threshold]
  df.no.na = df.no.na[complete.cases(df.no.na), ]
  stopifnot(count.na(df.no.na) == 0)
  df.no.na
}

#' A function that fills missing values using a function on columns
#'
#' @param df
#' @param fill_fn a function that takes a column and accepts `na.rm = T`
#' @keywords  cleaning data
#' @export
#' @examples
#' fill_missing(df, mean)
fill_mising <- function(df, fill_fn = mean) {
  do.call(cbind.data.frame, lapply(df, function(col) {
    avg = fill_fn(col, na.rm = T)
    col[is.na(col)] = avg
    col
  }) )
}

#' A function that plots ROC curve and returns the Area Under the Curve
#'
#' @param model
#' @param df
#' @keywords  performance
#' @export
#' @examples
#' roc.auc(model, df)
roc.auc <- function(model, df) {
  pred_col = predict(model, data.matrix(df))
  pred = prediction(pred_col, df$target)
  perf = performance(pred, "tpr", "fpr")
  par(mar=c(5,5,2,2),xaxs = "i",yaxs = "i",cex.axis=1.3,cex.lab=1.4)
  plot(perf,col="black",lty=3, lwd=3)
  auc <- performance(pred,"auc")
  auc <- unlist(slot(auc, "y.values"))
  auc
}
