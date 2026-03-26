# frozen_string_literal: true

module DiscourseMiniMod
  module GuardianExtensions
    def can_create_category?(parent = nil)
      return true if super
      return false if !SiteSetting.mini_mod_enabled
      return false if anonymous?

      if parent
        is_category_group_moderator?(parent)
      else
        category_group_moderation_allowed? && category_group_moderator_scope.exists?
      end
    end

    def can_edit_category?(category)
      return true if super
      return false if !SiteSetting.mini_mod_enabled

      is_category_group_moderator?(category)
    end

    def can_edit_serialized_category?(category_id:, read_restricted:)
      return true if super
      return false if !SiteSetting.mini_mod_enabled
      return false if !category_group_moderation_allowed?

      category_group_moderator_scope.where(id: category_id).exists?
    end
  end
end
