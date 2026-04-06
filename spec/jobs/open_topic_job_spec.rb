# frozen_string_literal: true

# Exercises the timer-based reopen path: Jobs::OpenTopic invokes
# Guardian#can_open_topic? when a topic timer fires. The plugin's
# can_open_topic? override should block the job from reopening when the
# user is a mini-mod and the restriction is on, and allow it when the
# restriction is off.
RSpec.describe Jobs::OpenTopic do
  fab!(:user)
  fab!(:group)
  fab!(:category)
  fab!(:closed_topic) { Fabricate(:topic, category: category, closed: true) }

  before do
    SiteSetting.mini_mod_enabled = true
    SiteSetting.enable_category_group_moderation = true
    group.add(user)
    Fabricate(:category_moderation_group, category: category, group: group)
  end

  def schedule_open_timer(by_user)
    Fabricate(
      :topic_timer,
      topic: closed_topic,
      user: by_user,
      status_type: TopicTimer.types[:open],
      execute_at: 1.minute.ago,
    )
  end

  describe "with the default restriction (mini_mod_can_reopen_topics: false)" do
    it "destroys the timer and leaves the topic closed when scheduled by a mini-mod" do
      timer = schedule_open_timer(user)
      described_class.new.execute(topic_timer_id: timer.id)
      expect(closed_topic.reload.closed).to eq(true)
      expect(TopicTimer.where(id: timer.id)).not_to exist
    end

    it "still reopens the topic when the timer is scheduled by an admin" do
      timer = schedule_open_timer(Fabricate(:admin))
      described_class.new.execute(topic_timer_id: timer.id)
      expect(closed_topic.reload.closed).to eq(false)
    end

    it "still reopens the topic when the timer is scheduled by a moderator" do
      timer = schedule_open_timer(Fabricate(:moderator))
      described_class.new.execute(topic_timer_id: timer.id)
      expect(closed_topic.reload.closed).to eq(false)
    end
  end

  context "when mini_mod_can_reopen_topics is enabled" do
    before { SiteSetting.mini_mod_can_reopen_topics = true }

    it "lets the mini-mod's timer reopen the topic" do
      timer = schedule_open_timer(user)
      described_class.new.execute(topic_timer_id: timer.id)
      expect(closed_topic.reload.closed).to eq(false)
    end
  end

  context "when the plugin is disabled" do
    before { SiteSetting.mini_mod_enabled = false }

    it "lets the mini-mod's timer reopen the topic (falls back to core behavior)" do
      timer = schedule_open_timer(user)
      described_class.new.execute(topic_timer_id: timer.id)
      expect(closed_topic.reload.closed).to eq(false)
    end
  end
end
