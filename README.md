# discourse-mod-categories

A Discourse plugin that grants **moderators** the ability to create, edit, and delete categories — capabilities that are normally reserved for admins.

Everything else moderators already have in core Discourse (editing topics, moving posts, bulk-changing topic categories, managing tags, etc.) is left untouched.

## How it works

1. Install the plugin
2. Enable `mod_categories_enabled` in site settings
3. Anyone in the built-in moderators group can now create, edit, and delete categories

## Settings

| Setting | Default | Description |
|---------|---------|-------------|
| `mod_categories_enabled` | `false` | Allow moderators to create, edit, and delete categories |

## Permissions granted

| Action | Default |
|--------|---------|
| Create categories | All categories |
| Edit categories | All categories |
| Delete categories | All categories (must be empty, no children) |

## Installation

Add the plugin's repository URL to your `app.yml`:

```yaml
hooks:
  after_code:
    - exec:
        cd: $home/plugins
        cmd:
          - git clone https://github.com/Shalom-Karr/discourse-mod.git
```

Then rebuild the container:

```
./launcher rebuild app
```
