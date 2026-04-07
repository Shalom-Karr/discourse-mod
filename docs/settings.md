# Settings Reference

The plugin's settings are split across two top-level sections in the admin site settings UI:

- **Discourse Mini Mod** — settings that govern category group moderators (mini-mods)
- **Trust Level 4** — settings that govern trust level 4 users site-wide. Independent of the mini-mod features; see [trust-level-4.md](trust-level-4.md) for the full rationale.

## Mini-mod settings

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

## Trust Level 4 settings

These two settings are independent of the mini-mod features and govern trust level 4 users site-wide. They live in their own **Trust Level 4** section in the admin UI. See [trust-level-4.md](trust-level-4.md) for the full design rationale and the interaction with mini-mod-hybrid users.

### `tl4_can_post_in_closed_topics`

- **Default:** `false`
- **Client:** no

When `false`, blocks any non-staff trust level 4 user from replying on a closed topic anywhere on the site. Discourse core normally treats TL4 as a "trusted" user that bypasses the closed-topic posting block (`Guardian::TopicGuardian#can_create_post_on_topic?`); the plugin revokes that bypass.

When `true`, falls through to core.

The restriction is narrowly scoped:

- Only `closed?` topics are affected — archived topics are left alone.
- Site staff are not affected.
- Only `can_create_post_on_topic?` is touched. Every other TL4 grant (`can_wiki?`, `can_rebake?`, `can_see_unlisted_topics?`, `can_skip_bump?`, etc.) is left alone.
- Applies to **any** category, not just mini-mod ones.

**Requires:** `mini_mod_enabled`

### `tl4_can_reopen_topics`

- **Default:** `false`
- **Client:** no

When `false`, blocks any non-staff trust level 4 user from reopening a closed topic anywhere on the site. Discourse core normally lets TL4 users close, reopen, archive, pin, split/merge, etc. on any topic they can see (`Guardian::TopicGuardian#can_perform_action_available_to_group_moderators?`, aliased to `can_close_topic?` and `can_open_topic?`); the plugin revokes only the reopen ability.

When `true`, falls through to core.

The restriction is narrowly scoped:

- Only the reopen action is blocked. Closing open topics still works, as do archiving, pinning, splitting, merging, and every other topic action.
- Two Guardian methods are overridden to cover both reopen paths: `can_close_topic?` (the manual UI toggle, since Discourse routes both close and reopen through this method and infers direction from `topic.closed?`) and `can_open_topic?` (the topic-timer reopen path used by `Jobs::OpenTopic`).
- The plugin also hides the close/reopen button on closed topics for affected TL4 users via `TopicViewDetailsSerializer#include_can_close_topic?`, so they don't see a button that would surface a 403 on click.
- Site staff are not affected.

**Requires:** `mini_mod_enabled`

## Required Discourse core settings

### `enable_category_group_moderation`

Must be enabled for any mini-mod functionality to work. This is Discourse's built-in setting that allows assigning moderation groups to categories.

### `tagging_enabled`

Must be enabled for tag management (`mini_mod_manage_tags`) to work.
