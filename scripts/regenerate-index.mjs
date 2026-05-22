#!/usr/bin/env node
//
// Walk every SKILL.md under `extensions/` and `standalone/`, parse
// frontmatter, hash every file under each skill's directory, and emit
// `index.json` at the repo root.
//
// Run locally:
//   node scripts/regenerate-index.mjs
//
// CI invokes the same path via `.github/workflows/regenerate-index.yml`.

import { promises as fs } from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';

const ROOT = path.resolve(path.dirname(new URL(import.meta.url).pathname), '..');
const ROOTS = ['extensions', 'standalone'];

/**
 * Walk a directory recursively, yielding (relativePath, absolutePath)
 * for every file.
 */
async function* walkFiles(dir, baseDir = dir) {
  const entries = await fs.readdir(dir, { withFileTypes: true });
  for (const ent of entries) {
    const full = path.join(dir, ent.name);
    if (ent.isDirectory()) {
      yield* walkFiles(full, baseDir);
    } else if (ent.isFile()) {
      yield { rel: path.relative(baseDir, full), abs: full };
    }
  }
}

/**
 * Parse YAML frontmatter from a markdown file. Minimal implementation —
 * supports the subset we use (scalars + flow-style and block-style
 * arrays of strings). Avoid a runtime YAML dep so the script runs on
 * any Node 20 install without `npm install`.
 */
function parseFrontmatter(raw) {
  if (!raw.startsWith('---\n')) return null;
  const end = raw.indexOf('\n---\n', 4);
  if (end < 0) return null;
  const block = raw.slice(4, end);
  const out = {};
  let key = null;
  for (const rawLine of block.split('\n')) {
    if (!rawLine.trim()) continue;
    // List item under the current key.
    if (rawLine.startsWith('  - ') && key) {
      out[key] = out[key] || [];
      out[key].push(rawLine.slice(4).trim());
      continue;
    }
    const m = rawLine.match(/^([a-zA-Z_][a-zA-Z0-9_]*):\s*(.*)$/);
    if (!m) continue;
    const [, k, rest] = m;
    key = k;
    if (!rest) {
      out[k] = []; // block-list follows
    } else if (rest.startsWith('[') && rest.endsWith(']')) {
      // Flow-style list: [a, b, c]
      const inner = rest.slice(1, -1).trim();
      out[k] = inner ? inner.split(',').map((s) => s.trim()) : [];
    } else if (rest.startsWith('"') && rest.endsWith('"')) {
      out[k] = rest.slice(1, -1);
    } else if (rest === 'true' || rest === 'false') {
      out[k] = rest === 'true';
    } else {
      out[k] = rest;
    }
  }
  return out;
}

function sha256(buf) {
  return crypto.createHash('sha256').update(buf).digest('hex');
}

async function buildEntry(skillDir, repoRoot) {
  const skillMdPath = path.join(skillDir, 'SKILL.md');
  let raw;
  try {
    raw = await fs.readFile(skillMdPath, 'utf8');
  } catch {
    return null; // dir without SKILL.md isn't a skill
  }
  const fm = parseFrontmatter(raw);
  if (!fm || !fm.name) {
    console.warn(`skipping ${skillMdPath}: missing frontmatter or name`);
    return null;
  }

  const files = [];
  const combined = crypto.createHash('sha256');
  for await (const file of walkFiles(skillDir)) {
    const buf = await fs.readFile(file.abs);
    const fileSha = sha256(buf);
    files.push({ path: file.rel, sha256: fileSha, size: buf.byteLength });
    combined.update(fileSha);
  }
  files.sort((a, b) => a.path.localeCompare(b.path));

  return {
    name: fm.name,
    path: path.relative(repoRoot, skillDir),
    description: fm.description || '',
    extensions: fm.extensions || [],
    requires: fm.requires || [],
    tools: fm.tools || [],
    tags: fm.tags || [],
    min_goose_version: fm.min_goose_version || null,
    isolated: !!fm.isolated,
    files,
    files_sha256: combined.digest('hex'),
  };
}

async function findSkillDirs(root) {
  const out = [];
  const stack = [root];
  while (stack.length) {
    const dir = stack.pop();
    let entries;
    try {
      entries = await fs.readdir(dir, { withFileTypes: true });
    } catch {
      continue;
    }
    // Heuristic: any directory containing a SKILL.md is a skill dir.
    const hasSkill = entries.some(
      (e) => e.isFile() && e.name === 'SKILL.md',
    );
    if (hasSkill) {
      out.push(dir);
    }
    for (const e of entries) {
      if (e.isDirectory()) {
        stack.push(path.join(dir, e.name));
      }
    }
  }
  return out;
}

async function main() {
  const skills = [];
  for (const r of ROOTS) {
    const abs = path.join(ROOT, r);
    try {
      await fs.stat(abs);
    } catch {
      continue;
    }
    const skillDirs = await findSkillDirs(abs);
    for (const d of skillDirs) {
      const entry = await buildEntry(d, ROOT);
      if (entry) skills.push(entry);
    }
  }
  skills.sort((a, b) => a.name.localeCompare(b.name));

  const index = {
    schema: 'https://goose-skills.spacia.ai/schemas/index/v1.json',
    version: 1,
    generated_at: new Date().toISOString(),
    registry_url: 'https://github.com/spacia-ai/goose-skills',
    skills,
  };

  await fs.writeFile(
    path.join(ROOT, 'index.json'),
    JSON.stringify(index, null, 2) + '\n',
    'utf8',
  );
  console.log(`wrote ${skills.length} skills to index.json`);
}

await main();
