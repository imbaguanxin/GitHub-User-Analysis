# title: "Prediction"
# author: "Xin Guan | Ziqian Ge"
# date: "4/16/2019"
  
# r setup
library(tidyverse)
library(MLmetrics)
library(class)
library(caret)
# ---------------------------------------------------------------------------------------


# Normalize variables and attempt to make an artificial representative of popularity of a repo.
normalize <- function(x) {
  numerator <- x
  denominator <- max(x)
  #print((numerator * 10) /denominator)
  return((numerator) /denominator)
}

popularity_index <- function(repos) {
  pop_i <- (repos$stargazers_count + 1) %>% normalize()
  pop_i <- pop_i + ((repos$watchers_count + 1) %>% normalize())
  pop_i <- pop_i + ((repos$forks_count + 1) %>% normalize())
  pop_i <- pop_i + ((repos$open_issues_count + 1) %>% normalize())
  return(pop_i / 4)
}
# ---------------------------------------------------------------------------------------

# Attempt to predict popularity index by other properties of a repo and its owner.

# One of our machine was continuously fetching data.
# We output some sample data out to do further analysis.
repo_input <- read.csv("repo_user.csv", stringsAsFactors = FALSE)

repo_input$popularity_normalized <- repo_input %>% popularity_index()
repo_input <- repo_input %>% na.omit()

avg_pi <- mean(repo_input$popularity_normalized)
std_pi <- sd(repo_input$popularity_normalized)
repo_input <- repo_input %>%
  filter(popularity_normalized <= avg_pi + 3 * std_pi | popularity_normalized <= avg_pi + 3 * std_pi)

possibleLanguage <- repo_input$language %>% unique()
training_set <- data.frame()
testing_set <- data.frame()
for (lan in possibleLanguage){
  df <- repo_input %>% filter(language == lan)
  testing_number <- sample(c(1:nrow(df)), size = floor(nrow(df) * 0.5), replace = FALSE)
  this_test <- df[testing_number,]
  this_train <- df[-testing_number,]
  testing_set <- testing_set %>% rbind(this_test)
  training_set <- training_set %>% rbind(this_train)
}

# The two models below are models that only use quantifiable properties.
model_lm_quantifiable <-
  lm(formula = popularity_normalized ~ public_repos + public_gists + followers + following,
     data = training_set)

model_glm_quantifiable <-
  glm(formula = popularity_normalized ~ public_repos + public_gists + followers + following,
      data = training_set,
      family = binomial)

# The two models below use all variables, including both quantifiable and categorizable properties.
model_lm <-
  lm(formula = popularity_normalized ~ public_repos + public_gists + followers + following + student + professor + engineer + university + language,
     data = training_set)

model_glm <-
  glm(formula = popularity_normalized ~ public_repos + public_gists + followers + following + student + professor + engineer + university + language,
      data = training_set,
      family = binomial)

summary(model_lm)
summary(model_glm)
# ---------------------------------------------------------------------------------------

#Use linear regression on quantifiable columns only.

probs <- predict(model_lm_quantifiable, newdata = testing_set, type = "response")
#head(testing_set$popularity_normalized)
#head(probs)
comparing <- data.frame(probs %>% as.vector(), testing_set$popularity_normalized)
colnames(comparing) <- c("prediction", "actual")
accuracies <- abs(probs - testing_set$popularity_normalized)/testing_set$popularity_normalized
accuracies[accuracies < 1] %>% length() / nrow(testing_set)
# ---------------------------------------------------------------------------------------

# Use logistic regression on quantifiable columns only.

probs <- predict(model_glm_quantifiable, newdata = testing_set, type = "response")
#head(testing_set$popularity_normalized)
#head(probs)
comparing <- data.frame(probs %>% as.vector(), testing_set$popularity_normalized)
colnames(comparing) <- c("prediction", "actual")
accuracies <- abs(probs - testing_set$popularity_normalized)/testing_set$popularity_normalized
accuracies[accuracies < 1] %>% length() / nrow(testing_set)


# Use linear regression on all possible columns.

probs <- predict(model_lm, newdata = testing_set, type = "response")
#head(testing_set$popularity_normalized)
#head(probs)
comparing <- data.frame(probs %>% as.vector(), testing_set$popularity_normalized)
colnames(comparing) <- c("prediction", "actual")
accuracies <- abs(probs - testing_set$popularity_normalized)/testing_set$popularity_normalized
accuracies[accuracies < 1] %>% length() / nrow(testing_set)
# ---------------------------------------------------------------------------------------

# Use logistic regression on all possible columns.

probs <- predict(model_glm, newdata = testing_set, type = "response")
#head(testing_set$popularity_normalized)
#head(probs)
comparing <- data.frame(probs %>% as.vector(), testing_set$popularity_normalized)
colnames(comparing) <- c("prediction", "actual")
accuracies <- abs(probs - testing_set$popularity_normalized)/testing_set$popularity_normalized
accuracies[accuracies < 1] %>% length() / nrow(testing_set)
# ---------------------------------------------------------------------------------------

# Since it is not accurate when predicting a artificial representative of popularity,
# especially that it is a countinuous variable, we turned our direction to predict binary properties.
# We start from student.

# The two models below are models that only use quantifiable properties.
model_lm_student_quantifiable <-
  lm(formula = student ~ public_repos + public_gists + followers + following,
     data = training_set)

model_glm_student_quantifiable <-
  glm(formula = student ~ public_repos + public_gists + followers + following,
      data = training_set,
      family = binomial)

# The two models below use all variables, including both quantifiable and categorizable properties.
model_lm_student <-
  lm(formula = student ~ public_repos + public_gists + followers + following + professor + engineer + university,
     data = training_set)

model_glm_student <-
  glm(formula = student ~ public_repos + public_gists + followers + following + professor + engineer + university,
      data = training_set,
      family = binomial)

summary(model_lm_student_quantifiable)
summary(model_glm_student_quantifiable)
summary(model_lm_student_lang)
summary(model_glm_student_lang)
# ---------------------------------------------------------------------------------------

# Use linear regression on quantifiable columns only.

probs <- predict(model_lm_student_quantifiable, newdata = testing_set, type = "response") %>% as.vector()
preds <- ifelse(probs > 0.5, TRUE, FALSE)
comparing <- tibble(Probability = probs, Predict = preds, Actual = testing_set$student)
caret::confusionMatrix(factor(comparing$Predict), factor(comparing$Actual))
# ---------------------------------------------------------------------------------------

# Use logistic regression on quantifiable columns only.

probs <- predict(model_glm_student_quantifiable, newdata = testing_set, type = "response") %>% as.vector()
preds <- ifelse(probs > 0.5, TRUE, FALSE)
comparing <- tibble(Probability = probs, Predict = preds, Actual = testing_set$student)
caret::confusionMatrix(factor(comparing$Predict), factor(comparing$Actual))
# ---------------------------------------------------------------------------------------

# Use linear regression on all possible columns.

probs <- predict(model_lm_student, newdata = testing_set, type = "response") %>% as.vector()
preds <- ifelse(probs > 0.5, TRUE, FALSE)
comparing <- tibble(Probability = probs, Predict = preds, Actual = testing_set$student)
caret::confusionMatrix(factor(comparing$Predict), factor(comparing$Actual))
# ---------------------------------------------------------------------------------------

# Use logistic regression on all possible columns.

probs <- predict(model_glm_student, newdata = testing_set, type = "response") %>% as.vector()
preds <- ifelse(probs > 0.5, TRUE, FALSE)
comparing <- tibble(Probability = probs, Predict = preds, Actual = testing_set$student)
caret::confusionMatrix(factor(comparing$Predict), factor(comparing$Actual))
# ---------------------------------------------------------------------------------------

# Then comes to professor.

model_lm_professor_quantifiable <-
  lm(formula = professor ~ public_repos + public_gists + followers + following,
     data = training_set)

model_glm_professor_quantifiable <-
  glm(formula = professor ~ public_repos + public_gists + followers + following,
      data = training_set,
      family = binomial)

model_lm_professor <-
  lm(formula = professor ~ public_repos + public_gists + followers + following + student + engineer + university,
     data = training_set)

model_glm_professor <-
  glm(formula = professor ~ public_repos + public_gists + followers + following + student + engineer + university,
      data = training_set,
      family = binomial)

summary(model_lm_professor_quantifiable)
summary(model_glm_professor_quantifiable)
summary(model_lm_professor)
summary(model_glm_professor)
# ---------------------------------------------------------------------------------------

# Use linear regression on quantifiable columns only.

probs <- predict(model_lm_professor_quantifiable, newdata = testing_set, type = "response") %>% as.vector()
preds <- ifelse(probs > 0.5, TRUE, FALSE)
comparing <- tibble(Probability = probs, Predict = preds, Actual = testing_set$professor)
caret::confusionMatrix(factor(comparing$Predict), factor(comparing$Actual))
# ---------------------------------------------------------------------------------------

# Use logistic regression on quantifiable columns only.

probs <- predict(model_glm_professor_quantifiable, newdata = testing_set, type = "response") %>% as.vector()
preds <- ifelse(probs > 0.5, TRUE, FALSE)
comparing <- tibble(Probability = probs, Predict = preds, Actual = testing_set$professor)
caret::confusionMatrix(factor(comparing$Predict), factor(comparing$Actual))
# ---------------------------------------------------------------------------------------

# Use linear regression on all possible columns.

probs <- predict(model_lm_professor, newdata = testing_set, type = "response") %>% as.vector()
preds <- ifelse(probs > 0.5, TRUE, FALSE)
comparing <- tibble(Probability = probs, Predict = preds, Actual = testing_set$professor)
caret::confusionMatrix(factor(comparing$Predict), factor(comparing$Actual))
# ---------------------------------------------------------------------------------------

# Use logistic regression on all possible columns.

probs <- predict(model_glm_professor, newdata = testing_set, type = "response") %>% as.vector()
preds <- ifelse(probs > 0.5, TRUE, FALSE)
comparing <- tibble(Probability = probs, Predict = preds, Actual = testing_set$professor)
caret::confusionMatrix(factor(comparing$Predict), factor(comparing$Actual))


# Then comes to engineer.

model_lm_engineer_quantifiable <-
  lm(formula = engineer ~ public_repos + public_gists + followers + following,
     data = training_set)

model_glm_engineer_quantifiable <-
  glm(formula = engineer ~ public_repos + public_gists + followers + following,
      data = training_set,
      family = binomial)

model_lm_engineer <-
  lm(formula = engineer ~ public_repos + public_gists + followers + following + student + professor + university,
     data = training_set)

model_glm_engineer <-
  glm(formula = engineer ~ public_repos + public_gists + followers + following + student + professor + university,
      data = training_set,
      family = binomial)

summary(model_lm_engineer_quantifiable)
summary(model_glm_engineer_quantifiable)
summary(model_lm_engineer)
summary(model_glm_engineer)
# ---------------------------------------------------------------------------------------

# Use linear regression on quantifiable columns only.
probs <- predict(model_lm_engineer_quantifiable, newdata = testing_set, type = "response") %>% as.vector()
preds <- ifelse(probs > 0.5, TRUE, FALSE)
comparing <- tibble(Probability = probs, Predict = preds, Actual = testing_set$engineer)
caret::confusionMatrix(factor(comparing$Predict), factor(comparing$Actual))
# ---------------------------------------------------------------------------------------

# Use logistic regression on quantifiable columns only.

probs <- predict(model_glm_engineer_quantifiable, newdata = testing_set, type = "response") %>% as.vector()
preds <- ifelse(probs > 0.5, TRUE, FALSE)
comparing <- tibble(Probability = probs, Predict = preds, Actual = testing_set$engineer)
caret::confusionMatrix(factor(comparing$Predict), factor(comparing$Actual))
# ---------------------------------------------------------------------------------------


# Use linear regression on all possible columns.

probs <- predict(model_lm_engineer, newdata = testing_set, type = "response") %>% as.vector()
preds <- ifelse(probs > 0.5, TRUE, FALSE)
comparing <- tibble(Probability = probs, Predict = preds, Actual = testing_set$engineer)
caret::confusionMatrix(factor(comparing$Predict), factor(comparing$Actual))
# ---------------------------------------------------------------------------------------

# Use logistic regression on all possible columns.

probs <- predict(model_glm_engineer, newdata = testing_set, type = "response") %>% as.vector()
preds <- ifelse(probs > 0.5, TRUE, FALSE)
comparing <- tibble(Probability = probs, Predict = preds, Actual = testing_set$engineer)
caret::confusionMatrix(factor(comparing$Predict), factor(comparing$Actual))
# ---------------------------------------------------------------------------------------

# Then comes to university

model_lm_university_quantifiable <-
  lm(formula = university ~ public_repos + public_gists + followers + following,
     data = training_set)

model_glm_university_quantifiable <-
  glm(formula = university ~ public_repos + public_gists + followers + following,
      data = training_set,
      family = binomial)

model_lm_university <-
  lm(formula = university ~ public_repos + public_gists + followers + following + student + professor + engineer,
     data = training_set)

model_glm_university <-
  glm(formula = university ~ public_repos + public_gists + followers + following + student + professor + engineer,
      data = training_set,
      family = binomial)

summary(model_lm_university_quantifiable)
summary(model_glm_university_quantifiable)
summary(model_lm_university)
summary(model_glm_university)
# ---------------------------------------------------------------------------------------

# Use linear regression on quantifiable columns only.

probs <- predict(model_lm_university_quantifiable, newdata = testing_set, type = "response") %>% as.vector()
preds <- ifelse(probs > 0.5, TRUE, FALSE)
comparing <- tibble(Probability = probs, Predict = preds, Actual = testing_set$university)
caret::confusionMatrix(factor(comparing$Predict), factor(comparing$Actual))
# ---------------------------------------------------------------------------------------

# Use logistic regression on quantifiable columns only.

probs <- predict(model_glm_university_quantifiable, newdata = testing_set, type = "response") %>% as.vector()
preds <- ifelse(probs > 0.5, TRUE, FALSE)
comparing <- tibble(Probability = probs, Predict = preds, Actual = testing_set$university)
caret::confusionMatrix(factor(comparing$Predict), factor(comparing$Actual))
# ---------------------------------------------------------------------------------------


# Use linear regression on all possible columns.

probs <- predict(model_lm_university, newdata = testing_set, type = "response") %>% as.vector()
preds <- ifelse(probs > 0.5, TRUE, FALSE)
comparing <- tibble(Probability = probs, Predict = preds, Actual = testing_set$university)
caret::confusionMatrix(factor(comparing$Predict), factor(comparing$Actual))
# ---------------------------------------------------------------------------------------


# Use logistic regression on all possible columns.

probs <- predict(model_glm_university, newdata = testing_set, type = "response") %>% as.vector()
preds <- ifelse(probs > 0.5, TRUE, FALSE)
comparing <- tibble(Probability = probs, Predict = preds, Actual = testing_set$university)
caret::confusionMatrix(factor(comparing$Predict), factor(comparing$Actual))
# ---------------------------------------------------------------------------------------

# We now try to use knn algorithm to build a machine learning model to predict binary properties just like what we have done above.

summary_users <- function(repo_in){
  users <- repo_in$owner %>% unique()
  users_summary <- data.frame()
  for (uid in users){
    df <- repo_in %>% filter(owner == uid)
    single_user_sum <- data.frame()
    id <- uid
    size <- df$size %>% mean()
    repo <- df$public_repos %>% mean()
    gist <- df$public_gists %>% mean()
    following <- df$following %>% mean()
    follower <- df$followers %>% mean()
    stargazer <- df$stargazers_count %>% mean()
    watcher <- df$watchers_count %>% mean()
    fork <- df$forks_count %>% mean()
    issue <- df$open_issues_count %>% mean()
    student <- df$student[1]
    professor <- df$professor[1]
    engineer <- df$engineer[1]
    university <- df$university[1]
    language <- df %>% group_by(language) %>% count() %>% arrange(desc(n))
    if (language %>% length > 0){
      language <- language %>% head(1)
      language <- language[1,1] %>% toString()
    } else {
      language <- NA
    }
    single_user_sum <- data.frame(id,size,repo,gist,following,follower,
                                  stargazer,watcher,fork,issue,language,
                                  student,professor,engineer,university)
    users_summary <- users_summary %>% rbind(single_user_sum)
  }
  return(users_summary)
}


user_training_set <- summary_users(training_set) %>% select(-language)%>% na.omit()
user_testing_set <- summary_users(testing_set) %>% select(-language) %>% na.omit()
# knn for students
pred1 <- knn(train = user_training_set %>% select(-c("id","professor","engineer","university")),
             test = user_testing_set%>% select(-c("id","professor","engineer","university")),
             cl = user_training_set$student %>% as.factor(), k = 3)
Accuracy(user_testing_set$student,pred1)
pred2 <- knn(train = user_training_set %>% select(-c("id","student","engineer","university")),
             test = user_testing_set%>% select(-c("id","student","engineer","university")),
             cl = user_training_set$professor %>% as.factor(), k = 3)
Accuracy(user_testing_set$professor,pred2)
pred3 <- knn(train = user_training_set %>% select(-c("id","student","professor","university")),
             test = user_testing_set%>% select(-c("id","student","professor","university")),
             cl = user_training_set$engineer %>% as.factor(), k = 3)
Accuracy(user_testing_set$engineer,pred3)
pred4 <- knn(train = user_training_set %>% select(-c("id","student","professor","engineer")),
             test = user_testing_set%>% select(-c("id","student","professor","engineer")),
             cl = user_training_set$university %>% as.factor(), k = 3)
Accuracy(user_testing_set$university,pred4)

