import React from 'react';
import { Composition } from 'remotion';
import { MealPlanningChaosVideo } from './remotion-prompt-1-meal-planning-chaos';
import { MealPlanMagicVideo } from './remotion-prompt-6-meal-plan-magic';

export const RemotionRoot: React.FC = () => {
  return (
    <>
      <Composition
        id="MealPlanningChaos"
        component={MealPlanningChaosVideo}
        durationInFrames={450}
        fps={30}
        width={1080}
        height={1920}
      />
      <Composition
        id="MealPlanMagicVideo"
        component={MealPlanMagicVideo}
        durationInFrames={450}
        fps={30}
        width={1080}
        height={1920}
      />
    </>
  );
};
