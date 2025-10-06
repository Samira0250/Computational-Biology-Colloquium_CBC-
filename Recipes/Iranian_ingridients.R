###############################################################################
# Persian/Kurdish Ingredient Analysis
# Finding the prevalence of traditional ingredients in recipe dataset (Bien_ProcICNLG_20202)
# By: A Kurdish neuroscientist bringing Persian flavors to data science!__SS
###############################################################################
library(data.table)
library(jsonlite)
library(ggplot2)
library(stringr)
library(viridis)
library(dplyr)

# Set working directory
setwd("C:/XX")

cat("Loading recipe dataset for Persian ingredient analysis...\n")

# Load dataset
dt <- fread("full_dataset.csv", 
            col.names = c("index", "title", "ingredients", "directions", 
                          "link", "data_source", "NER"))

# Drop unnecessary index column
dt[, index := NULL]

# Filter for higher-quality recipes
dt <- dt[data_source == "Gathered"]

cat(sprintf("Loaded %d recipes\n", nrow(dt)))

###############################################################################
# DEFINE PERSIAN/KURDISH INGREDIENTS
###############################################################################

persian_ingredients <- c(
  "saffron",        # زعفران - The golden spice
  "pistachio",      # پسته
  "walnut",         # گردو
  "pomegranate",    # انار
  "barberry",       # زرشک
  "lamb",           # گوشت گوسفند
  "yogurt",         # ماست
  "mint",           # نعناع
  "dill",           # شوید
  "turmeric",       # زردچوبه
  "rose water",     # گلاب
  "rosewater",      # Alternative spelling
  "sumac",          # سماق
  "fenugreek",      # شنبلیله
  "cardamom",       # هل
  "zereshk",        # زرشک (alternative)
  "lavash"          # نان لواش
)

# Remove duplicates and create display names
persian_display_names <- c(
  "Saffron", "Pistachio", "Walnut", "Pomegranate", "Barberry",
  "Lamb", "Yogurt", "Mint", "Dill", "Turmeric",
  "Rose Water", "Rose Water", "Sumac", "Fenugreek", 
  "Cardamom", "Barberry", "Lavash"
)

# Combine similar ingredients
ingredient_groups <- list(
  "Saffron" = c("saffron"),
  "Pistachio" = c("pistachio"),
  "Walnut" = c("walnut"),
  "Pomegranate" = c("pomegranate"),
  "Barberry (Zereshk)" = c("barberry", "zereshk"),
  "Lamb" = c("lamb"),
  "Yogurt" = c("yogurt", "yoghurt"),
  "Mint" = c("mint"),
  "Dill" = c("dill"),
  "Turmeric" = c("turmeric"),
  "Rose Water" = c("rose water", "rosewater"),
  "Sumac" = c("sumac"),
  "Fenugreek" = c("fenugreek"),
  "Cardamom" = c("cardamom"),
  "Lavash" = c("lavash")
)

###############################################################################
# DETECT EACH INGREDIENT
###############################################################################

cat("\nDetecting Persian ingredients in recipes...\n")

# Function to detect specific ingredient
detect_ingredient <- function(ner_str, ingredient_terms) {
  if (is.na(ner_str) || ner_str == "") return(FALSE)
  
  # Create pattern for all terms
  pattern <- paste(ingredient_terms, collapse = "|")
  return(grepl(pattern, tolower(ner_str), ignore.case = TRUE))
}

# Create columns for each ingredient group
ingredient_results <- data.frame(
  Ingredient = names(ingredient_groups),
  Count = 0,
  Percentage = 0,
  stringsAsFactors = FALSE
)

# Count occurrences of each ingredient
for (i in seq_along(ingredient_groups)) {
  ingredient_name <- names(ingredient_groups)[i]
  ingredient_terms <- ingredient_groups[[i]]
  
  cat(sprintf("Searching for: %s...\n", ingredient_name))
  
  # Count recipes containing this ingredient
  count <- sum(sapply(dt$NER, function(x) detect_ingredient(x, ingredient_terms)))
  
  ingredient_results$Count[i] <- count
  ingredient_results$Percentage[i] <- (count / nrow(dt)) * 100
}

# Sort by count
ingredient_results <- ingredient_results[order(-ingredient_results$Count), ]

###############################################################################
# DISPLAY RESULTS
###############################################################################

cat("\n", rep("=", 70), "\n", sep = "")
cat("PERSIAN/KURDISH INGREDIENT ANALYSIS RESULTS\n")
cat(rep("=", 70), "\n\n", sep = "")

cat(sprintf("Total recipes analyzed: %d\n\n", nrow(dt)))

cat("Ingredient Prevalence:\n")
cat(rep("-", 70), "\n", sep = "")
for (i in 1:nrow(ingredient_results)) {
  cat(sprintf("%-20s: %6d recipes (%.2f%%)\n", 
              ingredient_results$Ingredient[i],
              ingredient_results$Count[i],
              ingredient_results$Percentage[i]))
}
cat(rep("-", 70), "\n\n", sep = "")

# Find recipes with ANY Persian ingredient
has_any_persian <- function(ner_str) {
  if (is.na(ner_str) || ner_str == "") return(FALSE)
  all_terms <- unlist(ingredient_groups)
  pattern <- paste(all_terms, collapse = "|")
  return(grepl(pattern, tolower(ner_str), ignore.case = TRUE))
}

persian_recipe_count <- sum(sapply(dt$NER, has_any_persian))
persian_percentage <- (persian_recipe_count / nrow(dt)) * 100

cat(sprintf("Total recipes with ANY Persian ingredient: %d (%.2f%%)\n\n", 
            persian_recipe_count, persian_percentage))

###############################################################################
# VISUALIZATIONS
###############################################################################

cat("Creating visualizations...\n")

# 1. Bar chart - Percentage of each ingredient
p1 <- ggplot(ingredient_results, 
             aes(x = reorder(Ingredient, Percentage), y = Percentage, 
                 fill = Percentage)) +
  geom_bar(stat = "identity", alpha = 0.9) +
  geom_text(aes(label = sprintf("%.2f%%", Percentage)), 
            hjust = -0.1, size = 3.5) +
  scale_fill_gradient(low = "#FFB81C", high = "#C41E3A") +
  coord_flip() +
  labs(title = "Persian/Kurdish Ingredient Prevalence in Recipe Dataset",
       subtitle = sprintf("Analysis of %d recipes", nrow(dt)),
       x = "",
       y = "Percentage of Recipes (%)") +
  theme_minimal(base_size = 12) +
  theme(
    legend.position = "none",
    plot.title = element_text(face = "bold", size = 14),
    panel.grid.major.y = element_blank()
  ) +
  ylim(0, max(ingredient_results$Percentage) * 1.15)

ggsave("persian_ingredients_percentage.png", p1, width = 12, height = 8, dpi = 300)
cat("Saved: persian_ingredients_percentage.png\n")

# 2. Count bar chart
p2 <- ggplot(ingredient_results, 
             aes(x = reorder(Ingredient, Count), y = Count, fill = Count)) +
  geom_bar(stat = "identity", alpha = 0.9) +
  geom_text(aes(label = scales::comma(Count)), 
            hjust = -0.1, size = 3.5) +
  scale_fill_viridis(option = "plasma") +
  coord_flip() +
  labs(title = "Persian/Kurdish Ingredient Frequency",
       subtitle = "Absolute recipe counts",
       x = "",
       y = "Number of Recipes") +
  theme_minimal(base_size = 12) +
  theme(
    legend.position = "none",
    plot.title = element_text(face = "bold", size = 14),
    panel.grid.major.y = element_blank()
  )

ggsave("persian_ingredients_count.png", p2, width = 12, height = 8, dpi = 300)
cat("Saved: persian_ingredients_count.png\n")


#Pie chart: Top 5 Persian ingredients - Pie chart (no text labels)
# 3. Top 5 Persian ingredients - Pie chart (percentage labels only)
top5 <- head(ingredient_results, 5)

p3 <- ggplot(top5, aes(x = "", y = Count, fill = Ingredient)) +
  geom_col(width = 1, color = "Black") +
  coord_polar(theta = "y") +
  geom_text(aes(label = paste0(round(Count / sum(Count) * 100, 1), "%")),
            position = position_stack(vjust = 0.5),
            color = "Black", size = 5, fontface = "bold") +
  scale_fill_viridis_d(option = "plasma") +
  theme_void() +
  labs(title = "Top 5 Persian/Kurdish Ingredients") +
  theme(
    plot.title = element_text(face = "bold", size = 14, hjust = 0.5),
    legend.position = "right"
  )

ggsave("persian_top5_pie.png", p3, width = 8, height = 6, dpi = 300)
cat("Saved: persian_top5_pie.png\n")


# 4. Persian vs Non-Persian overall
overall_data <- data.frame(
  Category = c("With Persian Ingredients", "Without Persian Ingredients"),
  Count = c(persian_recipe_count, nrow(dt) - persian_recipe_count),
  Percentage = c(persian_percentage, 100 - persian_percentage)
)

p4 <- ggplot(overall_data, aes(x = Category, y = Percentage, fill = Category)) +
  geom_bar(stat = "identity", alpha = 0.8, width = 0.6) +
  geom_text(aes(label = sprintf("%.1f%%\n(%s recipes)", 
                                Percentage, scales::comma(Count))), 
            vjust = -0.3, size = 5) +
  scale_fill_manual(values = c("#C41E3A", "#2E86AB")) +
  labs(title = "Persian Influence in Recipe Dataset",
       subtitle = "How many recipes contain traditional Persian/Kurdish ingredients?",
       x = "",
       y = "Percentage (%)") +
  theme_minimal(base_size = 14) +
  theme(
    legend.position = "none",
    plot.title = element_text(face = "bold", size = 16),
    axis.text.x = element_text(size = 12)
  ) +
  ylim(0, 100)

ggsave("persian_overall_influence.png", p4, width = 10, height = 7, dpi = 300)
cat("Saved: persian_overall_influence.png\n")

###############################################################################
# PROTEIN COMPLEXITY ANALYSIS
###############################################################################

cat("\nAnalyzing protein complexity...\n")

# Define proteins to analyze
proteins <- c("chicken", "beef", "pork", "fish", "lamb", 
              "turkey", "shrimp", "salmon", "bacon", "duck")

# Detect proteins in recipes
for (protein in proteins) {
  dt[, (protein) := grepl(protein, tolower(NER), fixed = TRUE)]
}

# Calculate complexity metrics for recipes with each protein
dt[, `:=`(
  num_ingredients = str_count(NER, ",") + 1,  # Rough estimate
  num_steps = str_count(directions, "\\.") + 1  # Rough estimate
)]

# Create primary protein column
dt[, primary_protein := "No Protein"]
for (protein in proteins) {
  dt[get(protein) == TRUE & primary_protein == "No Protein", 
     primary_protein := protein]
}

# Calculate average complexity by protein
protein_complexity <- dt[primary_protein != "No Protein"] %>%
  group_by(primary_protein) %>%
  summarise(
    recipe_count = n(),
    avg_ingredients = mean(num_ingredients, na.rm = TRUE),
    avg_steps = mean(num_steps, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  as.data.frame()

# Print results
cat("\nProtein Complexity Analysis:\n")
cat(rep("-", 70), "\n", sep = "")
print(protein_complexity[order(-protein_complexity$avg_ingredients), ])
cat(rep("-", 70), "\n\n", sep = "")


# 5. Protein complexity bubble plot
p5 <- ggplot(protein_complexity, 
             aes(x = avg_ingredients, y = avg_steps, 
                 size = recipe_count, color = primary_protein, 
                 label = primary_protein)) +
  geom_point(alpha = 0.7) +
  geom_text(vjust = -1.5, size = 4, fontface = "bold") +
  scale_color_viridis_d(option = "turbo") +
  scale_size_continuous(range = c(5, 20), labels = scales::comma) +
  labs(title = "Recipe Complexity by Protein Type",
       subtitle = "Bubble size represents number of recipes",
       x = "Average Number of Ingredients",
       y = "Average Number of Steps",
       size = "Recipe Count",
       color = "Protein") +
  theme_minimal(base_size = 12) +
  theme(
    legend.position = "right",
    plot.title = element_text(face = "bold", size = 14)
  )

ggsave("protein_complexity_comparison.png", p5, width = 12, height = 8, dpi = 300)
cat("Saved: protein_complexity_comparison.png\n")

# 6. Protein diversity analysis
protein_diversity <- data.frame(
  Category = c("Single Protein", "Multiple Proteins", "No Protein"),
  Count = c(
    sum(rowSums(dt[, proteins, with = FALSE]) == 1),
    sum(rowSums(dt[, proteins, with = FALSE]) > 1),
    sum(rowSums(dt[, proteins, with = FALSE]) == 0)
  )
)
protein_diversity$Percentage <- (protein_diversity$Count / nrow(dt)) * 100

cat("\nProtein Diversity in Recipes:\n")
print(protein_diversity)

p6 <- ggplot(protein_diversity, aes(x = Category, y = Percentage, fill = Category)) +
  geom_bar(stat = "identity", alpha = 0.8, width = 0.6) +
  geom_text(aes(label = sprintf("%.1f%%\n(%s recipes)", 
                                Percentage, scales::comma(Count))), 
            vjust = -0.3, size = 4.5) +
  scale_fill_manual(values = c("#C41E3A", "#FFB81C", "#2E86AB")) +
  labs(title = "Protein Diversity in Recipe Dataset",
       subtitle = "How many proteins appear in each recipe?",
       x = "",
       y = "Percentage (%)") +
  theme_minimal(base_size = 14) +
  theme(
    legend.position = "none",
    plot.title = element_text(face = "bold", size = 16),
    axis.text.x = element_text(size = 12)
  ) +
  ylim(0, max(protein_diversity$Percentage) * 1.15)

ggsave("protein_diversity.png", p6, width = 10, height = 7, dpi = 300)
cat("Saved: protein_diversity.png\n")

# Special analysis: Lamb complexity vs other proteins
if ("lamb" %in% protein_complexity$primary_protein) {
  lamb_data <- protein_complexity[protein_complexity$primary_protein == "lamb", ]
  cat(sprintf("\nLamb Recipe Analysis (Persian protein of choice):\n"))
  cat(sprintf("  Average ingredients: %.2f\n", lamb_data$avg_ingredients))
  cat(sprintf("  Average steps: %.2f\n", lamb_data$avg_steps))
  cat(sprintf("  Number of recipes: %d\n", lamb_data$recipe_count))
  
  # Compare to overall average
  overall_avg_ing <- mean(protein_complexity$avg_ingredients)
  overall_avg_steps <- mean(protein_complexity$avg_steps)
  
  cat(sprintf("\nCompared to average protein recipe:\n"))
  cat(sprintf("  Ingredients: %.1f%% %s complex\n", 
              abs((lamb_data$avg_ingredients - overall_avg_ing) / overall_avg_ing * 100),
              ifelse(lamb_data$avg_ingredients > overall_avg_ing, "MORE", "LESS")))
  cat(sprintf("  Steps: %.1f%% %s complex\n", 
              abs((lamb_data$avg_steps - overall_avg_steps) / overall_avg_steps * 100),
              ifelse(lamb_data$avg_steps > overall_avg_steps, "MORE", "LESS")))
}

###############################################################################
# SAMPLE PERSIAN RECIPES
###############################################################################

cat("\nSAMPLE PERSIAN/KURDISH RECIPES:\n\n")

# Get recipes with Persian ingredients
dt_persian <- dt[sapply(NER, has_any_persian)]

if (nrow(dt_persian) > 0) {
  # Show 3 sample recipes
  for (i in 1:min(5, nrow(dt_persian))) {
    cat(sprintf("\n--- Recipe %d ---\n", i))
    cat(sprintf("Title: %s\n", dt_persian$title[i]))
    
    # Identify which Persian ingredients it contains
    present_ingredients <- c()
    for (ing_name in names(ingredient_groups)) {
      if (detect_ingredient(dt_persian$NER[i], ingredient_groups[[ing_name]])) {
        present_ingredients <- c(present_ingredients, ing_name)
      }
    }
    
    cat(sprintf("Persian Ingredients: %s\n", paste(present_ingredients, collapse = ", ")))
    cat(sprintf("Ingredients: %s\n", substr(dt_persian$ingredients[i], 1, 150)))
    cat("...\n")
  }
}

###############################################################################
# EXPORT DATA TABLE
###############################################################################

# Save detailed results to CSV
write.csv(ingredient_results, "persian_ingredient_analysis.csv", row.names = FALSE)
cat("\nSaved detailed results to: persian_ingredient_analysis.csv\n")

###############################################################################
# FINAL SUMMARY
###############################################################################

cat("\n", rep("=", 70), "\n", sep = "")
cat("KEY INSIGHTS\n")
cat(rep("=", 70), "\n\n", sep = "")

# Most popular
most_popular <- ingredient_results$Ingredient[1]
most_popular_pct <- ingredient_results$Percentage[1]
cat(sprintf("Most popular: %s (%.2f%% of recipes)\n", 
            most_popular, most_popular_pct))

# Least popular (but still present)
least_popular_idx <- which(ingredient_results$Count > 0)
if (length(least_popular_idx) > 0) {
  least_popular <- tail(ingredient_results$Ingredient[least_popular_idx], 1)
  least_popular_pct <- tail(ingredient_results$Percentage[least_popular_idx], 1)
  cat(sprintf("Rarest: %s (%.3f%% of recipes)\n", 
              least_popular, least_popular_pct))
}

# Saffron specifically (since you mentioned it!)
saffron_row <- ingredient_results[ingredient_results$Ingredient == "Saffron", ]
if (nrow(saffron_row) > 0) {
  cat(sprintf("\nSaffron (The Golden Spice): %d recipes (%.2f%%)\n",
              saffron_row$Count, saffron_row$Percentage))
  cat("   The most precious spice finds its way into cooking worldwide!\n")
}

cat("\n", rep("=", 70), "\n", sep = "")
cat("\nAnalysis complete! Check your working directory for all plots.\n")
cat("Persian ingredient analysis finished successfully.\n\n")
