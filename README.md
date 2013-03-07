# Snipe! #

## Install ##

Add the gem:

    gem 'snipe' #, :git => 'git_repo_url'
    bundle install

Create a Snipefile in the root of your app folder:

    ---
    # Remote recipes here will be downloaded to .snipe/recipes.
    production:
      gitrev: https://gist.github.com/mm53bar/5053150/raw/0e870a3a0842f9eb1129f546baf1f63febcac70c/gitrev
      whoami: https://raw.github.com/mm53bar/plow/recipes/bin/whoami
 
    files:
      - ~/.ssh/id_rsa.pub
 
    preferences:
      erase_remote_folder: false
      cache_remote_recipes: false
      erase_local_folder: true
      
Make sure you have a .env.production file that has your server connection settings. Something like [.env.sample](https://github.com/mm53bar/plow/blob/master/.env.sample) would work.

Run the compile action

    bin/snipe compile production

If that works, try to deploy!

    bin/snipe deploy production user@host

