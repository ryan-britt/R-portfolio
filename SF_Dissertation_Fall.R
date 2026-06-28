# Load Packages
library(tidyverse)
library(readxl)
library(broom)
library(stargazer)

# ==================
# 0. Import the Data
# ==================

# Get raw data
fall_data <- read_excel("fa23_data.xlsx")

# Recode the first ten columns as factor variables. 
# Capitalize first letter of columns.
fall_data <- fall_data |> 
  mutate(across(participant:income, as.factor)) |> 
  mutate(condition = as.factor(condition)) |> 
  mutate(condition = fct_rev(condition)) |> 
  mutate(question = as.factor(question))
names(fall_data) <- str_to_title(names(fall_data))

# Modify the default ggplot theme
theme_update(
  axis.title.x = element_text(size = 20, face = "bold"),
  axis.text.x = element_text(size = 20),
  axis.title.y = element_text(size = 20, face = "bold"),
  axis.text.y = element_text(size = 20),
  strip.text = element_text(size = 28),
  panel.grid = element_blank(),
  legend.text = element_text(size = 16)
)

# ===============
# 1. Data Subsets
#================

# 1.1 Separate data frame for just demographic information
fall_demo <- fall_data %>% 
  select(Participant:Anxiety) %>% 
  distinct()

# 1.2 Just the NASA TLX results
fall_results <- fall_data |> 
  select(Participant, Anxiety, Question, Condition, Mental:Frustration)

# 1.3 NASA TLX results in long form
fall_results_long <- fall_results |> 
  pivot_longer(Mental:Frustration,
               names_to = "Scale",
               values_to = "Rating",
               names_transform = list(Scale = as.factor)) |> 
  mutate(Scale =
           fct_relevel(Scale, "Mental", "Temporal", "Performance", "Effort", "Frustration"))

# 1.4 Just the completion times
fall_times <- fall_data |> 
  select(Participant, Question, Condition, Order, Time)

# 1.5 Correctness of SF
fall_correct <- fall_data |> 
  filter(Condition == "SF") |> 
  select(Participant, Question, Sf_correct)

# =================================
# 2. Analysis of NASA TLX Responses
#==================================

# 2.1.1 Average score on each question by condition
fall_results_long |> 
  summarize(.by = c(Question, Condition),
            Mean_Rating = mean(Rating, na.rm = TRUE))

# 2.1.2 T-test results
fall_results_long |> 
  summarize(.by = c(Participant, Question, Condition),
            Mean_Rating = mean(Rating, na.rm = TRUE)) |> 
  pivot_wider(
    names_from = Condition,
    values_from = Mean_Rating
  ) |> 
  nest(.by = Question) |> 
  mutate(T_test =
           map(data, \(x) tidy(t.test(x$SF, x$`Non-SF`, paired = TRUE)))) |> 
  unnest(T_test)

# 2.1.3 Visualization of Average Scores per question per condition
# Update 8/31/24: Added error bars
# Update 9/18/24: Started Y-axis at zero
fall_results |> 
  select(!Anxiety) |> 
  mutate(Average = (Mental + Temporal + Performance + Effort + Frustration) / 5) |> 
  select(!Mental:Frustration) |> 
  drop_na(Average) |> 
  summarize(.by = c(Question, Condition),
            Mean_Rating = (mean(Average)),
            SE_Rating = sd(Average) / sqrt(length(Average))) |> 
  ggplot(aes(x = Question, y = Mean_Rating, color = Condition)) +
  geom_point(size = 10) +
  geom_line(aes(group = Condition), linewidth = 2) +
  geom_errorbar(
    aes(ymax = Mean_Rating + SE_Rating,
        ymin = Mean_Rating - SE_Rating),
    color = "black",
    width = 0.1
  ) +
  labs(
    y = "Average NASA TLX Rating"
  ) +
  theme(
    axis.title.y = element_text(margin = margin(0, 0.5, 0, 0, "cm"))
  ) +
  theme(
    panel.border = element_rect(color = "black", fill = NA, linewidth = 2)
  ) +
  ylim(c(0, 40))

# 2.2.1 Average score per NASA TLX item, per question, per item, per condition
fall_results_long |> 
  summarize(.by = c(Question, Condition, Scale),
            Average_Rating = mean(Rating, na.rm = TRUE))

# 2.2.2 T-test for differences
fall_results_long |> 
  nest(.by = c(Question, Scale)) |> 
  mutate(Wider =
           map(data, \(x) x |> 
                 pivot_wider(
                   names_from = Condition,
                   values_from = Rating
                 ))) |> 
  mutate(T_test =
           map(Wider, \(x) tidy(t.test(x$SF, x$`Non-SF`,
                                       paired = TRUE, data = x)))) |> 
  select(!data:Wider) |> 
  unnest(T_test) |> 
  select(Question, Scale, estimate, statistic, p.value)

# 2.2.3 Boxplot of scores per question, condition, and scale
fall_results_long |> 
  ggplot(aes(x = Rating, y = Scale, fill = Condition)) +
  geom_boxplot(outlier.shape = NA) +
  facet_wrap(~ Question, labeller = labeller(
    Question = c("1" = "Question 1", "2" = "Question 2", "3" = "Question 3"))) +
  labs(y = "Score", fill = "Condition") +
  scale_fill_manual(
    values = c(norm = "#F8766D", sf = "#00BFC4")
  ) +
  scale_fill_discrete(
    labels = c("SF", "Non-SF")
  ) +
  theme(
    panel.spacing = unit(1, "cm"),
    panel.border = element_rect(color = "black", fill = NA, 
                                linewidth = 1),
    strip.background = element_rect(color = "black", linewidth = 1),
    legend.position = "top",
    axis.text.y = element_text(
      margin = margin(r = 10)
    ),
    legend.title = element_text(size = 28),
    legend.text = element_text(size = 24)
  )

# ===============================
# 3. Analysis of Completion Times
#================================

# 3.1.1 Get median times for each question and condition
fall_times |> 
  drop_na(Time) |> 
  summarize(.by = c(Question, Condition),
            Median_time = median(Time))

# 3.1.2 Wilcoxon Signed Rank test on times
fall_times |> 
  mutate(Condition = fct_rev(Condition)) |> 
  nest(.by = Question) |> 
  mutate(Wilcox_test =
           map(data, \(x) tidy(wilcox.test(Time ~ Condition, paired = TRUE,
                                           exact = FALSE, data = x)))) |> 
  select(-data) |> 
  unnest(Wilcox_test) |> 
  select(-c(method, alternative))

# 3.1.3 Box plots for completion times
fall_times |> 
  drop_na(Time) |> 
  filter(Time < 6) |> 
  mutate(Condition = fct_rev(Condition)) |> 
  ggplot(aes(x = Question, y = Time, fill = Condition)) +
  geom_boxplot(outlier.shape = NA) +
  facet_wrap(~ Order,
             labeller = labeller(
               Order = c("A" = "Order: SF Second", 
                         "B" = "Order: SF First")
             )) +
  scale_fill_manual(values = c("#00BFC4", "#F8766D")) +
  labs(
    y = "Time (min)"
  ) +
  theme(
    panel.border = element_rect(fill = NA, linewidth = 2),
    strip.background = element_rect(linewidth = 2, color = "black")
  )


# ========================================================
# 4. Significant Figure Condition as a Moderating Variable
#=========================================================

# 4.1 Hierarchical linear regression

# 4.1.1 Average workload regressed on one predictor variable: Anxiety
fall_results_long |> 
  summarize(.by = c(Participant, Anxiety, Question, Condition),
            Average = mean(Rating)) |> 
  nest(.by = Question) |> 
  mutate(Linear_model =
           map(data, \(x) tidy(lm(Average ~ Anxiety, data = x)))) |> 
  unnest(Linear_model)

# 4.1.2 Average workload regressed on two predictor variables: Anxiety and SF
fall_results_long |> 
  summarize(.by = c(Participant, Anxiety, Question, Condition),
            Average = mean(Rating)) |> 
  nest(.by = Question) |> 
  mutate(Linear_model =
           map(data, \(x) tidy(lm(Average ~ Anxiety + Condition, data = x)))) |> 
  unnest(Linear_model)

# 4.1.3 Average workload regressed on three predictor variables: Anxiety, SF, and interaction
fall_results_long |> 
  summarize(.by = c(Participant, Anxiety, Question, Condition),
            Average = mean(Rating)) |> 
  nest(.by = Question) |> 
  mutate(Linear_model =
           map(data, \(x) tidy(lm(Average ~ Anxiety + Condition + Anxiety:Condition, data = x)))) |> 
  unnest(Linear_model)

# 4.2 Representing the linear model graphically

# 4.2.1 Get the model terms
fall_model_terms <- fall_results_long |> 
  summarize(.by = c(Participant, Anxiety, Question, Condition),
            Average = mean(Rating)) |> 
  nest(.by = Question) |> 
  mutate(model =
           map(data, \(x) tidy(lm(Average ~ Anxiety + Condition + Anxiety:Condition, data = x)))) |> 
  unnest(model) |> 
  select(Question, term, estimate) |> 
  pivot_wider(
    names_from = term,
    values_from = estimate
  )

# 4.2.2 Build two lists of matrices to generate the slopes
fall_design_matrix <- list(
  non = matrix(c(rep(1, 10), 1:10, rep(1, 10), 1:10), ncol = 4),
  sf = matrix(c(rep(1, 10), 1:10, rep(0, 20)), ncol = 4)
)

fall_coef_matrix <- map(1:3, \(x) fall_model_terms |> 
                          select(-Question) |> 
                          slice(x) |> 
                          unlist() |> 
                          as.matrix())

# 4.2.3 Tibble of indices to be used in map function
fall_index <- tibble(
  x = rep(1:2, times = 3),
  y = rep(1:3, each = 2)
)

# 4.2.4 Assemble model-generated values into one data frame
fall_model_predictions <- map2_dfc(fall_index$x, fall_index$y, \(x, y) fall_design_matrix[[x]] %*% fall_coef_matrix[[y]]) |> 
  mutate(Anxiety = 1:10,
         .before = everything()) |> 
  set_names(c("Anxiety", "Non-SF_1", "SF_1",
              "Non-SF_2", "SF_2","Non-SF_3", "SF_3")) |> 
  pivot_longer(!Anxiety,
               names_to = c("Condition", "Question"),
               names_sep = "_",
               values_to = "Y_hat") |> 
  mutate(Condition = factor(Condition),
         Question = factor(Question)) |> 
  relocate(Anxiety, .before = Y_hat) |> 
  relocate(Question, .before = Condition)

# 4.2.5 Generate plots from model_predictions data frame
fall_model_predictions |> 
  mutate(Condition = fct_rev(Condition)) |> 
  ggplot(aes(x = Anxiety, y = Y_hat, color = Condition)) +
  geom_line(linewidth = 2) +
  facet_wrap(~ Question, labeller = labeller(
    Question = c("1" = "Question 1", "2" = "Question 2", "3" = "Question 3"))) +
  scale_x_continuous(breaks = c(2, 4, 6, 8, 10)) +
  labs(
    y = "Model-Predicted Average Workload"
  ) +
  theme(
    panel.border = element_rect(color = "black", fill = NA, linetype = 1),
    strip.background = element_rect(color = "black", linewidth = 1)
  ) +
  geom_point(data = subset(fall_model_predictions,
                           Anxiety %in% c(1,10)), size = 5)

# 4.2.6 Display Regression Table using Stargazer
fall_model_list <- fall_results_long |> 
  summarize(.by = c(Participant, Anxiety, Question, Condition),
            Average = mean(Rating)) |> 
  nest(.by = Question) |> 
  mutate(model =
           map(data, \(x) lm(Average ~ Anxiety + Condition + Anxiety:Condition, data = x))) |> 
  pull(model)

stargazer(fall_model_list[[1]], fall_model_list[[2]], fall_model_list[[3]],
          column.sep.width = "30pt",
          column.labels = c("Question 1", "Question 2", "Question 3"),
          model.numbers = FALSE,
          dep.var.labels = "Average Workload Rating"
)

# ======================
# 5. Sig Fig Correctness
# ======================

# 5.1 Sigfig percent correct per question
fall_data |> 
  filter(Condition == "SF") |> 
  select(Participant, Question, Sf_correct) |> 
  summarize(.by = Question,
            Total_correct = sum(Sf_correct)) |> 
  mutate(Pct_correct = Total_correct / 40 * 100)
