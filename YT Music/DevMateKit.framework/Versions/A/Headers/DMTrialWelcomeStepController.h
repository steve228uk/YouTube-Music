//
//  DMTrialWelcomeStepController.h
//  DevMateActivations
//
//  Copyright (c) 2014-2018 DevMate Inc. All rights reserved.
//

#import <DevMateKit/DMWelcomeStepController.h>

@interface DMTrialWelcomeStepController : DMWelcomeStepController

@property (nonatomic, assign) IBOutlet NSButton *startUsingAppButton;

- (IBAction)startUsingApp:(id)sender;

@end
