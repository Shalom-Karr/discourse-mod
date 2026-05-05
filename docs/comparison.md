# Moderators vs Admins

This compares a Discourse moderator with the plugin enabled against a Discourse admin.

The plugin only extends category create/edit/delete to moderators. Every other moderator/admin capability is unchanged from core.

## Content organization

| Ability | Admin | Moderator (with plugin) | Source |
|---------|-------|-------------------------|--------|
| Create categories | All | All | Plugin |
| Edit categories | All | All | Plugin |
| Delete categories | All (empty) | All (empty, no children) | Plugin |
| Create/edit/delete tags | Yes | Yes | Core |
| Edit topics | Yes | Yes | Core |
| Bulk change topic category | Yes | Yes | Core |

## Topic moderation

| Ability | Admin | Moderator | Source |
|---------|-------|-----------|--------|
| Close / reopen topics | Yes | Yes | Core |
| Reply on closed topics | Yes | Yes | Core |
| Archive / pin / unlist topics | Yes | Yes | Core |
| Split / merge topics | Yes | Yes | Core |
| Move posts | Yes | Yes | Core |
| Delete topics / posts | Yes | Yes | Core |

## User and site administration

| Ability | Admin | Moderator |
|---------|-------|-----------|
| Suspend / silence users | Yes | Yes |
| Review queue / handle flags | Yes | Yes |
| View deleted content | Yes | Yes |
| Access admin panel | Yes | Yes (limited) |
| Manage site settings | Yes | No |
| Install plugins | Yes | No |
| Manage admin users | Yes | No |

## Summary

The plugin closes a single specific gap in core: moderators can manage almost every aspect of the forum, but cannot create, edit, or delete categories themselves. With this plugin enabled, they can — without elevating them to full admins.
