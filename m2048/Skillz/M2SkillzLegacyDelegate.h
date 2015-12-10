//
//  M2SkillzLegacyDelegate.h
//  m2048
//
//  Created by TJ Fallon on 12/10/15.
//
//

#import <Foundation/Foundation.h>

@interface M2SkillzLegacyDelegate : NSObject

+ (BOOL)canLoadSkillz;
+ (void)loadSkillz;

+ (void)initializeSkillz;
+ (void)launchSkillz;

+ (void)notifyPlayerAbortWithCompletion:(void (^)(void))completion;
+ (void)displayTournamentResultsWithScore:(NSNumber *)score withCompletion:(void (^)(void))completion;
+ (BOOL)isTournamentInProgress;

+ (void)updatePlayersCurrentScore:(NSNumber *)currentScoreForPlayer;
+ (NSInteger)getRandomNumberWithMin:(NSInteger)min andMax:(NSInteger)max;

@end
