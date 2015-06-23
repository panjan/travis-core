Setting up irb
--------------

You can use `raisls s` or `irb` and then `$: << 'lib'; require 'bundler/setup'; require 'travis'`

Features
--------

Travis allows enable/disable features (see [lib/travis/features.rb]).
Features are stored in redis and shoud be applied globbaly, for user or
for repository:

 * `feature_active?`, `feature_inactive?`, `feature_deactivated?`
 * `active?(features, repository)`, `repository_active?`
 * `user_active?`, `owner_active?`

Exampe:

     Travis::Features.enable_for_all(:force_script)
     Travis::Features.enable_for_all(:multi_os)
     Travis::Features.enable_for_all(:fix_resolv_conf)
     Travis::Features.enable_for_all(:template_selection)
     Travis::Features.enable_for_all(:dist_group_expansion)
     Travis::Features.enable_for_all(:accept_private_repo)



Woring with repository's ssh_key
--------------------------------

Save repo key:

     r = Repository.find(1)
     r.settings.ssh_key = { value: File.read('repo_private_key') }
     r.settings.save


Dump key:

     Repository.find(1).settings.ssh_key.value.decrypt

