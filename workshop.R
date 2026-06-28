# ==================================================
# Introduction to R Workshop
# Author: Ryan Britt
# CU Anschutz | Version 1.0
# ==================================================


# ==================================================
# Section 1: Getting Started
# ==================================================

# Hello, and welcome to R!
# These lines are called "comments," and they're here to guide you.
# R doesn't run them, but they're very helpful in understanding code.
# Try writing a comment below! Just type shift-3 for the '#' symbol,
# and then write whatever you'd like.
_____Delete this line and insert a comment using `#` at the start_____

# --------------------------------------------------
# A. Data Frames
# --------------------------------------------------

# In R you will primarily work with "data frames."
# Data frames store large amounts of data in an organized way.
# Several datasets are built into R. Let's look at the "airquality" data

# You can view a data frame just by typing its name.
# Put your cursor at the end of the line below and hit Ctrl + Enter
airquality

# To get a small preview of the data, use the head() function
# Place the name of the data frame inside the parentheses.
# Again, place the cursor at the end of the line below and hit Ctrl + Enter
head(airquality)

# To get a larger view of the data, use the View() function.
# This will create a new tab right above this window. Click on it.
# Note: R is case-sensitive, so make sure 'View' is capitalized
View(airquality)

# This dataset has five columns. 
# To access a specific column, type the name of the dataframe
# and the name of the variable, separated by the dollar sign ($).
# Suppose we wanted just the Wind readings. Run the following:
airquality$Wind

# Your turn. Suppose you wanted all temperature
# readings. Delete the blank below and replace it with Temp
airquality$______


# --------------------------------------------------
# B. Simple Functions
# --------------------------------------------------

# We can now use some basic R functions to learn about our data.
# For example, what is the mean wind speed? 
# Let's try using the mean() function.
mean(airquality$Wind)

# We can also find the standard deviation using the sd() function
# Try it below on the Wind data. Don't forget the "$"
sd(______)

# Try it for yourself. Can you find the mean and standard deviation
# for the "Temp" column? Write the commands below:
____<Delete this line and type your command____________
____<Delete this line and type your command____________


# R has a few built-in visualization functions that let you quickly
# view data. Try this one below which gives us a histogram for temperatures
hist(airquality$Temp)

# Is there a relationship between temperature and wind speed?
# Let's see a quick scatter plot:
plot(airquality$Temp, airquality$Wind)

# --------------------------------------------------
# C. Arguments
# --------------------------------------------------

# Sometimes, a function needs more information to do its job.
# We call this extra information "arguments."
# Arguments are separated by a comma.
# Functions behave very differently depending on the arguments they're given

# Let's see an example. We've used mean() before, but if we try to take
# the mean of the "Ozone" data, it doesn't seem to work. Run the following:
mean(airquality$Ozone)

# Why did the command fail?
# Try inspecting the Ozone data. What do you notice about it?
airquality$Ozone

# Data sets frequently have missing values. In R these are marked "NA",
# meaning "Not Available." If any values are NA, the mean() function
# will return NA as a warning to the user.

# Can we find the mean of the non-missing values? Yes!
# But we need to pass an additional argument to the mean() function
# Every command in R has a help page. To access the help page,
# put a "?" in front of the command you wish to learn more about:
?mean

# The help page for mean() shows us we can include the "na.rm" argument,
# meaning "NA remove." 
# By default, mean() will not ignore missing values.
# The na.rm argument changes that behavior. Let's try it.
# Note: Make sure TRUE is in all caps. "True" or "true" will not work.
mean(airquality$Ozone, na.rm = TRUE)

# Now try it for yourself. Can you calculate the standard deviation
# of the Ozone data? Use sd() and add the "na.rm = TRUE" argument.
_____Delete this line and insert code here_____


# ==================================================
# Section 2: Importing Packages and Data
# ==================================================

# Like any language, R evolves over time.
# One reason for this is that users can create their own functions
# and share them with others.
# These collections of shared functions are called "packages."
# Some packages have become so popular that they’ve shaped
# entirely new styles of programming in R.

# Let's download the Tidyverse, a popular collection of functions that makes
# working with data easy.

# Install the tidyverse
install.packages("tidyverse")

# We'll also need the readr package to import data sets
install.packages("readr")

# Once the package has been installed, we have to load it using the
# library() function. This must be done with each new R session.
library(tidyverse)

# We'll also need to load the readr package:
library(readr)

# We'll need a dataset to practice on. R can import data sets
# directly from the internet. Run the following:
fastfood <- read_csv("https://www.openintro.org/data/csv/fastfood.csv")

# The first step in exploring a dataset is to learn what variables
# are present. We learned two functions that do this.
# Do you remember what they were? Try below. The data set name is: fastfood
_____Delete this line and insert code here_____

# This dataset shows nutritional information on 515 items
# from eight popular fast food places.
# ** How many variables are in this dataset? 
# ** What are they?
# ** What questions would you like to explore?


# ==================================================
# Section 3: The Tidyverse
# ==================================================

# --------------------------------------------------
# A. The pipe
# --------------------------------------------------

# Before exploring tidyverse functions, we need to learn about the pipe
# The pipe is an extremely useful way to chain commands together.
# Let's recall an example from before:
mean(airquality$Wind)

# The command above calculates the mean of the "Wind" variable in the
# airquality data set. But we can do it another way using the pipe.
# Run the following:
airquality$Wind |> 
  mean()

# We get the same answer, but the logic is a bit different.
# The pipe basically means: 
# "Take this data and feed it into the next function."
# Modern R programming uses the pipe extensively.
# The pipe is formed by typing the vertical bar "|" followed by ">"
# You can also use the default keyboard shortcut: Ctrl + Shift + M
# Try it below:
_____Delete this line and insert code here_____

# --------------------------------------------------
# B. The select() verb
# --------------------------------------------------

# When exploring a dataset, you may be interested in just one or two
# variables. The select() function lets you focus on just the columns
# that interest you:
fastfood |> 
  select(calories)

# This is similar to what we did before using the "$" operator.
# If you wish to select multiple columns, just separate the names
# with a comma:
fastfood |> 
  select(restaurant, item)

# Try it yourself! Use head() or View() to see what columns are in this
# dataset, and then use select to choose 2-3 of them:
# Put them inside the parentheses and be sure to separate them with commas
fastfood |> 
  select()

# --------------------------------------------------
# C. The filter() verb
# --------------------------------------------------

# We've seen how to choose specific columns of our data set.
# What about specific rows? We can use filter() to choose rows that
# match a certain criterion.
# Suppose we were only interested in food items served at Subway.
# Here's how we show just those entries:
fastfood |> 
  filter(restaurant == "Subway")

# Notice that "Sonic" has to be in quotes. We also use the
# double equal sign "==". This is very common in programming.

# We can use filter in countless ways. Suppose we were only interested
# in high calorie items. This code only shows rows where the
# calorie count is over 1000
fastfood |> 
  filter(calories > 1000)

# We can also filter for multiple criteria at once!
# Just separate them with a comma. For example, this code will only
# show food items from Subway that are over 1000 calories
fastfood |> 
  filter(restaurant == "Subway", calories > 1000)

# Try it yourself! Filter on one or two conditions:
fastfood |> 
  filter(_________)

# Let's now explore the power of the pipe.
# We've learned both select and filter. Let's do BOTH in one command
# The pipe allows us to chain a select() command and a filter() command:
fastfood |> 
  select(restaurant, item, calories) |> 
  filter(calories > 1000)

# Try it for yourself. Choose a few columns using select.
# Then filter the rows based on some condition
fastfood |> 
  select(_________) |> 
  filter(_________)

# --------------------------------------------------
# D. The arrange() verb
# --------------------------------------------------

# We can now start to ask questions about our data set.
# Suppose a person is watching their sodium intake. Which item has
# the least amount of sodium? Let's first select only the columns
# of interest:
fastfood |> 
  select(restaurant, item, sodium)

# We can now use a pipe to add the arrange() command. 
# What do you notice?
# Which item has the least sodium?
fastfood |> 
  select(restaurant, item, sodium) |> 
  arrange(sodium)

# By default, results are shown in ascending order.
# What if you wanted to see things in descending order?
# Just add desc() like so:
fastfood |> 
  select(restaurant, item, sodium) |> 
  arrange(desc(sodium))

# Your turn! Sort the data based on the variable of your choice
# Make sure to start the command with "fastfood" followed by the pipe
_____Delete this line and insert code here_____

# --------------------------------------------------
# E. The mutate() verb
# --------------------------------------------------

# Often, you may want to add a new column to your data set.
# Let's think about sodium again. Can you use select
# to choose just the restaurant, item, and sodium columns?
_____Delete this line and insert code here_____


# These values aren't very meaningful on their own.
# To interpret them, we need a point of reference.
# The recommended daily maximum sodium intake is 2300 mg.
# So a more informative question is:
# What percentage of the daily sodium limit does each item represent?
# Calculating this by hand would be tedious. 
# Instead, we can use a new verb - mutate() - to add a new column!
fastfood |> 
  select(item, sodium) |> 
  mutate(pct_sodium = sodium / 2300 * 100)

# *** Challenge question ***
# How many items EXCEED the recommended daily sodium intake?
# Use the pipe to add a filter() command to this code:
fastfood |> 
  select(item, sodium) |> 
  mutate(pct_sodium = sodium / 2300 * 100)

# --------------------------------------------------
# F. summarize()
# --------------------------------------------------

# Previously, we calculated the mean of a variable using mean()
# The summarize() function gives us a more powerful way to 
# calculate any kind of statistic you'd like.
# The basic format is summarize(new_column_name = calculation)
# Run the following:
fastfood |> 
  summarize(mean_sodium = mean(sodium))

# Within summarize, you can perform multiple calculations:
# Just separate each with a comma.
# Putting each calculation on a new line is recommended, but not required.
fastfood |> 
  summarize(
    mean_sodium = mean(sodium),
    sd_sodium = sd(sodium),
    median_sodium = median(sodium)
  )

# Try it for yourself. Can you find the mean and standard
# deviation for total_fat? Can you do it in one command?
fastfood |> 
  summarize(_________)

# --------------------------------------------------
# G. group_by()
# --------------------------------------------------

# Finding the average sodium content for all food items isn't very
# meaningful, as this dataset has food items from 8 different restaurants.
# A more meaningful question is: 
# "What is the average sodium content for *each* restaurant?"
# To find this out, we'll add a group_by() command.
fastfood |> 
  group_by()

# group_by doesn't do anything by itself. Rather, it changes the behavior
# of other commands. Let's see how our summarize() command now works
# differently. Let's group by restaurant and summarize again:
fastfood |> 
  group_by(restaurant) |> 
  summarize(mean_sodium = mean(sodium))

# We now have average sodium values for each restaurant.
# That's much more interesting! Which restaurant has, on average
# the least sodium?

# Your turn! 
# How many carbs, on average, does each restaurant have?
# Group by restaurant and use summarize to find mean of "total_carb"
_____Delete this line and insert code here_____

# Tidyverse commands are powerful, letting us perform 
# complex calculations in just one command.
# Run the code below. Look at the results. What is it doing?
fastfood |> 
  group_by(restaurant) |> 
  summarize(
    across(where(is.numeric), mean)
  )

# --------------------------------------------------
# H. Plotting with ggplot2
# --------------------------------------------------

# We've seen that R has a built-in plot system.
# However, the ggplot2() package gives us all sorts of plotting options
# We can easily create a plot for any data set by adding a ggplot()
# command after a pipe.
# For example, Do items higher in fat tend to have more salt?
fastfood |> 
  ggplot(aes(x = total_fat, y = sodium)) +
  geom_point()

# A plot is built one layer at a time
# The first command tells R which variable should go on the x-axis,
# and which should go on the y-axis. Additional layers are added
# by typing a `+` and starting a new line.
# The second command, geom_point(), tells R to make it a scatter plot
# What if we wanted a trend line? We can use `+` to add a new line:
fastfood |> 
  ggplot(aes(x = total_fat, y = sodium)) +
  geom_point() +
  geom_smooth(method = "lm", se = FALSE)

# geom_smooth() tells R to add a trendline.
# The argument (method = "lm") tells R to make it a linear regression.
# The second argument (se = FALSE) means "Don't show standard error"

# Plots in ggplot are completely customizable. 
# Perhaps you'd like different colored points? Or a wider line?
# Just add arguments to geom_point()
fastfood |> 
  ggplot(aes(x = total_fat, y = sodium)) +
  geom_point(color = "brown") +
  geom_smooth(method = "lm", se = FALSE, linewidth = 2)

# You can add as many features as you'd like to your plot
# How about a title? We can add that using `+`
# Try it for yourself. 
# Find the "title = " argument below, and put your title between the
# quotes!
fastfood |> 
  ggplot(aes(x = total_fat, y = sodium)) +
  geom_point(color = "brown") +
  geom_smooth(method = "lm", se = FALSE, linewidth = 2) +
  theme(plot.title = element_text(hjust = 0.5, size = 18)) +
  labs(
    title = ""
  )

# With ggplot you can make publication-ready plots in minutes!

# ==================================================
# Section 4: Putting It All Together
# ==================================================

# We will now use the skills we've learned to explore a simple question:
# Are any of these fast food restaurants healthier than the others?
# Let's focus on one variable: total_fat

# Can you find the mean total_fat for each restaurant?
# You'll need to use group_by() and summarize()
_____Delete this line and insert code here_____

# One of them seems to be the lowest.
# Let's confirm this visually with a boxplot
fastfood |> 
  ggplot(aes(x = restaurant, y = total_fat)) +
  geom_boxplot()

# The plot is informative, but how about adding a little color?
# We can color-code each boxplot by restaurant using a fill argument:
fastfood |> 
  ggplot(aes(x = restaurant, y = total_fat, fill = restaurant)) +
  geom_boxplot(color = "black")

# It looks like items from Sonic have, on average, highest total_fat
# Chick Fil-A seems to be the lowest.
# Is there a significant difference between the two?

# Let's find out by filtering our data down to just the relevant information
# The filter() command below will give us items from Sonic or
# Chick Fil-A only.
# Add a pipe and select only the following variables:
# restaurant, item, and total_fat
fastfood |> 
  filter(restaurant == "Sonic" | restaurant == "Chick Fil-A")

# When we create a subset of data, it can often be convenient
# to save it to a new data frame. 
# In R this is done using the "<-" command.
# This code saves our filtered data to a new data frame called "fat"
fat <- fastfood |> 
  filter(restaurant == "Sonic" | restaurant == "Chick Fil-A") |> 
  select(restaurant, item, total_fat)

# Use head() or View() on our new data frame "fat" to confirm:
_____Delete this line and insert code here_____

# Let's double-check: Find the mean total_fat for both
# Sonic and Chick Fil-A. Use group_by() and summarize()
_____Delete this line and insert code here_____

# There seems to be a big difference! Let's confirm that with a t-test.
# Several basic statistical tests are built into R:

# In the command below, we put the variable we want to test
# to the left of the tilde sign: (total_fat).
# We put the grouping variable (restaurant) on the right hand side.
# Finally, the "data =" argument tells R where to look for the data.
t.test(total_fat ~ restaurant, data = fat)

# Can you find the p-value in the test results?
# What can you conclude?


# -------------------------------------
# This is the end of our R workshop.  |
# I hope you've enjoyed it!          |
# -----------------------------------