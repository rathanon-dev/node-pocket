---
name: fullstack-scaffolder
description: >-
  Scaffold a complete Fullstack web application inside src/ based on user's prompt.
  Creates Frontend (UI), Backend (API), Database (SQLite), and wires them together.
---

# Fullstack Scaffolder Skill

## When to Activate
- When user says "สร้างเว็บ...", "build a website...", "create an app..."
- When the `src/` directory is empty or contains only placeholder files

## Scaffolding Blueprint

### Default Stack (adjustable based on user request)
- **Frontend:** Next.js (App Router) + Tailwind CSS
- **Backend:** Next.js API Routes (or Express/Hono if requested)
- **Database:** SQLite via better-sqlite3 or Drizzle ORM
- **Testing:** Deno + Playwright (already in `tests/`)

### Directory Structure to Generate
```
src/
├── app/
│   ├── layout.tsx          (Root Layout with Tailwind)
│   ├── page.tsx            (Home Page)
│   └── globals.css         (Tailwind Base)
├── api/
│   └── health/route.ts     (Health Check Endpoint)
├── db/
│   ├── schema.ts           (Database Schema)
│   ├── migrate.ts          (Migration Runner)
│   └── seed.ts             (Sample Data Seeder)
└── lib/
    ├── constants.ts        (App Constants)
    └── utils.ts            (Shared Utilities)
```

### Post-Scaffold Actions
1. Run `npm install` to install dependencies
2. Initialize SQLite database: `npx tsx src/db/migrate.ts`
3. Seed sample data: `npx tsx src/db/seed.ts`
4. Start dev server: `npm run dev`
5. Report URL to user: `http://localhost:3000`

## Important Rules
- Always use **relative imports** (never absolute paths)
- Always create `.env.example` with required environment variables
- Always update `package.json` with correct scripts
