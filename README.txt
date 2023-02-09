Story: Customer requests to see their image feed
Narrative #1
As an online customer 

I want the app to automatically load my latest image feed 

So I can always enjoy the newest images of my friends

Scenarios (Acceptance criteria)
Given the customer has connectivity 

When the customer requests to see the feed

Then the app should display the latest feed from remote

And replace the cache with the new feed


Narrative #2
As an offline customer

I want the app to show the latest saved version of my image feed

So I can always enjoy images of my friends

Scenarios (Acceptance criteria)
1.
Given the customer doesn't have connectivity

And there’s a cached version of the feed

When the customer requests to see the feed

Then the app should display the latest feed saved


2.
Given the customer doesn't have connectivity

And the cache is empty

When the customer requests to see the feed

Then the app should display an error message


We can then start drafting Use Cases, essentially small recipes, for translating the requirements in procedures that we will then turn into code.

Load Feed Use Case
Data (Input):
 -URL
Primary course (happy path):
1.Execute "Load Feed Items" command with above data.
2.System downloads data from the URL.
3.System validates downloaded data.
4.System creates feed items from valid data.
5.System delivers feed items.

Invalid data – error course (sad path):
1.System delivers error.

No connectivity – error course (sad path):
1.System delivers error.

Load Feed Fallback (Cache) Use Case
Data (Input):
-Max age

Primary course (happy path):
1.Execute "Retrieve Feed Items" command with above data.
2.System fetches feed data from cache.
3.System creates feed items from cached data.
4.System delivers feed items.
5.No cache course (sad path):
6.System delivers no feed items.
7.Save Feed Items Use Case
Data (Input):
-Feed items
Primary course (happy path):
1.Execute "Save Feed Items" command with above data.
2.System encodes feed items.
3.System timestamps the new cache.
4.System replaces the cache with new data.
5.System delivers a success message.