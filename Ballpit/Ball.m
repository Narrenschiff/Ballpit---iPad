//
//  Ball.m
//  Ballpit
//
//  Created by Richard Smith on 05/11/2013.
//  Copyright (c) 2013 Richard Smith. All rights reserved.
//

#import "Ball.h"
#import "MyScene.h"
#define POD_TIME 10
#define EXPLOSION_TIME 60
#define REFRACTORY_TIME 0.3


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
    
    // Explode after fixed time
    self.explosionCountdown = EXPLOSION_TIME;
    self.isFullBall = YES;
    
    self.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:50.0];
    self.physicsBody.affectedByGravity = NO;
    self.physicsBody.restitution = 1.0;
    
    self.physicsBody.categoryBitMask = 2;
    self.physicsBody.contactTestBitMask = 2;

    [self pulseBall];
    
    // Explode after fixed time
    [self runAction:[SKAction sequence:@[[SKAction waitForDuration:EXPLOSION_TIME],
                                         [SKAction performSelector:@selector(explodeSelf) onTarget:self]]]];
    
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
    self.isFullBall = NO;
    
    self.size = CGSizeMake(30.0, 30.0);
    
    self.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:15.0];
    self.physicsBody.affectedByGravity = NO;
    self.physicsBody.restitution = 1.0;
    
    self.physicsBody.categoryBitMask = 4;
    self.physicsBody.contactTestBitMask = 0;
    
    // Turn into a ball after a while
    [self runAction:[SKAction sequence:@[[SKAction waitForDuration:POD_TIME],
                                         [SKAction performSelector:@selector(podToBall) onTarget:self]]]];

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
    
    
    // Explode after fixed time
    self.explosionCountdown = EXPLOSION_TIME;
    
    // Start pulse effect on ball
    [self pulseBall];

    [self runAction:[SKAction sequence:@[[SKAction waitForDuration:EXPLOSION_TIME],
                                         [SKAction performSelector:@selector(explodeSelf) onTarget:self]]]];

    
}

// Do a couple of loops of the pulsing animation based on age of ball
-(void) pulseBall
{
    CFTimeInterval pulseDuration = 0.4 * self.explosionCountdown/EXPLOSION_TIME + 0.05;
//    NSLog(@"Time: %f Pulse Duration %f",timeAlive,pulseDuration);
    uint cycles = ceil(0.5/pulseDuration);
    self.explosionCountdown -= pulseDuration * cycles * 2;
    //NSLog(@"Countdown %f Duration %f",self.explosionCountdown, pulseDuration);
    //Tidy this up so code is called less often at higher blink rates
    SKAction *pulseBall = [SKAction repeatAction:[SKAction sequence:@[[SKAction scaleTo:1.1 duration:pulseDuration],
                                                                          [SKAction scaleTo:0.9 duration:pulseDuration]]]
                                                                     count:cycles];
    SKAction *completePulse = [SKAction sequence:@[pulseBall, [SKAction performSelector:@selector(pulseBall) onTarget:self]]];
    [self runAction:completePulse];
}


- (void) explodeSelf
{
    SKEmitterNode *explosion = [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle] pathForResource:@"Explode" ofType:@"sks"]];
    explosion.position = self.position;
    explosion.numParticlesToEmit = 20;
    explosion.particleColorBlendFactor = 1.0;
    explosion.particleColorBlendFactorSequence = nil;
    explosion.particleColorSequence = nil;
    switch (self.ballColour) {
        case 0:
            explosion.particleColor = [SKColor redColor];
            break;
        case 1:
            explosion.particleColor = [SKColor blueColor];
            break;
        case 2:
            explosion.particleColor = [SKColor greenColor];
            break;
            
        default:
            break;
    }
    [(MyScene *)self.scene explosionHasOccurred];
    
    [explosion runAction:[SKAction sequence:@[[SKAction waitForDuration:3], [SKAction removeFromParent]]]];
    [self.scene addChild:explosion];
    [self removeFromParent];

}


- (void) killSelfAfterSecond
{
    [self runAction:[SKAction sequence:@[[SKAction waitForDuration:1],
                               [SKAction performSelector:@selector(explodeSelf) onTarget:self]]]];
}

-(void) becomeRefractory
{
    self.isRefractory = YES;
    [self runAction:[SKAction sequence:@[[SKAction waitForDuration:REFRACTORY_TIME],
                                         [SKAction performSelector:@selector(becomeUnrefractory) onTarget:self]]]];
}
-(void) becomeUnrefractory;
{
    self.isRefractory = NO;
}
@end
