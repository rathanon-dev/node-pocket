# Cross-Browser Testing Rules

## 1. Test Engine Separation (แยกเอนจินเทสต์ออกจากเว็บ)
- เว็บรันด้วย **Node.js** (Dev Server อิสระ)
- ชุดทดสอบรันด้วย **Deno + Playwright** (External Test Harness)
- ห้ามติดตั้ง Playwright ใน `package.json` ของเว็บ เพื่อป้องกัน node_modules บวม

## 2. Browser Engine Support
ระบบรองรับ 3 Browser Engine:
- **Chromium** (Google Chrome / Microsoft Edge)
- **Firefox** (Mozilla Gecko)
- **WebKit** (Apple Safari)

## 3. Profile Isolation (แยกโปรไฟล์ตาม User + Engine)
โครงสร้างโปรไฟล์:
```
tests/profiles/<username>/<engine>/
├── downloads/      (ไฟล์ที่ดาวน์โหลดลงมา)
├── session.json    (Playwright StorageState)
└── data/           (Browser cache - ใส่ .gitignore)
```

## 4. Interactive Browser Selection
เมื่อรันเทสต์ ให้แสดงเมนูเลือก:
1. Chromium
2. Firefox
3. WebKit (Safari)
4. All 3 in Parallel (Matrix Test)

## 5. Profile Data Ownership
- `profile.json` → กำหนด IP จำลอง, Role, Viewport (แชร์ทุก Engine)
- `uploads/` → ไฟล์ที่เตรียมไว้ให้ User ใช้อัปโหลด (แชร์ทุก Engine)
- `<engine>/downloads/` → ไฟล์ดาวน์โหลดแยกตาม Engine
- `<engine>/session.json` → คุกกี้เซสชันแยกตาม Engine
- `<engine>/data/` → แคชดิบ แยกตาม Engine (ใส่ .gitignore)
