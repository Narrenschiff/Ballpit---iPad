//
//  AppConstants.h
//  Ballpit
//
//  Created by Richard Smith on 04/02/2014.
//  Copyright (c) 2014 Richard Smith. All rights reserved.
//

#ifndef Ballpit_AppConstants_h
#define Ballpit_AppConstants_h

#define THRUSTSCALE 3.0
#define POD_SCORE 100
#define COLLISION_SCORE 500
#define LEVEL_SCORE 1000
#define EXPLOSION_PENALTY 34
#define POD_ENERGY 15

#define POD_TIME 10
#define EXPLOSION_TIME 60
#define REFRACTORY_TIME 0.3

static const NSUInteger shipCategoryBitmask = 1;
static const NSUInteger ballCategoryBitmask = 2;
static const NSUInteger podCategoryBitmask = 4;
static const NSUInteger boundaryCategoryBitmask = 8;


#endif
