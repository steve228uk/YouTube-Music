//
//  DMActivationStepController.h
//  DevMateActivations
//
//  Copyright (c) 2012-2018 DevMate Inc. All rights reserved.
//

#import <DevMateKit/DMStepController.h>

@interface DMActivationStepController : DMStepController

@property (nonatomic, assign) IBOutlet NSTextField *licenseCaptionField;
@property (nonatomic, assign) IBOutlet NSTextField *licenseField;
@property (nonatomic, assign) IBOutlet NSTextField *descriptionField;
@property (nonatomic, assign) IBOutlet NSButton *activateButton;
@property (nonatomic, assign) IBOutlet NSButton *cancelButton;
@property (nonatomic, assign) IBOutlet NSProgressIndicator *progressIndicator;

- (IBAction)activate:(id)sender;
- (IBAction)cancel:(id)sender;

@end
