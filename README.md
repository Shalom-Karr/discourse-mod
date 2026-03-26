# discourse-mini-mod

A Discourse plugin that allows regular users (any trust level) to create, edit, and delete categories — without requiring moderator or admin status.

It builds on Discourse's existing [category group moderation](https://meta.discourse.org/t/category-moderation/203504) feature by extending the permissions it grants.

## How it works

1. Create a group and add your users to it

2. Go to category, press the wrench, then add the group to "In addition to staff, content in this category can also be reviewed by:".

3. Those users can now manage categories

By default, users can only manage the specific categories their group is assigned to. Enable `mini_mod_manage_all_categories` to let them manage all categories.

Moving other users' posts is already handled by Discourse core's category group moderation — no plugin needed.

## Settings

| Setting | Default | Description |
|---------|---------|-------------|
| `mini_mod_enabled` | `false` | Enable the plugin |
| `mini_mod_manage_all_categories` | `false` | Allow category group moderators to manage all categories, not just the ones they moderate |

Both settings require Discourse core's `enable_category_group_moderation` to also be enabled.

## Installation

Add the plugin's repository URL to your `app.yml`:

```yaml
hooks:
  after_code:
    - exec:
        cd: $home/plugins
        cmd:
          - git clone https://github.com/alltechdev/discourse-mini-mod.git
```

Then rebuild the container:

```
./launcher rebuild app
```

## Permissions granted

| Action | Default (per-category) | With manage all |
|--------|----------------------|-----------------|
| Create categories | Subcategories under moderated categories, or top-level if moderating any | All categories |
| Edit categories | Only moderated categories | All categories |
| Delete categories | Only moderated categories (must be empty, no children) | All categories (same constraints) |
| Move posts | All posts in moderated categories (core feature) | All posts in moderated categories (core feature) |