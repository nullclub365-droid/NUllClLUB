#!/usr/bin/env node

import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';
import dotenv from 'dotenv';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const configPath = path.join(__dirname, '.env');

console.log('🔍 SmartCart Image Agent - Configuration Validator\n');

if (!fs.existsSync(configPath)) {
  console.error('❌ .env file not found!');
  console.log('\n📝 To create it:');
  console.log('   cp .env.example .env');
  console.log('   # Then edit .env with your API keys\n');
  process.exit(1);
}

dotenv.config();

const required = [
  {
    key: 'GEMINI_API_KEY',
    description: 'Google Gemini API Key',
    format: 'Should start with AIzaSy',
  },
  {
    key: 'GITHUB_TOKEN',
    description: 'GitHub Personal Access Token',
    format: 'Should start with ghp_',
  },
  {
    key: 'GITHUB_OWNER',
    description: 'GitHub Username or Organization',
    format: 'Should be a valid GitHub username',
  },
  {
    key: 'GITHUB_REPO',
    description: 'GitHub Repository Name',
    format: 'Should be a valid repository name',
  },
];

const optional = [
  {
    key: 'IMAGE_OUTPUT_DIR',
    description: 'Output directory for images',
    default: './generated_images',
  },
  {
    key: 'COMMIT_MESSAGE_PREFIX',
    description: 'Commit message prefix',
    default: 'feat: Generated images from prompts',
  },
  {
    key: 'BRANCH_NAME',
    description: 'Target branch for commits',
    default: 'main',
  },
];

let missingRequired = [];
let invalidKeys = [];

console.log('📋 Checking Required Variables:\n');

for (const config of required) {
  const value = process.env[config.key];
  if (!value) {
    missingRequired.push(config.key);
    console.log(`❌ ${config.key}`);
    console.log(`   ${config.description}`);
    console.log(`   Expected format: ${config.format}\n`);
  } else if (value.includes('your_') || value.includes('xxx')) {
    invalidKeys.push(config.key);
    console.log(`⚠️  ${config.key}`);
    console.log(`   Value appears to be a placeholder. Please update it!\n`);
  } else {
    const masked = value.substring(0, 8) + '*'.repeat(Math.max(0, value.length - 8));
    console.log(`✅ ${config.key}`);
    console.log(`   Value: ${masked}\n`);
  }
}

console.log('📋 Checking Optional Variables:\n');

for (const config of optional) {
  const value = process.env[config.key] || config.default;
  console.log(`✅ ${config.key}`);
  console.log(`   Value: ${value}`);
  console.log(`   Default: ${config.default}\n`);
}

if (missingRequired.length > 0) {
  console.log('❌ Configuration Invalid!\n');
  console.log('Missing required variables:');
  missingRequired.forEach(key => {
    console.log(`  - ${key}`);
  });
  console.log('\n📝 Steps to fix:');
  console.log('1. Open .env file in your editor');
  console.log('2. Get API keys:');
  console.log('   - Gemini API: https://aistudio.google.com/');
  console.log('   - GitHub Token: https://github.com/settings/tokens');
  console.log('3. Fill in all required variables');
  console.log('4. Save and run this validator again\n');
  process.exit(1);
} else if (invalidKeys.length > 0) {
  console.log('⚠️  Configuration has placeholder values!\n');
  console.log('Placeholder variables found:');
  invalidKeys.forEach(key => {
    console.log(`  - ${key}`);
  });
  console.log('\nPlease update these variables with actual values.\n');
  process.exit(1);
} else {
  console.log('✅ Configuration is valid!\n');
  console.log('You can now run:');
  console.log('  npm start           # Run image generation');
  console.log('  npm run test        # Run tests\n');
  process.exit(0);
}
