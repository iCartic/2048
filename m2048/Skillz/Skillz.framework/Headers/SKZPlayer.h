//
//  SKZPlayer.h
//  SkillzSDK-iOS
//
//  Created by James McMahon on 6/10/15.
//  Copyright (c) 2015 Skillz. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * Represents data for the current logged in player
 */
@interface SKZPlayer : NSObject

/**
 * Player's unique id
 */
@property (readonly) NSString *id;

/**
 * Player's profile picture (or avatar) URL
 */
@property (readonly) NSString *avatarURL;

/**
 *  Player's display name
 */
@property (readonly) NSString *displayName;

/**
 *  URL for the flag for the player
 */
@property (readonly) NSString *flagURL;

@end
