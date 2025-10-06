library(data.table)
library(jsonlite)
library(ggplot2)

# Set working directory
setwd("C:/Users/szs0394/Downloads/Week8")

# Load dataset with explicit column specification
dt <- fread("full_dataset.csv", col.names = c("index", "title", "ingredients", "directions", "link", "data_source", "NER"), skip = 0)

# Drop unnecessary index column
dt[, index := NULL]

# Filter for higher-quality recipes
dt <- dt[data_source == "Gathered"]

# Optional: Sample for testing (remove for full analysis)
dt <- dt[sample(nrow(dt), 100000)]  # Test on 100k rows

# Define list of meats to check
meats <- c("beef", "pork", "bacon", "chicken", "lamb", "turkey", "duck", "venison", "sausage")

# Function to check for meats in NER with cleaning
has_meat <- function(ner_str, meat_list) {
  tryCatch({
    # Clean the string to remove invalid characters
    ner_str <- gsub("[^[:alnum:],\"\\[\\] ]", "", ner_str)  # Keep only alphanumeric, commas, quotes, brackets, and spaces
    ner_list <- fromJSON(ner_str)
    if (length(ner_list) == 0) return(rep(FALSE, length(meat_list)))
    sapply(meat_list, function(meat) any(tolower(ner_list) == meat))
  }, error = function(e) {
    cat("Invalid JSON in NER:", ner_str, "\n")
    return(rep(FALSE, length(meat_list)))
  })
}

# Count recipes with each meat
meat_counts <- colSums(rbindlist(lapply(dt$NER, function(x) data.table(t(has_meat(x, meats))))))
names(meat_counts) <- meats
total_recipes <- nrow(dt)

# Calculate percentages
meat_percentages <- (meat_counts / total_recipes) * 100

# Print results
cat(sprintf("Meat frequency in %d sampled recipes:\n", total_recipes))
print(data.frame(Meat = names(meat_counts), Count = meat_counts, Percentage = sprintf("%.2f%%", meat_percentages)))

# Create data frame for plotting
plot_data <- data.frame(Meat = names(meat_counts), Count = meat_counts)

# Pie chart
p_pie <- ggplot(plot_data, aes(x = "", y = Count, fill = Meat)) +
  geom_bar(width = 1, stat = "identity") +
  coord_polar("y", start = 0) +
  scale_fill_viridis_d() +
  labs(title = "Distribution of Meats in Recipes", fill = "Meat") +
  theme_void() +
  theme(legend.position = "right")
ggsave("meat_pie_chart.png", p_pie, width = 8, height = 6, dpi = 300)

# Bar plot
p_bar <- ggplot(plot_data, aes(x = reorder(Meat, -Count), y = Count, fill = Meat)) +
  geom_bar(stat = "identity") +
  scale_fill_viridis_d() +
  labs(title = "Frequency of Meats in Recipes", x = "Meat", y = "Count") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))
ggsave("meat_bar_chart.png", p_bar, width = 10, height = 6, dpi = 300)

# Optional: Sample recipes for each meat (if any)
for (meat in meats) {
  meat_recipes <- dt[sapply(NER, function(x) any(tolower(fromJSON(x)) == meat))]
  if (nrow(meat_recipes) > 0) {
    cat(sprintf("\nSample recipe with %s:\n", meat))
    print(meat_recipes[1, .(title, ingredients, directions)])
  }
}