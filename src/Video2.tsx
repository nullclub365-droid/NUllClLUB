import React from 'react';
import {
  AbsoluteFill,
  Sequence,
  Text,
  useCurrentFrame,
  useVideoConfig,
  spring,
  interpolate,
  Easing,
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

// Title Card Component
const TitleCard: React.FC<{ duration: number }> = ({ duration }) => {
  const frame = useCurrentFrame();

  // Scale in animation
  const scaleIn = spring({
    frame,
    fps: 30,
    config: { damping: 10, mass: 1, stiffness: 80 },
  });

  // Opacity fade in
  const opacity = interpolate(frame, [0, 10], [0, 1], { extrapolateRight: 'clamp' });

  return (
    <AbsoluteFill
      style={{
        backgroundColor: BRAND_COLORS.lightBg,
        justifyContent: 'center',
        alignItems: 'center',
      }}
    >
      <div
        style={{
          transform: `scale(${scaleIn})`,
          opacity,
          textAlign: 'center',
        }}
      >
        <div
          style={{
            fontSize: '80px',
            marginBottom: '20px',
          }}
        >
          ✨
        </div>
        <div
          style={{
            fontSize: '56px',
            fontWeight: 'bold',
            color: BRAND_COLORS.blue,
            fontFamily: 'system-ui, -apple-system, sans-serif',
            letterSpacing: '-1px',
          }}
        >
          Meet Your
        </div>
        <div
          style={{
            fontSize: '56px',
            fontWeight: 'bold',
            color: BRAND_COLORS.green,
            fontFamily: 'system-ui, -apple-system, sans-serif',
            marginTop: '10px',
            letterSpacing: '-1px',
          }}
        >
          Meal Planner
        </div>
      </div>
    </AbsoluteFill>
  );
};

// Phone Frame Component with Meal Plan Demo
const PhoneMealPlanDemo: React.FC<{ duration: number }> = ({ duration }) => {
  const frame = useCurrentFrame();
  const progress = frame / duration;

  // Days of week
  const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'];
  const mealCards = [
    { meal: 'Pasta Carbonara', icon: '🍝', time: '25 min' },
    { meal: 'Grilled Chicken', icon: '🍗', time: '20 min' },
    { meal: 'Vegetable Stir-Fry', icon: '🥘', time: '15 min' },
    { meal: 'Salmon & Rice', icon: '🍲', time: '30 min' },
    { meal: 'Taco Tuesday', icon: '🌮', time: '18 min' },
  ];

  return (
    <AbsoluteFill
      style={{
        backgroundColor: BRAND_COLORS.lightBg,
        justifyContent: 'center',
        alignItems: 'center',
        padding: '20px',
      }}
    >
      {/* Phone Frame */}
      <div
        style={{
          width: '320px',
          height: '640px',
          backgroundColor: '#000',
          borderRadius: '50px',
          border: '14px solid #000',
          boxShadow: '0 30px 60px rgba(0,0,0,0.4)',
          overflow: 'hidden',
          position: 'relative',
        }}
      >
        {/* Status Bar */}
        <div
          style={{
            position: 'absolute',
            top: 0,
            width: '100%',
            height: '45px',
            backgroundColor: BRAND_COLORS.green,
            display: 'flex',
            justifyContent: 'center',
            alignItems: 'center',
            color: 'white',
            fontSize: '14px',
            fontWeight: 'bold',
            zIndex: 10,
          }}
        >
          SmartCart
        </div>

        {/* Content Area */}
        <div
          style={{
            width: '100%',
            height: '100%',
            backgroundColor: BRAND_COLORS.lightBg,
            padding: '55px 15px 20px',
            boxSizing: 'border-box',
            overflowY: 'hidden',
            display: 'flex',
            flexDirection: 'column',
            gap: '12px',
          }}
        >
          {/* Header */}
          <div
            style={{
              fontSize: '18px',
              fontWeight: 'bold',
              color: BRAND_COLORS.darkText,
              marginBottom: '10px',
              fontFamily: 'system-ui, -apple-system, sans-serif',
            }}
          >
            Your Week 📅
          </div>

          {/* Meal Cards with staggered animation */}
          {mealCards.map((meal, idx) => {
            // Staggered slide-in animation
            const cardFrame = frame - (idx * 8);
            const cardOpacity = interpolate(cardFrame, [0, 15], [0, 1], {
              extrapolateRight: 'clamp',
            });
            const cardY = interpolate(cardFrame, [0, 15], [40, 0], {
              extrapolateRight: 'clamp',
            });

            // Color cycling
            const colors = [BRAND_COLORS.blue, BRAND_COLORS.orange, BRAND_COLORS.green];
            const bgColor = colors[idx % colors.length];

            return (
              <div
                key={idx}
                style={{
                  backgroundColor: bgColor,
                  borderRadius: '12px',
                  padding: '12px 14px',
                  color: 'white',
                  display: 'flex',
                  justifyContent: 'space-between',
                  alignItems: 'center',
                  opacity: cardOpacity,
                  transform: `translateY(${cardY}px)`,
                  fontFamily: 'system-ui, -apple-system, sans-serif',
                  fontSize: '14px',
                  fontWeight: '600',
                  boxShadow: `0 4px 12px ${bgColor}40`,
                }}
              >
                <div
                  style={{
                    display: 'flex',
                    alignItems: 'center',
                    gap: '10px',
                  }}
                >
                  <span style={{ fontSize: '20px' }}>{meal.icon}</span>
                  <div>
                    <div>{days[idx]}</div>
                    <div style={{ fontSize: '12px', opacity: 0.9 }}>
                      {meal.meal}
                    </div>
                  </div>
                </div>
                <div style={{ fontSize: '12px', opacity: 0.8 }}>
                  {meal.time}
                </div>
              </div>
            );
          })}
        </div>

        {/* Glow Effect */}
        {frame > 20 && (
          <div
            style={{
              position: 'absolute',
              width: '100%',
              height: '100%',
              border: `2px solid ${BRAND_COLORS.green}`,
              borderRadius: '45px',
              boxShadow: `inset 0 0 20px ${BRAND_COLORS.green}40, 0 0 30px ${BRAND_COLORS.green}60`,
              pointerEvents: 'none',
              opacity: interpolate(frame, [20, 30], [0, 0.8], {
                extrapolateRight: 'clamp',
              }),
            }}
          />
        )}
      </div>
    </AbsoluteFill>
  );
};

// Button Press Animation
const ButtonPressAnimation: React.FC<{ startFrame: number }> = ({ startFrame }) => {
  const frame = useCurrentFrame();
  const relativeFrame = frame - startFrame;

  if (relativeFrame < 0) return null;

  // Button scale animation (press effect)
  const buttonScale = interpolate(relativeFrame, [0, 5, 10], [1, 0.95, 1.05], {
    extrapolateRight: 'clamp',
  });

  // Glow burst effect
  const glowRadius = interpolate(relativeFrame, [0, 15], [0, 80], {
    extrapolateRight: 'clamp',
  });
  const glowOpacity = interpolate(relativeFrame, [0, 8, 15], [1, 0.5, 0], {
    extrapolateRight: 'clamp',
  });

  return (
    <AbsoluteFill
      style={{
        justifyContent: 'center',
        alignItems: 'center',
        pointerEvents: 'none',
      }}
    >
      {/* Central button */}
      <div
        style={{
          backgroundColor: BRAND_COLORS.green,
          color: 'white',
          padding: '14px 32px',
          borderRadius: '20px',
          fontSize: '16px',
          fontWeight: 'bold',
          fontFamily: 'system-ui, -apple-system, sans-serif',
          boxShadow: `0 8px 20px ${BRAND_COLORS.green}60`,
          transform: `scale(${buttonScale})`,
          position: 'relative',
        }}
      >
        Create Meal Plan
      </div>

      {/* Ripple effect */}
      <div
        style={{
          position: 'absolute',
          width: `${glowRadius * 2}px`,
          height: `${glowRadius * 2}px`,
          borderRadius: '50%',
          border: `2px solid ${BRAND_COLORS.green}`,
          opacity: glowOpacity,
          pointerEvents: 'none',
        }}
      />

      {/* Multiple ripples */}
      {[0.5, 0.7, 0.9].map((delay, idx) => {
        const rippleRadius = interpolate(
          relativeFrame - delay * 15,
          [0, 15],
          [0, 100],
          { extrapolateRight: 'clamp' }
        );
        const rippleOpacity = interpolate(
          relativeFrame - delay * 15,
          [0, 15],
          [0.8, 0],
          { extrapolateRight: 'clamp' }
        );

        return (
          <div
            key={idx}
            style={{
              position: 'absolute',
              width: `${rippleRadius * 2}px`,
              height: `${rippleRadius * 2}px`,
              borderRadius: '50%',
              border: `2px solid ${BRAND_COLORS.blue}`,
              opacity: rippleOpacity,
              pointerEvents: 'none',
            }}
          />
        );
      })}
    </AbsoluteFill>
  );
};

// Tagline Component
const Tagline: React.FC<{ startFrame: number }> = ({ startFrame }) => {
  const frame = useCurrentFrame();
  const progress = interpolate(frame, [startFrame, startFrame + 15], [0, 1], {
    extrapolateRight: 'clamp',
  });

  const scaleSpring = spring({
    frame: Math.max(0, frame - startFrame),
    fps: 30,
    config: { damping: 8 },
  });

  return (
    <AbsoluteFill
      style={{
        justifyContent: 'flex-end',
        alignItems: 'center',
        paddingBottom: '60px',
      }}
    >
      <div
        style={{
          opacity: progress,
          transform: `scale(${scaleSpring})`,
          textAlign: 'center',
          maxWidth: '85%',
        }}
      >
        <div
          style={{
            fontSize: '44px',
            fontWeight: 'bold',
            color: BRAND_COLORS.darkText,
            fontFamily: 'system-ui, -apple-system, sans-serif',
            lineHeight: '1.2',
          }}
        >
          Plans for you,
          <br />
          by AI
        </div>
      </div>
    </AbsoluteFill>
  );
};

// CTA Final Button
const FinalCTA: React.FC<{ startFrame: number }> = ({ startFrame }) => {
  const frame = useCurrentFrame();
  const progress = interpolate(frame, [startFrame, startFrame + 15], [0, 1], {
    extrapolateRight: 'clamp',
  });

  const pulse = 1 + Math.sin((frame - startFrame) / 10) * 0.08;

  return (
    <AbsoluteFill
      style={{
        justifyContent: 'flex-end',
        alignItems: 'flex-end',
        padding: '40px 20px',
      }}
    >
      <div
        style={{
          backgroundColor: BRAND_COLORS.green,
          color: 'white',
          padding: '14px 36px',
          borderRadius: '24px',
          fontSize: '16px',
          fontWeight: 'bold',
          fontFamily: 'system-ui, -apple-system, sans-serif',
          boxShadow: `0 8px 24px ${BRAND_COLORS.green}50`,
          opacity: progress,
          transform: `scale(${pulse})`,
          whiteSpace: 'nowrap',
        }}
      >
        Try Free
      </div>
    </AbsoluteFill>
  );
};

// Main Composition
export const MealPlanMagicVideo: React.FC = () => {
  const { durationInFrames, fps } = useVideoConfig();

  return (
    <AbsoluteFill style={{ backgroundColor: BRAND_COLORS.lightBg }}>
      {/* Scene 1: Title Card (0-45 frames) */}
      <Sequence from={0} durationInFrames={45}>
        <TitleCard duration={45} />
      </Sequence>

      {/* Scene 2: Phone Demo with Meal Cards (45-300 frames) */}
      <Sequence from={45} durationInFrames={255}>
        <PhoneMealPlanDemo duration={255} />
      </Sequence>

      {/* Button Press Animation (150-225 frames) */}
      <Sequence from={150} durationInFrames={75}>
        <ButtonPressAnimation startFrame={0} />
      </Sequence>

      {/* Tagline (300-375 frames) */}
      <Sequence from={300} durationInFrames={75}>
        <Tagline startFrame={0} />
      </Sequence>

      {/* Final CTA Button (375-450 frames) */}
      <Sequence from={375} durationInFrames={75}>
        <FinalCTA startFrame={0} />
      </Sequence>
    </AbsoluteFill>
  );
};
