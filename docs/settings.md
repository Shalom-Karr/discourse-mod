# Settings Reference

## Plugin settings

### `mini_mod_enabled`

- **Default:** `false`
- **Client:** yes

Master switch for the plugin. When disabled, all mini-mod extensions are inactive and only standard Discourse permissions apply.

**Requires:** `enable_category_group_moderation` (Discourse core)

### `mini_mod_manage_all_categories`

- **Default:** `false`
- **Client:** yes

When enabled, category group moderators can manage **all** categories, not just the ones their group is assigned to. Also allows editing topics and bulk-moving topics across all visible categories.

**Requires:** `mini_mod_enabled`

### `mini_mod_manage_tags`

- **Default:** `false`
- **Client:** yes

When enabled, category group moderators can create, edit, rename, and delete tags. Also enables the tag admin UI (wrench dropdown, bulk create form, delete button).

**Requires:** `mini_mod_enabled`, `tagging_enabled` (Discourse core)

## Required Discourse core settings

### `enable_category_group_moderation`

Must be enabled for any mini-mod functionality to work. This is Discourse's built-in setting that allows assigning moderation groups to categories.

### `tagging_enabled`

Must be enabled for tag management (`mini_mod_manage_tags`) to work.
