
- I am on the feature/results branch, add any files that I may have created
 
git add .

- now commit to the local repository to the branch feature/results

git commit -m "save to results"

- push from local repo to remote repo

git push origin feature/results

- switch to the main branch

git checkout main

- pull the latest changes

git pull origin main

- merge the branch feature/results INTO main branch

git merge feature/results

- push the local main branch up to the main branch in the remote repository

git push origin main



= = = = 

things to fix later

Last login: Sun Aug 31 17:57:44 on ttys006
lizzieteo@Lizzies-MacBook-Pro bloom-app % git add .
lizzieteo@Lizzies-MacBook-Pro bloom-app % git commit -m "save to results"
[feature/results 6d4e6e3] save to results
 Committer: Lizzie Teo <lizzieteo@Lizzies-MacBook-Pro.local>
Your name and email address were configured automatically based
on your username and hostname. Please check that they are accurate.
You can suppress this message by setting them explicitly. Run the
following command and follow the instructions in your editor to edit
your configuration file:

    git config --global --edit

After doing this, you may fix the identity used for this commit with:

    git commit --amend --reset-author

 4 files changed, 118 insertions(+), 17 deletions(-)
 create mode 100644 .docs/projects/20250831_save_result/prompt.md
lizzieteo@Lizzies-MacBook-Pro bloom-app % 