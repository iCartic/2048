//
//  SKZMatchInfo.h
//  SkillzSDK-iOS
//
//  Created by James McMahon on 6/10/15.
//  Copyright (c) 2015 Skillz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SKZPlayer.h"

@interface SKZMatchInfo : NSObject

/**
 * Unique match id
 */
@property (readonly) NSInteger id;

/**
 * Match description as configured in the Skillz Developer Portal
 */
@property (readonly) NSString *matchDescription;

/**
 * Cash entry fee, nil if there is none
 */
@property (readonly) NSNumber *entryCash;

/**
 * Z points entry fee, nil if there is none
 */
@property (readonly) NSNumber *entryPoints;

/**
 * Signifies a cash match
 */
@property (readonly) BOOL isCash;

/**
 *  Match name as configured in the Skillz Developer Portal
 */
@property (readonly) NSString *name;

/**
 * Current player in match
 */
@property (readonly) SKZPlayer *player;

/**
 * Template id for the template that the match is based on. These templates are
 * configured in the Skillz Developer Portal
 */
@property (readonly) NSNumber *templateId;

@end
