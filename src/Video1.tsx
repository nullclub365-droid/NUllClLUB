import React from 'react';
import {
  AbsoluteFill,
  AnimatedGradient,
  Img,
  interpolate,
  Sequence,
  Text,
  useCurrentFrame,
  useVideoConfig,
  spring,
  easeInOut,
} from 'remotion';

// Brand Colors
const BRAND_COLORS = {
  green: '#33CC33',
  blue: '#2E7CD4',
  orange: '#F5A962',
  red: '#FF3333',
  darkText: '#1A1A1A',
  lightBg: '#F9F9F9',
};

// Confusion Animation Component
const ConfusionScene: React.FC<{ duration: number }> = ({ duration }) => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  // Spinning clock animation
  const clockRotation = interpolate(frame, [0, duration], [0, 720], { extrapolateRight: 'clamp' });

  // Floating food icons
  const foodIcons = ['🍕', '🍗', '🌮', '🍜', '🥗', '🍔'];
  const foodPositions = foodIcons.map((_, idx) => ({
    y: Math.sin((frame + idx * 10) / 15) * 100,
    x: Math.cos((frame + idx * 10) / 15) * 150,
    opacity: 0.6 + 0.4 * Math.sin((frame + idx * 10) / 20),
  }));

  return (
    <AbsoluteFill style={{ backgroundColor: BRAND_COLORS.lightBg, justifyContent: 'center', alignItems: 'center' }}>
      {/* Spinning Clock */}
      <div
        style={{
          position: 'absolute',
          fontSize: '80px',
          transform: `rotate(${clockRotation}deg)`,
          transformOrigin: 'center',
        }}
      >
        🕐
      </div>

      {/* Floating Food Icons */}
      {foodIcons.map((icon, idx) => (
        <div
          key={idx}
          style={{
            position: 'absolute',
            fontSize: '60px',
            left: `${50 + foodPositions[idx].x / 5}%`,
            top: `${50 + foodPositions[idx].y / 5}%`,
            opacity: foodPositions[idx].opacity,
            transform: 'translate(-50%, -50%)',
          }}
        >
          {icon}
        </div>
      ))}

      {/* Confused Person Emoji */}
      <div style={{ position: 'absolute', top: '20%', left: '20%', fontSize: '120px' }}>😕</div>
    </AbsoluteFill>
  );
};

// SmartCart App Demo (Animated Phone Screen)
const AppDemoScene: React.FC<{ duration: number }> = ({ duration }) => {
  const frame = useCurrentFrame();
  const progress = frame / duration;

  // App screen slide in animation
  const screenY = interpolate(frame, [0, 15], [100, 0], { extrapolateRight: 'clamp' });

  // Checkmark appearance
  const checkmarkScale = spring({
    frame: Math.max(0, frame - 10),
    fps: 30,
    config: { damping: 8, mass: 1, stiffness: 100 },
  });

  // Glow effect
  const glowOpacity = interpolate(frame, [5, 10, 15], [0, 1, 1], { extrapolateRight: 'clamp' });

  return (
    <AbsoluteFill style={{ backgroundColor: BRAND_COLORS.lightBg, justifyContent: 'center', alignItems: 'center' }}>
      {/* Phone Frame */}
      <div
        style={{
          width: '300px',
          height: '600px',
          backgroundColor: '#000',
          borderRadius: '40px',
          border: '12px solid #000',
          boxShadow: '0 20px 60px rgba(0,0,0,0.3)',
          overflow: 'hidden',
          transform: `translateY(${screenY}px)`,
        }}
      >
        {/* App Screen */}
        <div
          style={{
            width: '100%',
            height: '100%',
            backgroundColor: BRAND_COLORS.lightBg,
            display: 'flex',
            flexDirection: 'column',
            justifyContent: 'center',
            alignItems: 'center',
            padding: '20px',
            boxSizing: 'border-box',
          }}
        >
          {/* Status Bar */}
          <div
            style={{
              position: 'absolute',
              top: 0,
              width: '100%',
              height: '40px',
              backgroundColor: BRAND_COLORS.green,
              display: 'flex',
              justifyContent: 'center',
              alignItems: 'center',
              color: 'white',
              fontSize: '14px',
              fontWeight: 'bold',
            }}
          >
            SmartCart
          </div>

          {/* Meal Plan Card Container */}
          <div
            style={{
              marginTop: '60px',
              display: 'flex',
              flexDirection: 'column',
              gap: '20px',
              width: '100%',
            }}
          >
            {/* Meal Cards */}
            {['Monday', 'Tuesday', 'Wednesday'].map((day, idx) => {
              const cardOpacity = interpolate(
                frame,
                [15 + idx * 8, 25 + idx * 8],
                [0, 1],
                { extrapolateRight: 'clamp' }
              );
              const cardY = interpolate(
                frame,
                [15 + idx * 8, 25 + idx * 8],
                [50, 0],
                { extrapolateRight: 'clamp' }
              );

              return (
                <div
                  key={idx}
                  style={{
                    backgroundColor: [BRAND_COLORS.blue, BRAND_COLORS.orange, BRAND_COLORS.green][idx],
                    borderRadius: '12px',
                    padding: '16px',
                    opacity: cardOpacity,
                    transform: `translateY(${cardY}px)`,
                    color: 'white',
                    fontWeight: 'bold',
                    fontSize: '16px',
                  }}
                >
                  <div>{day}</div>
                  <div style={{ fontSize: '12px', marginTop: '8px', opacity: 0.9 }}>
                    🍽️ Suggested meal plan
                  </div>
                </div>
              );
            })}
          </div>

          {/* Checkmark */}
          {frame > 10 && (
            <div
              style={{
                position: 'absolute',
                bottom: '80px',
                fontSize: '80px',
                transform: `scale(${checkmarkScale})`,
                transformOrigin: 'center',
              }}
            >
              ✅
            </div>
          )}
        </div>
      </div>

      {/* Glow Effect */}
      {frame > 5 && (
        <div
          style={{
            position: 'absolute',
            width: '330px',
            height: '630px',
            border: `2px solid ${BRAND_COLORS.green}`,
            borderRadius: '48px',
            opacity: glowOpacity,
            boxShadow: `0 0 30px ${BRAND_COLORS.green}`,
            pointerEvents: 'none',
          }}
        />
      )}
    </AbsoluteFill>
  );
};

// Text Reveal Component
const TextReveal: React.FC<{
  text: string;
  startFrame: number;
  duration: number;
  color: string;
  size: number;
  position?: 'top' | 'center' | 'bottom';
}> = ({ text, startFrame, duration, color, size, position = 'center' }) => {
  const frame = useCurrentFrame();
  const progress = interpolate(frame, [startFrame, startFrame + duration], [0, 1], {
    extrapolateRight: 'clamp',
  });

  const scaleSpring = spring({
    frame: Math.max(0, frame - startFrame),
    fps: 30,
    config: { damping: 8 },
  });

  const positionMap = {
    top: { top: '15%' },
    center: { top: '50%', transform: 'translateY(-50%)' },
    bottom: { bottom: '25%' },
  };

  return (
    <Sequence from={startFrame} durationInFrames={duration + 30}>
      <AbsoluteFill style={{ justifyContent: 'center', alignItems: 'center' }}>
        <div
          style={{
            position: 'absolute',
            ...positionMap[position],
            left: '50%',
            transform: `translateX(-50%) translateY(-50%) scale(${scaleSpring})`,
            opacity: progress,
            color,
            fontSize: `${size}px`,
            fontWeight: 'bold',
            textAlign: 'center',
            fontFamily: 'system-ui, -apple-system, sans-serif',
            maxWidth: '90%',
            whiteSpace: 'nowrap',
          }}
        >
          {text}
        </div>
      </AbsoluteFill>
    </Sequence>
  );
};

// CTA Button Component
const CTAButton: React.FC<{ startFrame: number; duration: number }> = ({ startFrame, duration }) => {
  const frame = useCurrentFrame();
  const progress = interpolate(frame, [startFrame, startFrame + duration], [0, 1], {
    extrapolateRight: 'clamp',
  });

  const scaleSpring = spring({
    frame: Math.max(0, frame - startFrame),
    fps: 30,
    config: { damping: 10 },
  });

  const pulse = 1 + Math.sin((frame - startFrame) / 8) * 0.08;

  return (
    <Sequence from={startFrame} durationInFrames={duration}>
      <AbsoluteFill style={{ justifyContent: 'flex-end', alignItems: 'flex-end' }}>
        <div
          style={{
            position: 'absolute',
            bottom: '40px',
            left: '50%',
            transform: `translateX(-50%) scale(${scaleSpring * pulse})`,
            opacity: progress,
            backgroundColor: BRAND_COLORS.green,
            color: 'white',
            padding: '16px 40px',
            borderRadius: '24px',
            fontSize: '16px',
            fontWeight: 'bold',
            boxShadow: `0 8px 24px rgba(51, 204, 51, 0.4)`,
            fontFamily: 'system-ui, -apple-system, sans-serif',
            whiteSpace: 'nowrap',
          }}
        >
          Download SmartCart
        </div>
      </AbsoluteFill>
    </Sequence>
  );
};

// Main Composition
export const MealPlanningChaosVideo: React.FC = () => {
  const { durationInFrames, fps } = useVideoConfig();

  return (
    <AbsoluteFill style={{ backgroundColor: BRAND_COLORS.lightBg }}>
      {/* Scene 1: Confusion (0-60 frames / 2 seconds @ 30fps) */}
      <Sequence from={0} durationInFrames={60}>
        <ConfusionScene duration={60} />
      </Sequence>

      {/* Text: "Spend 2 hours planning meals?" (30-90 frames) */}
      <TextReveal
        text="Spend 2 hours planning meals?"
        startFrame={30}
        duration={30}
        color={BRAND_COLORS.darkText}
        size={48}
        position="bottom"
      />

      {/* Scene 2: App Demo (90-180 frames / 3 seconds) */}
      <Sequence from={90} durationInFrames={180}>
        <AppDemoScene duration={180} />
      </Sequence>

      {/* Text: "SmartCart does it in 30 seconds" (180-270 frames) */}
      <TextReveal
        text="SmartCart does it in 30 seconds"
        startFrame={180}
        duration={30}
        color={BRAND_COLORS.green}
        size={44}
        position="bottom"
      />

      {/* CTA Button (390-450 frames) */}
      <CTAButton startFrame={390} duration={60} />
    </AbsoluteFill>
  );
};
