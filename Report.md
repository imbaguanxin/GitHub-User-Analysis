## Data Collection

###  Data through GitHub API
In this part, we made use of GitHub API to fetch users and repositories information and stored them in a mongoDB.

We view the entire community as a social network. As a result, we can represent this community using a graph. We try to use a breath first search to go through this graph. However, compared to the hourly limitation of accessing the API (5000 per hour), there are simply too many of the users out in the wild. We managed to download about 30 thousand users' information to our data base in about 10 hours. After fetching users' information, we tried to explore their repositories. We go through the entire list of users and download their repositories to our data base. Finally we managed to fetch about 650 thousand repositories.

### Data through GHTorrent

GHTorrent is a project that stores all the activities on GitHub every day, including commits, commit comments, user information change, issues, etc. We can download all the activities of a given day from its download center in the form of MongoDB dumps (bson files). We made used of data on 04/01/2019, 04/15/2018, 4/15/2017, 4/15/2016.
