# frozen_string_literal: true

RSpec.describe DiscourseMiniMod::GuardianExtensions do
  fab!(:user)
  fab!(:group)
  fab!(:category)

  before do
    SiteSetting.mini_mod_enabled = true
    SiteSetting.enable_category_group_moderation = true
    group.add(user)
    Fabricate(:category_moderation_group, category: category, group: group)
  end

  describe "#can_create_category?" do
    it "allows category group moderators to create categories" do
      expect(Guardian.new(user).can_create_category?).to eq(true)
    end

    it "allows category group moderators to create subcategories under their moderated category" do
      expect(Guardian.new(user).can_create_category?(category)).to eq(true)
    end

    it "does not allow category group moderators to create subcategories under unmoderated categories" do
      other_category = Fabricate(:category)
      expect(Guardian.new(user).can_create_category?(other_category)).to eq(false)
    end

    it "does not allow when plugin is disabled" do
      SiteSetting.mini_mod_enabled = false
      expect(Guardian.new(user).can_create_category?).to eq(false)
    end

    it "does not allow when category group moderation is disabled" do
      SiteSetting.enable_category_group_moderation = false
      expect(Guardian.new(user).can_create_category?).to eq(false)
    end

    it "does not allow anonymous users" do
      expect(Guardian.new.can_create_category?).to eq(false)
    end
  end

  describe "#can_edit_category?" do
    it "allows category group moderators to edit their moderated category" do
      expect(Guardian.new(user).can_edit_category?(category)).to eq(true)
    end

    it "does not allow editing unmoderated categories" do
      other_category = Fabricate(:category)
      expect(Guardian.new(user).can_edit_category?(other_category)).to eq(false)
    end

    it "does not allow when plugin is disabled" do
      SiteSetting.mini_mod_enabled = false
      expect(Guardian.new(user).can_edit_category?(category)).to eq(false)
    end
  end

  describe "#can_delete_category?" do
    it "allows category group moderators to delete their moderated category" do
      expect(Guardian.new(user).can_delete_category?(category)).to eq(true)
    end

    it "does not allow deleting categories with topics" do
      Fabricate(:topic, category: category)
      category.reload
      expect(Guardian.new(user).can_delete_category?(category)).to eq(false)
    end
  end

  describe "#can_edit_serialized_category?" do
    it "allows category group moderators" do
      guardian = Guardian.new(user)
      expect(
        guardian.can_edit_serialized_category?(category_id: category.id, read_restricted: false),
      ).to eq(true)
    end

    it "does not allow for unmoderated categories" do
      other_category = Fabricate(:category)
      guardian = Guardian.new(user)
      expect(
        guardian.can_edit_serialized_category?(
          category_id: other_category.id,
          read_restricted: false,
        ),
      ).to eq(false)
    end
  end

  context "with mini_mod_manage_all_categories enabled" do
    before { SiteSetting.mini_mod_manage_all_categories = true }

    it "allows creating subcategories under any category" do
      other_category = Fabricate(:category)
      expect(Guardian.new(user).can_create_category?(other_category)).to eq(true)
    end

    it "allows editing any category" do
      other_category = Fabricate(:category)
      expect(Guardian.new(user).can_edit_category?(other_category)).to eq(true)
    end

    it "allows deleting any empty category" do
      other_category = Fabricate(:category)
      expect(Guardian.new(user).can_delete_category?(other_category)).to eq(true)
    end

    it "allows editing serialized categories the user does not moderate" do
      other_category = Fabricate(:category)
      guardian = Guardian.new(user)
      expect(
        guardian.can_edit_serialized_category?(
          category_id: other_category.id,
          read_restricted: false,
        ),
      ).to eq(true)
    end

    it "still requires the user to be in a category moderation group" do
      other_user = Fabricate(:user)
      expect(Guardian.new(other_user).can_edit_category?(category)).to eq(false)
    end
  end

  describe "#can_move_topic_to_category?" do
    it "allows moving topics to a moderated category" do
      expect(Guardian.new(user).can_move_topic_to_category?(category)).to eq(true)
    end

    it "does not allow moving topics to an unmoderated category" do
      other_category = Fabricate(:category)
      expect(Guardian.new(user).can_move_topic_to_category?(other_category)).to eq(false)
    end

    it "does not allow when plugin is disabled" do
      SiteSetting.mini_mod_enabled = false
      expect(Guardian.new(user).can_move_topic_to_category?(category)).to eq(false)
    end

    it "does not allow when category group moderation is disabled" do
      SiteSetting.enable_category_group_moderation = false
      expect(Guardian.new(user).can_move_topic_to_category?(category)).to eq(false)
    end

    context "with mini_mod_manage_all_categories enabled" do
      before { SiteSetting.mini_mod_manage_all_categories = true }

      it "allows moving topics to any visible category" do
        other_category = Fabricate(:category)
        expect(Guardian.new(user).can_move_topic_to_category?(other_category)).to eq(true)
      end

      it "does not allow moving to a category the user cannot see" do
        restricted = Fabricate(:category, read_restricted: true)
        expect(Guardian.new(user).can_move_topic_to_category?(restricted)).to eq(false)
      end
    end
  end

  describe "#can_create_post_on_topic?" do
    fab!(:closed_topic) { Fabricate(:topic, category: category, closed: true) }
    fab!(:open_topic) { Fabricate(:topic, category: category) }

    it "blocks category group moderators from posting on closed topics by default" do
      expect(Guardian.new(user).can_create_post_on_topic?(closed_topic)).to eq(false)
    end

    it "still allows category group moderators to post on open topics" do
      expect(Guardian.new(user).can_create_post_on_topic?(open_topic)).to eq(true)
    end

    it "does not affect site moderators" do
      expect(Guardian.new(Fabricate(:moderator)).can_create_post_on_topic?(closed_topic)).to eq(
        true,
      )
    end

    it "is a no-op when the plugin is disabled" do
      SiteSetting.mini_mod_enabled = false
      expect(Guardian.new(user).can_create_post_on_topic?(closed_topic)).to eq(true)
    end

    context "when mini_mod_can_post_in_closed_topics is enabled" do
      before { SiteSetting.mini_mod_can_post_in_closed_topics = true }

      it "allows category group moderators to post on closed topics they moderate" do
        expect(Guardian.new(user).can_create_post_on_topic?(closed_topic)).to eq(true)
      end
    end
  end

  describe "#can_close_topic?" do
    fab!(:closed_topic) { Fabricate(:topic, category: category, closed: true) }
    fab!(:open_topic) { Fabricate(:topic, category: category) }

    # Discourse routes manual reopen through can_close_topic? (the controller infers
    # direction from topic.closed?), so the reopen restriction has to live here too.
    it "allows category group moderators to close open topics they moderate" do
      expect(Guardian.new(user).can_close_topic?(open_topic)).to eq(true)
    end

    it "blocks category group moderators from reopening closed topics by default" do
      expect(Guardian.new(user).can_close_topic?(closed_topic)).to eq(false)
    end

    it "does not affect site moderators" do
      expect(Guardian.new(Fabricate(:moderator)).can_close_topic?(closed_topic)).to eq(true)
    end

    it "is a no-op when the plugin is disabled" do
      SiteSetting.mini_mod_enabled = false
      expect(Guardian.new(user).can_close_topic?(closed_topic)).to eq(true)
    end

    context "when mini_mod_can_reopen_topics is enabled" do
      before { SiteSetting.mini_mod_can_reopen_topics = true }

      it "allows category group moderators to reopen closed topics they moderate" do
        expect(Guardian.new(user).can_close_topic?(closed_topic)).to eq(true)
      end
    end
  end

  describe "#can_open_topic?" do
    fab!(:closed_topic) { Fabricate(:topic, category: category, closed: true) }

    # can_open_topic? gates the timer-based reopen path (Jobs::OpenTopic).
    # The manual reopen path goes through can_close_topic? (see above).
    it "blocks category group moderators from reopening closed topics by default" do
      expect(Guardian.new(user).can_open_topic?(closed_topic)).to eq(false)
    end

    it "does not affect site moderators" do
      expect(Guardian.new(Fabricate(:moderator)).can_open_topic?(closed_topic)).to eq(true)
    end

    it "is a no-op when the plugin is disabled" do
      SiteSetting.mini_mod_enabled = false
      expect(Guardian.new(user).can_open_topic?(closed_topic)).to eq(true)
    end

    context "when mini_mod_can_reopen_topics is enabled" do
      before { SiteSetting.mini_mod_can_reopen_topics = true }

      it "allows category group moderators to reopen closed topics they moderate" do
        expect(Guardian.new(user).can_open_topic?(closed_topic)).to eq(true)
      end
    end
  end

  context "with mini_mod_manage_tags enabled" do
    before do
      SiteSetting.tagging_enabled = true
      SiteSetting.mini_mod_manage_tags = true
    end

    describe "#can_admin_tags?" do
      it "allows category group moderators to admin tags" do
        expect(Guardian.new(user).can_admin_tags?).to eq(true)
      end

      it "does not allow when plugin is disabled" do
        SiteSetting.mini_mod_enabled = false
        expect(Guardian.new(user).can_admin_tags?).to eq(false)
      end

      it "does not allow when manage_tags is disabled" do
        SiteSetting.mini_mod_manage_tags = false
        expect(Guardian.new(user).can_admin_tags?).to eq(false)
      end

      it "does not allow when tagging is disabled" do
        SiteSetting.tagging_enabled = false
        expect(Guardian.new(user).can_admin_tags?).to eq(false)
      end

      it "does not allow users not in a category moderation group" do
        other_user = Fabricate(:user)
        expect(Guardian.new(other_user).can_admin_tags?).to eq(false)
      end

      it "does not allow when category group moderation is disabled" do
        SiteSetting.enable_category_group_moderation = false
        expect(Guardian.new(user).can_admin_tags?).to eq(false)
      end
    end

    describe "#can_create_tag?" do
      it "allows category group moderators to create tags" do
        expect(Guardian.new(user).can_create_tag?).to eq(true)
      end

      it "does not allow when manage_tags is disabled" do
        SiteSetting.mini_mod_manage_tags = false
        expect(Guardian.new(user).can_create_tag?).to eq(false)
      end
    end

    describe "#can_edit_tag_names?" do
      it "allows category group moderators to edit tag names" do
        expect(Guardian.new(user).can_edit_tag_names?).to eq(true)
      end

      it "does not allow when manage_tags is disabled" do
        SiteSetting.mini_mod_manage_tags = false
        expect(Guardian.new(user).can_edit_tag_names?).to eq(false)
      end
    end

    describe "#can_edit_tag?" do
      it "allows category group moderators to edit visible tags" do
        tag = Fabricate(:tag)
        expect(Guardian.new(user).can_edit_tag?(tag)).to eq(true)
      end
    end
  end
end
