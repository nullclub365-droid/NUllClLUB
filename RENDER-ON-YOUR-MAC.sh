#!/bin/bash

# SmartCart Video Renderer - Run on your Mac
# This script sets up and renders both videos

set -e

PROJECT_DIR="/Users/lazaretchaava/Desktop/SmartCart"
WORK_DIR="$PROJECT_DIR/smartcart-remotion"

echo "🎬 SmartCart Video Rendering Setup"
echo "===================================="
echo ""

# Create working directory
mkdir -p "$WORK_DIR"
cd "$WORK_DIR"

echo "📦 Step 1: Installing dependencies..."
npm init -y > /dev/null 2>&1
npm install remotion react react-dom --legacy-peer-deps

echo "✅ Dependencies installed"
echo ""

# Create tsconfig
cat > tsconfig.json << 'TSCONFIG'
{
  "compilerOptions": {
    "jsx": "react-jsx",
    "target": "ES2020",
    "module": "ES2020",
    "lib": ["ES2020", "DOM"],
    "moduleResolution": "node",
    "strict": false,
    "esModuleInterop": true,
    "skipLibCheck": true
  }
}
TSCONFIG

# Create remotion.config.ts
cat > remotion.config.ts << 'CONFIG'
import { Config } from 'remotion';

Config.setRoot('./src');
Config.setEntryPoint('./Root.tsx');
CONFIG

# Create directories
mkdir -p src videos

# Copy components
cp "$PROJECT_DIR/remotion-prompt-1-meal-planning-chaos.tsx" src/Video1.tsx
cp "$PROJECT_DIR/remotion-prompt-6-meal-plan-magic.tsx" src/Video2.tsx

# Create Root.tsx
cat > src/Root.tsx << 'ROOT'
import { Composition } from 'remotion';
import { MealPlanningChaosVideo } from './Video1';
import { MealPlanMagicVideo } from './Video2';

export const RemotionRoot: React.FC = () => {
  return (
    <>
      <Composition
        id="prompt1"
        component={MealPlanningChaosVideo}
        durationInFrames={450}
        fps={30}
        width={1080}
        height={1920}
      />
      <Composition
        id="prompt6"
        component={MealPlanMagicVideo}
        durationInFrames={450}
        fps={30}
        width={1080}
        height={1920}
      />
    </>
  );
};
ROOT

echo "📂 Step 2: Project structure created"
echo "   Location: $WORK_DIR"
echo ""

echo "🎬 Step 3: Rendering videos..."
echo ""

# Render Prompt 1
echo "   Rendering: Meal Planning Chaos..."
npx remotion render \
  --concurrency=4 \
  --codec=h264 \
  --quality=80 \
  src/Video1.tsx prompt1 \
  videos/smartcart-prompt-1-meal-planning-chaos.mp4

echo "   ✅ Prompt 1 complete"
echo ""

# Render Prompt 6
echo "   Rendering: Meal Plan Magic..."
npx remotion render \
  --concurrency=4 \
  --codec=h264 \
  --quality=80 \
  src/Video2.tsx prompt6 \
  videos/smartcart-prompt-6-meal-plan-magic.mp4

echo "   ✅ Prompt 6 complete"
echo ""

echo "✨ Success!"
echo ""
echo "Your videos are ready:"
echo "  📹 $WORK_DIR/videos/smartcart-prompt-1-meal-planning-chaos.mp4"
echo "  📹 $WORK_DIR/videos/smartcart-prompt-6-meal-plan-magic.mp4"
echo ""
echo "Next: Upload to TikTok, Instagram Reels, YouTube Shorts, or X!"
echo ""
