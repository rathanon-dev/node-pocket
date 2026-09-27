/**
 * 🎭 Node-Pocket Cross-Browser Test Runner
 * Powered by Deno + Playwright (Zero node_modules)
 *
 * Usage:
 *   deno test --allow-all                    → Default (Chromium)
 *   deno test --allow-all -- --browser=all   → All 3 browsers
 */

import { chromium, firefox, webkit, type BrowserType } from "npm:playwright@latest";

// Browser engine registry
const ENGINES: Record<string, BrowserType> = {
  chromium,
  firefox,
  webkit,
};

/**
 * Get selected browser engine(s) from CLI args
 */
export function getSelectedBrowsers(): Array<{ name: string; engine: BrowserType }> {
  const args = Deno.args;
  const browserArg = args.find((a) => a.startsWith("--browser="));
  const selected = browserArg?.split("=")[1] ?? "chromium";

  if (selected === "all") {
    return Object.entries(ENGINES).map(([name, engine]) => ({ name, engine }));
  }

  const engine = ENGINES[selected];
  if (!engine) {
    console.error(`❌ Unknown browser: ${selected}. Available: chromium, firefox, webkit, all`);
    Deno.exit(1);
  }

  return [{ name: selected, engine }];
}

/**
 * Read profile config for a given user
 */
export async function readProfile(username: string): Promise<{
  role: string;
  ip: string;
  targetUrl: string;
  viewport: { width: number; height: number };
}> {
  const profilePath = `${import.meta.dirname}/../profiles/${username}/profile.json`;
  const text = await Deno.readTextFile(profilePath);
  return JSON.parse(text);
}

/**
 * Resolve profile paths for a user + browser engine
 */
export function getProfilePaths(username: string, engineName: string) {
  const base = `${import.meta.dirname}/../profiles/${username}`;
  return {
    profileJson: `${base}/profile.json`,
    uploads: `${base}/uploads`,
    downloads: `${base}/${engineName}/downloads`,
    sessionJson: `${base}/${engineName}/session.json`,
    browserData: `${base}/${engineName}/data`,
  };
}
