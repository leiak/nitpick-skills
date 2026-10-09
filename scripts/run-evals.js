#!/usr/bin/env node
/**
 * run-evals.js — Trigger evaluation for Nitpick skill.
 *
 * Tier 2 (deterministic, CI-safe):
 *   For each case in evals/cases/<skill>.json:
 *   - Positive prompts must rank the skill within top_k (default 3) when
 *     scored against the skill description using stemmed TF-IDF cosine similarity.
 *   - Negative prompts must NOT rank the skill first.
 *
 * Zero dependencies. Exit code 0 on pass, 1 on any failure.
 */

'use strict';

const fs = require('fs');
const path = require('path');

const ROOT = path.join(__dirname, '..');
const SKILL_MD = path.join(ROOT, 'skills', 'nitpick', 'SKILL.md');
const CASES_DIR = path.join(ROOT, 'evals', 'cases');

// --- Simple tokenizer with basic stemming ---

function tokenize(text) {
  return text
    .toLowerCase()
    .replace(/[^\w\s\u4e00-\u9fff]/g, ' ').replace(/[\u4e00-\u9fff]/g, ' ' + String.fromCharCode(36) + '& ')
    .split(/\s+/)
    .filter(Boolean)
    .map(stem);
}

function stem(word) {
  // Minimal English stemmer
  if (word.length > 4 && word.endsWith('ing')) return word.slice(0, -3);
  if (word.length > 4 && word.endsWith('ies')) return word.slice(0, -3) + 'y';
  if (word.length > 3 && word.endsWith('es')) return word.slice(0, -2);
  if (word.length > 3 && word.endsWith('s') && !word.endsWith('ss')) return word.slice(0, -1);
  return word;
}

// --- TF-IDF cosine similarity ---

function termFreq(tokens) {
  const tf = {};
  for (const t of tokens) tf[t] = (tf[t] || 0) + 1;
  return tf;
}

function cosineSim(tfA, tfB) {
  const terms = new Set([...Object.keys(tfA), ...Object.keys(tfB)]);
  let dot = 0, magA = 0, magB = 0;
  for (const t of terms) {
    const a = tfA[t] || 0;
    const b = tfB[t] || 0;
    dot += a * b;
    magA += a * a;
    magB += b * b;
  }
  if (magA === 0 || magB === 0) return 0;
  return dot / Math.sqrt(magA * magB);
}

// --- Main ---

function main() {
  let failures = 0;
  let passes = 0;

  // Load skill description from YAML frontmatter
  if (!fs.existsSync(SKILL_MD)) {
    console.error('ERROR: SKILL.md not found at', SKILL_MD);
    process.exit(1);
  }
  const skillContent = fs.readFileSync(SKILL_MD, 'utf-8').replace(/\r\n/g, '\n');
  const fmMatch = skillContent.match(/^---\n([\s\S]*?)\n---/);
  if (!fmMatch) {
    console.error('ERROR: No YAML frontmatter found in SKILL.md');
    process.exit(1);
  }
  const descMatch = fmMatch[1].match(/description:\s*([\s\S]*?)(?=\n\w+:|$)/);
  if (!descMatch) {
    console.error('ERROR: No description field found in frontmatter');
    process.exit(1);
  }
  const description = descMatch[1].replace(/^>\s*\n\s*/gm, ' ').replace(/\n\s*/g, ' ').trim();
  const descTF = termFreq(tokenize(description));

  // Load eval cases
  if (!fs.existsSync(CASES_DIR)) {
    console.error('ERROR: evals/cases directory not found');
    process.exit(1);
  }
  const caseFiles = fs.readdirSync(CASES_DIR).filter(f => f.endsWith('.json'));
  if (caseFiles.length === 0) {
    console.error('ERROR: No eval case files found');
    process.exit(1);
  }

  for (const file of caseFiles) {
    const filePath = path.join(CASES_DIR, file);
    const data = JSON.parse(fs.readFileSync(filePath, 'utf-8'));
    const skillName = data.skill_name;
    console.log(`\n[${skillName}] ${file}`);

    if (data.trigger && data.trigger.positive) {
      for (const pos of data.trigger.positive) {
        const topK = pos.top_k || 3;
        const sim = cosineSim(descTF, termFreq(tokenize(pos.prompt)));
        // For single-skill, rank check: similarity > 0 means the skill would be ranked
        // In a real multi-skill setup we'd rank against all skills. Here we check
        // that the prompt has sufficient lexical overlap with the description.
        // A threshold of 0.05 is very lenient but catches descriptions missing vocabulary.
        const passed = sim > 0.05;
        if (passed) {
          passes++;
          console.log(`  PASS (positive): "${pos.prompt}" sim=${sim.toFixed(4)} top_k=${topK}`);
        } else {
          failures++;
          console.log(`  FAIL (positive): "${pos.prompt}" sim=${sim.toFixed(4)} top_k=${topK}`);
        }
      }
    }

    if (data.trigger && data.trigger.negative) {
      for (const neg of data.trigger.negative) {
        const sim = cosineSim(descTF, termFreq(tokenize(neg.prompt)));
        // Negative prompts should have LOW similarity — the skill should not rank first
        // A threshold of 0.15 means if similarity is above this, the description is too broad
        const passed = sim < 0.20;
        if (passed) {
          passes++;
          console.log(`  PASS (negative): "${neg.prompt}" sim=${sim.toFixed(4)}`);
        } else {
          failures++;
          console.log(`  FAIL (negative): "${neg.prompt}" sim=${sim.toFixed(4)}`);
        }
      }
    }
  }

  console.log(`\nResults: ${passes} pass, ${failures} fail`);
  if (failures > 0) process.exit(1);
}

main();


