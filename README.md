# TeamFlow API

![Ruby](https://img.shields.io/badge/Ruby-3.4-CC342D?logo=ruby&logoColor=white)
![Rails](https://img.shields.io/badge/Rails-8.1-CC0000?logo=rubyonrails&logoColor=white)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-16-4169E1?logo=postgresql&logoColor=white)
![Tests](https://img.shields.io/badge/tests-96%20passing-brightgreen)
![Docker](https://img.shields.io/badge/Docker-ready-2496ED?logo=docker&logoColor=white)

A REST API for team and task management, built as a portfolio project to demonstrate backend
engineering practices with Ruby on Rails: authentication, role-based authorization, consistent
error handling, filtering, pagination, and a tested, containerized development setup.

## Highlights

Built for backend júnior/estágio applications. What it's meant to demonstrate:

- **Authentication built from scratch** — JWT encode/decode implemented by hand rather than
  plugging in Devise, to show the mechanics of password hashing, token signing and expiration
  are understood, not just used. The trade-off is spelled out in
  [Architecture notes](#architecture-notes).
- **Role-based authorization** — Pundit policies enforce a member/admin/owner permission matrix
  scoped per team, with every role × action combination covered by policy specs.
- **Consistent API design** — versioned routes (`/api/v1`), a single standardized error envelope
  across the whole app, filtering and pagination on list endpoints.
- **Automated testing** — 96 RSpec examples across models, policies and full HTTP request specs;
  RuboCop and Brakeman both run clean (see [Running tests](#running-tests)).
- **Containerized development** — one `docker compose up` brings up the app and Postgres
  together; verified end-to-end (build → migrate → seed → boot).
- **Trade-offs are documented, not hidden** — every non-obvious architectural choice (why manual
  JWT, why members can add tasks but not projects, why pagination is pinned to an older Pagy
  release) is written down in [Architecture notes](#architecture-notes).

## Table of contents

- [Stack](#stack)
- [Domain model](#domain-model)
- [Architecture notes](#architecture-notes)
- [Getting started](#getting-started)
- [Running tests](#running-tests)
- [API reference](#api-reference)
- [Environment variables](#environment-variables)
- [Possible next steps](#possible-next-steps)

## Stack

- Ruby 3.4 / Rails 8.1 (API-only mode)
- PostgreSQL
- RSpec (model, policy and request specs)
- Docker / Docker Compose for local development
- Pundit (authorization), Blueprinter (serialization), Pagy (pagination)

## Domain model

```
User ─┬──< TeamMembership >──┬─ Team ──< Project ──< Task >── assignee (User)
      │      role: member/admin/owner
```

- **User** — has a name, a unique email and a password (via `has_secure_password`).
- **Team** — has many members through `TeamMembership`, has many `Project`s.
- **TeamMembership** — join model between `User` and `Team`, carries the `role`
  (`member`, `admin`, `owner`). A team has exactly one `owner`, assigned automatically to
  whoever creates the team; ownership is not transferable through the API.
- **Project** — belongs to a `Team`, has many `Task`s.
- **Task** — belongs to a `Project`, has a title, description, `status`
  (`pending`/`in_progress`/`done`), `priority` (`low`/`medium`/`high`), an optional `due_date`
  and an optional `assignee`, who must belong to the project's team.

### Permission model

| Action                          | member | admin | owner |
|----------------------------------|:------:|:-----:|:-----:|
| View team / projects / tasks     |   ✅   |  ✅   |  ✅   |
| Create / edit tasks              |   ✅   |  ✅   |  ✅   |
| Create / edit / delete projects  |   ❌   |  ✅   |  ✅   |
| Add / remove / promote members   |   ❌   |  ✅   |  ✅   |
| Update / delete the team         |   ❌   | update only |  ✅   |

Authorization is implemented with [Pundit](https://github.com/varvet/pundit); every policy
resolves the caller's role through their `TeamMembership` on the relevant team. See
`app/policies/`.

## Architecture notes

- **Authentication is a hand-rolled JWT implementation** (`app/lib/json_web_token.rb` +
  `ApplicationController#authenticate_request`), built intentionally instead of using
  Devise/devise-jwt. This is a deliberate portfolio choice to demonstrate understanding of how
  token-based auth works under the hood (password hashing with bcrypt, token signing,
  expiration). **In a production application this would typically be replaced by a maintained
  solution** such as Devise + devise-jwt, which adds things like refresh tokens, revocation and
  battle-tested edge-case handling that this implementation does not attempt to cover.
- **Adding members to a team** is done directly by an admin/owner (`POST
  /api/v1/teams/:team_id/memberships` with an existing user's id) rather than through an email
  invitation flow. This keeps the project's scope focused; a token-based email invite system
  would be a natural next step.
- **Errors** are always returned in the same envelope, handled centrally in
  `ApplicationController`:
  ```json
  { "error": { "code": "validation_failed", "message": "Validation failed", "details": { "title": ["can't be blank"] } } }
  ```
  `details` is omitted when there's nothing more specific than the message.
- **Pagination** uses [Pagy](https://github.com/ddnexus/pagy), pinned to the `~> 9.4` line — the
  latest Pagy major release (43.x) is a from-scratch rewrite of the gem's API; 9.x is the last
  version with the classic, widely-documented `Pagy::Backend` API.

## Getting started

### Option A — Docker (recommended)

Requires Docker and Docker Compose.

```bash
cp .env.example .env        # defaults already work as-is
docker compose build
docker compose up -d
docker compose exec web bin/rails db:setup   # create, migrate and seed the database
```

The API is now available at `http://localhost:3000`. Check `http://localhost:3000/up` for a
health check.

Useful commands:

```bash
docker compose logs -f web          # tail app logs
docker compose exec web bin/rails console
docker compose exec web bundle exec rspec
docker compose down                 # stop containers (add -v to also wipe the db volume)
```

### Option B — Local Ruby

Requires Ruby 3.4 (see `.ruby-version`) and a running PostgreSQL instance.

```bash
bundle install
cp .env.example .env                       # adjust DATABASE_* if not using the defaults below
bin/rails db:setup                         # create, migrate and seed the database
bin/rails server
```

By default the app connects to `postgres:postgres@localhost:5432`. If you don't have Postgres
installed locally, you can still just run `docker compose up -d db` to start only the database
container and point the local Rails server at `localhost:5432`.

### Sample login (after seeding)

```
email: ana@teamflow.dev
password: password123
```

## Running tests

```bash
bundle exec rspec        # or: docker compose exec web bundle exec rspec
bin/rubocop               # style
bin/brakeman               # static security scan
```

Tests are organized as:

- `spec/models` — validations, associations, enums, business rules (e.g. one owner per team).
- `spec/policies` — the full member/admin/owner permission matrix per resource.
- `spec/requests` — end-to-end HTTP specs per endpoint: happy paths, authorization boundaries,
  filters, pagination and the error envelope.
- `spec/factories` — FactoryBot factories used across all of the above.

## API reference

All endpoints are under `/api/v1`. Except for signup/login, every request requires:

```
Authorization: Bearer <token>
```

### Auth

| Method | Path             | Description                          |
|--------|------------------|---------------------------------------|
| POST   | `/signup`        | Create an account, returns a token    |
| POST   | `/login`         | Authenticate, returns a token         |

<details>
<summary>Examples</summary>

```bash
curl -X POST localhost:3000/api/v1/signup \
  -H "Content-Type: application/json" \
  -d '{"user":{"name":"Ana","email":"ana@example.com","password":"password123"}}'

curl -X POST localhost:3000/api/v1/login \
  -H "Content-Type: application/json" \
  -d '{"session":{"email":"ana@example.com","password":"password123"}}'
```
</details>

### Teams

| Method | Path                 | Who                    |
|--------|----------------------|-------------------------|
| GET    | `/teams`             | any authenticated user (returns their own teams, paginated) |
| POST   | `/teams`             | any authenticated user (creator becomes owner) |
| GET    | `/teams/:id`         | team members |
| PATCH  | `/teams/:id`         | admin/owner |
| DELETE | `/teams/:id`         | owner |

### Team memberships

| Method | Path                                      | Who |
|--------|--------------------------------------------|-----|
| GET    | `/teams/:team_id/memberships`               | team members |
| POST   | `/teams/:team_id/memberships`               | admin/owner — body: `{ "membership": { "user_id": 2, "role": "member" } }` |
| PATCH  | `/teams/:team_id/memberships/:id`           | admin/owner — change `role` to `member`/`admin` (not `owner`) |
| DELETE | `/teams/:team_id/memberships/:id`           | admin/owner (cannot remove the owner) |

### Projects

| Method | Path                              | Who |
|--------|------------------------------------|-----|
| GET    | `/teams/:team_id/projects`          | team members, paginated |
| POST   | `/teams/:team_id/projects`          | admin/owner |
| GET    | `/projects/:id`                     | team members |
| PATCH  | `/projects/:id`                     | admin/owner |
| DELETE | `/projects/:id`                     | admin/owner |

### Tasks

| Method | Path                                | Who |
|--------|--------------------------------------|-----|
| GET    | `/projects/:project_id/tasks`         | team members, paginated, filterable |
| POST   | `/projects/:project_id/tasks`         | any team member |
| GET    | `/tasks/:id`                          | team members |
| PATCH  | `/tasks/:id`                          | any team member |
| DELETE | `/tasks/:id`                          | any team member |

Filters on `GET /projects/:project_id/tasks` (combinable, all optional):

```
?status=pending|in_progress|done
&priority=low|medium|high
&assignee_id=<user_id>
&page=<n>
```

```bash
curl "localhost:3000/api/v1/projects/1/tasks?status=pending&priority=high" \
  -H "Authorization: Bearer <token>"
```

Paginated list responses share this shape:

```json
{
  "tasks": [ { "...": "..." } ],
  "meta": { "page": 1, "items": 20, "count": 7, "pages": 1 }
}
```

## Environment variables

See `.env.example`. In short:

| Variable | Purpose |
|----------|---------|
| `DATABASE_HOST`, `DATABASE_PORT`, `DATABASE_USERNAME`, `DATABASE_PASSWORD` | Postgres connection |
| `JWT_SECRET_KEY` | Secret used to sign auth tokens (falls back to the Rails credentials secret key base if unset) |
| `CORS_ORIGINS` | Comma-separated allowed origins for CORS (defaults to `*` for local development) |

## Possible next steps

- Email-based team invitations instead of direct add-by-id.
- Refresh tokens / token revocation for the JWT flow.
- Soft deletes for teams/projects/tasks instead of hard cascade deletes.
- Rate limiting (e.g. `rack-attack`) on the auth endpoints.

## Author

**Ana Morais** — [LinkedIn](https://www.linkedin.com/in/ana-morais-dev/)
