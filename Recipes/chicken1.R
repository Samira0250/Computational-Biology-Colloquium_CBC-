###############################################################################
# Simple Chicken Recipe Analysis - DEBUGGED VERSION
# Fixed common errors with JSON parsing and data handling
###############################################################################

library(data.table)
library(jsonlite)
library(ggplot2)

# Set working directory
setwd("C:/Users/szs0394/Downloads/Week8")

cat("Loading dataset...\n")

# Load dataset
dt <- fread("full_dataset.csv", 
            col.names = c("index", "title", "ingredients", "directions", 
                          "link", "data_source", "NER"))

cat(sprintf("Loaded %d recipes\n", nrow(dt)))

# Drop index column
dt[, index := NULL]

# Filter for higher-quality recipes
dt <- dt[data_source == "Gathered"]
cat(sprintf("After filtering for 'Gathered' source: %d recipes\n", nrow(dt)))

# Sample for testing (adjust or remove as needed)
set.seed(123)  # For reproducibility
dt <- dt[sample(.N, min(100000, .N))]
cat(sprintf("Working with sample of %d recipes\n", nrow(dt)))

###############################################################################
# IMPROVED CHICKEN DETECTION FUNCTION
###############################################################################

# Method 1: Simple string search (most reliable)
has_chicken_simple <- function(ner_str) {
  if (is.na(ner_str) || ner_str == "") return(FALSE)
  return(grepl("chicken", tolower(ner_str), fixed = TRUE))
}

# Method 2: Try to parse JSON, but fallback to string search
has_chicken_safe <- function(ner_str) {
  # Handle NA or empty strings
  if (is.na(ner_str) || nchar(trimws(ner_str)) == 0) {
    return(FALSE)
  }
  
  # First, try simple string search (fastest and most reliable)
  if (grepl("chicken", tolower(ner_str), fixed = TRUE)) {
    # If "chicken" appears in the string, try to parse properly
    tryCatch({
      # Clean the string
      cleaned <- gsub("\\\\", "", ner_str)  # Remove backslashes
      cleaned <- gsub("'", '"', cleaned)     # Replace single quotes
      
      # Try to parse as JSON
      ner_list <- fromJSON(cleaned)
      
      # Check if any element contains "chicken"
      if (length(ner_list) > 0) {
        return(any(grepl("chicken", tolower(ner_list), fixed = TRUE)))
      }
      return(FALSE)
      
    }, error = function(e) {
      # If JSON parsing fails, fall back to simple string match
      return(grepl("chicken", tolower(ner_str), fixed = TRUE))
    })
  }
  
  return(FALSE)
}

###############################################################################
# ANALYZE CHICKEN PRESENCE
###############################################################################

cat("\nAnalyzing chicken presence in recipes...\n")

# Quick check: Does "chicken" appear anywhere in the dataset?
raw_check <- sum(grepl("chicken", tolower(dt$NER), fixed = TRUE))
cat(sprintf("Quick check - 'chicken' appears in %d NER fields\n", raw_check))

# Apply the detection function
cat("Running detailed chicken detection...\n")

# Use simpler function for speed and reliability
dt[, has_chicken := has_chicken_simple(NER), by = seq_len(nrow(dt))]

# Count results
chicken_count <- sum(dt$has_chicken)
total_recipes <- nrow(dt)
percentage <- (chicken_count / total_recipes) * 100

cat("\n=== RESULTS ===\n")
cat(sprintf("Total recipes analyzed: %d\n", total_recipes))
cat(sprintf("Recipes with chicken: %d\n", chicken_count))
cat(sprintf("Percentage: %.2f%%\n", percentage))

###############################################################################
# VISUALIZATIONS
###############################################################################

if (chicken_count > 0) {
  cat("\nCreating visualizations...\n")
  
  # Prepare data for plotting
  plot_data <- data.frame(
    Category = c("With Chicken", "Without Chicken"),
    Count = c(chicken_count, total_recipes - chicken_count),
    Percentage = c(percentage, 100 - percentage)
  )
  
  # Bar plot
  p_bar <- ggplot(plot_data, aes(x = Category, y = Count, fill = Category)) +
    geom_bar(stat = "identity", alpha = 0.8) +
    geom_text(aes(label = sprintf("%d\n(%.1f%%)", Count, Percentage)), 
              vjust = -0.5, size = 5) +
    scale_fill_manual(values = c("With Chicken" = "#FFB81C", 
                                 "Without Chicken" = "#2E86AB")) +
    labs(title = "Chicken Presence in Recipe Dataset",
         subtitle = sprintf("Analysis of %d recipes", total_recipes),
         x = "",
         y = "Number of Recipes") +
    theme_minimal(base_size = 14) +
    theme(legend.position = "none",
          plot.title = element_text(face = "bold", size = 16))
  
  ggsave("chicken_bar_chart.png", p_bar, width = 8, height = 6, dpi = 300)
  cat("Saved: chicken_bar_chart.png\n")
  
  # Pie chart
  p_pie <- ggplot(plot_data, aes(x = "", y = Count, fill = Category)) +
    geom_bar(width = 1, stat = "identity") +
    coord_polar("y", start = 0) +
    geom_text(aes(label = sprintf("%.1f%%", Percentage)), 
              position = position_stack(vjust = 0.5),
              size = 6, fontface = "bold") +
    scale_fill_manual(values = c("With Chicken" = "#FFB81C", 
                                 "Without Chicken" = "#2E86AB")) +
    labs(title = "Chicken Recipe Distribution",
         fill = "") +
    theme_void(base_size = 14) +
    theme(plot.title = element_text(face = "bold", hjust = 0.5, size = 16))
  
  ggsave("chicken_pie_chart.png", p_pie, width = 8, height = 6, dpi = 300)
  cat("Saved: chicken_pie_chart.png\n")
  
  ###########################################################################
  # SAMPLE RECIPES
  ###########################################################################
  
  cat("\n=== SAMPLE CHICKEN RECIPES ===\n")
  chicken_recipes <- dt[has_chicken == TRUE]
  
  if (nrow(chicken_recipes) > 0) {
    # Show 3 sample recipes
    for (i in 1:min(3, nrow(chicken_recipes))) {
      cat(sprintf("\n--- Recipe %d ---\n", i))
      cat(sprintf("Title: %s\n", chicken_recipes$title[i]))
      cat(sprintf("Ingredients: %s\n", 
                  substr(chicken_recipes$ingredients[i], 1, 100)))
      cat(sprintf("Directions: %s\n", 
                  substr(chicken_recipes$directions[i], 1, 100)))
      cat("...\n")
    }
  }
  
} else {
  cat("\n⚠️ WARNING: No chicken recipes found!\n")
  cat("This might mean:\n")
  cat("1. The NER column doesn't contain parsed ingredients\n")
  cat("2. The data format is different than expected\n")
  cat("3. There really are no chicken recipes in your sample\n\n")
  
  cat("Debugging info:\n")
  cat("First few NER entries:\n")
  print(head(dt$NER, 3))
  cat("\nFirst few ingredient entries:\n")
  print(head(dt$ingredients, 3))
}

###############################################################################
# ADDITIONAL DIAGNOSTICS
###############################################################################

cat("\n=== DIAGNOSTICS ===\n")
cat(sprintf("NA values in NER: %d\n", sum(is.na(dt$NER))))
cat(sprintf("Empty strings in NER: %d\n", sum(dt$NER == "", na.rm = TRUE)))
cat(sprintf("Average NER length: %.0f characters\n", 
            mean(nchar(dt$NER), na.rm = TRUE)))

cat("\n✅ Script completed successfully!\n")