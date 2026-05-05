# Test Suite

The plugin's specs run on every push and pull request through the workflow at `.github/workflows/plugin-tests.yml`. The job mounts this repo as `discourse/plugins/discourse-mod` against `discourse/discourse` (main) and runs RSpec.

## Layout

```
spec/
├── plugin_spec.rb                              # plugin.rb wiring + master switch
├── lib/
│   └── guardian_extensions_spec.rb             # Guardian.prepend behaviour
└── requests/
    └── moderator_category_management_spec.rb   # /categories.json end-to-end
```

## What's covered

### `spec/plugin_spec.rb` — `DiscourseModCategories plugin.rb`

Verifies the plugin's wiring:

- Guardian prepend
  - `DiscourseModCategories::GuardianExtensions` is in `Guardian.ancestors`
- Master switch (`mod_categories_enabled`)
  - When disabled: moderators denied; admins still allowed; regular users still denied
  - When enabled: moderators granted create/edit/delete; admins still allowed; regular users still denied
- Settings registration
  - `mod_categories_enabled` defaults to `false`

### `spec/lib/guardian_extensions_spec.rb` — `DiscourseModCategories::GuardianExtensions`

Per-method coverage of every Guardian override:

- `#can_create_category?` — moderator allow, admin allow (super), regular-user deny, anonymous deny, plugin-disabled deny
- `#can_edit_category?` — moderator allow, regular-user deny, plugin-disabled deny
- `#can_edit_serialized_category?` — moderator allow, regular-user deny, plugin-disabled deny
- `#can_delete_category?` — moderator allow on empty category; deny when topics exist, when subcategories exist, when uncategorized; regular-user deny; plugin-disabled deny

### `spec/requests/moderator_category_management_spec.rb` — `/categories.json`

End-to-end request specs hitting the actual controller routes:

- `POST /categories.json`
  - Moderator can create a top-level category
  - Moderator can create a subcategory under any category
  - Regular user gets 403
- `PUT /categories/:id.json`
  - Moderator can rename any category
  - Regular user gets 403, name unchanged
- `DELETE /categories/:id.json`
  - Moderator can delete an empty category
  - Regular user gets 403, category remains

## Running locally

From your Discourse checkout with the plugin mounted at `plugins/discourse-mod`:

```bash
bundle exec rspec plugins/discourse-mod/spec --format documentation
```

## Environment

| Component | Version |
|-----------|---------|
| Ruby | 3.4 |
| PostgreSQL | pgvector/pgvector:pg16 |
| Discourse | main branch |
