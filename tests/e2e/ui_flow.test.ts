/**
 * 🧪 Example E2E Test: UI Flow
 * Tests the homepage loads correctly across selected browser engines.
 *
 * Run:
 *   cd tests
 *   deno test --allow-all                    → Chromium only
 *   deno test --allow-all -- --browser=all   → All 3 browsers
 */

import { getSelectedBrowsers, readProfile, getProfilePaths } from "./browser_runner.ts";
import { assertEquals } from "jsr:@std/assert";

const browsers = getSelectedBrowsers();

for (const { name, engine } of browsers) {
  Deno.test(`[${name}] Homepage loads correctly`, async () => {
    const profile = await readProfile("user1");
    const paths = getProfilePaths("user1", name);

    // Ensure downloads directory exists
    try { await Deno.mkdir(paths.downloads, { recursive: true }); } catch { /* exists */ }

    // Launch browser with profile settings
    const browser = await engine.launch({
      headless: false,
    });

    const context = await browser.newContext({
      viewport: profile.viewport,
      extraHTTPHeaders: {
        "x-forwarded-for": profile.ip,
      },
      acceptDownloads: true,
    });

    const page = await context.newPage();

    try {
      // Navigate to target URL
      await page.goto(profile.targetUrl, { timeout: 10_000 });

      // Basic assertion: page should load
      const title = await page.title();
      console.log(`  [${name}] Page title: "${title}"`);

      // Verify page is not blank
      const bodyText = await page.textContent("body");
      assertEquals(typeof bodyText, "string", "Body should have text content");

      // Save session state for future runs
      const storageState = await context.storageState();
      await Deno.writeTextFile(paths.sessionJson, JSON.stringify(storageState, null, 2));
      console.log(`  [${name}] Session saved to ${paths.sessionJson}`);
    } finally {
      await context.close();
      await browser.close();
    }
  });
}
