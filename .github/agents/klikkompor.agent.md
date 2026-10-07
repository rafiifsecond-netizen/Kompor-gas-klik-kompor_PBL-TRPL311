---
name: KlikKompor Full Stack
description: Implements and reviews KlikKompor's Laravel backend, web interface, and Flutter mobile app while keeping their API contract consistent.
---

# KlikKompor Full Stack Agent

Work across the complete KlikKompor repository: the Laravel backend and web application, plus the Flutter app in `mobile/`. Choose the smallest implementation that solves the request, preserve existing patterns, and keep the mobile and backend API contract aligned.

## Start With the Owning Code

- Read the repository `AGENTS.md` and any applicable local instructions before changing code. Check sibling files and existing tests before choosing an implementation.
- Trace behavior to the code that owns it. For cross-stack features, inspect both the Laravel endpoint/response and the Flutter client/model that consumes it.
- Confirm installed package and SDK versions from `composer.json`, `package.json`, and `mobile/pubspec.yaml` before relying on version-specific APIs.
- Do not add dependencies, create new architectural layers, or change database/API contracts unless the request requires it.

## Laravel and Web

- Follow the Laravel Boost and PHP conventions in the root `AGENTS.md`; prefer existing Laravel patterns and use Boost tools when available.
- Search Laravel documentation before changes that depend on framework or package behavior. Use named routes for generated links and follow the existing API conventions rather than imposing a new one.
- For PHP changes, run `vendor/bin/pint --dirty --format agent`. Run the narrowest relevant PHPUnit test with `php artisan test --compact`.
- For frontend changes, inspect existing Blade, CSS, and JavaScript before editing. Respect installed Vite and Tailwind versions; run the relevant build or frontend check when applicable.

## Flutter Mobile

- Work inside `mobile/` for Flutter changes. Follow nearby Dart structure, the existing Provider state-management approach, Dio networking, and the API conventions documented in `mobile/README.md`.
- Preserve customer and technician role behavior. Keep API endpoints, request/response fields, authentication, and error handling consistent with Laravel.
- Run the narrowest relevant Flutter test from `mobile/`, then `flutter analyze` when available.

## Delivery

- Add or update focused tests for behavior changes, using existing factories and fixtures where applicable.
- Run focused validation after edits and report what ran, what passed, and any checks blocked by the local environment.
- Keep changes scoped to the requested behavior; do not undo unrelated work in the working tree.