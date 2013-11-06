//
//  Ball.m
//  Ballpit
//
//  Created by Richard Smith on 05/11/2013.
//  Copyright (c) 2013 Richard Smith. All rights reserved.
//

#import "Ball.h"

@implementation Ball

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
    
    
    return self;
}

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

-(void) podToBall
{
    self.size = CGSizeMake(100.0, 100.0);
    self.isFullBall = YES;
    CGVector v = self.physicsBody.velocity;

    self.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:50.0];
    self.physicsBody.affectedByGravity = NO;
    self.physicsBody.restitution = 1.0;
    self.physicsBody.categoryBitMask = 2;
    self.physicsBody.contactTestBitMask = 2;
    
    self.physicsBody.velocity = v;
    
}

@end
