# title: "repo analysis"
# author: "ZiqianGe"
# date: "4/7/2019"

# set up
library(mongolite)
library(tidyverse)
library(tidyverse)
library(class)
library(e1071)
library(MLmetrics)
# -----------------------------------------------------------------------------------------------------

#Build connections to MongoDB databases.
#Databases below named after a date are databases downloaded from GHtorrent.
#Others are databases fetched by ourselves.

userdb_190401 <- mongo(db = "users", collection = "users_190401", url = "mongodb://127.0.0.1:27017")
repodb_190401 <- mongo(db = "repos", collection = "repos_190401", url = "mongodb://127.0.0.1:27017")
userdb_180415 <- mongo(db = "users", collection = "users_180415", url = "mongodb://127.0.0.1:27017")
repodb_180415 <- mongo(db = "repos", collection = "repos_180415", url = "mongodb://127.0.0.1:27017")
userdb_170415 <- mongo(db = "users", collection = "users_170415", url = "mongodb://127.0.0.1:27017")
repodb_170415 <- mongo(db = "repos", collection = "repos_170415", url = "mongodb://127.0.0.1:27017")
userdb_160415 <- mongo(db = "users", collection = "users_160415", url = "mongodb://127.0.0.1:27017")
repodb_160415 <- mongo(db = "repos", collection = "repos_160415", url = "mongodb://127.0.0.1:27017")
github_RepoUsers <- mongo(db = "github", collection = "repo_users", url = "mongodb://127.0.0.1:27017")
userdb_190401$import(file("/Volumes/LaCie/MongoDB/db/dump_2019_04_01/github/users.bson"), bson = TRUE)
#repodb_190401$import(file("/Volumes/LaCie/MongoDB/db/dump_2019_04_01/github/repos.bson"), bson = TRUE)
#userdb_190401$import(file("~/overview-f17/MongoDB/db/dump_2019_04_01/github/users.bson"), bson = TRUE)
repodb_190401$import(file("~/overview-f17/MongoDB/db/dump_2019_04_01/github/repos.bson"), bson = TRUE)
userdb_180415$import(file("/Volumes/LaCie/MongoDB/db/dump_2018_04_15/github/users.bson"), bson = TRUE)
repodb_180415$import(file("/Volumes/LaCie/MongoDB/db/dump_2018_04_15/github/repos.bson"), bson = TRUE)
userdb_170415$import(file("/Volumes/LaCie/MongoDB/db/dump_2017_04_15/github/users.bson"), bson = TRUE)
repodb_170415$import(file("/Volumes/LaCie/MongoDB/db/dump_2017_04_15/github/repos.bson"), bson = TRUE)
userdb_160415$import(file("/Volumes/LaCie/MongoDB/db/dump_2016_04_15/github/users.bson"), bson = TRUE)
repodb_160415$import(file("/Volumes/LaCie/MongoDB/db/dump_2016_04_15/github/repos.bson"), bson = TRUE)
# -----------------------------------------------------------------------------------------------------

#Quick view on trends of popular languages throughout years.

#Language distribution on Apr. 1st, 2019.
langs_190401 <- repodb_190401$find(fields = '{"_id" : false, "full_name" : true, "language" : true}')
cleanedLangs_190401 <- langs_190401 %>%
  na.omit() %>%
  distinct(full_name, .keep_all = TRUE) %>%
  group_by(language) %>%
  count() %>%
  arrange(desc(n))
cleanedLangs_190401$Percentage <- cleanedLangs_190401$n / sum(cleanedLangs_190401$n)
cleanedLangs_190401
ggplot(cleanedLangs_190401 %>% filter(Percentage > 0.01)) +
  geom_bar(mapping = aes(x = language, y = Percentage), stat = "identity") +
  theme(axis.text.x = element_text(vjust = 0.5, hjust = 1, angle = 90))
pieLangs_190406 <- cleanedLangs_190401 %>% head(10)
ggplot(pieLangs_190406, mapping = aes(x = "", y = Percentage, fill = language)) +
  geom_bar(width = 1, stat = "identity") +
  coord_polar(theta = "y") +
  theme_void()
# -----------------------------------------------------------------------------------------------------

# Language distribution on Apr. 15th, 2018.
langs_180415 <- repodb_180415$find(fields = '{"_id" : false, "full_name" : true, "language" : true}')
cleanedLangs_180415 <- langs_180415 %>%
  na.omit() %>%
  distinct(full_name, .keep_all = TRUE) %>%
  group_by(language) %>%
  count() %>%
  arrange(desc(n))
cleanedLangs_180415$Percentage <- cleanedLangs_180415$n / sum(cleanedLangs_180415$n)
# -----------------------------------------------------------------------------------------------------

# Language distribution on Apr. 15th, 2017.
langs_170415 <- repodb_170415$find(fields = '{"_id" : false, "full_name" : true, "language" : true}')
cleanedLangs_170415 <- langs_170415 %>%
  na.omit() %>%
  distinct(full_name, .keep_all = TRUE) %>%
  group_by(language) %>%
  count() %>%
  arrange(desc(n))
cleanedLangs_170415$Percentage <- cleanedLangs_170415$n / sum(cleanedLangs_170415$n)
cleanedLangs_170415
# -----------------------------------------------------------------------------------------------------

# Language distribution on Apr. 15th, 2016.
langs_160415 <- repodb_160415$find(fields = '{"_id" : false, "full_name" : true, "language" : true}')
cleanedLangs_160415 <- langs_160415 %>%
  na.omit() %>%
  distinct(full_name, .keep_all = TRUE) %>%
  group_by(language) %>%
  count() %>%
  arrange(desc(n))
cleanedLangs_160415$Percentage <- cleanedLangs_160415$n / sum(cleanedLangs_160415$n)
cleanedLangs_160415
ggplot(cleanedLangs_160415 %>% filter(Percentage > 0.01)) +
  geom_bar(mapping = aes(x = language, y = Percentage), stat = "identity") +
  theme(axis.text.x = element_text(vjust = 0.5, hjust = 1, angle = 90))
pieLangs_160415 <- cleanedLangs_160415 %>% head(10)
ggplot(pieLangs_160415, mapping = aes(x = "", y = Percentage, fill = language)) +
  geom_bar(width = 1, stat = "identity") +
  coord_polar(theta = "y") +
  theme_void()
# -----------------------------------------------------------------------------------------------------

# Comparison of trends on languages between years.
comparison <- cleanedLangs_190401 %>%
  inner_join(cleanedLangs_180415, by = "language") %>%
  inner_join(cleanedLangs_170415, by = "language") %>%
  inner_join(cleanedLangs_160415, by = "language")
colnames(comparison) <- c("language",
                          "190401", "Percentage_190401",
                          "180415", "Percentage_180415",
                          "170415", "Percentage_170415",
                          "160415", "Percentage_160415")
comparison <- comparison %>%
  arrange(desc(`Percentage_190401`
               + `Percentage_180415`
               + `Percentage_170415`
               + `Percentage_160415`))
comparison
comparison %>%
  filter(Percentage_190401 > 0.02) %>%
  gather(key = "date", value = "Percentage",
         -language, -`190401`, -`180415`, -`170415`, -`160415`) %>%
  ggplot(mapping = aes(x = language, y = Percentage, fill = date)) +
  geom_bar(width = 1, stat = "identity", position = "dodge") +
  theme(axis.text.x = element_text(vjust = 0.5, hjust = 1, angle = 90))
# -----------------------------------------------------------------------------------------------------


cleanedLangs_190401 %>% with(wordcloud(language, n, max.words = 100, colors=brewer.pal(8, "Dark2")))
cleanedLangs_160415 %>% with(wordcloud(language, n, max.words = 100, colors=brewer.pal(8, "Dark2")))


# The code below is trying to see if there is any relationship between properties of a repo.
repoProperties_190401 <- repodb_190401$find(
  fields = '{"_id" : false, "full_name" : true, "language" : true, "stargazers_count" : true, "forks_count" : true, "open_issues_count" : true, "subscribers_count" : true}')
repoProperties_190401 <- repoProperties_190401 %>%
  na.omit() %>%
  distinct(full_name, .keep_all = TRUE) %>%
  filter((stargazers_count > 0)
         | (forks_count > 0)
         | (open_issues_count > 0)
         | (subscribers_count > 0)) %>%
  arrange(desc(stargazers_count + forks_count + open_issues_count + subscribers_count))
avgForks <- mean(repoProperties_190401$forks_count)
stdDevForks <- sd(repoProperties_190401$forks_count)
avgIssues <- mean(repoProperties_190401$open_issues_count)
stdDevIssues <- sd(repoProperties_190401$open_issues_count)
avgStars <- mean(repoProperties_190401$stargazers_count)
stdDevStars <- sd(repoProperties_190401$stargazers_count)
avgSubs <- mean(repoProperties_190401$subscribers_count)
stdDevSubs <- sd(repoProperties_190401$subscribers_count)
repoProperties_190401 <- repoProperties_190401 %>%
  filter(forks_count > avgForks - 3 * stdDevForks & forks_count < avgForks + 3 * stdDevForks) %>%
  filter(open_issues_count > avgIssues - 3 * stdDevIssues & open_issues_count < avgIssues + 3 * stdDevIssues) %>%
  filter(stargazers_count > avgStars - 3 * stdDevStars & stargazers_count < avgStars + 3 * stdDevStars) %>%
  filter(subscribers_count > avgSubs - 3 * stdDevSubs & subscribers_count < avgSubs + 3 * stdDevSubs)

repoProperties_190401 %>% 
  ggplot(mapping = aes(x = forks_count, y = open_issues_count)) +
  geom_point() +
  geom_smooth()
repoProperties_190401 %>% 
  ggplot(mapping = aes(x = forks_count, y = stargazers_count)) +
  geom_point() +
  geom_smooth()
repoProperties_190401 %>% 
  ggplot(mapping = aes(x = forks_count, y = subscribers_count)) +
  geom_point() +
  geom_smooth()
repoProperties_190401 %>% 
  ggplot(mapping = aes(x = open_issues_count, y = stargazers_count)) +
  geom_point() +
  geom_smooth()
repoProperties_190401 %>% 
  ggplot(mapping = aes(x = open_issues_count, y = subscribers_count)) +
  geom_point() +
  geom_smooth()
repoProperties_190401 %>% 
  ggplot(mapping = aes(x = stargazers_count, y = subscribers_count)) +
  geom_point() +
  geom_smooth()

