# Portability Rules (กฎการพกพาข้าม Account)

## 1. Zero Absolute Paths (ห้ามเขียน Path ตายตัว)
- ห้ามเขียน `C:\...` หรือ `/home/...` ในโค้ดหรือสคริปต์ใดๆ
- ใน Batch File: ใช้ `%~dp0` (Path ของไฟล์ Batch เอง)
- ใน Node.js: ใช้ `process.cwd()` หรือ `import.meta.dirname`
- ใน Deno: ใช้ `import.meta.dirname` หรือ `Deno.cwd()`

## 2. Featherweight Zip (ซิปต้องเบาที่สุด)
ไฟล์/โฟลเดอร์ที่ห้ามรวมใน Zip:
- `node_modules/`
- `tests/profiles/**/data/` (Browser cache)
- `.git/`
- `.env` (ข้อมูลลับ)
- `*.sqlite` (ฐานข้อมูลที่สร้างขึ้นระหว่าง dev)

## 3. Self-Healing on First Boot
เมื่อแตกไฟล์ในเครื่องใหม่:
1. รัน `doctor.bat` เพื่อตรวจเครื่องมือ
2. ถ้าขาด Deno → `winget install DenoLand.Deno`
3. ถ้าขาด Playwright Browsers → `npx playwright install`
4. `npm install` เพื่อสร้าง node_modules ใหม่

## 4. No Credentials in Repository
- ห้ามเก็บ API Key, SSH Key, Token ในโค้ด
- ใช้ `.env.example` เป็นแม่แบบ ให้ Account ใหม่สร้าง `.env` เอง
