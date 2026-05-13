 /*Total Posts*/
 Select count(*) as total_posts from photos; 
 
 /*checking duplicate and null values*/
select count(*) from comments
where id is null 
or comment_text is null
or user_id is null
or photo_id is null
or created_at is null;

select * from follows 
where follower_id is null
or followee_id is null
or created_at is null;

select * from likes
where user_id is null
or photo_id is null
or created_at is null;

select * from photo_tags
where photo_id is null
or tag_id is null;

select * from photos
where id is null
or image_url is null
or user_id is null
or created_dat is null;

select * from tags
where id is null
or tag_name is null
or created_at is null;

select * from users
where id is null
or username is null
or created_at is null;


select
      id,
      count(*)
from users
group by id
having count(*) > 1;

select
      user_id,
      photo_id,
      count(*) as count
from likes
group by user_id,photo_id
having count(*) > 1;

select
      follower_id,
      followee_id,
      count(*)
from follows
group by follower_id,followee_id
having count(*) > 1;

select * from follows
where follower_id = followee_id;

select
      photo_id,
      tag_id,
      count(*) as count
from photo_tags
group by photo_id,tag_id
having count(*) > 1;

select
      id,
      count(*)
from comments
group by id
having count(*) > 1;

select 
      user_id,
      photo_id,
      comment_text,
      count(*)
from comments
group by user_id,photo_id,comment_text
having count(*) > 1;

select
      id,
      count(*)
from photos
group by id
having count(*) > 1;

select
      user_id,
      image_url,
      count(*)
from photos
group by user_id,image_url
having count(*) > 1;

select 
      id,
      count(*)
from tags
group by id
having count(*) > 1;

select 
      tag_name,
      count(*)
from tags
group by tag_name
having count(*) > 1;

/*count of total posts, total comments, total likes for each user*/
Select
      u.id,
      count(distinct p.id) as TotalPosts,
      count(distinct l.photo_id) as TotalLikes,
      count(distinct c.id) as TotalComments
from users u 
left join photos p 
on u.id = p.user_id
left join likes l 
on u.id = l.user_id
left join comments c
on u.id = c.user_id
group by u.id;

select
      activity_level,
      count(*) as total_users
from (
	  select
			u.id,
	        case when count(p.id) = 0 then 'Inactive'
                 when count(p.id) between 1 and 3 then 'Low Activity'
                 when count(p.id) between 4 and 7 then 'Medium Activity'
                 else 'High activity'
           end as activity_level
from users u 
left join photos p 
on u.id = p.user_id
group by u.id) as user_activity
group by activity_level;

/*calculation of average tags per post*/
select
      avg(tag_count) as AvgTagsPerPost
from (
      select
            p.id as photoID,
            count(pt.tag_id) as tag_count
	  from photos p 
      left join photo_tags pt
      on p.id = pt.photo_id
      group by p.id
      )t;
      
select * from photo_tags;

/*Engagement rate and rank position for each user*/
select
      p.user_id,
      U.username,
      count(distinct l.user_id) + count(distinct c.id) as TotalEngagement,
      rank() over(order by count(distinct l.user_id) + count(distinct c.id) desc) as RankPosition
from photos p
left join users u 
on p.user_id =  u.id
left join likes l 
on p.id = l.photo_id
left join comments c 
on p.id = c.photo_id
group by p.user_id
order by RankPosition;

/*Total number of followers and following for each user*/
select
       u.id as userID,
       count(distinct f1.follower_id) as TotalFollowers,
       count(distinct f2.followee_id) as TotalFollowing
 from users u 
 left join follows f1 
 on u.id = f1.followee_id
 left join follows f2 
 on u.id = f2.follower_id
 group by u.id
 order by userID;
 
 /*calculation of average engagement rate for each user*/
 select
       p.user_id,
       count(distinct p.id) as total_posts,
       count(distinct l.user_id) + count(distinct c.id) as total_engagement,
       (count(distinct l.user_id) + count(distinct c.id)) / count(distinct p.id) as avg_engagemnt_per_post
from photos p 
left join likes l 
on p.id = l.photo_id
left join comments c 
on p.id = c.photo_id
group by p.user_id;

select
     user_id,
     count(*) as posts
from photos
group by user_id;


/*users who never liked any post*/
select
	  u.id,
      u.username
from users u 
left join likes l 
on u.id = l.user_id
where l.user_id is null;

/*correlations between user activity levels and specific content types*/
with user_stats as (
                    select
                          p.user_id,
                          count(distinct p.id) as posts,
                          count(distinct l.user_id) + count(distinct c.id) as engagement
				    from photos p 
                    left join likes l 
                    on p.id = l.photo_id
                    left join comments c 
                    on p.id = c.photo_id
                    group by p.user_id
                    )
select
      (avg(posts * engagement) - avg(posts) * avg(engagement)) /
      (stddev(posts) * stddev(engagement)) as correlation
from user_stats;

/*Relation between posts and engagement rate*/
select
	  p.user_id,
	  count(distinct p.id) as posts,
	  count(distinct l.user_id) + count(distinct c.id) as engagement
from photos p 
left join likes l 
on p.id = l.photo_id
left join comments c 
on p.id = c.photo_id
group by p.user_id
order by engagement desc
limit 30;


/*total number of likes, comments, and photo tags for each user*/
select 
      p.user_id,
      count(distinct l.user_id, l.photo_id) as total_likes,
      count(distinct c.id) as total_comments,
      count(distinct pt.tag_id, pt.photo_id) as total_tags
from photos p
left join likes l
on p.id = l.photo_id
left join comments c
on p.id = c.photo_id
left join photo_tags pt
on p.id = pt.photo_id
group by p.user_id;

/*Ranking of users based on their total engagement over a month*/
select
      p.user_id,
      count(distinct l.user_id,l.photo_id) + 
      count(distinct c.id) as total_engagement,
      rank() over(order by count(distinct l.user_id,l.photo_id) +
                           count(distinct c.id) desc) as rank_position
from photos p 
left join likes l 
on p.id = l.photo_id
and l.created_at >= curdate() - interval 1 month
left join comments c 
on p.id = c.photo_id
and c.created_at >= curdate() - interval 1 month
where p.created_dat >= curdate() - interval 1 month
group by p.user_id;

/*Hashtags associated with the posts having more than average number of likes*/
with hashtag_likes as (
                       select
                             t.tag_name,
                             count(l.photo_id) as total_likes,
                             count(distinct p.id) as total_posts,
                             count(l.photo_id) / count(distinct p.id) as avg_likes
					  from photo_tags pt 
                      join tags t 
                      on pt.tag_id = t.id
                      join photos p
                      on pt.photo_id = p.id
                      left join likes l 
                      on p.id = l.photo_id
                      group by t.tag_name
                      )
select * from hashtag_likes
order by avg_likes desc;

/*users who have started following someone after being followed by that person*/
select
      f2.follower_id as user_id,
      f2.followee_id as followed_back_user
from follows f1
join follows f2
on f1.follower_id = f2.followee_id
and f1.followee_id = f2.follower_id
where f2.created_at >= f1.created_at;

/*Users having high engagement score*/
select 
      u.id,
      u.username,
      count(distinct p.id) as total_posts,
      count(distinct l.user_id) as total_likes,
      count(distinct c.id) as total_comments,
      (count(distinct p.id) * 5 + count(distinct c.user_id) * 3 + count(distinct l.user_id) * 1) as engagement_score
from users u 
left join photos p 
on u.id = p.user_id
left join likes l 
on u.id = l.user_id
left join comments c 
on u.id = c.user_id
group by u.id, u.username
order by engagement_score desc
limit 10;

/*Content topics having highest engagement rates*/
select
      p.id as photo_id,
      p.image_url,
      count(distinct l.user_id) as total_likes,
      count(distinct c.user_id) as total_comments,
      (count(distinct l.user_id) + count(distinct c.user_id)) / count(distinct p.id) as engagement_rate
from photos p 
left join likes l 
on p.id = l.photo_id
left join comments c 
on p.id = c.photo_id 
group by p.id
order by engagement_rate desc
limit 10;

/*User engagement based on posting time*/
select
      hour(p.created_dat) as post_hour,
      count(distinct l.user_id) as total_likes,
      count(distinct c.user_id) as total_comments,
      (count(distinct l.user_id) + count(distinct c.user_id)) as engagement
from photos p 
left join likes l 
on p.id = l.photo_id
left join comments c 
on p.id = c.photo_id
group by hour(p.created_dat) 
order by engagement desc;

/*Total followers, likes, comments, engagement score for each user*/
select
      u.id as user_id,
      u.username,
      count(distinct f.follower_id) as total_followers,
      count(distinct l.photo_id) as total_likes,
      count(distinct c.photo_id) as total_comments,
      (count(distinct l.photo_id) + count(distinct c.photo_id)) as engagement_score
from users u 
left join follows f 
on u.id = f.followee_id
left join photos p
on u.id = p.user_id
left join likes l 
on p.id = l.photo_id
left join comments c 
on p.id = c.photo_id 
group by u.id
order by total_followers desc,engagement_score desc
limit 10;

/*Users segementation based on their engagement rate*/
SELECT 
    u.id,
    u.username,
    COUNT(DISTINCT p.id) AS total_posts,
    COUNT(DISTINCT l.photo_id) AS total_likes,
    COUNT(DISTINCT c.photo_id) AS total_comments,
    CASE
        WHEN COUNT(DISTINCT p.id) >= 10 THEN 'Content Creator'
        WHEN COUNT(DISTINCT l.photo_id) + COUNT(DISTINCT c.photo_id) >= 100 THEN 'Highly Engaged User'
        WHEN COUNT(DISTINCT p.id) = 0 
             AND COUNT(DISTINCT l.photo_id) = 0 
             AND COUNT(DISTINCT c.photo_id) = 0 THEN 'Inactive User'
        ELSE 'Moderately Active User'
    END AS user_segment
FROM users u
LEFT JOIN photos p ON u.id = p.user_id
LEFT JOIN likes l ON u.id = l.user_id
LEFT JOIN comments c ON u.id = c.user_id
GROUP BY u.id, u.username;

/*Total Users*/
select count(*) as total_users from users;

/*Active and Inactive users*/
Select
      user_status,
      count(*) as total_users
from (
	  select
            u.id,
            case
                when count(distinct p.id) = 0 and count(distinct l.photo_id) = 0
				and count(distinct c.id) = 0
                then 'Inactive User'
                else 'Active User'
                end as user_status
		from users u 
        left join photos p 
        on u.id = p.user_id 
        left join likes l
        on u.id = l.user_id 
        left join comments c 
        on u.id = c.user_id
        group by u.id
        )t
group by user_status;

/*User Engagement by joining year*/  
select
      year(u.created_at) as joining_year,
      count(distinct u.id) as total_users,
      count(distinct p.id) as total_posts,
      count(distinct l.user_id) as total_likes,
      count(distinct c.id) as total_comments
from users u 
left join photos p 
on u.id = p.user_id
left join likes l
on u.id = l.user_id 
left join comments c 
on u.id = c.user_id
group by joining_year
order by joining_year;

/*User Segmentation by number of posts*/
select
      case when post_count = 0 then 'No posts'
      when post_count between 1 and 2 then '1-2 posts'
      when post_count between 3 and 5 then '3-5 posts'
      else '5+ posts'
      end as post_segment,
      count(*) as total_users
from (
      select
            u.id,
            count(p.id) as post_count
	  from users u 
      left join photos p 
      on u.id = p.user_id
      group by u.id
      )t
group by post_segment
order by total_users desc;

/*tag count*/
select
      t.tag_name,
      count(pt.photo_id) as usage_count
from tags t 
join photo_tags pt
on t.id = pt.tag_id
group by t.tag_name
order by usage_count desc;

/*User Activity Segmentation*/ 
select
      user_segment,
      count(*) as total_users
from (
      select
            u.id,
            case when count(distinct p.id) = 0 and count(distinct l.photo_id) = 0 
            and count(distinct c.photo_id) = 0 then 'Inactive User' 
            when count(distinct p.id) >= 10 then 'Content creator' 
            when count(distinct l.photo_id) + count(distinct c.photo_id) >= 100 then 'Highly engaged'
            else 'Moderately active'
            end as user_segment
      from users u 
      left join photos p 
      on u.id = p.user_id 
      left join likes l 
      on u.id = l.user_id 
      left join comments c 
      on u.id = c.user_id
      group by u.id 
      )t
group by user_segment
order by total_users desc;

/*Total Posts*/
select
      u.id,
      count(p.id) as total_posts
from users u 
join photos p 
on u.id = p.user_id
group by u.id
order by total_posts desc;

/*Tag activity*/
select
      t.tag_name,
      count(pt.photo_id) as usage_count
from tags t 
left join photo_tags pt 
on t.id = pt.tag_id
group by t.tag_name;

/*Content likes and comments*/
select
      p.user_id,
      count(distinct l.user_id) as total_likes,
      count(distinct c.user_id) as total_comments
from photos p 
left join likes l 
on p.id = l.photo_id
left join comments c 
on p.id = c.photo_id
group by p.user_id
order by total_likes desc,total_comments desc
limit 10;

/*Total tags*/
select
      photo_id,
      count(tag_id) as total_tags
from photo_tags
group by photo_id;

/*Inactive Users*/
select
      u.id,
      u.username,
      max(p.created_dat) as last_post_date
from users u 
left join photos p 
on u.id = p.user_id
group by u.id, u.username
having last_post_date is null;

/*Potential brand ambassadors*/
select 
      u.id as user_id,
      u.username,
      count(distinct p.id) as total_posts,
      count(distinct l.user_id) as total_likes,
      count(distinct c.id) as total_comments,
      count(distinct f.follower_id) as total_followers,
      (count(distinct l.user_id) + count(distinct c.id) + count(distinct f.follower_id)
      )as ambassador_score
from users u 
left join photos p 
on u.id = p.user_id
left join likes l 
on p.id = l.photo_id
left join comments c 
on p.id = c.photo_id
left join follows f 
on u.id = f.followee_id
group by u.id, u.username
order by ambassador_score desc,total_posts desc
limit 10;










	
      