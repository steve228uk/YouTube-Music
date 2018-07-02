//
//  DMStepController.h
//  DevMateActivations
//
//  Copyright (c) 2012-2018 DevMate Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <DevMateKit/DMActivationController.h>

/*! @interface DMStepController
    @brief Controller for the specific activation step.
    @discussion All defined \p IBOutlet members can be used to change their properties (visibility/target/action/...).
*/
@interface DMStepController : NSViewController

/*! @brief Returns default nib name for step controller.
    @discussion Should be overriden by subclasses to create default controller correctly.
    @return Default nib name for step controller.
*/
+ (NSString *)defaultNibName;

/*! @brief Returns autoreleased step controller with \p +defaultNibName nib file.
    @return Autoreleased step controller.
*/
+ (instancetype)defaultViewController;

@property (nonatomic, assign) DMActivationController *activationController;

/*! @brief Corrects UI elements properties (localized titles, positions, ...).
    @discussion Will be called right after view was loaded from nib.
 */
- (void)updateUIElements;

/*! @brief Should be overriden by subclasses to store its' state and additional info.
    @discussion Will be called from activation controller before removing step view from container view.
    @param saveContainer    Dictionary container.
*/
- (void)saveCurrentState:(NSMutableDictionary *)saveContainer;

/*! @brief Should be overriden by subclasses to store its state and additional info.
    @discussion Will be called from activation controller after moving step view into container view.
    @discussion \p saveContainer will have all saved states before for one activation session (from the start of activation to it's end).
    @param saveContainer    Dictionary container.
*/
- (void)restoreState:(NSDictionary *)saveContainer;

//! Will be called from activation controller at start of new activation session
- (void)resetStateToDefault;

/*! @brief Activation reason for cases when user closes dialog window with close button.
    @discussion Can be overriden by subclasses. Default implementation returns \p DMActivationEndWindowClosed.
    @return Returns the activation reason for window close action.
 */
- (DMActivationProcessResult)activationResultForWindowCloseAction;

// IBOutlets
@property (nonatomic, assign) IBOutlet NSImageView *applicationIconView;
@property (nonatomic, assign) IBOutlet NSTextField *stepTitleField;

@end

// Keys for storing states
FOUNDATION_EXTERN NSString *const DMActivationNumberKey; // NSString value
FOUNDATION_EXTERN NSString *const DMActivationErrorKey; // NSError value
FOUNDATION_EXPORT NSString *const DMActivationUserNameKey; // NSString value
FOUNDATION_EXPORT NSString *const DMActivationUserEmailKey; // NSString value
FOUNDATION_EXPORT NSString *const DMActivationKeepUpToDateKey; // NSNumber with BOOL
