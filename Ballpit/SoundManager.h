//
//  SoundManager.h
//  Laser Quantum Game
//
//  Created by Richard Smith on 09/01/2014.
//  Copyright (c) 2014 Play. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SoundManager : NSObject

+ (id)theSoundManager;

-(void) playSoundWallHit;
-(void) playSoundGlowHit;
-(void) playGetPowerup;
-(void) playSoundBackInPlay;
-(void) playPaddleThud;
-(void) playExplosion;
-(void) playPodCollected;

@end
