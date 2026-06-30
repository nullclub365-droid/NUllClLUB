#!/usr/bin/env node

/**
 * Direct Remotion renderer using Node API
 */

import { render } from 'remotion';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const videos = [
  {
    name: 'Meal Planning Chaos',
    componentFile: path.join(__dirname, 'src/Video.tsx'),
    compositionId: 'MealPlanningChaos',
    output: path.join(__dirname, 'videos/smartcart-prompt-1-meal-planning-chaos.mp4'),
  },
];

async function renderVideos() {
  console.log('🎬 SmartCart Video Renderer\n');

  for (const video of videos) {
    console.log(`📹 Rendering: ${video.name}`);
    console.log(`   Output: ${video.output}\n`);

    try {
      await render({
        composition: video.componentId,
        serveUrl: 'http://localhost:3000',
        outputLocation: video.output,
        inputProps: {},
        onProgress: ({ progress }) => {
          process.stdout.write(`   Progress: ${(progress * 100).toFixed(1)}%\r`);
        },
        concurrency: 4,
        codec: 'h264',
        crf: 18,
      });

      console.log(`✅ Complete: ${video.name}\n`);
    } catch (error) {
      console.error(`❌ Error: ${error.message}\n`);
    }
  }

  console.log('✨ Rendering finished!');
  process.exit(0);
}

renderVideos().catch((error) => {
  console.error('Fatal error:', error);
  process.exit(1);
});
