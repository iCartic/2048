//
//  SKZRoundResults.h
//  SkillzSDK-iOS
//
//  Created by teejay on 5/29/14.
//  Copyright (c) 2014 Skillz. All rights reserved.
//

#import "Skillz+TurnBased.h"

@interface SKZRoundResults : NSObject

/**
 *  The round that this information corresponds to. For the first round: roundNumber = 1
 */
@property (nonatomic) NSInteger roundNumber;

/**
 *  The score you've submitted for this round for the current player, will be displayed within the Skillz UI.
 */
@property (nonatomic, strong) NSString *playerScore;

/**
 *  The score you've submitted for this round for the current player's opponent, will be displayed within the Skillz UI.
 */
@property (nonatomic, strong) NSString *opponentScore;

/**
 *  This is the outcome you've specified for this round, this will be used to display results within the Skillz UI.
 */
@property (nonatomic) SKZTurnBasedRoundOutcome roundOutcome;

@end
