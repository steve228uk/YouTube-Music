//
//  DMFailureStepController.h
//  DevMateActivations
//
//  Copyright (c) 2012-2018 DevMate Inc. All rights reserved.
//

#import <DevMateKit/DMStepController.h>

@interface DMFailureStepController : DMStepController

@property (retain) NSError *activationError;

@property (nonatomic, assign) IBOutlet NSTextField *errorDescriptionField;
@property (nonatomic, assign) IBOutlet NSButton *tryAgainButton;
@property (nonatomic, assign) IBOutlet NSButton *cancelButton;

- (IBAction)tryAgainActivation:(id)sender;
- (IBAction)cancelActivation:(id)sender;

@end
