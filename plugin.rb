# frozen_string_literal: true

# name: discourse-mod
# about: Allows moderators to create, edit, and delete categories
# version: 0.1.0
# authors: alltechdev
# url: https://github.com/Shalom-Karr/discourse-mod
# required_version: 2.7.0
# enabled_site_setting: mod_categories_enabled

require_relative "lib/discourse_mod_categories/guardian_extensions"

after_initialize do
  reloadable_patch { ::Guardian.prepend(DiscourseModCategories::GuardianExtensions) }
end
