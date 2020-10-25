# Deployment Checklist

### Must be followed for any manual deployment

1. Announce deploy in slack `#casa`: "I am about to deploy [staging|prod]". 
 * If you have any problems (need to rerun a deploy, need to run code in rails console) post to a slack thread about it.
 * Do not include any identifying info about youths or any passwords or credentials of course!
2. Log into heroku console https://dashboard.heroku.com/teams/rubyforgood/apps
3. Download a manual db backup (do this for staging also both for practice and in case there is data in there which we want to be able to retrieve) https://dashboard.heroku.com/apps/casa-production > click add-on "heroku postgres" > Durability > "Create Manual Backup" > Download
4. Log into heroku rails console for the environment to which you are about to deploy.
 * To make sure your credentials are set up in case you need to clean something up in a hurry `heroku run rails c --app casa-production` or `heroku run rails c --app casa-r4g-staging`
5. Locally, check out the version of the code that is going to be deployed (so if there is a bug you can look at the exact code that has the bug in order to diagnose it) `git checkout <hash from heroku UI>`
6. Click the deploy button https://dashboard.heroku.com/pipelines/ab5437b7-b7da-4204-bcfc-33bac4466347
7. Watch the log until it's done and **watch for errors**.
8. Go to the environment which was just deployed and click around looking for problems. Always check as user type `Volunteer` first because they are the users of which we have the most.
9. Post in slack that the deploy is done!
10. Pat yourself on the back; you did it!