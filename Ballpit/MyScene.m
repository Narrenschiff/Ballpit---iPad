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
#define POD_SCORE 100
#define COLLISION_SCORE 500
#define LEVEL_SCORE 1000
#define EXPLOSION_PENALTY 34
#define POD_ENERGY 15


@implementation MyScene

SKSpriteNode *ship;
SKNode *balls;
CGPoint thrustLocation;
BOOL thrustIsEngaged;
NSMutableArray *podsToAdd;
NSMutableArray *chingsToAdd;
CFTimeInterval respawnCounter;
uint score;
int energy;
uint ching;
BOOL isDead;

-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        
        self.backgroundColor = [SKColor colorWithRed:0.15 green:0.15 blue:0.3 alpha:1.0];
        
        // Node to which all balls are added
        balls = [[SKNode alloc] init];
        
        // Create ship node
        ship = [SKSpriteNode spriteNodeWithImageNamed:@"Ship"];
        ship.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:45.0];
        ship.physicsBody.affectedByGravity = NO;
        ship.physicsBody.categoryBitMask = 1;
        ship.physicsBody.contactTestBitMask = 4;

        
        // Add balls to playfield
        [self addChild:balls];
        
        // Set up boundaries on screen
        SKNode *edge = [[SKNode alloc] init];
        edge.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
        [self addChild:edge];
        edge.physicsBody.categoryBitMask = 8;
        
        // Set up contact delegate for processing collisions
        self.scene.physicsWorld.contactDelegate = self;
        
        // Set random number seed
        srand (time(NULL));
        
        // Lay out levels and add ship
        [self newGame];
        
        // Allocate array for pods to be added after collisions
        podsToAdd = [[NSMutableArray alloc] init];
    }
    return self;
}

// Create a ball pit with some balls in to play with
-(void) layoutBallPit
{
    respawnCounter = 0;
    for (uint i = 0; i<10; i++){
        Ball *ball = [[Ball alloc] initWithBallColour:rand() % 3];
        ball.position = CGPointMake((float)rand()/(float)(RAND_MAX / self.frame.size.width), (float)rand()/(float)(RAND_MAX / self.frame.size.height));
        
        [balls addChild:ball];
    }
}

-(void) killBallPit
{
    // Nuke all extant balls.
    for (Ball *b in balls.children) {
        b.explosionTimer = [[NSDate date] timeIntervalSinceReferenceDate] - EXPLOSION_TIME + 1.0;
        b.isFullBall = YES;
    }
    
    // And kill any pods in the pipeline, too.
    podsToAdd = [[NSMutableArray alloc] init];
}

-(void) shipAppears
{
    ship.position = CGPointMake(CGRectGetMidX(self.frame),CGRectGetMidY(self.frame));
    [self addChild:ship];
}

-(void) shipExplodes
{
    [self gameOverLabel];
    isDead = YES;
    SKEmitterNode *explosion = [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle] pathForResource:@"Explode" ofType:@"sks"]];
    explosion.position = ship.position;
    explosion.numParticlesToEmit = 80;
    [explosion runAction:[SKAction sequence:@[[SKAction waitForDuration:4], [SKAction removeFromParent]]]];
    [self addChild:explosion];
    [ship removeFromParent];
    [self killBallPit];
}

-(void) newGame
{
    [self layoutBallPit];
    [self shipAppears];
    score = 0;
    energy = 100;
    isDead = NO;
    ching = 0;
    chingsToAdd = [[NSMutableArray alloc] init];
}

-(void) gameOverLabel
{
    SKLabelNode *gameOver = [SKLabelNode labelNodeWithFontNamed:@"HelveticaNeue-LightItalic"];
    gameOver.text = @"Game Over, loser.";
    gameOver.position = CGPointMake(CGRectGetMidX(self.frame),CGRectGetMidY(self.frame));
    gameOver.color = [UIColor whiteColor];
    gameOver.fontSize = 70;
    [self addChild:gameOver];
    [gameOver runAction:[SKAction sequence:@[[SKAction waitForDuration:2],
                                             [SKAction fadeAlphaTo:0 duration:1],
                                             [SKAction removeFromParent]]]];
}

-(void) levelUpLabel
{
    SKLabelNode *levelUp = [SKLabelNode labelNodeWithFontNamed:@"HelveticaNeue-Light"];
    levelUp.text = @"Level Up!";
    levelUp.position = CGPointMake(CGRectGetMidX(self.frame),CGRectGetMidY(self.frame));
    levelUp.color = [UIColor whiteColor];
    levelUp.fontSize = 70;
    [self addChild:levelUp];
    [levelUp runAction:[SKAction group:@[[SKAction scaleTo:10 duration:2],
                                         [SKAction sequence:@[[SKAction fadeAlphaTo:0 duration:2],
                                             [SKAction removeFromParent]]]]]];
}

-(void) chingLabelAtPosition:(CGPoint) p
{
    if (ching<2) return;
    NSString *chingText;
    switch (ching) {
        case 2:
            chingText = @"Nice! x2";
            score += COLLISION_SCORE;
            break;
        case 3:
            chingText = @"Great! x4";
            score += COLLISION_SCORE * 3;
            break;
        case 4:
            chingText = @"BLAZIN'! x6";
            score += COLLISION_SCORE * 5;
            break;
        default:
            chingText = @"HAIL SATAN x10";
            score += COLLISION_SCORE * 9;
            break;
    }
    
    SKLabelNode *chingLabel = [SKLabelNode labelNodeWithFontNamed:@"HelveticaNeue-CondensedBlack"];
    chingLabel.text = chingText;
    chingLabel.position = p;
    chingLabel.fontColor = ching >= 4 ? [UIColor redColor] : [UIColor yellowColor];
    chingLabel.fontSize = 30;
    [chingsToAdd addObject:chingLabel];
    [chingLabel runAction:[SKAction group:@[[SKAction scaleTo:4 duration:2],
                                         [SKAction sequence:@[[SKAction fadeAlphaTo:0 duration:2],
                                                              [SKAction removeFromParent]]]]]];
    
}

// Generate an impulse on ship towards a point
-(void)shipThrustToPoint
{
    CGFloat xThrust = (thrustLocation.x - ship.position.x) / THRUSTSCALE;
    CGFloat yThrust = (thrustLocation.y - ship.position.y) / THRUSTSCALE;
    CGVector thrustVector = CGVectorMake(xThrust, yThrust);
    [ship.physicsBody applyForce:thrustVector];
    ship.zRotation = atan2f(-xThrust, yThrust);
}


#pragma mark touch controls

// Detect touches in play, set a location for ship to fly towards and then set thrustIsEngaged flag
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

#pragma mark Points in scene rendering

-(void)didEvaluateActions
{
    // Thrust towards ship if touch is in effect
    if (thrustIsEngaged) [self shipThrustToPoint];
}

-(void)didSimulatePhysics
{
    // Add pods to playfield
    // (adding sprites while physics is being evaluated is buggy)
    if ([podsToAdd count] > 0) {
        for (Ball *b in podsToAdd) {
            [balls addChild:b];
        }
        podsToAdd = [[NSMutableArray alloc] init];
    }

    // Add chings
    if ([chingsToAdd count] > 0) {
        for (SKNode *n in chingsToAdd) {
            [self addChild:n];
        }
        chingsToAdd = [[NSMutableArray alloc] init];
    }
    
    
    //Don't let the sprites rotate even though they have angular momentum
    for (SKNode *n in balls.children) {
        n.zRotation = 0;
    }
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
    
    self.scoreLabel.text = [NSString stringWithFormat:@"%08d",score];
    self.energyLabel.text = [NSString stringWithFormat:@"%d",energy];
    
    // Die if we're out of energy and not already dead
    if (energy <= 0) {
        if (!isDead) {
            [self shipExplodes];
            respawnCounter = currentTime + 3;
            return;
        }
    }
    
    // If there's no balls left, wait a while and spawn some new ones
    if ([balls.children count] == 0){
        if (respawnCounter == 0) {
            respawnCounter = currentTime;
        }else{
            if (currentTime - respawnCounter > 3) {
                if (isDead) {
                    // New game if dead
                    [self newGame];
                }else{
                    // Otherwise new level
                    [self layoutBallPit];
                    score += LEVEL_SCORE;
                    [self levelUpLabel];
                }
            }
        }
        return;
    }
    
    // If there's just one ball left, blow it up.
    if ([balls.children count] == 1){
        Ball *b = [balls.children objectAtIndex:0];
        if (b.isFullBall == YES && respawnCounter  == 0){
            // Start respawn counter ticking
            respawnCounter = currentTime;
            // Give last ball one second to blow
            b.explosionTimer = [[NSDate date] timeIntervalSinceReferenceDate] - EXPLOSION_TIME + 1.0;
            return;
        }
    }
    
    // Check to see if balls need to be altered according to their age
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
                SKEmitterNode *explosion = [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle] pathForResource:@"Explode" ofType:@"sks"]];
                explosion.position = b.position;
                explosion.numParticlesToEmit = 20;
                [b removeFromParent];
                [explosion runAction:[SKAction sequence:@[[SKAction waitForDuration:3], [SKAction removeFromParent]]]];
                [self addChild:explosion];
                energy -= EXPLOSION_PENALTY;
                energy = energy < 0 ? 0 : energy;

                // Lose combo
                ching = 0;
            }
        }
    }
}

#pragma mark collision delegate

- (void)didBeginContact:(SKPhysicsContact *)contact {
    
    BOOL bodyAIsBall = [contact.bodyA.node isKindOfClass:[Ball class]];
    BOOL bodyBIsBall = [contact.bodyB.node isKindOfClass:[Ball class]];
    
    // Check to see if it's a ball-on-ball collision
    if (bodyAIsBall && bodyBIsBall){
        Ball *a = (Ball *)contact.bodyA.node;
        Ball *b = (Ball *)contact.bodyB.node;
        
        if (a.ballColour == b.ballColour){
            // If they're the same colour, remove from field
            SKAction *removeSequence = [SKAction sequence:@[[SKAction scaleTo:0 duration:0.2], [SKAction removeFromParent] ]];
            [a runAction:removeSequence];
            [b runAction:removeSequence];
            score += COLLISION_SCORE;
            ching++;
            [self chingLabelAtPosition:contact.contactPoint];
        }else{
            // Otherwise spawn a pod
            // Add refractory period to stop too many pods being created
            CFTimeInterval currentTimeSinceReferenceDate = [[NSDate date] timeIntervalSinceReferenceDate];
            if ((currentTimeSinceReferenceDate - a.refractoryTimer < REFRACTORY_TIME) ||
                (currentTimeSinceReferenceDate - b.refractoryTimer < REFRACTORY_TIME)) return;
            b.refractoryTimer = currentTimeSinceReferenceDate;
            a.refractoryTimer = currentTimeSinceReferenceDate;
            
            // Generate pod of different colour to parents
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
            
            // Pod will appear at contact point
            pod.position = contact.contactPoint;
            
            // Add to an array to be added later, as adding sprites during the physics update is buggy
            [podsToAdd addObject:pod];
            
            // Lose combo
            ching = 0;
        }
    }else{
        // If it's not a ball-on-ball, it must be pod-on-ship. Remove pod.
        if (bodyAIsBall) [contact.bodyA.node removeFromParent];
        if (bodyBIsBall) [contact.bodyB.node removeFromParent];
        score += POD_SCORE;
        energy += POD_ENERGY;
        energy = energy > 100 ? 100 : energy;
        
        // Lose combo
        ching = 0;
    }
}

@end
