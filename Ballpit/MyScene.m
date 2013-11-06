//
//  MyScene.m
//  Ballpit
//
//  Created by Richard Smith on 05/11/2013.
//  Copyright (c) 2013 Richard Smith. All rights reserved.
//

#import "MyScene.h"
#import "Ball.h"
#define THRUSTSCALE 3.0
#define REFRACTORY_TIME 0.2
#define POD_TIME 10
#define EXPLOSION_TIME 60


@implementation MyScene

SKSpriteNode *ship;
SKNode *balls;
CGPoint thrustLocation;
BOOL thrustIsEngaged;
NSMutableArray *podsToAdd;

-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        
        self.backgroundColor = [SKColor colorWithRed:0.15 green:0.15 blue:0.3 alpha:1.0];
        
        balls = [[SKNode alloc] init];
        ship = [SKSpriteNode spriteNodeWithImageNamed:@"Ship"];
        ship.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:45.0];
        ship.physicsBody.affectedByGravity = NO;
        ship.physicsBody.categoryBitMask = 1;
        ship.physicsBody.contactTestBitMask = 4;
        
        [self addChild:balls];
        [self addChild:ship];
        
        ship.position = CGPointMake(CGRectGetMidX(self.frame),CGRectGetMidY(self.frame));
        
        SKNode *edge = [[SKNode alloc] init];
        edge.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
        [self addChild:edge];
        edge.physicsBody.categoryBitMask = 8;
        
        self.scene.physicsWorld.contactDelegate = self;
        
        for (uint i = 0; i<10; i++){
            Ball *ball = [[Ball alloc] initWithBallColour:rand() % 3];
            ball.position = CGPointMake((float)rand()/(float)(RAND_MAX / self.frame.size.width), (float)rand()/(float)(RAND_MAX / self.frame.size.height));

            [balls addChild:ball];
        }
        
        podsToAdd = [[NSMutableArray alloc] init];
    }
    return self;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    
    thrustIsEngaged = NO;
    
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInNode:self];
        
        if (touch.phase == UITouchPhaseBegan || touch.phase == UITouchPhaseMoved){
            thrustLocation = location;
            thrustIsEngaged = YES;
        }
    }
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    thrustIsEngaged = NO;
    for (UITouch *touch in touches) {
        if (touch.phase == UITouchPhaseBegan || touch.phase == UITouchPhaseMoved){
            thrustLocation = [touch locationInNode:self];
            thrustIsEngaged = YES;
        }
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    thrustIsEngaged = NO;
    for (UITouch *touch in touches) {
        if (touch.phase == UITouchPhaseBegan || touch.phase == UITouchPhaseMoved){
            thrustLocation = [touch locationInNode:self];
            thrustIsEngaged = YES;
        }
    }
}

-(void)shipThrustToPoint
{
    CGFloat xThrust = (thrustLocation.x - ship.position.x) / THRUSTSCALE;
    CGFloat yThrust = (thrustLocation.y - ship.position.y) / THRUSTSCALE;
    CGVector thrustVector = CGVectorMake(xThrust, yThrust);
    [ship.physicsBody applyForce:thrustVector];
    ship.zRotation = atan2f(-xThrust, yThrust);
}

-(void)didEvaluateActions
{
    if (thrustIsEngaged) [self shipThrustToPoint];
}

-(void)didSimulatePhysics
{
    if ([podsToAdd count] > 0) {
        for (Ball *b in podsToAdd) {
            [balls addChild:b];
        }
        podsToAdd = [[NSMutableArray alloc] init];
    }

    //Don't let the sprites rotate even though they have angular momentum
    for (SKNode *n in balls.children) {
        n.zRotation = 0;
    }
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
    CFTimeInterval currentTimeSinceReferenceDate = [[NSDate date] timeIntervalSinceReferenceDate];
    for (Ball *b in balls.children) {
        // Check if pod needs to become a ball
        if (b.isFullBall == NO) {
            // Check if pod needs to become a ball
            if (currentTimeSinceReferenceDate - b.explosionTimer > POD_TIME){
                [b podToBall];
            }
        }else{
            // Check if ball explodes
            if (currentTimeSinceReferenceDate - b.explosionTimer > EXPLOSION_TIME){
                [b removeFromParent];
            }
        }
    }
}

#pragma mark collision delegate

- (void)didBeginContact:(SKPhysicsContact *)contact {
    
    BOOL bodyAIsBall = [contact.bodyA.node isKindOfClass:[Ball class]];
    BOOL bodyBIsBall = [contact.bodyB.node isKindOfClass:[Ball class]];
    
    if (bodyAIsBall && bodyBIsBall){
    Ball *a = (Ball *)contact.bodyA.node;
    Ball *b = (Ball *)contact.bodyB.node;
    
    if (a.ballColour == b.ballColour){
        [a removeFromParent];
        [b removeFromParent];
    }else{
        CFTimeInterval currentTimeSinceReferenceDate = [[NSDate date] timeIntervalSinceReferenceDate];
        if ((currentTimeSinceReferenceDate - a.refractoryTimer < REFRACTORY_TIME) ||
            (currentTimeSinceReferenceDate - b.refractoryTimer < REFRACTORY_TIME)) return;
        b.refractoryTimer = currentTimeSinceReferenceDate;
        a.refractoryTimer = currentTimeSinceReferenceDate;
        Ball *pod;
        switch (a.ballColour + b.ballColour) {
            case 1:
                pod = [[Ball alloc] initPodWithColour:2];
                break;
            case 2:
                pod = [[Ball alloc] initPodWithColour:1];
                break;
            case 3:
                pod = [[Ball alloc] initPodWithColour:0];
                break;
            default:
                break;
        }
        pod.position = contact.contactPoint;
        [podsToAdd addObject:pod];
    }
    }else{
        if (bodyAIsBall) [contact.bodyA.node removeFromParent];
        if (bodyBIsBall) [contact.bodyB.node removeFromParent];
    }
}

@end
