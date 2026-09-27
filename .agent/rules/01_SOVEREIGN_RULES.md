# Sovereign Architecture Rules

## 1. Single-Project Boundary (กฎอาณาจักรเดี่ยว)
- โฟลเดอร์นี้คือ 1 โปรเจกต์ Fullstack ที่เบ็ดเสร็จในตัวเอง
- **ห้ามสร้าง Sub-Project หรือ Nested Application** ภายใต้โฟลเดอร์นี้เด็ดขาด
- Frontend, Backend, Database ต้องรวมอยู่ใน `src/` ภายใต้โปรเจกต์เดียวกัน

## 2. External Service Communication
- หากต้องการเชื่อมต่อ Backend หรือ Microservice ที่อยู่ภายนอก ให้สื่อสารผ่าน HTTP API / WebSocket / IP Address
- ห้ามนำโค้ดของระบบภายนอกมาวางรวมในโฟลเดอร์นี้

## 3. Replication over Nesting (แตกหน่อ ไม่ซ้อน)
- ต้องการเว็บใหม่ → ก๊อปปี้โฟลเดอร์ Master Seed → ตั้งชื่อใหม่ → ปรับแต่ง `.agent/` ให้เหมาะกับโปรเจกต์ใหม่
- ห้ามสร้างโปรเจกต์ซ้อนภายในโปรเจกต์ที่มีอยู่แล้ว

## 4. Fullstack Unity (ความเป็นเอกภาพ)
- `src/app/` → Frontend UI (Pages, Components, Layouts)
- `src/api/` → Backend API Routes / Controllers
- `src/db/` → Database Schema, Migrations, Seeds
- `src/lib/` → Shared Utilities, Constants, Types
- `package.json` → มีเพียง 1 ไฟล์เท่านั้นสำหรับทั้งโปรเจกต์

## 5. Port Management
- กำหนด Port ใน `.env` → `PORT=3000`
- ห้ามใช้ Port ซ้ำกับเว็บอื่นที่อาจรันอยู่พร้อมกัน
