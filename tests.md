# Tests Ran

## Latest run (2026-05-05, GitHub Actions)

- **RSpec: 33 examples, 0 failures** (~11.25s, files loaded in 7.87s)
- Seed: `25635`
- Run: [`Plugin Tests` #25350762069](https://github.com/Shalom-Karr/discourse-mod/actions/runs/25350762069)
- Discourse: `discourse/discourse` main
- Ruby: 3.4 · Postgres: pgvector/pgvector:pg16

The CI workflow at `.github/workflows/plugin-tests.yml` re-runs this suite on every push and pull request.

## RSpec coverage

### `spec/plugin_spec.rb` — `DiscourseModCategories plugin.rb`

#### Guardian prepend
- ✓ wires the `GuardianExtensions` module into `Guardian`

#### master switch (`mod_categories_enabled`)

When **enabled**:
- ✓ grants moderators category create/edit/delete
- ✓ does not change admin privileges
- ✓ still denies regular users

When **disabled** (default):
- ✓ denies moderators
- ✓ still allows admins
- ✓ still denies regular users

#### settings registration
- ✓ registers `mod_categories_enabled` with the correct default (`false`)

### `spec/lib/guardian_extensions_spec.rb` — `DiscourseModCategories::GuardianExtensions`

#### `#can_create_category?`
- ✓ allows moderators to create categories
- ✓ allows moderators to create subcategories under any category
- ✓ still allows admins
- ✓ does not allow regular users
- ✓ does not allow anonymous users
- ✓ does not allow when plugin is disabled

#### `#can_edit_category?`
- ✓ allows moderators to edit categories
- ✓ does not allow regular users
- ✓ does not allow when plugin is disabled

#### `#can_edit_serialized_category?`
- ✓ allows moderators
- ✓ does not allow regular users
- ✓ does not allow when plugin is disabled

#### `#can_delete_category?`
- ✓ allows moderators to delete an empty category
- ✓ does not allow deleting categories with topics
- ✓ does not allow deleting categories with subcategories
- ✓ does not allow deleting the uncategorized category
- ✓ does not allow regular users
- ✓ does not allow when plugin is disabled

### `spec/requests/moderator_category_management_spec.rb` — `Category management for moderators`

#### `POST /categories.json`
- ✓ lets a moderator create a top-level category
- ✓ lets a moderator create a subcategory under any category
- ✓ blocks a regular user from creating a category (403)

#### `PUT /categories/:id.json`
- ✓ lets a moderator edit any category
- ✓ blocks a regular user from editing a category (403, name unchanged)

#### `DELETE /categories/:id.json`
- ✓ lets a moderator delete an empty category
- ✓ blocks a regular user from deleting a category (403, category remains)

## Summary

| Metric | Value |
|--------|-------|
| Total examples | 33 |
| Failures | 0 |
| Time | 11.25 seconds (files loaded in 7.87s) |
| Seed | 25635 |
| Discourse version | main branch |
| Ruby | 3.4 |
| PostgreSQL | pgvector/pgvector:pg16 |

## Running locally

From your Discourse checkout with the plugin mounted at `plugins/discourse-mod`:

```bash
bundle exec rspec plugins/discourse-mod/spec --format documentation
```
