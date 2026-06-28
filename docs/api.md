# DeepSafe 验证 API (v1)

深度云网络验证（DeepSafe）客户端 SDK 使用的 REST 接口说明。

Base path: `/api/v1/verify`

All endpoints accept and return `application/json` unless noted. Client SDK uses WinHTTP POST to these paths.

## Authentication

| Header | Description |
|--------|-------------|
| `Content-Type` | `application/json` |

Application credentials (`app_key`, optional `app_secret` or HMAC) are validated server-side. Exact signing scheme depends on deployment (SaaS vs self-hosted).

---

## POST `/api/v1/verify/login`

Card-key login and machine binding.

**Request body**

```json
{
  "app_key": "string",
  "card_key": "string",
  "machine_code": "string"
}
```

**Response (200)**

```json
{
  "code": 0,
  "message": "ok",
  "data": {
    "token": "string",
    "user_id": "string",
    "expires_at": 1710000000
  }
}
```

**Errors**

| code | Meaning |
|------|---------|
| 401 | Invalid card or app |
| 403 | Machine mismatch / banned |
| 429 | Rate limited |

---

## POST `/api/v1/verify/heartbeat`

Keep session alive; extend `expires_at` if policy allows.

**Request body**

```json
{
  "token": "string"
}
```

**Response (200)**

```json
{
  "code": 0,
  "data": {
    "expires_at": 1710003600
  }
}
```

---

## POST `/api/v1/verify/logout`

Invalidate session token.

**Request body**

```json
{
  "token": "string"
}
```

**Response (200)**

```json
{
  "code": 0,
  "message": "ok"
}
```

---

## Machine code

Clients call `Verify_GetMachineCode` to obtain a stable fingerprint sent as `machine_code` on login. Server may bind the card to the first seen machine or allow N devices per product policy.

---

## Self-hosted licenses

For offline or hybrid self-hosted mode, issue `.lic` files signed with Ed25519 via `tools/license-gen`. Server or launcher verifies signature and `expires_at` before calling online APIs (implementation-specific).

---

## SDK mapping

| C API | HTTP |
|-------|------|
| `Verify_Init` | Configures base URL and timeouts |
| `Verify_Login` | `POST /api/v1/verify/login` |
| `Verify_Heartbeat` | `POST /api/v1/verify/heartbeat` |
| `Verify_Logout` | `POST /api/v1/verify/logout` |
| `Verify_GetMachineCode` | Local only |
