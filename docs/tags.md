# Tag Management

## Prerequisites

- `mini_mod_enabled` must be on
- `mini_mod_manage_tags` must be on
- `enable_category_group_moderation` must be on (Discourse core setting)
- `tagging_enabled` must be on (Discourse core setting)
- User must be in a group assigned as a moderation group on at least one category

## What they can do

- **Create tags** — both inline (when tagging topics) and bulk creation from the `/tags` page
- **Edit tags** — rename tags, change tag settings
- **Delete tags** — remove individual tags
- **Manage synonyms** — create and remove tag synonyms
- **Upload tags** — bulk upload via CSV
- **Delete unused tags** — remove all tags with no topics

## What they cannot do

- **Manage tag groups** — the `/tag_groups` routes are behind a staff-only constraint at the routing level, which cannot be overridden by Guardian extensions alone

## How it works technically

The plugin extends three Guardian methods:

| Method | What it controls | Core requirement |
|--------|-----------------|-----------------|
| `can_admin_tags?` | Delete tags, upload, bulk create, list/delete unused | `is_staff?` |
| `can_create_tag?` | Inline tag creation when tagging topics | Group-based site setting |
| `can_edit_tag_names?` | Rename tags, edit tag settings | Group-based site setting |

All three fall through to a shared `mini_mod_tag_manager?` check that verifies:
- Plugin is enabled
- `mini_mod_manage_tags` is on
- Tagging is enabled
- Category group moderation is enabled
- User is in at least one category moderation group

### Frontend changes

Discourse core hardcodes `currentUser.staff` for tag admin UI visibility in two places:

- `tags/index` controller — controls the wrench dropdown (manage groups, upload, delete unused) and bulk create form
- `tag-info` component — controls the delete button and synonym management

The plugin adds a `can_admin_tags` field to the `CurrentUserSerializer` and patches both frontend locations via a JS initializer to check `currentUser.staff || currentUser.can_admin_tags`.
