//
//  DMActivationChecker.h
//  DevMateActivations
//
//  Copyright (c) 2012-2018 DevMate Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DMActivator <NSObject>
@required

/*! @brief Method that manages all activation process.
    @discussion For standard keys of \p activationInfo see storing state keys in \p DMStepController.h
    @param activationInfo   Dictionary with all activation info from user.
    @param handler          Completion handler.
*/
- (void)activateWithInfo:(NSDictionary *)activationInfo completionHandler:(void (^)(BOOL success, NSError *error))handler;

@optional

/*! @brief Method that checks if activator can potentially activate application with key.
    @discussion Makes it possible to enable further activation process and in some cases even start it automatically without waiting for user action.
    @discussion If this method is not implemented simple check will be used (\p potentialKey is not empty).
    @param potentialKey Key that can be potentially valid for activation.
    @return \p YES in case you want to enable further activation process. \p NO otherwise.
*/
- (BOOL)canPotentiallyActivateWithKey:(NSString *)potentialKey;

/*! @brief Method for checking if activator needs additional info for key.
    @discussion Makes it possible to switch activation dialog to \p DMActivationStepAdditionalActivation step.
    @param activationKey Key to check.
    @return \p YES in case you want to switch activation dialog to step with additional info fields. \p NO otherwise.
*/
- (BOOL)needsInAdditionalInfoForKey:(NSString *)activationKey;

@end
