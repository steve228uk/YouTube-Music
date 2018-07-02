//
//  DMAdditionalActivationStepController.h
//  DevMateActivations
//
//  Copyright (c) 2014-2018 DevMate Inc. All rights reserved.
//

#import <DevMateKit/DMActivationStepController.h>

@interface DMAdditionalActivationStepController : DMActivationStepController

@property (nonatomic, assign, getter = isUserNameRequired) BOOL userNameRequired; // default is YES
@property (nonatomic, assign, getter = isUserEmailRequired) BOOL userEmailRequired; // default is YES

@property (nonatomic, assign) IBOutlet NSTextField *additionalInfoDescription;
@property (nonatomic, assign) IBOutlet NSTextField *userNameField;
@property (nonatomic, assign) IBOutlet NSTextField *userEmailField;
@property (nonatomic, assign) IBOutlet NSButton *keepUpToDateButton;

@end

/*! @brief Function that checks if email string is correct.
    @param ioEmailString Email string. Out string will be whitespace-trimmed if needs.
    @return YES in case of email string is valid. NO otherwise.
 */
FOUNDATION_EXTERN BOOL DMIsEmailValid(NSString **ioEmailString);
