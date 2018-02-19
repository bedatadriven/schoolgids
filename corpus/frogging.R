
library(frogr)

inputs <- list.files("pdf", pattern = "\\.txt.post$")

# The frog tool can parallelize the analysis of a single document, but
# doesn't seem to be able to parallelize the processing of multiple documents
# in sequence. So we split the input set up ourselves into seperate directories,

num_workers <- max(1, detectCores() - 1)
batches <- split(inputs, rep(1:num_workers, length.out=length(inputs)))

for(i in seq_along(batches)) {
  batch_dir <- sprintf("frog/batch%d", i) 
  dir.create(batch_dir, recursive = TRUE, showWarnings = FALSE)
  file.copy(file.path("pdf", batches[[i]]), to = batch_dir)
  
  # Launch the batch
  system2("../lamachine/bin/frog", c(sprintf("--testdir=%s", batch_dir), "--threads=1", "--skip=ap"), wait = FALSE)
}
