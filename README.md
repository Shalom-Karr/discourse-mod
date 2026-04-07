# discourse-mini-mod

> Mini-mods can rearrange the shelves. Moderators can kick people out of the store.

A Discourse plugin that gives regular users the power to manage categories, tags, and topics — without requiring moderator or admin status.

It builds on Discourse's existing category group moderation feature by extending the permissions it grants.

The plugin also bundles two **trust level 4 closed-topic restrictions** as a separate, optional concern. These are independent of the mini-mod features and clamp down core Discourse's default behaviour of letting TL4 users reply on and reopen closed topics anywhere on the site. They live in their own **Trust Level 4** section in the admin site settings UI. See [docs/trust-level-4.md](docs/trust-level-4.md) for the rationale and full design.

## How it works

1. Create a group and add your users to it
2. Go to a category, press the wrench, then add the group to "In addition to staff, content in this category can also be reviewed by:"
3. Enable `mini_mod_enabled` in site settings
4. Those users can now manage categories they moderate

Optionally enable `mini_mod_manage_all_categories` to let them manage **all** categories and move topics between any categories. Enable `mini_mod_manage_tags` to let them create, edit, and delete tags.

## Settings

The plugin's settings are split across two top-level sections in the admin site settings UI.

### Mini-mod settings

These govern category group moderators (mini-mods). Visit `/admin/site_settings/category/discourse_mini_mod`.

| Setting | Default | Description |
|---------|---------|-------------|
| `mini_mod_enabled` | `false` | Enable the plugin |
| `mini_mod_manage_all_categories` | `false` | Allow category group moderators to manage all categories and edit/move topics across all categories |
| `mini_mod_manage_tags` | `false` | Allow category group moderators to create, edit, and delete tags |
| `mini_mod_can_post_in_closed_topics` | `false` | Allow category group moderators to reply on closed topics in categories they moderate. Disabled by default — enable to grant; site staff are unaffected |
| `mini_mod_can_reopen_topics` | `false` | Allow category group moderators to reopen closed topics in categories they moderate. Disabled by default — enable to grant; site staff are unaffected |

### Trust Level 4 settings

Independent of the mini-mod features. These clamp down core Discourse's default behaviour of letting trust level 4 users reply on and reopen closed topics anywhere on the site. Visit `/admin/site_settings/category/trust_level_4`.

| Setting | Default | Description |
|---------|---------|-------------|
| `tl4_can_post_in_closed_topics` | `false` | Allow trust level 4 users to reply on closed topics anywhere on the site. Disabled by default — enable to grant; site staff are unaffected |
| `tl4_can_reopen_topics` | `false` | Allow trust level 4 users to reopen closed topics anywhere on the site. Disabled by default — enable to grant; site staff are unaffected |

See [docs/trust-level-4.md](docs/trust-level-4.md) for the full design rationale.

All settings require `mini_mod_enabled` to also be enabled (it's the plugin's master switch). Mini-mod settings additionally require Discourse core's `enable_category_group_moderation`. Tag management also requires `tagging_enabled`.

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

## Trust Level 4 restrictions

Discourse core treats trust level 4 (TL4) users as "trusted" and lets them reply on closed topics and close/reopen any topic they can see, site-wide. This plugin bundles two settings that clamp that down:

| Action | Default | Granted by |
|--------|---------|------------|
| Reply on closed topics anywhere on the site (as TL4) | Off | `tl4_can_post_in_closed_topics: true` |
| Reopen closed topics anywhere on the site (as TL4) | Off | `tl4_can_reopen_topics: true` |

These restrictions are **independent of the mini-mod features**. They apply to any TL4 user regardless of whether they're in a category moderation group, and they only touch the reply-on-closed and reopen actions — every other TL4 grant in core (`can_wiki?`, `can_rebake?`, `can_see_unlisted_topics?`, etc.) is left alone. Site staff are unaffected. A user who is **both** TL4 and a mini-mod must clear both gates to act.

See [docs/trust-level-4.md](docs/trust-level-4.md) for the full design rationale.

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
