//
//  DMWelcomeStepController.h
//  DevMateActivations
//
//  Copyright (c) 2012-2018 DevMate Inc. All rights reserved.
//

#import <DevMateKit/DMStepController.h>

@interface DMWelcomeStepController : DMStepController

@property (nonatomic, assign) IBOutlet NSTextField *welcomeDescriptionField;
@property (nonatomic, assign) IBOutlet NSButton *continueButton;
@property (nonatomic, assign) IBOutlet NSButton *cancelButton;
@property (nonatomic, assign) IBOutlet NSButton *getLicenseButton;
@property (nonatomic, assign) IBOutlet NSButton *webStoreButton DM_DEPRECATED("Does not present in UI anymore.");

- (IBAction)continueActivation:(id)sender;
- (IBAction)cancelActivation:(id)sender;

//! By default action will open https://devmate.io/gostore/... webpage
- (IBAction)openWebStore:(id)sender;

//! Will open embedded FastSpring store if delegate implements necessary methods or just call -openWebStore: method
- (IBAction)getLicense:(id)sender;

@end
