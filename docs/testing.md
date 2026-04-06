# Running the Test Suite

A minimal recipe for running this plugin's RSpec specs without standing up the full Discourse development environment (no admin user, no dev seed data, no Ember CLI, no web server).

The official `discourse/discourse_dev:release` Docker image already contains Ruby, Postgres, Redis, Node, pnpm, and Discourse's gem bundle pre-installed — most of the heavy work is just downloading the image once.

## Prerequisites

- Docker (x86_64 host)
- A local checkout of the Discourse repo
- A local checkout of this plugin

## One-time setup

Set shell variables to point at your checkouts (adjust to match your environment):

```bash
export DISCOURSE_DIR=/path/to/discourse
export PLUGIN_DIR=/path/to/discourse-mini-mod
```

### 1. Symlink the plugin into Discourse's `plugins/` directory

Discourse's test loader discovers plugins from `plugins/<plugin-name>/`, so the plugin source needs to be reachable from there. A symlink works:

```bash
ln -s "$PLUGIN_DIR" "$DISCOURSE_DIR/plugins/discourse-mini-mod"
```

### 2. Pull the dev image

```bash
docker pull discourse/discourse_dev:release
```

### 3. Start the dev container

This is a stripped-down version of `d/boot_dev` — no port forwarding, no `--restart=always`, just the volume mounts the test runner needs. The plugin source is mounted explicitly because the symlink in `plugins/` would otherwise point to a host path that doesn't exist inside the container.

```bash
mkdir -p "$DISCOURSE_DIR/data/postgres"

docker run -d \
  -v "$DISCOURSE_DIR/data/postgres:/shared/postgres_data:delegated" \
  -v "$DISCOURSE_DIR:/src:delegated" \
  -v "$PLUGIN_DIR:/src/plugins/discourse-mini-mod:delegated" \
  --hostname=discourse \
  --name=discourse_dev \
  discourse/discourse_dev:release /sbin/boot
```

Wait a second or two for Postgres inside the container to come up:

```bash
docker exec -u discourse:discourse discourse_dev pg_isready -h localhost -p 5432
```

### 4. Confirm gems are satisfied

The image already ships with `bundle install` complete. Verify:

```bash
docker exec -u discourse:discourse -w /src discourse_dev bundle check
```

Expected output: `The Gemfile's dependencies are satisfied`. If not, run `docker exec -u discourse:discourse -w /src discourse_dev bundle install`.

### 5. Install JS dependencies (required for `db:migrate`)

You don't need a frontend build, but `db:migrate` depends on `assets:precompile:asset_processor`, which reads `node_modules/.pnpm/lock.yaml` to compute a cache digest. Without that file, migrations abort. Run pnpm install once:

```bash
docker exec -u discourse:discourse -w /src discourse_dev pnpm install
```

This is fast (a few seconds) because the image's volume already contains the resolved package store.

### 6. Create and migrate the test database

```bash
docker exec -u discourse:discourse -w /src \
  -e RAILS_ENV=test -e LOAD_PLUGINS=1 \
  discourse_dev bin/rake db:create db:migrate
```

This is a one-time cost (a few minutes the first time) and only sets up the **test** database — no dev DB, no admin user, no seed data.

## Running specs

```bash
docker exec -u discourse:discourse -w /src \
  -e RAILS_ENV=test -e LOAD_PLUGINS=1 \
  discourse_dev bin/rspec plugins/discourse-mini-mod/spec/lib/guardian_extensions_spec.rb
```

`LOAD_PLUGINS=1` is required so plugin specs are loaded. To run a single describe block:

```bash
docker exec -u discourse:discourse -w /src \
  -e RAILS_ENV=test -e LOAD_PLUGINS=1 \
  discourse_dev bin/rspec plugins/discourse-mini-mod/spec/lib/guardian_extensions_spec.rb \
  -e "#can_create_post_on_topic?"
```

To run a single example by line number:

```bash
docker exec -u discourse:discourse -w /src \
  -e RAILS_ENV=test -e LOAD_PLUGINS=1 \
  discourse_dev bin/rspec plugins/discourse-mini-mod/spec/lib/guardian_extensions_spec.rb:42
```

## Linting

```bash
docker exec -u discourse:discourse -w /src discourse_dev bin/lint \
  plugins/discourse-mini-mod/lib/discourse_mini_mod/guardian_extensions.rb \
  plugins/discourse-mini-mod/spec/lib/guardian_extensions_spec.rb
```

Add `--fix` to auto-format:

```bash
docker exec -u discourse:discourse -w /src discourse_dev bin/lint --fix \
  plugins/discourse-mini-mod/lib/discourse_mini_mod/guardian_extensions.rb
```

## Why not use `d/rspec`, `d/rake`, etc.?

Discourse ships wrapper scripts in `d/` that call `d/exec`, which uses `docker exec -it`. The `-i` flag requires a TTY, so the wrappers can't be used from non-interactive contexts (CI, scripts, background processes). Calling `docker exec` directly avoids this. If you're at an interactive shell, the `d/*` wrappers work fine — substitute `d/rspec` for the long `docker exec ... bin/rspec` commands above.

## Tearing down

Stop and remove the container (Postgres data is preserved in `$DISCOURSE_DIR/data/postgres` and reused on the next `docker run`):

```bash
docker stop discourse_dev && docker rm discourse_dev
```

To also wipe the test database:

```bash
rm -rf "$DISCOURSE_DIR/data/postgres"
```

To remove the plugin symlink:

```bash
rm "$DISCOURSE_DIR/plugins/discourse-mini-mod"
```

## What this skips compared to `d/boot_dev`

| `d/boot_dev` does | This recipe |
|---|---|
| Pulls image | Same |
| Mounts source + symlinked plugins | Same |
| Forwards ports 3000/4200/8025/9292/9405 | Skipped (no web server) |
| `bundle install` | Skipped (image-baked) |
| `pnpm install` | Done (required for `db:migrate`) |
| With `--init`: `db:create`, `db:migrate` (dev + test), `admin:create` | Test DB only, no admin |
| `--restart=always` on the container | Skipped |
