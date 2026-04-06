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

### `mini_mod_can_post_in_closed_topics`

- **Default:** `false`
- **Client:** no

Controls whether category group moderators can reply on **closed** topics in categories they moderate. Defaults to `false`, which overrides Discourse core's default behavior — core normally treats category group moderators as "trusted" users who bypass the closed-topic posting block. The plugin revokes that bypass.

When set to `true`, the plugin's override falls through to core and category group moderators regain the ability to reply on closed topics in their categories.

The restriction is narrowly scoped:

- Only `closed?` topics are affected — archived topics are left alone.
- Site staff (admins, moderators) are not affected; they retain their independent ability to post on closed topics.
- Only `can_create_post_on_topic?` is touched — every other category group moderator privilege (closing topics, editing topics, managing categories, etc.) is unchanged.

**Requires:** `mini_mod_enabled`

### `mini_mod_can_reopen_topics`

- **Default:** `false`
- **Client:** no

Controls whether category group moderators can **reopen** closed topics in categories they moderate. Defaults to `false`, which overrides Discourse core's default behavior — core normally lets category group moderators close, archive, and reopen topics in their categories. The plugin revokes only the reopen ability.

When set to `true`, the plugin's overrides fall through to core and category group moderators regain the ability to reopen closed topics in their categories.

The restriction is narrowly scoped:

- Only the reopen action is blocked. Closing open topics still works, as do archiving, pinning, splitting, merging, and every other topic action.
- Two Guardian methods are overridden to cover both reopen paths: `can_close_topic?` (the manual UI toggle, since Discourse routes both close and reopen through this method and infers direction from `topic.closed?`) and `can_open_topic?` (the topic-timer reopen path used by `Jobs::OpenTopic`).
- Site staff (admins, moderators) are not affected.
- Topics outside the moderator's categories were never reachable to begin with — core blocks that.

**Requires:** `mini_mod_enabled`

## Required Discourse core settings

### `enable_category_group_moderation`

Must be enabled for any mini-mod functionality to work. This is Discourse's built-in setting that allows assigning moderation groups to categories.

### `tagging_enabled`

Must be enabled for tag management (`mini_mod_manage_tags`) to work.
