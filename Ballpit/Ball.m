//
//  Ball.m
//  Ballpit
//
//  Created by Richard Smith on 05/11/2013.
//  Copyright (c) 2013 Richard Smith. All rights reserved.
//

#import "Ball.h"

@implementation Ball


// Create a new ball
-(id) initWithBallColour: (uint) c
{
    switch (c) {
        case 0:
            self = [self initWithImageNamed:@"Red"];
            break;
        case 1:
            self = [self initWithImageNamed:@"Blue"];
            break;
        case 2:
            self = [self initWithImageNamed:@"Green"];
            break;
            
        default:
            break;
    }
    self.ballColour = c;
    self.explosionTimer = [[NSDate date] timeIntervalSinceReferenceDate];
    self.isFullBall = YES;
    
    self.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:50.0];
    self.physicsBody.affectedByGravity = NO;
    self.physicsBody.restitution = 1.0;
    
    self.physicsBody.categoryBitMask = 2;
    self.physicsBody.contactTestBitMask = 2;

    [self pulseBall];
    
    
    return self;
}

// Create a new pod
-(id) initPodWithColour: (uint) c
{
    switch (c) {
        case 0:
            self = [self initWithImageNamed:@"Red"];
            break;
        case 1:
            self = [self initWithImageNamed:@"Blue"];
            break;
        case 2:
            self = [self initWithImageNamed:@"Green"];
            break;
            
        default:
            break;
    }
    self.ballColour = c;
    self.explosionTimer = [[NSDate date] timeIntervalSinceReferenceDate];
    self.isFullBall = NO;
    
    self.size = CGSizeMake(30.0, 30.0);
    
    self.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:15.0];
    self.physicsBody.affectedByGravity = NO;
    self.physicsBody.restitution = 1.0;
    
    self.physicsBody.categoryBitMask = 4;
    self.physicsBody.contactTestBitMask = 0;
    
    return self;
}

// Turn a pod into a ball
-(void) podToBall
{
    [self runAction:[SKAction resizeToWidth:100.0 height:100.0 duration:0.3]];
    //self.size = CGSizeMake(100.0, 100.0);
    self.isFullBall = YES;
    CGVector v = self.physicsBody.velocity;
    // Add a new physics body
    self.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:50.0];
    self.physicsBody.affectedByGravity = NO;
    self.physicsBody.restitution = 1.0;
    self.physicsBody.categoryBitMask = 2;
    self.physicsBody.contactTestBitMask = 2;
    // Fuck you, Newton
    self.physicsBody.velocity = v;
    
    // Start pulse effect on ball
    [self pulseBall];
    
}

// Do a couple of loops of the pulsing animation based on age of ball
-(void) pulseBall
{
    CFTimeInterval timeAlive = [[NSDate date] timeIntervalSinceReferenceDate] - self.explosionTimer;
    CFTimeInterval pulseDuration = 0.4 * (60 - timeAlive)/60 + 0.05;
//    NSLog(@"Time: %f Pulse Duration %f",timeAlive,pulseDuration);
    uint cycles = ceil(0.5/pulseDuration);
    //NSLog(@"Cycles %d",cycles);
    //Tidy this up so code is called less often at higher blink rates
    SKAction *pulseBall = [SKAction repeatAction:[SKAction sequence:@[[SKAction scaleTo:1.1 duration:pulseDuration],
                                                                          [SKAction scaleTo:0.9 duration:pulseDuration]]]
                                                                     count:cycles];
    SKAction *completePulse = [SKAction sequence:@[pulseBall, [SKAction performSelector:@selector(pulseBall) onTarget:self]]];
    [self runAction:completePulse];
}

@end
