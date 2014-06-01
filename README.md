The MarketPlace Podcast Crawler*
================================

*Not actually a "web crawler". While writing the script, I found an xml
file that stored all the podcast links and decided to use that instead.

This project will pull down podcasts from APM's MarketPlace radio show and 
    will store and sort them automatically.

Coupled with DropBox (or another cloud-based service) the shows can then
    been synced up with a mobile device or other platform for listening.

About
-----

I initially wrote this script so I could listen to the podcasts offline while
    commuting to and from work. The Android app can store clips for offline
    playing but you have to manually pick and choose each episode before hand.

The podcast is free for download, available on the MarketPlace website.

Usage
-----

```shell
./mpCrawler.sh
```

Run this script either manually or via a cron job to update.

To change the download directory, edit the value of the "MP_DIR" in the script.
