# Biscou Reservation API — Frontend Reference

This is the reference for the HTTP and WebSocket API that the frontend talks to. It covers every route the API exposes today. The behavior described here was checked by calling each endpoint against the backend (branch `user-mgmt-changes`, 2026-10-23). Routes that are unfinished or broken are flagged as **NOT USABLE** — do not build features on them yet.

## General conventions

- **Base URL (dev):** `http://localhost:3000`
- **Format:** JSON in and out. Send `Content-Type: application/json` and a JSON body on POST/PATCH/PUT. GET parameters go in the query string. All routes default to JSON, so no `.json` suffix is needed.
- **IDs:** user IDs are UUID strings, e.g. `"01a2380c-b225-4a8f-91fb-249933afca81"`.
- **Timestamps:** ISO 8601 UTC strings, e.g. `"2026-10-23T19:05:45.345Z"`.
- **CORS:** only `http://localhost:5173` and `http://127.0.0.1:5173` are allowed origins, with credentials enabled. The frontend dev server must run on port 5173.

## Authentication

Authentication is a **cookie-based session**. There are no tokens and no `Authorization` header.

- A successful `POST /auth/login` or `POST /users/signup` sets a signed, `HttpOnly` cookie named `session_id`. JavaScript cannot read it; the browser just sends it back.
- **Every request must include credentials** so that the cookie is sent and stored:
  - `fetch(url, { credentials: 'include', ... })`
  - axios: `withCredentials: true`
- Sessions expire **3 hours after login**. The expiry is fixed; activity does not extend it. After expiry, protected routes return `401` and the user must log in again.
- Logging in while already logged in ends the old session and starts a new one.
- To find out whether the user is logged in (for example, on app load), call `GET /auth/current_user`: `200` means logged in, `401` means logged out.
- Handle `401` from any protected route globally: clear local user state and redirect to login.

## Data types

### User object

Every endpoint that returns a user returns this exact shape:

```json
{
  "id": "d21cf752-d320-4fb6-82da-f730e74e8723",
  "email": "john@surfretreat.com",
  "first_name": "John",
  "last_name": "Doe",
  "full_name": "John Doe",
  "role": "guest",
  "phone_number": "+15551234567",
  "created_at": "2026-10-23T19:05:45.345Z"
}
```

```ts
type User = {
  id: string;
  email: string;
  first_name: string;
  last_name: string;
  full_name: string;      // first_name + " " + last_name
  role: "guest" | "employee";
  phone_number: string;
  created_at: string;     // ISO 8601
};
```

Password fields are never returned. **`nationality` and `permission` are stored on the user but are NOT included in responses.**

### Roles and permissions

Every user has a **role** and a **permission**. Both are lowercase strings.

| Field | Allowed values | Default |
|---|---|---|
| `role` | `guest`, `employee` | `guest` |
| `permission` | `guest`, `employee`, `instructor`, `manager`, `admin` | `guest` |

Access rules that the API enforces:

- **Employee role:** `role == "employee"`.
- **Management:** `permission` is `manager` or `admin`.

Because `permission` is not in the User object, the frontend cannot currently tell from the API whether the logged-in user is management. To decide whether to show management-only UI, either attempt the call and handle `403`, or ask for `permission` to be added to the serializer.

## Errors

Rely on the **HTTP status code**. The response body is not consistent across errors.

| Status | Meaning | Body |
|---|---|---|
| `400` | A required parameter is missing (`/auth/login`, `/auth/email_exists`) | Rails error JSON (see below) |
| `401` | Not logged in or session expired, or wrong login credentials | `{"error": "Unauthorized"}` or `{"error": "Invalid email or password"}` |
| `403` | Logged in but lacks the required role or permission | `{"error": "Forbidden"}` |
| `404` | Record not found (e.g. an unknown user id on update) | Rails error JSON |
| `422` | Validation failed (duplicate email, invalid role/permission value, bad email format) | Rails error JSON |
| `429` | Rate limit hit | `{"error": "Too many attempts"}` |
| `500` | Server bug | Rails error JSON or HTML |

**Rails error JSON** in development looks like this:

```json
{ "status": 422, "error": "Unprocessable Content", "exception": "#<ActiveRecord::RecordInvalid: Validation failed: Email has already been taken>", "traces": { ... } }
```

The human-readable validation message is only embedded in the `exception` string, and only in development. In production the body is just `{"status": 422, "error": "Unprocessable Content"}`. Do not parse `exception` for UI messages. Show a generic message per status code; for `422` on signup, a duplicate email is the most likely cause.

Rate limits are counted per client IP.

---

## Endpoints

### Auth

#### `POST /auth/login`

Logs a user in and sets the session cookie.

- **Auth:** none
- **Rate limit:** 10 requests per minute
- **Body:**

  | Field | Type | Required |
  |---|---|---|
  | `email` | string | yes. Matching ignores case and surrounding whitespace |
  | `password` | string | yes |

- **Responses:**
  - `200` — the User object; `session_id` cookie is set
  - `400` — `email` or `password` missing or empty
  - `401` — `{"error": "Invalid email or password"}`. The response is the same whether the email is unknown or the password is wrong.
  - `429` — rate limited

```js
await fetch('http://localhost:3000/auth/login', {
  method: 'POST',
  credentials: 'include',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({ email, password }),
});
```

#### `POST /auth/logout`

Ends the current session, clears the cookie, and disconnects the user's WebSocket connections.

- **Auth:** none required. Calling it while logged out is safe.
- **Body:** none
- **Responses:** `204` with no body, always

#### `GET /auth/current_user`

Returns the logged-in user. Use it on app load to restore auth state.

- **Auth:** required
- **Responses:**
  - `200` — the User object
  - `401` — `{"error": "Unauthorized"}` (not logged in or session expired)

#### `GET /auth/email_exists`

Checks whether an account with this email exists. Use it in signup and login forms.

- **Auth:** none
- **Rate limit:** 10 requests per **10 minutes**. This limit is tight, so call it on blur or submit, never on every keystroke.
- **Query params:**

  | Param | Type | Required |
  |---|---|---|
  | `email` | string | yes |

- **Responses:**
  - `200` — the body is a bare JSON boolean: `true` or `false` (not an object)
  - `400` — `email` missing
  - `429` — rate limited

```js
const res = await fetch(`http://localhost:3000/auth/email_exists?email=${encodeURIComponent(email)}`, { credentials: 'include' });
const exists = await res.json(); // true | false
```

### Users

#### `POST /users/signup`

Public self-registration. Creates a user with role `guest` and permission `guest`, and **logs them in immediately** (sets the session cookie).

- **Auth:** none
- **Rate limit:** 10 requests per minute
- **Body** — all fields required and non-empty:

  | Field | Type | Notes |
  |---|---|---|
  | `first_name` | string | |
  | `last_name` | string | |
  | `email` | string | must be a valid email and unique; lowercased and trimmed by the server |
  | `password` | string | no server-side strength rules currently |
  | `nationality` | string | free text |
  | `phone_number` | string | free text; E.164 format (`+15551234567`) recommended |

  Any `role` or `permission` sent here is ignored.

- **Responses:**
  - `200` — the User object for the new user; `session_id` cookie is set
  - `422` — validation failed (most often: email already taken, or invalid email format)
  - `500` — **any required field missing or empty.** This is currently a server bug: it should be `422`. Validate all six fields on the client before submitting.
  - `429` — rate limited

#### `POST /users`

An employee creates a user, for example registering a guest at the front desk or adding a staff member. This does **not** log in as the new user.

- **Auth:** required; the caller's **role must be `employee`**
- **Body:** the same six required fields as signup, plus optional:

  | Field | Type | Notes |
  |---|---|---|
  | `role` | `"guest"` \| `"employee"` | defaults to `guest` |
  | `permission` | `"guest"` \| `"employee"` \| `"instructor"` \| `"manager"` \| `"admin"` | defaults to `guest` |

- **Responses:**
  - `200` — the User object for the created user
  - `401` — not logged in
  - `403` — caller's role is not `employee`
  - `422` — validation failed (duplicate email, invalid role or permission value)
  - `500` — a required field is missing (same bug as signup)

#### `PATCH /users/:id` (also `PUT`) — NOT USABLE YET

Updates a user. All body fields are optional; send only the fields being changed.

- **Auth:** required; the caller must be **management** (permission `manager` or `admin`)
- **Path:** `id` — the user's UUID
- **Body:**

  | Field | Type |
  |---|---|
  | `first_name` | string |
  | `last_name` | string |
  | `email` | string |
  | `nationality` | string |
  | `phone_number` | string |
  | `role` | `"guest"` \| `"employee"` |
  | `permission` | `"guest"` \| `"employee"` \| `"instructor"` \| `"manager"` \| `"admin"` |

  Password cannot be changed through this route.

- **Intended responses:** `200` with the updated User object, `401`, `403` for non-management callers, `404` for an unknown id, `422` for invalid values.
- **Current state:** valid updates currently fail with `422` because of a backend bug, and nothing is saved. `401`, `403` and `404` already behave as described.

#### `GET /users/:id` — NOT USABLE YET

Fetch a single user. Requires role `employee` (otherwise `403`). For employees it **currently returns `500`**, because the backend action is not implemented.

#### `GET /users` — NOT USABLE YET

List users. Requires management permission (otherwise `403`). For management users it **currently returns `200` with the placeholder string `"users/index"`** instead of a list. The response format is undecided.

---

## WebSocket (ActionCable)

- **URL:** `ws://localhost:3000/cable`
- **Auth:** the same `session_id` cookie. The connection is rejected if the user is not logged in. Open it only after login; logout disconnects it on the server.
- **Channel:** `EventChannel` (no params)

```js
import { createConsumer } from '@rails/actioncable';
const consumer = createConsumer('ws://localhost:3000/cable');
consumer.subscriptions.create({ channel: 'EventChannel' }, {
  received(data) { /* event payload */ },
});
```

**Current state:** you can subscribe, but the backend does not broadcast anything on this channel yet, and the payload format is not defined. Event types that will exist include `user.created`, `user.updated`, `reservation.created` and `reservation.updated`. Do not depend on them yet.

---

## Quick reference

| Method | Path | Auth | Purpose | Status |
|---|---|---|---|---|
| POST | `/auth/login` | none | Log in, set cookie | Working |
| POST | `/auth/logout` | none | Log out, clear cookie | Working |
| GET | `/auth/current_user` | logged in | Get the current user | Working |
| GET | `/auth/email_exists?email=` | none | Check whether an email is registered | Working |
| POST | `/users/signup` | none | Self-register and log in | Working (missing field gives 500) |
| POST | `/users` | role `employee` | Create a user | Working (missing field gives 500) |
| PATCH/PUT | `/users/:id` | permission `manager`/`admin` | Update a user | Not usable yet |
| GET | `/users/:id` | role `employee` | Get a user | Not usable yet (500) |
| GET | `/users` | permission `manager`/`admin` | List users | Not usable yet |
| WS | `/cable` → `EventChannel` | logged in | Live events | Connects; no events sent yet |
