# 🧠 NODE-POCKET: Sovereign Fullstack AI Agent

> **Architecture:** Sovereign Single-Project (1 Folder = 1 Complete Fullstack App)
> **Runtime:** Node.js (Web Application) + Deno (Cross-Browser Testing via Playwright)
> **Rule:** NO nested subprojects allowed. If you need another app, create a NEW root folder.

---

## First-Contact Protocol (สำหรับ AI ที่เปิดโฟลเดอร์นี้เป็นครั้งแรก)

เมื่อคุณ (AI Agent) เปิด Workspace นี้ ให้ปฏิบัติตามลำดับต่อไปนี้:

### Step 1: System Doctor (ตรวจสอบเครื่องมือในเครื่อง)
เรียกใช้ Skill `system-doctor` เพื่อตรวจสอบว่าเครื่องโฮสต์มีเครื่องมือพื้นฐานครบหรือไม่:
- **Node.js** >= 18 (สำหรับรันเว็บ)
- **Deno** >= 1.40 (สำหรับรันชุดเทสต์ Playwright)
- **Git** (สำหรับ Version Control)
- **Playwright Browsers** (Chromium, Firefox, WebKit)

### Step 2: รอรับคำสั่งจากผู้ใช้
เมื่อตรวจสอบเสร็จ ให้รายงานสถานะเครื่องมือ แล้วถามผู้ใช้ว่าต้องการสร้างเว็บอะไร

### Step 3: Scaffold & Build
เมื่อผู้ใช้สั่ง ให้สร้างโค้ดใน `src/` (Frontend + Backend + Database) โดยใช้โครงสร้าง Fullstack ที่รวมทุกอย่างไว้ในโปรเจกต์เดียว

---

## กฎเหล็กสถาปัตยกรรม (Architectural Laws)

1. **Sovereign Boundary:** โปรเจกต์นี้คือ 1 โปรเจกต์เดี่ยวที่เบ็ดเสร็จในตัวเอง ห้ามสร้างซับโปรเจกต์ซ้อนภายใต้โฟลเดอร์นี้เด็ดขาด
2. **Zero Absolute Paths:** ห้ามเขียน Path แบบตายตัว (เช่น `C:\Users\...`) ทุกสคริปต์ต้องใช้ Relative Path เท่านั้น
3. **Fullstack Unity:** Frontend, Backend, Database อยู่รวมกันใน `src/` ห้ามแยกเป็นโฟลเดอร์โปรเจกต์ย่อย
4. **External Services via API:** หากต้องการเชื่อมต่อ Backend ภายนอก ให้สื่อสารผ่าน HTTP API / IP Address ห้ามนำโค้ดมารวมในโฟลเดอร์เดียวกัน
5. **Isolated Testing:** ชุดทดสอบใน `tests/` รันด้วย Deno + Playwright แยกจาก Node.js ของเว็บอย่างสิ้นเชิง
6. **Replication over Nesting:** ต้องการเว็บใหม่? ให้ก๊อปปี้โฟลเดอร์ Master Seed ไปตั้งชื่อใหม่ ห้ามสร้างโปรเจกต์ซ้อนกัน
7. **Auto Git Snapshot:** เบื้องหลังมี Hook บันทึก Local Git Snapshot อัตโนมัติทุกครั้งที่ AI ปรับปรุงโค้ด ไม่รบกวนการ Push ขึ้น Git ภายนอกของผู้ใช้
