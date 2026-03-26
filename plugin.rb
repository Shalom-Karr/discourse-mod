# frozen_string_literal: true

# name: discourse-mini-mod
# about: Allows category group moderators to create and edit categories
# version: 0.1.0
# authors: Discourse
# url: https://github.com/discourse/discourse-mini-mod
# required_version: 2.7.0
# enabled_site_setting: mini_mod_enabled

require_relative "lib/discourse_mini_mod/guardian_extensions"

after_initialize do
  reloadable_patch do
    ::Guardian.prepend(DiscourseMiniMod::GuardianExtensions)
  end
end
