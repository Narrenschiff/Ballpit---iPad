//
//  MyScene.h
//  Ballpit
//

//  Copyright (c) 2013 Richard Smith. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface MyScene : SKScene <SKPhysicsContactDelegate>

@property UILabel *scoreLabel;
@property UILabel *energyLabel;

- (void) explosionHasOccurred;

@end
