# Who is GitHub user and How do they impact the world
### Members: Ziqian Ge | Xin Guan

GitHub is one of the biggest open source community and a large proportion of programmer do have a GitHub account. As a result, we think GitHub users are a good representation of all programmers.

## Data sources
For our project, we will be gathering as much GitHub user’s information as possible including:
- name
- location
- email
- contributions
- repositories. 

Also, we are going to get the data relating to economic, population and high-tech industry from:
- OECD database
- American Bureau of Labor Statistic

We would like to retrieve data to a local database and clean them.

## Analysis
The analysis will include two part. 
- GitHub user’s biography:
  We are trying to understand where are they, what institute do they work for, what language do they use and how do they contribute to
  their repositories. 
- Relate these users back to real life:
  We might look at the relationship between GitHub user’s geometry distribution and the high-tech industries’ distribution. We are also
  interested in how these users affect the local income, education level, and even the crime rate. 

## Prediction
We are trying to predict the place where high-tech industry develops the best given GitHub user’s contribution in a particular year. We may use linear regression and Bayes model to support our prediction.

## Tools and Approaches
We are planning to use Github API to get user data, but some data might not be available through Github API. We will try our best to keep our code in R. However, we might use Python to generate the GitHub user information since the official web crawler is written in Python. Meanwhile, we do have the choice to use third-party GitHub data, such as GHTorrent, and GHArchive. However, we would rather try to fetch data by ourselves so that the process of getting unbiased data is crystal clear to us.
