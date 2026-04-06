# Mini-mods vs Moderators

This compares a mini-mod user (all plugin settings enabled) with a Discourse moderator.

## Content organization

| Ability | Moderator | Mini-mod | Notes |
|---------|-----------|----------|-------|
| Create/edit/delete categories | All | All | Plugin feature |
| Create/edit/delete tags | All | All (not tag groups) | Plugin feature |
| Edit topics (title, content) | All | All visible | Core in moderated categories; plugin extends to all with manage-all |
| Bulk change topic category | All | All visible | Plugin feature |
| Reorder categories | Yes | Yes | Plugin feature |

## Topic moderation

| Ability | Moderator | Mini-mod | Notes |
|---------|-----------|----------|-------|
| Close/open topics | All | Moderated categories only | Core feature, not extended by plugin |
| Reply on closed topics | All | Moderated categories (revocable) | Core feature; plugin can revoke via `mini_mod_can_post_in_closed_topics` |
| Archive topics | All | Moderated categories only | Core feature |
| Pin/unpin topics | All | Moderated categories only | Core feature |
| Unlist/relist topics | All | Moderated categories only | Core feature |
| Split/merge topics | All | Moderated categories only | Core feature |
| Move posts | All | Moderated categories only | Core feature |
| Delete topics/posts | Yes | No | |
| Lock posts | Yes | No | |
| Edit staff notes | All | Moderated categories only | Core feature |
| Convert topic to/from PM | Yes | No | |

`manage_all_categories` does **not** extend these core moderation abilities beyond moderated categories.

## User management

| Ability | Moderator | Mini-mod |
|---------|-----------|----------|
| Suspend users | Yes | No |
| Silence users | Yes | No |
| Send official warnings | Yes | No |
| Approve/reject users | Yes | No |
| Anonymize users | Yes | No |
| View user emails/IPs | Yes | No |
| View user activity in detail | Yes | No |

## Site administration

| Ability | Moderator | Mini-mod |
|---------|-----------|----------|
| Access admin panel | Yes | No |
| Review queue / manage flags | Yes | No |
| View deleted content | Yes | No |
| Manage tag groups | Yes | No |
| View staff action logs | Yes | No |
| Manage site settings | No (admin only) | No |

## Summary

Mini-mods are **content organizers** — they can manage categories, tags, and move topics around. Moderators are **rule enforcers** — they can manage users, handle flags, and take disciplinary action. The plugin bridges the gap for teams that need people organizing content without giving them full moderation power.
