# Instagram user engagement analysis using SQL
## Project overview
-This project analyzes Instagram-style social media data using SQL to identify user engagement patterns, influencers, inactive users and content interaction trends.
-The analysis was performed on multiple relational tables including users, photos, likes, comments, follows and tags.

## Business Problem
Social media platforms need to understand user behaviour and engagement patterns to improve user retention, identify influencers and increase platform activity.

## Objectives
- Analyze user engagement and activity
- Identify top influencers based on followers and engagement
- Detect inactive users
- Perform user segmentation analysis
- Study interaction trends between posts, likes and comments

## Dataset Information
The project contains : 
- 100 users
- Photos dataset
- Likes dataset
- Comments dataset
- Follows dataset
- Tags dataset

## Tools & technologies used
- MySQL
- SQL
- PowerPoint
- GitHub

## SQL Concepts used 
- Joins
- Group By
- Having
- Subqueries
- Common Table Expressions (CTEs)
- Aggregate Functions
- CASE Statements

## Key Insights
- Strong positive correlation found between posts and likes (-0.99)
- Highly engaged users generated maximum platform interactions
- Some users were completely inactive and required re-engagement strategies
- Influencers had high follower counts and engagement rates
- User activity distribution showed unequal engagement across the platform

## Sample SQL Query 
'''sql
SELECT u.username,
       COUNT(l.photo_id) as total_likes
FROM users u 
JOIN photos p 
ON u.id = p.user_id
JOIN likes l 
ON p.id = l.photo_id
GROUP BY u.username
ORDER BY total_likes DESC;
