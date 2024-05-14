#Load required packages
library(tidyverse)
library(readxl)
library(dplyr)
library(R.utils)
library(janitor)
library(stargazer)
#load the dataset
load("C:/Users/Njoroge/Desktop/EUROPE/Canda_election_2021_data.RData")
##Selecting the chosen variables to be used in the analysis
attach(ces21.data)
RAD <-ces21.data %>% select(c(cps21_religion, cps21_income_cat,
                              cps21_ownfinanc_fed, cps21_education, cps21_genderid))
detach(ces21.data)
head(RAD)
#Remove any missing values
RAD <- na.omit(RAD)
#Question 3
## Descriptive statsistics  with standard error and margin of error included
stats_finance <- RAD %>% 
  summarise(mean_finance = mean(cps21_ownfinanc_fed),
            median_finance = median(cps21_ownfinanc_fed),
            sd_finance = sd(cps21_ownfinanc_fed),
            min_finance = sd(cps21_ownfinanc_fed),
            se_finance = sd(cps21_ownfinanc_fed) / sqrt(length(cps21_ownfinanc_fed)),
            max_finance = max(cps21_ownfinanc_fed),
            margin_of_error_finance = 2 * sd_finance)
print(stats_finance)

stats_education <- RAD %>% 
  summarise(mean_edu = mean(cps21_education),
            median_edu = median(cps21_education),
            sd_edu = sd(cps21_education),
            min_edu = sd(cps21_education),
            max_edu = max(cps21_education),
            se_edu = sd(cps21_education) / sqrt(length(cps21_education)),
            margin_of_error_education = 2 * sd_edu)
print(stats_education)
stats_religion <- RAD %>% 
  summarise(mean_Relig = mean(cps21_religion),
            median_Relig = median(cps21_religion),
            sd_Relig = sd(cps21_religion),
            min_Relig = sd(cps21_religion),
            max_Relig = max(cps21_religion),
            se_edu = sd(cps21_religion) / sqrt(length(cps21_religion)),
            margin_of_error_religion = 2 * sd_Relig)
print(stats_religion)

stats_gender <- RAD %>% 
  summarise(mean_gend = mean(cps21_genderid),
            median_gend = median(cps21_genderid),
            sd_gend = sd(cps21_genderid),
            min_gend = sd(cps21_genderid),
            se_gend = sd(cps21_genderid) / sqrt(length(cps21_genderid)),
            max_gend = max(cps21_genderid),
            margin_of_error = 2*sd_gend)
print(stats_gender)

library(ggplot2)
# Assuming RAD is your data frame
ggplot(RAD, aes(x = cps21_ownfinanc_fed)) +
  geom_bar() +
  ggtitle("The bar graph showing the distribution of voters by their personal finances") +
  theme_bw()

#From the  bar graph  we can tell that  most  of the  subjects in the survey are in the middle lvel and
#also ownfinance follows normal distribution.


## A two way contingency table of gender and education, it shows the 
## frequency of each combination of gender and education levels amd then in persentages
cross_table <- table(RAD$cps21_education , RAD$cps21_genderid )
#Converting the table to  percentages
crosstab_percentage <-  prop.table(cross_table) * 100
print(crosstab_percentage)
#The table above has shown the descriptives of the confounding variables using 
#table functiom
unique(RAD$cps21_education)

#Below we are going top cut education in to two groups
#First we create  a mapping for grouping where education level 1 to 6 in Group 1  while 7 to 12 is Group 12
grouping_map <- ifelse(RAD$cps21_education %in% c(1, 2, 3, 4, 5, 6), "Group1", "Group2")
#Add the newly made variable based on grouping
RAD <- RAD %>% 
  mutate(new_category = factor(grouping_map, levels =  c("Group1", "Group2")))

#Now lets divide the dependent variable finance  in to two based on the newly created category
Finance_0 <- RAD$cps21_ownfinanc_fed[RAD$new_category == "Group1"]
Finance_1 <- RAD$cps21_ownfinanc_fed[RAD$new_category == "Group2"]

#Now performing ttest(Difference of means)
t_test_result <- t.test(Finance_0, Finance_1) 

#Print t-statistic and p-value
cat("t-statistic:", t_test_result$statistic, "\n")
cat("p-value:", t_test_result$p.value, "\n")


######
#Using option 1
#Under this part which is part 2 here I used option 1 where I repeated the regression but with a new but related
#dependent variable(income)
#The linear regrission on  assignment 3
model <-lm(cps21_ownfinanc_fed ~ cps21_education + cps21_genderid +
             cps21_religion, RAD)
summary(model)

#Now the new multiple linear regression using income category as the new dependent variable
new_model <- lm(cps21_income_cat ~ cps21_education + cps21_genderid +
                  cps21_religion, RAD)
summary(new_model)

#From the output of the new model we see that the education variable has a positive impact on the income  compared to the previous model in which it had a negative impact
#We see that religion also has had a positive impact compared to the last model in which it showed a negative impact

