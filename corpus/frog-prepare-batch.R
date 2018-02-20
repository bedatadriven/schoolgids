
# The frog tool can parallelize the analysis of a single document, but
# doesn't seem to be able to parallelize the processing of multiple documents
# in sequence. 

# So we split the input set up ourselves into seperate directories, and
# write out a shell script to run the batches in parallel.

library(parallel)

inputs <- list.files("pdf", pattern = "\\.txt.post$")


num_workers <- max(1, detectCores() - 1)
batches <- split(inputs, rep(1:num_workers, length.out=length(inputs)))

for(i in seq_along(batches)) {
  batch_dir <- sprintf("frog/batch%d", i)
  dir.create(batch_dir, recursive = TRUE, showWarnings = FALSE)
  file.copy(file.path("pdf", batches[[i]]), to = batch_dir)
  
}

script <- sapply(1:num_workers, function(batch) {
  paste("$FROG", sprintf("--testdir=frog/batch%d", batch), sprintf("--outputdir=frog/batch%d", batch), "--threads=1", "--skip=ap", sprintf("&>frog/batch%d.log", batch), "&")
})

writeLines(c(script, "wait"), "frog.sh")