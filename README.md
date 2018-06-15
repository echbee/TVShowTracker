# TVShowTracker
iOS app which uses TVMazeAPI to track Episodes running in current week and show details about them

Uses MVVM design to Create 2 Screens

Weekly Episodes List Screen
-
1. Shows the episodes list in coming 7 days 
2. Users can search by show/network name
3. Adaptable UI for iPad (shows 3 items on a single row)

This screen is backed by WeeklyTVEpisodeListViewModel which is further backed by DailyTVEpisodeListViewModel and TVEpisodeViewModel.

Show Detail Screen
-
1. Shows the details of selected show along with a short summary
2. Also shows the show cast in a scrollable collection view

This screen is backed by TVShowDetailViewModel and TVShowCastListViewModel respectively
