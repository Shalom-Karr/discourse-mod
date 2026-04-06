# discourse-mini-mod

> Mini-mods can rearrange the shelves. Moderators can kick people out of the store.

A Discourse plugin that gives regular users the power to manage categories, tags, and topics — without requiring moderator or admin status.

It builds on Discourse's existing category group moderation feature by extending the permissions it grants.

## How it works

1. Create a group and add your users to it
2. Go to a category, press the wrench, then add the group to "In addition to staff, content in this category can also be reviewed by:"
3. Enable `mini_mod_enabled` in site settings
4. Those users can now manage categories they moderate

Optionally enable `mini_mod_manage_all_categories` to let them manage **all** categories and move topics between any categories. Enable `mini_mod_manage_tags` to let them create, edit, and delete tags.

## Settings

| Setting | Default | Description |
|---------|---------|-------------|
| `mini_mod_enabled` | `false` | Enable the plugin |
| `mini_mod_manage_all_categories` | `false` | Allow category group moderators to manage all categories and edit/move topics across all categories |
| `mini_mod_manage_tags` | `false` | Allow category group moderators to create, edit, and delete tags |
| `mini_mod_can_post_in_closed_topics` | `false` | Allow category group moderators to reply on closed topics in categories they moderate. Disabled by default — enable to grant; site staff are unaffected |
| `mini_mod_can_reopen_topics` | `false` | Allow category group moderators to reopen closed topics in categories they moderate. Disabled by default — enable to grant; site staff are unaffected |

All settings require Discourse core's `enable_category_group_moderation` to also be enabled. Tag management also requires `tagging_enabled`.

## Permissions granted

| Action | Default (per-category) | With manage all categories | With manage tags |
|--------|----------------------|-----------------|-----------------|
| Create categories | Subcategories under moderated categories, or top-level | All categories | — |
| Edit categories | Only moderated categories | All categories | — |
| Delete categories | Only moderated categories (must be empty, no children) | All categories (same constraints) | — |
| Edit topics | Only in moderated categories (core feature) | All visible topics | — |
| Bulk change topic category | To/from moderated categories | Any visible category | — |
| Move posts | In moderated categories (core feature) | In moderated categories (core feature) | — |
| Create tags | — | — | Yes |
| Edit/rename tags | — | — | Yes |
| Delete tags | — | — | Yes |
| Manage tag synonyms | — | — | Yes |

Two additional capabilities are **off by default** but can be granted by enabling the corresponding site setting:

| Action | Default | Granted by |
|--------|---------|------------|
| Reply on closed topics in moderated categories | Off | `mini_mod_can_post_in_closed_topics: true` |
| Reopen closed topics in moderated categories | Off | `mini_mod_can_reopen_topics: true` |

Closing open topics, archiving, pinning, splitting/merging, and every other moderation action remain available to mini-mods in their categories regardless of these settings.

See [docs/](docs/) for detailed documentation, including a [comparison of mini-mods vs moderators](docs/comparison.md).

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
