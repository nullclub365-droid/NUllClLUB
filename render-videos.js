#!/usr/bin/env node

/**
 * Simple Remotion video renderer for SmartCart marketing videos
 * Usage: node render-videos.js
 */

const { execSync } = require('child_process');
const path = require('path');
const fs = require('fs');

const VIDEOS = [
  {
    name: 'Meal Planning Chaos',
    file: 'remotion-prompt-1-meal-planning-chaos.tsx',
    compositionId: 'MealPlanningChaos',
    output: 'smartcart-prompt-1-meal-planning-chaos.mp4',
  },
  {
    name: 'Meal Plan Magic',
    file: 'remotion-prompt-6-meal-plan-magic.tsx',
    compositionId: 'MealPlanMagicVideo',
    output: 'smartcart-prompt-6-meal-plan-magic.mp4',
  },
];

const outputDir = path.join(__dirname, 'videos');

// Create output directory if it doesn't exist
if (!fs.existsSync(outputDir)) {
  fs.mkdirSync(outputDir, { recursive: true });
  console.log(`📁 Created output directory: ${outputDir}`);
}

console.log('\n🎬 SmartCart Video Renderer\n');
console.log(`Rendering ${VIDEOS.length} videos...\n`);

VIDEOS.forEach((video, idx) => {
  const videoPath = path.join(__dirname, video.file);
  const outputPath = path.join(outputDir, video.output);

  // Check if input file exists
  if (!fs.existsSync(videoPath)) {
    console.error(`❌ Error: File not found - ${videoPath}`);
    return;
  }

  console.log(`[${idx + 1}/${VIDEOS.length}] 📹 Rendering: ${video.name}`);
  console.log(`   Input:  ${video.file}`);
  console.log(`   Output: ${video.output}`);

  try {
    // Run remotion render command
    const cmd = `npx remotion render --concurrency=4 ${videoPath} ${video.compositionId} "${outputPath}"`;
    console.log(`   Command: ${cmd}\n`);

    const output = execSync(cmd, {
      stdio: 'inherit',
      cwd: __dirname,
    });

    console.log(`✅ Successfully rendered: ${video.output}\n`);
  } catch (error) {
    console.error(`❌ Error rendering ${video.name}:`, error.message);
    console.log('');
  }
});

console.log('\n✨ Rendering complete!');
console.log(`📂 All videos saved to: ${outputDir}\n`);
console.log('Videos ready to upload to:');
console.log('  • YouTube Shorts');
console.log('  • Instagram Reels');
console.log('  • TikTok');
console.log('  • X (Twitter)\n');
