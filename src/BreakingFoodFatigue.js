"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.BreakingFoodFatigueVideo = void 0;
var react_1 = require("react");
var remotion_1 = require("remotion");
// ============ BRAND COLORS ============
var COLORS = {
    paper: '#F5ECD7',
    ink: '#2C1A0E',
    red: '#D4544C',
    mustard: '#E8A838',
    teal: '#4AAFA8',
    plum: '#7B5EA7',
    grey: '#5A6B7D',
    darkGrey: '#4A4A4A',
    lightGrey: '#999999',
    blue: '#2E7CD4',
};
// ============ UTILITIES ============
var hexToRgb = function (hex) {
    var result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex);
    return result
        ? {
            r: parseInt(result[1], 16),
            g: parseInt(result[2], 16),
            b: parseInt(result[3], 16),
        }
        : { r: 255, g: 255, b: 255 };
};
var lerpColor = function (color1, color2, t) {
    var rgb1 = hexToRgb(color1);
    var rgb2 = hexToRgb(color2);
    var r = Math.round(rgb1.r + (rgb2.r - rgb1.r) * t);
    var g = Math.round(rgb1.g + (rgb2.g - rgb1.g) * t);
    var b = Math.round(rgb1.b + (rgb2.b - rgb1.b) * t);
    return "rgb(".concat(r, ", ").concat(g, ", ").concat(b, ")");
};
// ============ SCENE 1: PROBLEM IDENTIFICATION (0-90 frames) ============
var Scene1ProblemIdentification = function () {
    var frame = (0, remotion_1.useCurrentFrame)();
    // Color desaturation over time
    var saturation = (0, remotion_1.interpolate)(frame, [0, 90], [0.4, 0.4]);
    var coolBlueShift = (0, remotion_1.interpolate)(frame, [0, 90], [0, -15]);
    // Fridge opening animation
    var fridgeScale = (0, remotion_1.interpolate)(frame, [0, 30], [0.8, 1], { extrapolateRight: 'clamp' });
    var fridgeOpacity = (0, remotion_1.interpolate)(frame, [0, 20], [0, 1], { extrapolateRight: 'clamp' });
    // Face expression appears at 15-30
    var faceOpacity = (0, remotion_1.interpolate)(frame, [15, 30], [0, 1], { extrapolateRight: 'clamp' });
    // Timestamp appears
    var timestampOpacity = (0, remotion_1.interpolate)(frame, [30, 45], [0, 1], { extrapolateRight: 'clamp' });
    return (<remotion_1.AbsoluteFill style={{
            backgroundColor: '#E8E8E8',
            justifyContent: 'center',
            alignItems: 'center',
            filter: "saturate(".concat(saturation, ") hue-rotate(").concat(coolBlueShift, "deg)"),
        }}>
      {/* Fridge Opening Scene */}
      <div style={{
            position: 'absolute',
            fontSize: '120px',
            opacity: fridgeOpacity,
            transform: "scale(".concat(fridgeScale, ")"),
        }}>
        🧊
      </div>

      {/* Tired Face */}
      <div style={{
            position: 'absolute',
            fontSize: '140px',
            bottom: '30%',
            opacity: faceOpacity,
        }}>
        😔
      </div>

      {/* Timestamp */}
      <div style={{
            position: 'absolute',
            bottom: '20%',
            fontSize: '32px',
            opacity: timestampOpacity,
            color: COLORS.darkGrey,
            fontFamily: 'Arial, sans-serif',
        }}>
        Monday 6:45 PM
      </div>
    </remotion_1.AbsoluteFill>);
};
// ============ SCENE 2: REPETITION LOOP (90-195 frames) ============
var Scene2RepetitionLoop = function () {
    var frame = (0, remotion_1.useCurrentFrame)();
    var localFrame = frame - 90;
    // Repeated plates animation
    var plate1Opacity = (0, remotion_1.interpolate)(localFrame, [0, 10], [0, 1], {
        extrapolateRight: 'clamp',
    });
    var plate2Opacity = (0, remotion_1.interpolate)(localFrame, [20, 30], [0, 1], {
        extrapolateRight: 'clamp',
    });
    var plate3Opacity = (0, remotion_1.interpolate)(localFrame, [40, 50], [0, 1], {
        extrapolateRight: 'clamp',
    });
    // Frustration text
    var text1Opacity = (0, remotion_1.interpolate)(localFrame, [15, 20], [0, 1], {
        extrapolateRight: 'clamp',
    });
    var text2Opacity = (0, remotion_1.interpolate)(localFrame, [30, 35], [0, 1], {
        extrapolateRight: 'clamp',
    });
    // Calendar flip animation
    var calendarOpacity = (0, remotion_1.interpolate)(localFrame, [55, 65], [0, 1], {
        extrapolateRight: 'clamp',
    });
    var calendarScale = (0, remotion_1.interpolate)(localFrame, [55, 70], [0.8, 1], {
        extrapolateRight: 'clamp',
    });
    // Main sad text appearing around frame 60
    var sadTextOpacity = (0, remotion_1.interpolate)(localFrame, [60, 75], [0, 1], {
        extrapolateRight: 'clamp',
    });
    // Piano music audio hint (sad minor key emotional beat)
    var emotionalWeight = (0, remotion_1.interpolate)(localFrame, [60, 105], [0, 1]);
    return (<remotion_1.AbsoluteFill style={{
            backgroundColor: COLORS.lightGrey,
            justifyContent: 'center',
            alignItems: 'center',
            filter: "saturate(0.4)",
        }}>
      {/* Plate 1 */}
      <div style={{
            position: 'absolute',
            fontSize: '80px',
            opacity: plate1Opacity,
            top: '25%',
            left: '15%',
        }}>
        🍗 🍚 🥦
      </div>

      {/* Plate 2 - Identical */}
      <div style={{
            position: 'absolute',
            fontSize: '80px',
            opacity: plate2Opacity,
            top: '25%',
            left: '50%',
            transform: 'translateX(-50%)',
        }}>
        🍗 🍚 🥦
      </div>

      {/* Frustration Text 1 */}
      <div style={{
            position: 'absolute',
            opacity: text1Opacity,
            top: '22%',
            right: '10%',
            fontSize: '48px',
            color: COLORS.red,
            fontFamily: 'Cursive, Arial',
            fontStyle: 'italic',
        }}>
        Again?
      </div>

      {/* Plate 3 */}
      <div style={{
            position: 'absolute',
            fontSize: '80px',
            opacity: plate3Opacity,
            bottom: '30%',
            right: '15%',
        }}>
        🍗 🍚 🥦
      </div>

      {/* Frustration Text 2 */}
      <div style={{
            position: 'absolute',
            opacity: text2Opacity,
            bottom: '27%',
            left: '10%',
            fontSize: '44px',
            color: COLORS.grey,
            fontFamily: 'Georgia, serif',
            fontStyle: 'italic',
        }}>
        And again...
      </div>

      {/* Calendar/Days Passing */}
      <div style={{
            position: 'absolute',
            top: '50%',
            left: '50%',
            transform: "translate(-50%, -50%) scale(".concat(calendarScale, ")"),
            opacity: calendarOpacity,
            fontSize: '28px',
            color: COLORS.grey,
            textAlign: 'center',
            fontFamily: 'Arial, sans-serif',
        }}>
        📅 Tue 📅 Wed 📅 Thu
      </div>

      {/* Main Emotional Text */}
      <div style={{
            position: 'absolute',
            bottom: '15%',
            left: '50%',
            transform: 'translateX(-50%)',
            textAlign: 'center',
            opacity: sadTextOpacity,
            maxWidth: '80%',
            fontSize: '44px',
            color: COLORS.grey,
            fontFamily: 'Georgia, serif',
            lineHeight: 1.3,
        }}>
        7 days. Same meal.<br />Is there more to life?
      </div>
    </remotion_1.AbsoluteFill>);
};
// ============ SCENE 3: FRUSTRATION PEAK (195-285 frames) ============
var Scene3FrustrationPeak = function () {
    var frame = (0, remotion_1.useCurrentFrame)();
    var localFrame = frame - 195;
    // Neural network visualization
    var networkOpacity = (0, remotion_1.interpolate)(localFrame, [0, 15], [0, 1], {
        extrapolateRight: 'clamp',
    });
    // What should I cook text
    var questionOpacity = (0, remotion_1.interpolate)(localFrame, [0, 15], [0, 1], {
        extrapolateRight: 'clamp',
    });
    var questionScale = (0, remotion_1.spring)({
        frame: Math.max(0, localFrame - 0),
        fps: 30,
        config: { damping: 8, mass: 1, stiffness: 100 },
    });
    // Rapid scrolling food images
    var scrollOpacity = (0, remotion_1.interpolate)(localFrame, [30, 45], [0, 1], {
        extrapolateRight: 'clamp',
    });
    // Color drain
    var colorDrainProgress = (0, remotion_1.interpolate)(localFrame, [60, 90], [0, 1], {
        extrapolateRight: 'clamp',
    });
    // Too many choices text
    var tooManyOpacity = (0, remotion_1.interpolate)(localFrame, [60, 75], [0, 1], {
        extrapolateRight: 'clamp',
    });
    return (<remotion_1.AbsoluteFill style={{
            backgroundColor: '#2A2A2A',
            justifyContent: 'center',
            alignItems: 'center',
            overflow: 'hidden',
        }}>
      {/* Neural Network Dots */}
      <div style={{
            position: 'absolute',
            opacity: networkOpacity,
            fontSize: '60px',
            top: '20%',
            left: '50%',
            transform: 'translateX(-50%)',
        }}>
        🧠 ⚡ 🔴
      </div>

      {/* What should I cook? */}
      <div style={{
            position: 'absolute',
            top: '35%',
            left: '50%',
            transform: "translate(-50%, -50%) scale(".concat(questionScale, ")"),
            opacity: questionOpacity,
            fontSize: '52px',
            fontWeight: 'bold',
            color: COLORS.mustard,
            fontFamily: 'Arial, sans-serif',
            textAlign: 'center',
        }}>
        What should I cook?
      </div>

      {/* Rapid scrolling food montage */}
      <div style={{
            position: 'absolute',
            top: '55%',
            left: '50%',
            transform: 'translateX(-50%)',
            opacity: scrollOpacity,
            fontSize: '48px',
            animation: "scroll 0.5s infinite",
        }}>
        🍕 🍔 🌮 🍜 🥗 🍝 🍱 🍣 🥘 🍲
      </div>

      {/* Too many choices text */}
      <div style={{
            position: 'absolute',
            bottom: '20%',
            left: '50%',
            transform: 'translateX(-50%)',
            opacity: tooManyOpacity,
            fontSize: '48px',
            color: COLORS.lightGrey,
            fontFamily: 'Georgia, serif',
            fontStyle: 'italic',
            textAlign: 'center',
        }}>
        Too many choices.
      </div>

      {/* Delivery app icon hint */}
      <div style={{
            position: 'absolute',
            bottom: '10%',
            right: '10%',
            fontSize: '80px',
            opacity: tooManyOpacity,
        }}>
        📱
      </div>

      <style>{"\n        @keyframes scroll {\n          0% { transform: translateX(0); }\n          100% { transform: translateX(-100%); }\n        }\n      "}</style>
    </remotion_1.AbsoluteFill>);
};
// ============ SCENE 4: TURNING POINT (285-390 frames) ============
var Scene4TurningPoint = function () {
    var frame = (0, remotion_1.useCurrentFrame)();
    var localFrame = frame - 285;
    // Notification slide down
    var notificationY = (0, remotion_1.interpolate)(localFrame, [0, 15], [-100, 0], {
        extrapolateRight: 'clamp',
    });
    var notificationOpacity = (0, remotion_1.interpolate)(localFrame, [0, 15], [0, 1], {
        extrapolateRight: 'clamp',
    });
    // App transition zoom
    var appZoom = (0, remotion_1.interpolate)(localFrame, [30, 55], [0.5, 1], {
        extrapolateRight: 'clamp',
    });
    var appOpacity = (0, remotion_1.interpolate)(localFrame, [30, 55], [0, 1], {
        extrapolateRight: 'clamp',
    });
    // Logo glow
    var logoGlow = (0, remotion_1.spring)({
        frame: Math.max(0, localFrame - 30),
        fps: 30,
        config: { damping: 8, mass: 1, stiffness: 100 },
    });
    // Discover text
    var discoverOpacity = (0, remotion_1.interpolate)(localFrame, [45, 60], [0, 1], {
        extrapolateRight: 'clamp',
    });
    // Recipe cards sliding in
    var card1X = (0, remotion_1.interpolate)(localFrame, [75, 95], [-500, 0], {
        extrapolateRight: 'clamp',
    });
    var card1Opacity = (0, remotion_1.interpolate)(localFrame, [75, 95], [0, 1], {
        extrapolateRight: 'clamp',
    });
    var card2X = (0, remotion_1.interpolate)(localFrame, [85, 105], [500, 0], {
        extrapolateRight: 'clamp',
    });
    var card2Opacity = (0, remotion_1.interpolate)(localFrame, [85, 105], [0, 1], {
        extrapolateRight: 'clamp',
    });
    var card3X = (0, remotion_1.interpolate)(localFrame, [95, 115], [-500, 0], {
        extrapolateRight: 'clamp',
    });
    var card3Opacity = (0, remotion_1.interpolate)(localFrame, [95, 115], [0, 1], {
        extrapolateRight: 'clamp',
    });
    // Background color transition (desaturated to colorful)
    var bgColor = lerpColor('#666666', COLORS.paper, (0, remotion_1.interpolate)(localFrame, [0, 105], [0, 1]));
    return (<remotion_1.AbsoluteFill style={{
            backgroundColor: bgColor,
            justifyContent: 'center',
            alignItems: 'center',
            overflow: 'hidden',
        }}>
      {/* Phone Lock Screen Notification */}
      <div style={{
            position: 'absolute',
            top: "".concat(20 + notificationY, "px"),
            left: '50%',
            transform: 'translateX(-50%)',
            opacity: notificationOpacity,
            backgroundColor: COLORS.teal,
            padding: '12px 16px',
            borderRadius: '8px',
            color: 'white',
            fontSize: '16px',
            fontFamily: 'Arial, sans-serif',
            zIndex: 10,
            boxShadow: '0 4px 12px rgba(0,0,0,0.2)',
        }}>
        📲 Let us handle meal variety
      </div>

      {/* Phone Screen / App Interface */}
      <div style={{
            position: 'absolute',
            opacity: appOpacity,
            transform: "scale(".concat(appZoom, ")"),
            textAlign: 'center',
        }}>
        {/* SmartCart Logo with Glow */}
        <div style={{
            fontSize: '80px',
            opacity: logoGlow > 0.5 ? 1 : 0.7,
            filter: "drop-shadow(0 0 ".concat(logoGlow * 20, "px ").concat(COLORS.teal, ")"),
            marginBottom: '16px',
        }}>
          🛒
        </div>

        {/* Discover Text */}
        <div style={{
            opacity: discoverOpacity,
            fontSize: '44px',
            fontWeight: 'bold',
            color: COLORS.darkGrey,
            fontFamily: 'Arial, sans-serif',
            marginBottom: '24px',
        }}>
          Discover 1000+ Recipes
        </div>
      </div>

      {/* Recipe Cards */}
      {/* Card 1: Asian Noodles - slides left */}
      <div style={{
            position: 'absolute',
            left: "calc(50% - 200px + ".concat(card1X, "px)"),
            top: '50%',
            transform: 'translateY(-50%)',
            opacity: card1Opacity,
            backgroundColor: COLORS.paper,
            padding: '16px',
            borderRadius: '8px',
            width: '120px',
            textAlign: 'center',
            fontSize: '60px',
            boxShadow: '0 4px 8px rgba(0,0,0,0.1)',
        }}>
        🍜
      </div>

      {/* Card 2: Mediterranean - slides right */}
      <div style={{
            position: 'absolute',
            left: "calc(50% + ".concat(card2X, "px)"),
            top: '50%',
            transform: 'translateY(-50%)',
            opacity: card2Opacity,
            backgroundColor: COLORS.paper,
            padding: '16px',
            borderRadius: '8px',
            width: '120px',
            textAlign: 'center',
            fontSize: '60px',
            boxShadow: '0 4px 8px rgba(0,0,0,0.1)',
        }}>
        🐟
      </div>

      {/* Card 3: Tacos - slides left */}
      <div style={{
            position: 'absolute',
            left: "calc(50% - 200px + ".concat(card3X, "px)"),
            bottom: '20%',
            opacity: card3Opacity,
            backgroundColor: COLORS.paper,
            padding: '16px',
            borderRadius: '8px',
            width: '120px',
            textAlign: 'center',
            fontSize: '60px',
            boxShadow: '0 4px 8px rgba(0,0,0,0.1)',
        }}>
        🌮
      </div>
    </remotion_1.AbsoluteFill>);
};
// ============ SCENE 5: VARIETY SHOWCASE (390-600 frames) ============
var Scene5VarietyShowcase = function () {
    var frame = (0, remotion_1.useCurrentFrame)();
    var localFrame = frame - 390;
    // Cuisine diversity cycling
    var cycleProgress = (localFrame % 45) / 45;
    // Filter tags appearing
    var filter1Opacity = (0, remotion_1.interpolate)(localFrame, [60, 75], [0, 1], {
        extrapolateRight: 'clamp',
    });
    var filter2Opacity = (0, remotion_1.interpolate)(localFrame, [80, 95], [0, 1], {
        extrapolateRight: 'clamp',
    });
    var filter3Opacity = (0, remotion_1.interpolate)(localFrame, [100, 115], [0, 1], {
        extrapolateRight: 'clamp',
    });
    // Personalization text
    var personalizationOpacity = (0, remotion_1.interpolate)(localFrame, [150, 165], [0, 1], {
        extrapolateRight: 'clamp',
    });
    // Weekly meal plan
    var weeklyOpacity = (0, remotion_1.interpolate)(localFrame, [200, 215], [0, 1], {
        extrapolateRight: 'clamp',
    });
    var displayRecipes = [
        { emoji: '🍜', name: 'Asian Noodle', color: COLORS.mustard },
        { emoji: '🐟', name: 'Mediterranean', color: COLORS.blue },
        { emoji: '🌮', name: 'Mexican Taco', color: COLORS.red },
    ];
    var cuisineIndex = Math.floor((localFrame / 45) % displayRecipes.length);
    return (<remotion_1.AbsoluteFill style={{
            backgroundColor: COLORS.paper,
            justifyContent: 'center',
            alignItems: 'center',
            padding: '20px',
        }}>
      {/* Rotating Recipe Showcase */}
      <div style={{
            position: 'absolute',
            top: '15%',
            left: '50%',
            transform: 'translateX(-50%)',
            textAlign: 'center',
        }}>
        {displayRecipes.map(function (recipe, idx) { return (<div key={idx} style={{
                position: 'absolute',
                opacity: cuisineIndex === idx ? 1 : 0,
                transition: 'opacity 0.3s',
                fontSize: '100px',
            }}>
            {recipe.emoji}
          </div>); })}
      </div>

      {/* Filter Tags */}
      <div style={{
            position: 'absolute',
            top: '35%',
            left: '50%',
            transform: 'translateX(-50%)',
            textAlign: 'center',
            display: 'flex',
            gap: '12px',
            flexWrap: 'wrap',
            justifyContent: 'center',
            maxWidth: '80%',
        }}>
        {/* Filter 1 */}
        <div style={{
            opacity: filter1Opacity,
            backgroundColor: COLORS.teal,
            color: 'white',
            padding: '8px 16px',
            borderRadius: '20px',
            fontSize: '18px',
            fontFamily: 'Arial, sans-serif',
        }}>
          ⏱️ Quick Meals
        </div>

        {/* Filter 2 */}
        <div style={{
            opacity: filter2Opacity,
            backgroundColor: COLORS.mustard,
            color: COLORS.ink,
            padding: '8px 16px',
            borderRadius: '20px',
            fontSize: '18px',
            fontFamily: 'Arial, sans-serif',
        }}>
          💪 High Protein
        </div>

        {/* Filter 3 */}
        <div style={{
            opacity: filter3Opacity,
            backgroundColor: COLORS.plum,
            color: 'white',
            padding: '8px 16px',
            borderRadius: '20px',
            fontSize: '18px',
            fontFamily: 'Arial, sans-serif',
        }}>
          💰 Budget-Friendly
        </div>
      </div>

      {/* Personalization Text */}
      <div style={{
            position: 'absolute',
            top: '55%',
            left: '50%',
            transform: 'translateX(-50%)',
            opacity: personalizationOpacity,
            textAlign: 'center',
            fontSize: '32px',
            color: COLORS.ink,
            fontFamily: 'Arial, sans-serif',
            fontWeight: 'bold',
        }}>
        SmartCart remembers YOU
      </div>

      {/* Weekly Meal Plan */}
      <div style={{
            position: 'absolute',
            bottom: '15%',
            left: '50%',
            transform: 'translateX(-50%)',
            opacity: weeklyOpacity,
            textAlign: 'center',
        }}>
        <div style={{
            display: 'flex',
            gap: '8px',
            justifyContent: 'center',
            marginBottom: '12px',
        }}>
          {['🍜', '🐟', '🌮', '🍛', '🍝'].map(function (emoji, idx) { return (<div key={idx} style={{
                fontSize: '40px',
                animation: "fadeInSequence ".concat(0.5 + idx * 0.15, "s forwards"),
            }}>
              {emoji}
            </div>); })}
        </div>
        <div style={{
            fontSize: '28px',
            color: COLORS.ink,
            fontFamily: 'Arial, sans-serif',
            fontWeight: 'bold',
        }}>
          A week of variety. No repetition.
        </div>
      </div>

      <style>{"\n        @keyframes fadeInSequence {\n          from { opacity: 0; transform: translateY(20px); }\n          to { opacity: 1; transform: translateY(0); }\n        }\n      "}</style>
    </remotion_1.AbsoluteFill>);
};
// ============ SCENE 6: TRANSFORMATION REVEALED (600-720 frames) ============
var Scene6TransformationRevealed = function () {
    var frame = (0, remotion_1.useCurrentFrame)();
    var localFrame = frame - 600;
    // Cooking montage
    var cookingOpacity = (0, remotion_1.interpolate)(localFrame, [0, 15], [0, 1], {
        extrapolateRight: 'clamp',
    });
    // Finished dishes with proud reaction
    var platesOpacity = (0, remotion_1.interpolate)(localFrame, [45, 60], [0, 1], {
        extrapolateRight: 'clamp',
    });
    var prideTextOpacity = (0, remotion_1.interpolate)(localFrame, [45, 60], [0, 1], {
        extrapolateRight: 'clamp',
    });
    // Life impact scenes
    var lifeImpactOpacity = (0, remotion_1.interpolate)(localFrame, [90, 105], [0, 1], {
        extrapolateRight: 'clamp',
    });
    var varietyTextOpacity = (0, remotion_1.interpolate)(localFrame, [90, 105], [0, 1], {
        extrapolateRight: 'clamp',
    });
    return (<remotion_1.AbsoluteFill style={{
            backgroundColor: COLORS.paper,
            justifyContent: 'center',
            alignItems: 'center',
        }}>
      {/* Cooking Scene */}
      <div style={{
            position: 'absolute',
            top: '20%',
            left: '50%',
            transform: 'translateX(-50%)',
            opacity: cookingOpacity,
            fontSize: '100px',
            animation: 'sizzle 0.5s infinite',
        }}>
        🔥👨‍🍳
      </div>

      {/* Finished Beautiful Plates */}
      <div style={{
            position: 'absolute',
            top: '35%',
            left: '50%',
            transform: 'translateX(-50%)',
            opacity: platesOpacity,
            textAlign: 'center',
        }}>
        <div style={{ fontSize: '80px', marginBottom: '12px' }}>
          🍽️✨
        </div>
        <div style={{
            fontSize: '48px',
            fontWeight: 'bold',
            color: COLORS.ink,
            fontFamily: 'Arial, sans-serif',
            opacity: prideTextOpacity,
        }}>
          Food fatigue? Gone.
        </div>
      </div>

      {/* Happy reactions */}
      <div style={{
            position: 'absolute',
            bottom: '35%',
            left: '50%',
            transform: 'translateX(-50%)',
            opacity: lifeImpactOpacity,
            textAlign: 'center',
            fontSize: '80px',
        }}>
        😊 👨‍👩‍👧 🎉
      </div>

      {/* Impact Text */}
      <div style={{
            position: 'absolute',
            bottom: '15%',
            left: '50%',
            transform: 'translateX(-50%)',
            opacity: varietyTextOpacity,
            textAlign: 'center',
            maxWidth: '85%',
            fontSize: '36px',
            color: COLORS.ink,
            fontFamily: 'Georgia, serif',
            lineHeight: 1.4,
        }}>
        More variety.<br />More confidence.<br />More joy.
      </div>

      <style>{"\n        @keyframes sizzle {\n          0%, 100% { transform: scale(1) rotate(0deg); }\n          50% { transform: scale(1.1) rotate(5deg); }\n        }\n      "}</style>
    </remotion_1.AbsoluteFill>);
};
// ============ SCENE 7: CLOSING & CALL TO ACTION (720-840 frames) ============
var Scene7ClosingCTA = function () {
    var frame = (0, remotion_1.useCurrentFrame)();
    var localFrame = frame - 720;
    // Feature icons sliding in
    var featureOpacity = (0, remotion_1.interpolate)(localFrame, [0, 15], [0, 1], {
        extrapolateRight: 'clamp',
    });
    // Brand message
    var brandMessageOpacity = (0, remotion_1.interpolate)(localFrame, [20, 35], [0, 1], {
        extrapolateRight: 'clamp',
    });
    // CTA Button spring animation
    var buttonScale = (0, remotion_1.spring)({
        frame: Math.max(0, localFrame - 40),
        fps: 30,
        config: { damping: 8, mass: 1, stiffness: 100 },
    });
    var buttonOpacity = (0, remotion_1.interpolate)(localFrame, [40, 50], [0, 1], {
        extrapolateRight: 'clamp',
    });
    // Button glow pulse
    var glowIntensity = 1 + Math.sin((localFrame - 40) / 5) * 0.2;
    // Subtext
    var subtextOpacity = (0, remotion_1.interpolate)(localFrame, [50, 60], [0, 1], {
        extrapolateRight: 'clamp',
    });
    return (<remotion_1.AbsoluteFill style={{
            backgroundColor: COLORS.paper,
            justifyContent: 'center',
            alignItems: 'center',
            overflow: 'hidden',
        }}>
      {/* Feature Icons */}
      <div style={{
            position: 'absolute',
            top: '10%',
            left: '50%',
            transform: 'translateX(-50%)',
            opacity: featureOpacity,
            display: 'flex',
            gap: '20px',
            justifyContent: 'center',
            fontSize: '50px',
        }}>
        <div>🔍</div>
        <div>📅</div>
        <div>📊</div>
        <div>🛒</div>
      </div>

      {/* Brand Message */}
      <div style={{
            position: 'absolute',
            top: '25%',
            left: '50%',
            transform: 'translateX(-50%)',
            opacity: brandMessageOpacity,
            textAlign: 'center',
            fontSize: '44px',
            fontWeight: 'bold',
            color: COLORS.ink,
            fontFamily: 'Arial, sans-serif',
        }}>
        SmartCart.<br />Variety built in.
      </div>

      {/* CTA Button */}
      <div style={{
            position: 'absolute',
            top: '55%',
            left: '50%',
            transform: "translate(-50%, -50%) scale(".concat(buttonScale, ")"),
            opacity: buttonOpacity,
            backgroundColor: COLORS.teal,
            backgroundImage: "linear-gradient(135deg, ".concat(COLORS.teal, ", ").concat(COLORS.blue, ")"),
            padding: '18px 36px',
            borderRadius: '12px',
            color: 'white',
            fontSize: '44px',
            fontWeight: 'bold',
            fontFamily: 'Arial, sans-serif',
            textAlign: 'center',
            boxShadow: "0 8px 16px rgba(74, 175, 168, ".concat(glowIntensity * 0.3, ")"),
            cursor: 'pointer',
            whiteSpace: 'nowrap',
            minWidth: '280px',
        }}>
        Beat Food Fatigue Today
      </div>

      {/* Subtext */}
      <div style={{
            position: 'absolute',
            bottom: '20%',
            left: '50%',
            transform: 'translateX(-50%)',
            opacity: subtextOpacity,
            textAlign: 'center',
            fontSize: '24px',
            color: COLORS.darkGrey,
            fontFamily: 'Arial, sans-serif',
        }}>
        Free. Start now.<br />Change your meals forever.
      </div>
    </remotion_1.AbsoluteFill>);
};
// ============ MAIN VIDEO COMPONENT ============
var BreakingFoodFatigueVideo = function () {
    return (<>
      {/* Scene 1: Problem Identification (0-90) */}
      <remotion_1.Sequence from={0} durationInFrames={90}>
        <Scene1ProblemIdentification />
      </remotion_1.Sequence>

      {/* Scene 2: Repetition Loop (90-195) */}
      <remotion_1.Sequence from={90} durationInFrames={105}>
        <Scene2RepetitionLoop />
      </remotion_1.Sequence>

      {/* Scene 3: Frustration Peak (195-285) */}
      <remotion_1.Sequence from={195} durationInFrames={90}>
        <Scene3FrustrationPeak />
      </remotion_1.Sequence>

      {/* Scene 4: Turning Point (285-390) */}
      <remotion_1.Sequence from={285} durationInFrames={105}>
        <Scene4TurningPoint />
      </remotion_1.Sequence>

      {/* Scene 5: Variety Showcase (390-600) */}
      <remotion_1.Sequence from={390} durationInFrames={210}>
        <Scene5VarietyShowcase />
      </remotion_1.Sequence>

      {/* Scene 6: Transformation Revealed (600-720) */}
      <remotion_1.Sequence from={600} durationInFrames={120}>
        <Scene6TransformationRevealed />
      </remotion_1.Sequence>

      {/* Scene 7: Closing & CTA (720-840) */}
      <remotion_1.Sequence from={720} durationInFrames={120}>
        <Scene7ClosingCTA />
      </remotion_1.Sequence>
    </>);
};
exports.BreakingFoodFatigueVideo = BreakingFoodFatigueVideo;
