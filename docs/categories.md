# Category Management

## Prerequisites

- `mod_categories_enabled` must be on
- User must be a moderator

## What the plugin adds

When `mod_categories_enabled` is on, any moderator can:

- **Create** any category — top-level or as a subcategory under any other category
- **Edit** any category (name, description, permissions, settings, etc.)
- **Delete** any category, provided it is empty (no topics) and has no subcategories

## What is unchanged

Every other moderator capability comes from Discourse core and is untouched by this plugin:

- Editing topics
- Closing, reopening, archiving, pinning topics
- Splitting/merging topics
- Moving posts
- Bulk-changing topic categories
- Managing tags
- The full review queue, user management, and admin actions that core grants moderators

The plugin **only** extends category create/edit/delete. It does not change behavior for admins, regular users, trust-level-4 users, or category group moderators.

## How it works technically

The plugin prepends a Guardian extension that overrides four methods:

| Method | What it controls |
|--------|------------------|
| `can_create_category?` | Creating new categories |
| `can_edit_category?` | Editing category settings |
| `can_edit_serialized_category?` | Whether the category shows as editable in the site category list |
| `can_delete_category?` | Deleting empty categories |

Each override calls `super` first — if core Discourse already allows the action (e.g. for an admin), the plugin doesn't interfere. Otherwise it returns `true` for moderators when the plugin setting is enabled.

`can_delete_category?` additionally enforces the standard core constraints: the category must have no topics, no subcategories, and must not be the uncategorized category.
