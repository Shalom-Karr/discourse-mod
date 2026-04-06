# Category Management

## Prerequisites

- `mini_mod_enabled` must be on
- `enable_category_group_moderation` must be on (Discourse core setting)
- User must be in a group assigned as a moderation group on at least one category

## What core Discourse already gives category group moderators

Before the plugin even gets involved, Discourse core grants category group moderators these abilities **in their moderated categories**:

- Edit topics (title, content)
- Close/open, archive, pin/unpin topics
- Unlist/relist topics
- Split/merge topics
- Move posts
- Edit staff notes
- Reply on closed and archived topics (treated as "trusted" by `can_create_post_on_topic?`)

The plugin does **not** add these — they come from core's `can_perform_action_available_to_group_moderators?`. Note that the plugin **does** revoke two of these abilities by default (replying on closed topics, and reopening closed topics) — see [Restrictions the plugin applies by default](#restrictions-the-plugin-applies-by-default) below.

## What the plugin adds

### Per-category mode (default)

- **Create** subcategories under moderated categories, or create top-level categories
- **Edit** moderated categories (name, description, permissions, settings, etc.)
- **Delete** moderated categories (must have no topics and no subcategories)
- **Bulk change topic category** — move topics from a moderated category to another moderated category

### What they cannot do in per-category mode

- Edit or delete categories they don't moderate
- Edit topics in categories they don't moderate
- Move topics from/to categories they don't moderate

### Manage all categories mode

Enable `mini_mod_manage_all_categories` to expand permissions beyond moderated categories.

- **Create** subcategories under any category
- **Edit** any category
- **Delete** any empty category
- **Edit topics** in any visible category (not just moderated ones)
- **Bulk change topic category** — move topics between any visible categories

Note: core moderation abilities (close, pin, unlist, etc.) still only work in moderated categories — `manage_all_categories` does not extend those.

## How bulk topic category change works

When a user selects topics and uses the "Change Category" bulk action:

1. The plugin checks `can_edit_topic?` for each topic — with manage all, this passes for any visible topic
2. Discourse core's `PostRevisor` checks `can_move_topic_to_category?` for the target — the plugin allows any visible category
3. Topics are moved and the response includes the changed topic IDs

Without the plugin, non-staff users who pass the base `can_edit_topic?` check (e.g., topic authors) can still move topics to public categories where they can create topics. The plugin extends this for category group moderators.

## Restrictions the plugin applies by default

Discourse core treats category group moderators as "trusted" users for two actions that the plugin revokes by default:

1. **Replying on closed topics.** Core lets category group moderators bypass the closed-topic posting block. The plugin's `can_create_post_on_topic?` override removes that bypass when `mini_mod_can_post_in_closed_topics` is `false` (the default).
2. **Reopening closed topics.** Core lets category group moderators close, archive, and reopen topics in their categories. The plugin's `can_open_topic?` override removes only the reopen ability when `mini_mod_can_reopen_topics` is `false` (the default).

Both restrictions are intentionally narrow:

- Site staff are unaffected — admins and moderators retain core's trusted-user privileges independently.
- Other category group moderator abilities (closing topics, archiving, editing, category management, etc.) are untouched.
- Only the specific Guardian methods listed above are overridden; every other path through core is left as-is.

To restore either ability, flip the corresponding site setting to `true`. See [docs/settings.md](settings.md) for the full setting reference.

## How it works technically

The plugin prepends Guardian extensions that override these methods:

| Method | What it controls |
|--------|-----------------|
| `can_create_category?` | Creating new categories |
| `can_edit_category?` | Editing category settings |
| `can_edit_serialized_category?` | Whether the category shows as editable in the site category list |
| `can_edit_topic?` | Editing topics in non-moderated categories (manage all mode only) |
| `can_move_topic_to_category?` | Moving topics to a different category |
| `can_create_post_on_topic?` | Replying on closed topics (blocked unless `mini_mod_can_post_in_closed_topics` is `true`) |
| `can_close_topic?` | Reopening closed topics via the manual close/reopen toggle (blocked unless `mini_mod_can_reopen_topics` is `true`); closing open topics still works |
| `can_open_topic?` | Reopening closed topics via topic timers (blocked unless `mini_mod_can_reopen_topics` is `true`) |

Most methods call `super` first — if the base Discourse permission allows it, the plugin doesn't interfere. The plugin only adds permissions, with two exceptions: `can_create_post_on_topic?` and `can_open_topic?` revoke specific core "trusted user" privileges from category group moderators by default. Either can be restored with the corresponding site setting.

The admin JS bundle is preloaded for mini-mod users so the category edit/create routes (which live in the admin bundle) work in the browser.
