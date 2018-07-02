//
//  DMDeactivationStepController.h
//  DevMateActivations
//
//  Copyright (c) 2015-2018 DevMate Inc. All rights reserved.
//

#import <DevMateKit/DMStepController.h>

@interface DMDeactivationStepController : DMStepController

@property (retain) NSError *deactivationError;

@property (nonatomic, assign) IBOutlet NSTextField *errorDescriptionField;
@property (nonatomic, assign) IBOutlet NSButton *confirmButton;

- (IBAction)confirmAction:(id)sender;

@end
