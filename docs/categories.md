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

The plugin does **not** add these — they come from core's `can_perform_action_available_to_group_moderators?`.

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

## Restricting replies on closed topics

By default, category group moderators inherit a core Discourse privilege that lets them reply on closed (and archived) topics in their categories — they're treated as "trusted" users who bypass the closed-topic posting block.

If you want category group moderators to lose **only** the closed-topic reply privilege while keeping every other ability, set `mini_mod_can_post_in_closed_topics` to `false`. The override is intentionally narrow:

- Only fires for `topic.closed?` — archived topics still follow core behavior
- Site staff and trust level 4 users keep their independent ability to post on closed topics
- No other category group moderator privilege is touched (closing topics, editing, category management, etc. all behave identically)

See [docs/settings.md](settings.md#mini_mod_can_post_in_closed_topics) for the full setting reference.

## How it works technically

The plugin prepends Guardian extensions that override these methods:

| Method | What it controls |
|--------|-----------------|
| `can_create_category?` | Creating new categories |
| `can_edit_category?` | Editing category settings |
| `can_edit_serialized_category?` | Whether the category shows as editable in the site category list |
| `can_edit_topic?` | Editing topics in non-moderated categories (manage all mode only) |
| `can_move_topic_to_category?` | Moving topics to a different category |
| `can_create_post_on_topic?` | Replying on closed topics (only when `mini_mod_can_post_in_closed_topics` is `false`) |

Most methods call `super` first — if the base Discourse permission allows it, the plugin doesn't interfere. The plugin only adds permissions, with one exception: `can_create_post_on_topic?` can revoke the core "trusted user bypasses closed topics" exception for category group moderators when explicitly configured to do so.

The admin JS bundle is preloaded for mini-mod users so the category edit/create routes (which live in the admin bundle) work in the browser.
