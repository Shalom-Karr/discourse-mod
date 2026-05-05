# frozen_string_literal: true

module DiscourseModCategories
  module GuardianExtensions
    def can_create_category?(parent = nil)
      return true if super
      mod_categories_grant?
    end

    def can_edit_category?(category)
      return true if super
      mod_categories_grant?
    end

    def can_edit_serialized_category?(category_id:, read_restricted:)
      return true if super
      mod_categories_grant?
    end

    def can_delete_category?(category)
      return true if super
      return false if !mod_categories_grant?
      category.topic_count == 0 && !category.uncategorized? && !category.has_children?
    end

    private

    def mod_categories_grant?
      SiteSetting.mod_categories_enabled && is_moderator?
    end
  end
end
