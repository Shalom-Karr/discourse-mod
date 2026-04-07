# Trust Level 4 closed-topic restrictions

The plugin bundles two site settings that clamp down trust level 4 (TL4) users on closed topics. **These are independent of the mini-mod features** and apply site-wide to any TL4 user, regardless of whether they're in a category moderation group.

## Why this is in this plugin

Discourse core treats TL4 users as "trusted" in two ways that overlap with what the mini-mod side of this plugin already overrides:

1. `Guardian::TopicGuardian#can_create_post_on_topic?` lets TL4 users reply on closed topics anywhere on the site (via core's "trusted" branch).
2. `Guardian::TopicGuardian#can_perform_action_available_to_group_moderators?` — aliased to `can_close_topic?`, `can_open_topic?`, `can_archive_topic?`, `can_pin_unpin_topic?`, `can_split_merge_topic?`, `can_edit_staff_notes?` — returns `true` for any TL4 user on any topic they can see, allowing all of those actions site-wide.

Because the plugin already overrides those Guardian methods to gate mini-mods, adding TL4 gates to the same overrides was a small extension that solved a related forum-management problem (strict closed-topic semantics) without needing a second plugin.

The two settings live in their own **Trust Level 4** section in the admin site settings UI, separate from the mini-mod settings.

## Settings

### `tl4_can_post_in_closed_topics`

- **Default:** `false`
- **Client:** no

When `false`, blocks any non-staff TL4 user from replying on a closed topic anywhere on the site. When `true`, falls through to core's normal "trusted" handling.

**Requires:** `mini_mod_enabled` (the plugin's master switch)

### `tl4_can_reopen_topics`

- **Default:** `false`
- **Client:** no

When `false`, blocks any non-staff TL4 user from reopening a closed topic anywhere on the site. Both reopen paths are covered:

- The manual UI toggle, via `can_close_topic?` — Discourse routes both close and reopen through this method and infers the direction from `topic.closed?`.
- The topic-timer reopen path, via `can_open_topic?` — used by `Jobs::OpenTopic` when a scheduled timer fires.

When `true`, falls through to core.

**Requires:** `mini_mod_enabled`

## What is and isn't restricted

The restrictions are intentionally narrow:

- **Only closed topics** are affected. Open topics are untouched — TL4 users can still close them, archive them, pin them, and so on.
- **Only the two Guardian methods listed above** are touched. Every other TL4 grant (wiki posts via `can_wiki?`, `can_rebake?`, `can_see_unlisted_topics?`, `can_skip_bump?`, `can_update_bumped_at?`, etc.) is left exactly as core ships it.
- **Site staff are unaffected.** Admins and moderators retain their independent capabilities — the gates short-circuit on `is_staff?` before checking trust level.
- **The button hides too.** When the reopen gate is active, `TopicViewDetailsSerializer#include_can_close_topic?` returns `false` on closed topics for non-staff TL4 users, so the close/reopen button disappears from the topic admin menu instead of staying visible and surfacing a 403 on click.

## Interaction with the mini-mod settings

A user who is **both** a TL4 user **and** a mini-mod for a category is gated by **both** the `mini_mod_*` setting and the `tl4_*` setting for that action. Both must be enabled for the user to act. This is verified at every layer:

| Layer | Spec |
|-------|------|
| Guardian unit | `spec/lib/guardian_extensions_spec.rb` — "TL4 user who is also a mini-mod" |
| HTTP request | `spec/requests/closed_topic_reply_spec.rb`, `spec/requests/topic_status_toggle_spec.rb` |
| Topic-view serializer | `spec/lib/topic_view_details_serializer_extension_spec.rb` — "TL4 user who is also a mini-mod" |
| Topic-timer job | `spec/jobs/open_topic_job_spec.rb` — "TL4 user who is also a mini-mod" |

## How it works technically

The plugin's existing Guardian overrides each grew an extra TL4 branch:

| Method | TL4 branch fires when |
|--------|----------------------|
| `can_create_post_on_topic?` | `tl4_can_post_in_closed_topics` is `false`, topic is closed, viewer is non-staff TL4 |
| `can_close_topic?` | `tl4_can_reopen_topics` is `false`, topic is closed, viewer is non-staff TL4 |
| `can_open_topic?` | `tl4_can_reopen_topics` is `false`, viewer is non-staff TL4 |

All three TL4 branches sit **above** the mini-mod branches in each method, so a TL4-mini-mod hybrid hits the TL4 gate first.

The serializer extension `TopicViewDetailsSerializerExtension#include_can_close_topic?` mirrors the `can_close_topic?` Guardian override so the close/reopen button is hidden client-side as well — without it, the button stayed visible for TL4 users on closed topics and clicking it surfaced a 403 from `ensure_can_close_topic!`.
