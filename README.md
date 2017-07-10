# is-my-website-up
call me once when my website is up

a file called are-they-up.txt is needed with a list of website to test. One per line.
ex:
```
google.com
linkedin.com
localtest.me
```
The script modify the file to add the last status at the end of the line.
Use a cronjob to call this script every minute to know if a website status is changed from UP to DOWN and from DOWN to UP.

TODO
- What to do with unresponding URL ?
- Send to pushbullet only once per checkup
- Accept cookies to prevent infinit redirects
