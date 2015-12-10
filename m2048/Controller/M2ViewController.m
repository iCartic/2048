//
//  M2ViewController.m
//  m2048
//
//  Created by Danqing on 3/16/14.
//  Copyright (c) 2014 Danqing. All rights reserved.
//

#import "M2ViewController.h"
#import "M2Scene.h"
#import "M2GameManager.h"
#import "M2ScoreView.h"
#import "M2Overlay.h"
#import "M2GridView.h"
#import "M2SkillzLegacyDelegate.h"

@interface M2ViewController ()

@property (nonatomic, weak) IBOutlet UIButton *restartButton;
@property (nonatomic, weak) IBOutlet UILabel *timerLabel;
@property (nonatomic, weak) IBOutlet UILabel *targetScore;
@property (nonatomic, weak) IBOutlet UILabel *subtitle;
@property (nonatomic, weak) IBOutlet M2ScoreView *scoreView;
@property (nonatomic, weak) IBOutlet M2ScoreView *bestView;
@property (nonatomic, weak) IBOutlet M2Overlay *overlay;
@property (nonatomic, weak) IBOutlet UIImageView *overlayBackground;
@property (nonatomic, strong) NSTimer *skillzTimer;
@property (nonatomic, strong) M2Scene *scene;

@end

@implementation M2ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self updateState];

    self.bestView.score.text = [NSString stringWithFormat:@"%ld", (long)[Settings integerForKey:@"Best Score"]];

    self.restartButton.layer.cornerRadius = [GSTATE cornerRadius];
    self.restartButton.layer.masksToBounds = YES;
    self.timerLabel.layer.cornerRadius = [GSTATE cornerRadius];
    self.timerLabel.layer.masksToBounds = YES;

    self.overlay.hidden = YES;
    self.overlayBackground.hidden = YES;

    // Configure the view.
    SKView *skView = (SKView *)self.view;

    // Create and configure the scene.
    M2Scene *scene = [M2Scene sceneWithSize:skView.bounds.size];
    scene.scaleMode = SKSceneScaleModeAspectFill;

    // Present the scene.
    [skView presentScene:scene];
    [self updateScore:0];

    if ([M2SkillzLegacyDelegate canLoadSkillz]) {
        [M2SkillzLegacyDelegate launchSkillz];
    }

    [self.timerLabel setHidden:YES];

    self.scene = scene;
    self.scene.controller = self;
}

- (void)startNewGame
{
    [self.timerLabel setText:@":90"];
    [self.timerLabel setHidden:NO];

    [self.skillzTimer invalidate];
    self.skillzTimer = [NSTimer scheduledTimerWithTimeInterval:1
                                                        target:self
                                                      selector:@selector(updateCountdown)
                                                      userInfo:nil
                                                       repeats:YES];
    [self.scene startNewGame];
}

- (void)updateCountdown
{
    NSInteger currentTime = [[self.timerLabel.text substringFromIndex:1] integerValue];
    if (currentTime == 0) {
        [self.skillzTimer invalidate];
        self.skillzTimer = nil;

        [self endGame:YES];
    } else {
        [self.timerLabel setText:[NSString stringWithFormat:@":%ld", (long)(currentTime - 1)]];
    }
}


- (void)updateState
{
    [self.scoreView updateAppearance];
    [self.bestView updateAppearance];

    self.restartButton.backgroundColor = [GSTATE buttonColor];
    self.restartButton.titleLabel.font = [UIFont fontWithName:[GSTATE boldFontName] size:14];
    self.timerLabel.backgroundColor = [GSTATE buttonColor];

    self.targetScore.textColor = [GSTATE buttonColor];

    long target = [GSTATE valueForLevel:GSTATE.winningLevel];

    if (target > 100000) {
        self.targetScore.font = [UIFont fontWithName:[GSTATE boldFontName] size:34];
    } else if (target < 10000) {
        self.targetScore.font = [UIFont fontWithName:[GSTATE boldFontName] size:42];
    } else {
        self.targetScore.font = [UIFont fontWithName:[GSTATE boldFontName] size:40];
    }

    self.targetScore.text = [NSString stringWithFormat:@"%ld", target];

    self.subtitle.textColor = [GSTATE buttonColor];
    self.subtitle.font = [UIFont fontWithName:[GSTATE regularFontName] size:14];
    self.subtitle.text = [NSString stringWithFormat:@"Join the numbers to get to %ld!", target];

    self.overlay.message.font = [UIFont fontWithName:[GSTATE boldFontName] size:36];
    self.overlay.keepPlaying.titleLabel.font = [UIFont fontWithName:[GSTATE boldFontName] size:17];
    self.overlay.restartGame.titleLabel.font = [UIFont fontWithName:[GSTATE boldFontName] size:17];

    self.overlay.message.textColor = [GSTATE buttonColor];
    [self.overlay.keepPlaying setTitleColor:[GSTATE buttonColor] forState:UIControlStateNormal];
    [self.overlay.restartGame setTitleColor:[GSTATE buttonColor] forState:UIControlStateNormal];
}


- (void)updateScore:(NSInteger)score
{
    self.scoreView.score.text = [NSString stringWithFormat:@"%ld", (long)score];
    if ([M2SkillzLegacyDelegate isTournamentInProgress]) {
        [M2SkillzLegacyDelegate updatePlayersCurrentScore:@(score)];
    }
    if ([Settings integerForKey:@"Best Score"] < score) {
        [Settings setInteger:score forKey:@"Best Score"];
        self.bestView.score.text = [NSString stringWithFormat:@"%ld", (long)score];
    }
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Pause Sprite Kit. Otherwise the dismissal of the modal view would lag.
    ((SKView *)self.view).paused = YES;
}


- (IBAction)restart:(id)sender
{
    if ([M2SkillzLegacyDelegate isTournamentInProgress]) {
        UIAlertView *alertForfeit = [[UIAlertView alloc] initWithTitle:@"Are you sure you want to forfeit?"
                                                               message:@""
                                                              delegate:self
                                                     cancelButtonTitle:@"Yes"
                                                     otherButtonTitles:@"No", nil];
        [alertForfeit show];
    } else {
        [self hideOverlay];
        [self updateScore:0];
        [self.scene startNewGame];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (!buttonIndex) {
        NSLog(@"Yes was selected.");
        [M2SkillzLegacyDelegate notifyPlayerAbortWithCompletion:^(){
            NSLog(@"Player is forfeiting the game.");
        }];
    } else {
        NSLog(@"No was selected.");
    }
}


- (IBAction)keepPlaying:(id)sender
{
    [self hideOverlay];
}


- (IBAction)done:(UIStoryboardSegue *)segue
{
    ((SKView *)self.view).paused = NO;
    if (GSTATE.needRefresh) {
        [GSTATE loadGlobalState];
        [self updateState];
        [self updateScore:0];
        [self.scene startNewGame];
    }
}


- (void)endGame:(BOOL)won
{
    if([M2SkillzLegacyDelegate isTournamentInProgress]) {
        [self.timerLabel setHidden:YES];
        [M2SkillzLegacyDelegate displayTournamentResultsWithScore:@([self.scoreView.score.text integerValue])
                                                   withCompletion:^{
                                                       NSLog(@"Reporting score to Skillz...");
                                                   }];
    } else {
        self.overlay.hidden = NO;
        self.overlay.alpha = 0;
        self.overlayBackground.hidden = NO;
        self.overlayBackground.alpha = 0;

        if (!won) {
            self.overlay.keepPlaying.hidden = YES;
            self.overlay.message.text = @"Game Over";
        } else {
            self.overlay.keepPlaying.hidden = NO;
            self.overlay.message.text = @"You Win!";
        }

        // Fake the overlay background as a mask on the board.
        self.overlayBackground.image = [M2GridView gridImageWithOverlay];

        // Center the overlay in the board.
        CGFloat verticalOffset = [[UIScreen mainScreen] bounds].size.height - GSTATE.verticalOffset;
        NSInteger side = GSTATE.dimension * (GSTATE.tileSize + GSTATE.borderWidth) + GSTATE.borderWidth;
        self.overlay.center = CGPointMake(GSTATE.horizontalOffset + side / 2, verticalOffset - side / 2);

        [UIView animateWithDuration:0.5 delay:1.5 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.overlay.alpha = 1;
            self.overlayBackground.alpha = 1;
        } completion:^(BOOL finished) {
            // Freeze the current game.
            ((SKView *)self.view).paused = YES;
        }];
    }
}


- (void)hideOverlay
{
    ((SKView *)self.view).paused = NO;
    if (!self.overlay.hidden) {
        [UIView animateWithDuration:0.5 animations:^{
            self.overlay.alpha = 0;
            self.overlayBackground.alpha = 0;
        } completion:^(BOOL finished) {
            self.overlay.hidden = YES;
            self.overlayBackground.hidden = YES;
        }];
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

@end
