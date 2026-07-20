#!/usr/bin/env node
/**
 * Salva a Cursor API key no Pi para pi-cursor-sdk (Composer 2.5).
 * A key vem de: https://cursor.com/dashboard → Integrations → API Keys
 */
import { chmodSync, mkdirSync, readFileSync, writeFileSync } from "node:fs";
import { homedir } from "node:os";
import { dirname, join } from "node:path";
import { createInterface } from "node:readline/promises";
import { stdin as input, stdout as output } from "node:process";

const agentDir = process.env.PI_CODING_AGENT_DIR ?? join(homedir(), ".pi", "agent");
const authPath = join(agentDir, "auth.json");
const settingsPath = join(agentDir, "settings.json");

function readJson(path, fallback) {
  try {
    return JSON.parse(readFileSync(path, "utf8"));
  } catch {
    return fallback;
  }
}

function writeAuth(apiKey) {
  mkdirSync(dirname(authPath), { recursive: true, mode: 0o700 });
  const auth = readJson(authPath, {});
  delete auth.cursor;
  auth.cursor = { type: "api_key", key: apiKey.trim() };
  writeFileSync(authPath, `${JSON.stringify(auth, null, 2)}\n`, { mode: 0o600 });
  chmodSync(authPath, 0o600);
}

function syncCursorApiKeyEnv(apiKey) {
  const envPath = join(agentDir, ".env");
  const lines = [];
  let replaced = false;
  try {
    for (const line of readFileSync(envPath, "utf8").split("\n")) {
      if (line.startsWith("CURSOR_API_KEY=")) {
        lines.push(`CURSOR_API_KEY=${apiKey.trim()}`);
        replaced = true;
      } else if (line.length > 0 || lines.length > 0) {
        lines.push(line);
      }
    }
  } catch {
    // no .env yet
  }
  if (!replaced) {
    if (lines.length > 0 && lines[lines.length - 1] !== "") lines.push("");
    lines.push(`CURSOR_API_KEY=${apiKey.trim()}`);
  }
  writeFileSync(envPath, `${lines.join("\n").replace(/\n*$/, "\n")}`, { mode: 0o600 });
}

function setComposerDefaults() {
  const settings = readJson(settingsPath, {});
  settings.defaultProvider = "cursor";
  settings.defaultModel = "composer-2.5";
  settings.enabledModels = [
    "composer-2.5",
    "deepseek-v4-flash-free",
    "mimo-v2.5-free",
  ];
  const packages = new Set(settings.packages ?? []);
  packages.add("npm:@ff-labs/pi-fff");
  packages.add("npm:pi-cursor-sdk");
  packages.add("npm:pine-of-glass");
  settings.packages = [...packages];
  writeFileSync(settingsPath, `${JSON.stringify(settings, null, 2)}\n`);
}

function looksLikeApiKey(value) {
  const key = value.trim();
  if (!key || key.length < 20) return false;
  if (/^Name\tToken/i.test(key) || key.includes("\t")) return false;
  if (/^cursor-agent-worker/i.test(key)) return false;
  return true;
}

async function main() {
  const fromEnv = process.env.CURSOR_API_KEY?.trim();
  let apiKey = fromEnv;

  if (!apiKey) {
    console.log("==> Cursor API key para Pi (Composer 2.5)");
    console.log("    1. Abra https://cursor.com/dashboard");
    console.log("    2. Vá em Integrations → API Keys → Create key");
    console.log("    3. Copie só o TOKEN (começa com crsr_...)");
    console.log("    Não cole o cabeçalho da tabela nem nomes de worker.\n");
    const rl = createInterface({ input, output });
    apiKey = (await rl.question("Cole o token crsr_...: ")).trim();
    rl.close();
  }

  if (!looksLikeApiKey(apiKey)) {
    console.error("\nErro: isso não parece uma API key válida.");
    console.error("Use o token crsr_... da coluna Token em cursor.com/dashboard → Integrations.");
    process.exit(1);
  }

  if (!apiKey.startsWith("crsr_")) {
    console.warn("Aviso: keys do Cursor SDK costumam começar com crsr_. Se falhar, gere outra no dashboard.");
  }

  writeAuth(apiKey);
  syncCursorApiKeyEnv(apiKey);
  setComposerDefaults();

  console.log("\n==> Salvo em ~/.pi/agent/auth.json");
  console.log("    CURSOR_API_KEY espelhada em ~/.pi/agent/.env");
  console.log("    Modelo padrão: composer-2.5");
  console.log("    Só Composer 2.5 visível no /model");
  console.log("\n    Abra o pi e rode /cursor-refresh-models se a lista estiver vazia.");
}

main().catch((err) => {
  console.error(err instanceof Error ? err.message : err);
  process.exit(1);
});
