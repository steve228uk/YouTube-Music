//
//  DMSuccessStepController.h
//  DevMateActivations
//
//  Copyright (c) 2012-2018 DevMate Inc. All rights reserved.
//

#import <DevMateKit/DMStepController.h>

@interface DMSuccessStepController : DMStepController

@property (nonatomic, assign) IBOutlet NSTextField *thanksField;
@property (nonatomic, assign) IBOutlet NSTextField *descriptionField;
@property (nonatomic, assign) IBOutlet NSButton *finishActivationButton;

- (IBAction)finishActivation:(id)sender;

@end
