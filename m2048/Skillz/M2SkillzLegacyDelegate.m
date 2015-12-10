//
//  M2SkillzLegacyDelegate.m
//  m2048
//
//  Created by TJ Fallon on 12/10/15.
//
//

#import "M2SkillzLegacyDelegate.h"
#import "M2ViewController.h"

#include <dlfcn.h>

typedef NS_ENUM (NSInteger, SkillzOrientation) {
    M2SkillzPortrait,
    M2SkillzLandscape
};

@implementation M2SkillzLegacyDelegate

+ (id)sharedInstance
{
    __block M2SkillzLegacyDelegate *_sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[M2SkillzLegacyDelegate alloc] init];
    });

    return _sharedInstance;
}

+ (BOOL)canLoadSkillz
{
    return (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_7_1);
}

+ (void)loadSkillz
{
    NSLog(@"Skillz class should be null: %@", NSClassFromString(@"Skillz"));
    dlopen("Skillz.framework/Skillz", RTLD_NOW); //Perform linking

    if (!NSClassFromString(@"Skillz")) {
        NSLog(@"Skillz load error: %s" , dlerror());
    } else {
        NSLog(@"Skillz loaded successfully %@", NSClassFromString(@"Skillz"));
    }
}

#pragma mark SkillzDelegate

- (void)tournamentWillBegin:(NSDictionary *)gameParameters
              withMatchInfo:(id *)matchInfo
{
    M2ViewController *vc = (M2ViewController *)[[[UIApplication sharedApplication] keyWindow] rootViewController];
    [vc startNewGame];
}

- (void)skillzWillExit
{
    M2ViewController *vc = (M2ViewController *)[[[UIApplication sharedApplication] keyWindow] rootViewController];
    [vc restart:nil];
}

- (NSInteger)preferredSkillzInterfaceOrientation
{
    return M2SkillzPortrait;
}


#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"

#pragma mark Legacy Skillz Usage


+ (void)initializeSkillz
{
    if ([self canLoadSkillz]) {
        Class Skillz = NSClassFromString(@"Skillz");
        id skillzInstance = [Skillz performSelector:@selector(skillzInstance)];

        NSMethodSignature *signature = [skillzInstance methodSignatureForSelector:@selector(initWithGameId:forDelegate:withEnvironment:)];
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
        [invocation setTarget:skillzInstance];
        [invocation setSelector:@selector(initWithGameId:forDelegate:withEnvironment:)];

        NSInteger environment;
#ifdef RELEASE
        environment = 0 /* SkillzProduction */;
#else
        environment = 1 /* SkillzSandbox */;
#endif

        id delegate = [M2SkillzLegacyDelegate sharedInstance];
        NSString *gameId = @"1494";

        [invocation setArgument:&gameId atIndex:2];
        [invocation setArgument:&delegate atIndex:3];
        [invocation setArgument:&environment atIndex:4];
        [invocation invoke];
    }
}

+ (void)launchSkillz
{
    Class Skillz = NSClassFromString(@"Skillz");
    id skillzInstance = [Skillz performSelector:@selector(skillzInstance)];
    [skillzInstance performSelector:@selector(launchSkillz)];
}

+ (void)notifyPlayerAbortWithCompletion:(void (^)(void))completion
{
    Class Skillz = NSClassFromString(@"Skillz");
    id skillzInstance = [Skillz performSelector:@selector(skillzInstance)];
    [skillzInstance performSelector:@selector(notifyPlayerAbortWithCompletion:)
                         withObject:[completion copy]];
}

+ (void)displayTournamentResultsWithScore:(NSNumber *)score withCompletion:(void (^)(void))completion
{
    Class Skillz = NSClassFromString(@"Skillz");
    id skillzInstance = [Skillz performSelector:@selector(skillzInstance)];
    [skillzInstance performSelector:@selector(displayTournamentResultsWithScore:withCompletion:)
                         withObject:score
                         withObject:[completion copy]];
}

+ (BOOL)isTournamentInProgress
{
    if ([self canLoadSkillz]) {
        Class Skillz = NSClassFromString(@"Skillz");
        id skillzInstance = [Skillz performSelector:@selector(skillzInstance)];

        NSMethodSignature *signature = [skillzInstance methodSignatureForSelector:@selector(tournamentIsInProgress)];
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
        [invocation setTarget:skillzInstance];
        [invocation setSelector:@selector(tournamentIsInProgress)];
        [invocation invoke];

        BOOL isTournamentInProgress;
        [invocation getReturnValue:&isTournamentInProgress];

        return isTournamentInProgress;
    } else {
        return NO;
    }
}

+ (void)updatePlayersCurrentScore:(NSNumber *)currentScoreForPlayer
{
    if ([self canLoadSkillz]) {
        Class Skillz = NSClassFromString(@"Skillz");
        id skillzInstance = [Skillz performSelector:@selector(skillzInstance)];
        [skillzInstance performSelector:@selector(updatePlayersCurrentScore:)
                             withObject:currentScoreForPlayer];
    }
}

+ (NSInteger)getRandomNumberWithMin:(NSInteger)min andMax:(NSInteger)max
{
    if ([self canLoadSkillz]) {
        Class Skillz = NSClassFromString(@"Skillz");

        NSMethodSignature *signature = [Skillz methodSignatureForSelector:@selector(getRandomNumberWithMin:andMax:)];
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
        [invocation setTarget:Skillz];
        [invocation setSelector:@selector(getRandomNumberWithMin:andMax:)];

        [invocation setArgument:&min atIndex:2];
        [invocation setArgument:&max atIndex:3];
        [invocation invoke];
        
        NSInteger randomNumber;
        [invocation getReturnValue:&randomNumber];
        
        return randomNumber;
    } else {
        return 0;
    }
}

#pragma clang diagnostic pop

@end
