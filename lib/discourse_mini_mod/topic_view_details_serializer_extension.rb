# frozen_string_literal: true

module DiscourseMiniMod
  # Hides the close/reopen toggle button on the topic admin menu when the
  # mini_mod_can_reopen_topics restriction is active and the topic is closed.
  #
  # The Guardian-level can_close_topic? override blocks the action server-side
  # (TopicsController#status -> ensure_can_close_topic!), but the button
  # visibility is decided independently by include_can_close_topic? on this
  # serializer (which core aliases to can_perform_action_available_to_group_moderators?).
  # Without this override the button stays visible and clicking it surfaces a
  # permission error.
  #
  # This only hides the button; closing open topics still shows it (because
  # topic.closed? is false), and every other admin action (archive, pin,
  # split/merge, etc.) is unaffected.
  module TopicViewDetailsSerializerExtension
    def include_can_close_topic?
      topic = object.topic
      if SiteSetting.mini_mod_enabled && !SiteSetting.mini_mod_can_reopen_topics && topic.closed? &&
           scope.user.present? && !scope.is_staff? && topic.category.present? &&
           scope.is_category_group_moderator?(topic.category)
        return false
      end
      super
    end
  end
end
