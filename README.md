# GitHub User Analysis
[![LICENSE](https://img.shields.io/badge/license-Anti%20996-blue.svg)](https://github.com/996icu/996.ICU/blob/master/LICENSE)
### Members: Xin Guan | Ziqian Ge

GitHub is one of the biggest open source community and a large proportion of programmer do have a GitHub account. As a result, we think GitHub users are a good representation of all programmers.

## Data sources
For our project, we will be gathering as much GitHub user’s information as possible including:
- name
- location
- email
- repositories

Also, we are going to get the data relating to economic, population and high-tech industry from:
- OECD database
- American Bureau of Labor Statistic

We would like to retrieve data to a local database and clean them.

## Analysis
The analysis will include two part.
- GitHub user’s biography:

  We are trying to understand where are they, what institute do they work for, and how do they introduce themselves
  their repositories.
- GitHub user’s repositories:

  We are trying to look at what language do they use and Characteristic of their repositories

## Prediction
We are trying to predict the the popularity of a user's repository based ou given user and given user's other repositories.

We also would like to predict a user's identity from given information on repositories.

We are using regressions and simple machine learning techniques in predictions above.

## Tools and Approaches
Tools we use:
- GitHub API
- R Language
- MongoDB

We will try our best to keep our code in R. Since some data might not be available through Github API, we might use use third-party GitHub data, such as GHTorrent, and GHArchive. However, we would rather try to fetch data by ourselves so that the process of getting unbiased data is crystal clear to us.

## How to use Data_Collector.Rmd?

Data_Collector.rmd is trying to fetch all the users by go through the graph of users.
In the `set up` block, I just start populate the database with my own GitHub account.
I store me and my friends (followers and followings) in **unfetched** collection.
Then I go through the **unfetched** collection and get their friends to the **unfetched** collection.
After go through a single person, I move that person to **user** collection.
Consequently, people in **user** are those who have been processed while those in **unfetched** needs to be processed.
Each time going through **unfetched** collection helps me get people in to **user** collection.

1. Replace GitHub Api key in the Rmd file with your own key.
2. Set up a mongoDB and save the url and port information. Then connect to your mongoDB.
3. Go to code block named `set up`. replace the api url of the author with whichever GitHub user you like. If you decide not to change, the data might be biased since I am Chinese and my followers and followings are also Chinese. If you are not going run the `start fetch` for multiple time, you might be restricted to a Chinese GitHub community.
3. run the rest of the code.
4. run the last block whoes name is `start fetch` multiple time populates the data base.

After fetching all the users, there is another part that fetches user's repository, try to run that block will fetch all the repositories owned by users in db.userNoRepo. You can change the db as well.

There is a block of code trying to export all repositories along with their owners information. It take a lot of time to run that block if you have a large number of repositories. I didn't managed to export all repositories we have (~610k). I only exported a small sample (~8k)
