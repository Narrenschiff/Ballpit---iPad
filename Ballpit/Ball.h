//
//  Ball.h
//  Ballpit
//
//  Created by Richard Smith on 05/11/2013.
//  Copyright (c) 2013 Richard Smith. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface Ball : SKSpriteNode
@property BOOL isFullBall;
@property CFTimeInterval refractoryTimer;
@property uint ballColour;
@property CFTimeInterval explosionCountdown;

-(id) initWithBallColour: (uint) c;
-(id) initPodWithColour: (uint) c;
-(void) podToBall;
-(void) killSelfAfterSecond;

@end
