# Install and load necessary packages
install.packages(c("bigrquery", "ggplot2", "dplyr", "tidyr", "ggpubr", "nortest", "moments"))
library(bigrquery)
library(ggplot2)
library(dplyr)
library(tidyr)
library(ggpubr)
library(nortest)
library(moments)
library(ggh4x)
library(glue)

# Define a custom theme for consistency
my_custom_theme <- theme_bw() +
  theme(
    # Customize facet strip (titles)
    strip.background = element_blank(),
    strip.text = element_text(
      size = 14,          # Font size for facet titles
      face = "bold",
      hjust = 1,          # Right-align the facet titles
      color = "black"
    ),
    
    # Remove panel borders for a cleaner look
    panel.border = element_blank(),
    
    # Customize major and minor grid lines
    panel.grid.major.x = element_line(color = "grey80"),
    panel.grid.minor.x = element_blank(),
    panel.grid.major.y = element_line(color = "grey80"),
    panel.grid.minor.y = element_blank(),
    
    # Remove x-axis labels and ticks from all facets
    axis.text.x = element_blank(),
    axis.ticks.x = element_blank(),
    
    # Add x-axis labels and ticks to the bottom panel only
    axis.text.x.bottom = element_text(size = 12, angle = 0, hjust = 0.5),
    axis.ticks.x.bottom = element_line(),
    
    # Customize axis titles with added margins for spacing
    axis.title.x = element_text(
      size = 16,
      margin = margin(t = 10),  # Space above x-axis label
      face = "bold"
    ),
    axis.title.y = element_text(
      size = 16,
      margin = margin(r = 10),  # Space to the right of y-axis label
      face = "bold"
    ),
    
    # Customize y-axis text
    axis.text.y = element_text(size = 12),
    
    # Adjust panel spacing
    panel.spacing = unit(-0.6, "lines"),
    
    # Overall text size
    text = element_text(size = 16),
    
    # Customize plot title
    plot.title = element_text(
      size = 20,
      face = "bold",
      hjust = 0.5,
      margin = margin(b = 20)
    )
  )

# Set your Google Cloud project ID and dataset ID
project_id <- "nih-nci-dceg-connect-prod-6d04"      
dataset_id <- "ehr_healthpartners"      

# List of OMOP CDM tables to analyze
tables <- c(
  "visit_occurrence",
  "condition_occurrence",
  "drug_exposure",
  "procedure_occurrence",
  "device_exposure",
  "measurement",
  "observation"
)

### **A. Histogram of Records per Participant**

# Initialize an empty list to store data frames
df_list_hist <- list()

# Loop over each table to get counts per person
for (table_name in tables) {
  # Construct the SQL query using glue
  query <- glue("
    SELECT
      person_id,
      COUNT(*) AS record_count,
      '{table_name}' AS table_name
    FROM
      `{project_id}.{dataset_id}.{table_name}`
    GROUP BY
      person_id
  ")
  
  # Execute the query and download the results
  df <- bq_project_query(project_id, query) %>%
    bq_table_download()
  
  # Append the data frame to the list
  df_list_hist[[table_name]] <- df
}

# Combine all data frames into one
combined_df_hist <- bind_rows(df_list_hist)

# Plotting: Histogram of Records per Participant
histogram_plot <- ggplot(combined_df_hist, aes(x = record_count)) +
  geom_histogram(
    bins = 20,
    color = "black",
    fill = "steelblue"
  ) +
  scale_x_log10(
    breaks = scales::trans_breaks("log10", function(x) 10^x),
    labels = scales::trans_format("log10", scales::math_format(10^.x))
  ) +
  facet_wrap2(
    ~ table_name,
    ncol = 1,
    scales = "fixed",      # Keep y-scales fixed; adjust if needed
    strip.position = "top",
    axes = "all",
    remove_labels = "x"
  ) +
  my_custom_theme +        # Apply the custom theme
  # Set axis labels and limits
  xlab("Records per Participant (Log Scale)") +
  ylab("Participants") +
  ylim(c(0, 1500)) +        # Consider adjusting or removing if you want free scales
  # Add plot title
  ggtitle("Records per Participant")

# Display the histogram plot
print(histogram_plot)

### **B. Records per Year**

# Define the corresponding date fields for each table
date_fields <- c(
  "visit_start_date",
  "condition_start_date",
  "drug_exposure_start_date",
  "procedure_date",
  "device_exposure_start_date",
  "measurement_date",
  "observation_date"
)

# Initialize an empty list to store data frames
df_list_year <- list()

# Loop over each table to get counts per year
for (i in seq_along(tables)) {
  table_name <- tables[i]
  date_field <- date_fields[i]
  
  # Construct the SQL query using glue
  query <- glue("
    SELECT
      EXTRACT(YEAR FROM {date_field}) AS year,
      COUNT(*) AS record_count,
      '{table_name}' AS table_name
    FROM
      `{project_id}.{dataset_id}.{table_name}`
    WHERE
      EXTRACT(YEAR FROM {date_field}) BETWEEN 1990 AND 2024
    GROUP BY
      year
    ORDER BY
      year
  ")
  
  # Execute the query and download the results
  df <- bq_project_query(project_id, query) %>%
    bq_table_download()
  
  # Append the data frame to the list
  df_list_year[[table_name]] <- df
}

# Combine all data frames into one
combined_yearly_df <- bind_rows(df_list_year)

# Ensure all years are represented for each table
combined_yearly_df <- combined_yearly_df %>%
  complete(table_name, year = 1990:2024, fill = list(record_count = 0))

# Plotting: Records per Year
records_per_year_plot <- ggplot(combined_yearly_df, aes(x = year, y = record_count)) +
  # Fill the area under the curve
  geom_area(fill = "steelblue", alpha = 0.4) +        # Adjust fill color and transparency as needed
  # Add the line on top of the filled area
  geom_line(color = "steelblue", size = 1) +
  # Set x-axis breaks every 5 years
  scale_x_continuous(breaks = seq(1990, 2024, by = 5)) +
  # Facet the plot by table_name with free y-scales
  facet_wrap2(
    ~ table_name,
    ncol = 1,
    scales = "free_y",    # Allow y-axis to vary independently for each panel
    strip.position = "top",
    axes = "all",
    remove_labels = "x"
  ) +
  # Customize y-axis to show only 0 and max for each facet
  scale_y_continuous(
    breaks = function(x) {
      # Define breaks as 0 and the maximum y-value for each panel
      c(0, max(x, na.rm = TRUE))
    },
    labels = function(x) {
      # Format labels as integers or with commas for readability
      scales::comma(x)
    }
  ) +
  my_custom_theme +        # Apply the custom theme
  # Set axis labels
  xlab("Year") +
  ylab("Number of Records") +
  # Add plot title
  ggtitle("Records per Year (1990-2024)")

# Display the records per year plot
print(records_per_year_plot)
