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
        guardian.can_edit_serialized_category?(
          category_id: category.id,
          read_restricted: false,
        ),
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
end
