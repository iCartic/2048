//
//  M2AppDelegate.m
//  m2048
//
//  Created by Danqing on 3/16/14.
//  Copyright (c) 2014 Danqing. All rights reserved.
//

#import "M2AppDelegate.h"
#import "M2ViewController.h"
#import <Skillz/Skillz.h>

@interface M2AppDelegate () <SkillzDelegate>

@end

@implementation M2AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[Skillz skillzInstance] initWithGameId:@"1494"
                                forDelegate:self
                            withEnvironment:SkillzSandbox
                                  allowExit:NO];

    [[Skillz skillzInstance] launchSkillz];

    return YES;
}

- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    return UIInterfaceOrientationMaskPortrait;
}

- (M2ViewController *)gameViewController
{
    return (M2ViewController *)[[[UIApplication sharedApplication] keyWindow] rootViewController];
}

#pragma mark Skillz Delegate

- (SkillzOrientation)preferredSkillzInterfaceOrientation
{
    return SkillzPortrait;
}

- (void)tournamentWillBegin:(NSDictionary *)gameParameters
              withMatchInfo:(SKZMatchInfo *)matchInfo
{
    [[self gameViewController] startNewGame];
}

@end
