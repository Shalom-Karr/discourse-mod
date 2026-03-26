# frozen_string_literal: true

# name: discourse-mini-mod
# about: Allows category group moderators to create and edit categories
# version: 0.1.0
# authors: Discourse
# url: https://github.com/discourse/discourse-mini-mod
# required_version: 2.7.0
# enabled_site_setting: mini_mod_enabled

require_relative "lib/discourse_mini_mod/guardian_extensions"

# Load the admin JS bundle for category group moderators so they can access
# the category edit/create routes (which live in the admin bundle).
# Security: this only loads client-side route handlers. All actual permissions
# are enforced server-side by Guardian. The admin bundle is a public static
# asset — loading it grants no server-side privileges.
register_html_builder("server:before-head-close") do |controller|
  next "" if controller.blank?
  user = controller.current_user
  next "" if user.blank? || user.staff?
  next "" unless SiteSetting.mini_mod_enabled
  next "" unless SiteSetting.enable_category_group_moderation

  guardian = Guardian.new(user)
  next "" unless guardian.send(:category_group_moderator_scope).exists?

  chunks = EmberCli.script_chunks["chunk.admin"]
  next "" if chunks.blank?

  nonce = controller.helpers.csp_nonce_placeholder
  chunks.map do |script_name|
    path = controller.helpers.script_asset_path(script_name)
    %(<link rel="preload" href="#{path}" as="script" nonce="#{nonce}" data-discourse-entrypoint="admin">)
  end.join("\n")
end

after_initialize do
  reloadable_patch do
    ::Guardian.prepend(DiscourseMiniMod::GuardianExtensions)
  end
end
