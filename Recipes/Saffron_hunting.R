library(data.table)
library(jsonlite)
# Set working directory and create output folder
setwd("C:/Users/szs0394/Downloads/Week8")
# Load dataset with explicit column specification
dt <- fread("full_dataset.csv", col.names = c("index", "title", "ingredients", "directions", "link", "data_source", "NER"), skip = 0)

# Drop unnecessary index column
dt[, index := NULL]

# Filter for higher-quality recipes
dt <- dt[data_source == "Gathered"]

# Optional: Sample for testing (remove for full analysis)
dt <- dt[sample(nrow(dt), 100000)]  # Test on 100k rows

# Function to check for saffron in NER
has_saffron <- function(ner_str) {
  tryCatch({
    ner_list <- fromJSON(ner_str)
    if (length(ner_list) == 0) return(FALSE)
    return(any(tolower(ner_list) == "saffron"))
  }, error = function(e) {
    cat("Invalid JSON in NER:", ner_str, "\n")
    return(FALSE)
  })
}

# Count recipes with saffron
saffron_recipes <- dt[sapply(NER, has_saffron)]
saffron_count <- nrow(saffron_recipes)
total_recipes <- nrow(dt)
percentage <- (saffron_count / total_recipes) * 100

# Print results
cat(sprintf("Found %d recipes with saffron out of %d (%.2f%%) in the sampled dataset.\n", 
            saffron_count, total_recipes, percentage))

# Optional: Sample a saffron recipe
if (saffron_count > 0) {
  cat("\nSample recipe with saffron:\n")
  print(saffron_recipes[1, .(title, ingredients, directions)])
}