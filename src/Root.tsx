import React from 'react';
import { Composition } from 'remotion';
import { MealPlanningChaosVideo } from './Video1';
import { MealPlanMagicVideo } from './Video2';
import { BreakingFoodFatigueVideo } from './BreakingFoodFatigue';

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
      <Composition
        id="food-fatigue"
        component={BreakingFoodFatigueVideo}
        durationInFrames={450}
        fps={30}
        width={1080}
        height={1920}
      />
    </>
  );
};
