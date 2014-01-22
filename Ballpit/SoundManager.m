//
//  SoundManager.m
//  Laser Quantum Game
//
//  Created by Richard Smith on 09/01/2014.
//  Copyright (c) 2014 Play. All rights reserved.
//

#import "SoundManager.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

@implementation SoundManager{
    
    AVAudioPlayer *thunkPlayer;
    AVAudioPlayer *thudPlayer;
    AVAudioPlayer *powerupPlayer;
    AVAudioPlayer *bloop1;
    AVAudioPlayer *bloop2;
    AVAudioPlayer *bloop3;
    AVAudioPlayer *backInPlay;
    AVAudioPlayer *explosion;
}

+ (id)theSoundManager
{
    static SoundManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

-(id) init
{
    if (self = [super init]) {
        NSURL *pingURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"tink" ofType:@"wav"]];
        NSURL *thudURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"thunk" ofType:@"aif"]];
        NSURL *laserURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"laser" ofType:@"wav"]];
        
        NSURL *bloop1URL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"bloop1" ofType:@"wav"]];
        NSURL *bloop2URL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"bloop2" ofType:@"wav"]];
        NSURL *bloop3URL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"bloop3" ofType:@"wav"]];
        NSURL *backInPlayURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"resumeplay" ofType:@"wav"]];
        NSURL *explosionURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Explosion" ofType:@"wav"]];
        
        NSError *error;
        thunkPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:pingURL error:&error];
        powerupPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:laserURL error:&error];
        thudPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:thudURL error:&error];
        
        bloop1 = [[AVAudioPlayer alloc] initWithContentsOfURL:bloop1URL error:&error];
        bloop2 = [[AVAudioPlayer alloc] initWithContentsOfURL:bloop2URL error:&error];
        bloop3 = [[AVAudioPlayer alloc] initWithContentsOfURL:bloop3URL error:&error];
        
        backInPlay = [[AVAudioPlayer alloc] initWithContentsOfURL:backInPlayURL error:&error];
        
        explosion = [[AVAudioPlayer alloc] initWithContentsOfURL:explosionURL error:&error];
    }
    return self;
}

-(void) playExplosion
{
    [explosion play];
}

-(void) playSoundWallHit
{
    uint r = arc4random() % 3;
    switch (r) {
        case 0:
            [bloop1 play];
            break;
        case 1:
            [bloop2 play];
            break;
        case 2:
            [bloop3 play];
            break;
        default:
            break;
    }
}

-(void) playSoundGlowHit
{
    [thunkPlayer play];
}

-(void) playGetPowerup
{
    [powerupPlayer play];
}

-(void) playSoundBackInPlay
{
    [backInPlay play];
}

-(void) playPaddleThud
{
    [thudPlayer play];
}

@end
