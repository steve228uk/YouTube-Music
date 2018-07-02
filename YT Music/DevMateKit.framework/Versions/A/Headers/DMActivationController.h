//
//  DMActivationController.h
//  DevMateActivations
//
//  Copyright (c) 2012-2018 DevMate Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>
#import <DevMateKit/DMDefines.h>
#import <DevMateKit/DMTrial.h>
#import <DevMateKit/DMFsprgEmbeddedStoreProtocols.h>

//! Standard activation steps implemented in current framework.
typedef NS_ENUM(NSInteger, DMActivationStandardStep)
{
    DMActivationStepWelcome = 0,
    DMActivationStepActivation,
    DMActivationStepAdditionalActivation,
    DMActivationStepSuccess,
    DMActivationStepFailure,
    DMActivationStepExpired,
    DMActivationStepDeactivated,
    DMActivationStepEmbeddedStore
};

//! Standard trial steps implemented in current framework.
typedef NS_ENUM(NSInteger, DMTrialStandardStep)
{
    DMTrialStepWelcome = 10,
    DMTrialStepManualReminder,
    DMTrialStepManualExpired,
    DMTrialStepTimeReminder,
    DMTrialStepTimeExpired
};

typedef NSInteger DMActivationStep;

//! Modes for showing activation dialog.
typedef NS_ENUM(NSUInteger, DMActivationMode)
{
    DMActivationModeIndependent = 0, // dialog with normal window
    DMActivationModeChild, // dialog with child window
    DMActivationModeModal, // dialog with modal window
    DMActivationModeSheet, // dialog with sheet window
    DMActivationModeFloating // dialog with floating window
};

typedef NS_ENUM(NSUInteger, DMStandardActivationProcessResult)
{
    DMActivationResultCanceled         = 0,
    DMActivationResultWindowClosed     = DMActivationResultCanceled,
    DMActivationResultAppActivated     = 1,
    DMActivationResultTrialStarted     = 2,
    DMActivationResultTrialFailed      = 3 // could not initialize trial
};
typedef NSUInteger DMActivationProcessResult;

typedef NS_ENUM(NSUInteger, DMShowDialogReason)
{
    DMShowReasonStandardCall = 0,
    
    DMShowReasonActivateViaURLScheme,
    DMShowReasonLicenseExpired,
    DMShowReasonLicenseDeactivated,
    
    DMShowReasonTrialInitialize,
    DMShowReasonTrialContinue,
    DMShowReasonTrialExpired
};

typedef NS_ENUM(NSUInteger, DMAnimationAnchor)
{
    DMAnimationAnchorTopLeft = 0,
    DMAnimationAnchorTopCenter,
    DMAnimationAnchorTopRight,
    DMAnimationAnchorLeftCenter,
    DMAnimationAnchorRightCenter,
    DMAnimationAnchorCenter,
    DMAnimationAnchorBottomLeft,
    DMAnimationAnchorBottomCenter,
    DMAnimationAnchorBottomRight,
    
    DMAnimationAnchorDefault = DMAnimationAnchorTopCenter
};

typedef NS_ENUM(NSUInteger, DMTerminationReason)
{
    DMTerminationReasonTrialExpired = 0,
    DMTerminationReasonLicenseExpired,
    DMTerminationReasonLicenseDeactivated
};

typedef NS_ENUM(NSUInteger, DMFsprgEmbeddedStoreType)
{
    DMFsprgEmbeddedStoreNone = 0,
    DMFsprgEmbeddedStoreNative, // implemented inside framework
    DMFsprgEmbeddedStoreCustom // should be implemented by developer
};

//! Additional info keys for \p DMShowReasonActivateViaURLScheme reason
FOUNDATION_EXTERN NSString * const DMAdditionalInfoURLSchemeNameKey;

//! To support activation via URL scheme, there should be special bundle URL type in info.plist file (CFBundleURLTypes key)
//      with "com.devmate.ActivationScheme" value for CFBundleURLName key
//  URL for registration should have predefined structure (key-value pairs will be used as initial activation info):
//      registered_schema://activate?key_1=value_1&...&key_N=value_N
//  Use key 'key' to automatically fill dialog license field (e.g. registered_schema://activate?key=id1111111111111odr)
#define DMActivationSchemeURLName @"com.devmate.ActivationScheme"
#define DMActivationSchemeCommand @"activate"

typedef void (^DMCompletionHandler)(DMActivationProcessResult result);

//! Forward declarations
@protocol DMActivationControllerDelegate;
@protocol DMActivator;
@class DMStepController;

//! Main controller class for activation.
@interface DMActivationController : NSWindowController

/*! @brief Method for getting shared controller instance.
    @return Shared controller instance.
*/
+ (instancetype)sharedController;

/*! @brief Initializes new controller with default window.
    @discussion To use your own XIB for controller use \p-initWithWindowNibName: method instead.
    @return New autoreleased controller with default window.
*/
+ (instancetype)defaultController;

/*! @brief Method for setting shared delegate object for all activation/trial controllers.
    @discussion Shared delegate object will be used in case of absence concrete controller's delegate.
    @param delegate Shared delegate object for all activation/trial controllers.
 */
+ (void)setDelegate:(id<DMActivationControllerDelegate>)delegate;

//! Required in case of using your own activation scheme instead of Kevlar lib.
@property (nonatomic, retain) id<DMActivator> activator;

//! Controller delegate
@property (nonatomic, assign) id<DMActivationControllerDelegate> delegate;

@property (nonatomic, assign, readonly) DMActivationStep currentStep;
@property (nonatomic, retain, readonly) DMStepController *currentStepController;

//! Anchor point for step views change animation.
@property (nonatomic, assign) DMAnimationAnchor animationAnchor;

//! All saved steps states including current step.
@property (nonatomic, readonly) NSDictionary *allStepsStates;

/*! @brief Register current activation controller for the specific scheme
    @discussion By default all schemes mentioned in \p info.plist file will be handled by \p sharedController
    @param schemeName Scheme name.
*/
- (void)registerForScheme:(NSString *)schemeName;

/*! @brief Will handle Apple event if it contains URL scheme
    @discussion In case if you register your own event handler for \p kAEGetURL events don't forget to pass input params
                to \p DMActivationController for correct URL scheme work.
    @param event Apple event descriptor.
    @param replyEvent Apple reply event descriptor.
    @return \p YES in case if event was handled correcty, \p NO otherwise.
*/
+ (BOOL)tryToHandleAppleEvent:(NSAppleEventDescriptor *)event withReplyEvent:(NSAppleEventDescriptor *)replyEvent;

/*! @brief Shows activation window and starts activation process.
    @param activationMode           Activation mode.
    @param initialActivationInfo    Initial info that will be used for activation, can be \p nil.
    @param completionHandler        Completion handler.
*/
- (void)runActivationWindowInMode:(DMActivationMode)activationMode
            initialActivationInfo:(NSDictionary *)initialActivationInfo
            withCompletionHandler:(DMCompletionHandler)completionHandler;

/*! @brief Updates activation info with received FastSpring order via embedded Web Store.
    @param  order   FastSpring order info.
*/
- (void)updateActivationInfoWithFastSpringOrder:(id<DMFsprgOrder>)order;

/*! @brief Use this method to register own steps with own controllers.
    @discussion Can be also used to re-register standard steps with own controller or XIB for standard controller.
    @param controllerClassName  Controller class for registered step. Use \p nil to remove step controller info. Must be subclass of \p DMStepController.
    @param controllerNibName    XIB name in main bundle for controller.
    @param step                 activation step (custom or \p DMActivationStandardStep) to register new controller.
*/
- (void)registerStepController:(NSString *)controllerClassName
                   withNibName:(NSString *)controllerNibName
             forActivationStep:(DMActivationStep)step;

/*! @brief Use this method to register own steps with own controllers.
 @discussion                 Can be also used to re-register standard steps with own controller
 @param controller           Controller for registered step. Use \p nil to remove step controller.
 @param step                 activation step (custom or \p DMActivationStandardStep) to register new controller.
 */
- (void)registerStepController:(DMStepController *)controller
             forActivationStep:(DMActivationStep)step;

//! Outlet for view container for step views to be placed into.
@property (nonatomic, assign) IBOutlet NSView *containerView;

/*! @brief Method to change activation step view.
    @discussion In most cases should be called from step controllers.
*/
- (void)performActivationStepWithStep:(DMActivationStep)step;

/*! @brief Method that ends activation dialog and calls success/failure completion handler.
    @discussion In most cases should be called from step controllers.
*/
- (void)endActivationWithResult:(DMActivationProcessResult)result;

@end

// ============ TRIAL FUNCTIONALITY =============
@interface DMActivationController (com_devmate_Trial)

/*! @brief Method for getting time trial controller.
    @param area Trial area.
    @param seconds Trial time in seconds.
    @param nibName Custom window nib name if exists or \p nil.
    @return Time trial controller.
*/
+ (DMActivationController *)timeTrialControllerForArea:(DMTrialArea)area timeInterval:(NSTimeInterval)seconds customWindowNib:(NSString *)nibName;

/*! @brief Method for getting manual trial controller.
    @param area Trial area.
    @param callbacks Manual trial callbacks.
    @param nibName Custom window nib name if exists or \p nil.
    @return Manual trial controller.
*/
+ (DMActivationController *)manualTrialControllerForArea:(DMTrialArea)area callbacks:(DMTrialCallbacks)callbacks customWindowNib:(NSString *)nibName;

/*! @brief Method for getting current trial controller.
    @discussion Will return trial controller that was used to start previous trial process or \p nil if no trial was started.
    @return Current trial controller.
*/
+ (DMActivationController *)currentTrialController;

//! Trial object getter for trial activation controller; \p nil for standard activation controllers
@property (nonatomic, readonly) DMTrialRef trialObject;

//! Method to start trial process.
- (void)startTrial;

@end

@protocol DMActivationDelegate <NSObject>
@optional
    
/*! @brief Returns parent window for activation dialog.
    @discussion Delegate should implement this method in case when using \p DMActivationChildMode or
                \p DMActivationSheetMode activation modes. For other modes dialog will be just centered
                in parent window.
    @param controller   Activation controller.
    @param mode         Activation mode.
    @return Parent window for activation dialog.
*/
- (NSWindow *)activationController:(DMActivationController *)controller parentWindowForActivationMode:(DMActivationMode)mode;

/*! @brief Returns new activation step instead of proposed one to customize activation dialog behavior.
    @discussion Delegate should implement this method in case when there is need to customize standard behavior.
                Activation controller always starts with \p DMActivationStepWelcome step.
    @discussion This is the last chance to register step controller for returned/proposed activation step.
    @param controller   Activation controller.
    @param proposedStep Proposed step.
    @return New activation step to adjust standard behavior or \p proposedStep.
*/
- (DMActivationStep)activationController:(DMActivationController *)controller activationStepForProposedStep:(DMActivationStep)proposedStep;

/*! @brief Informs delegate that activation controller will change activation step.
    @discussion Will be called before changing \p currentStep and \p currentStepController properties with new ones.
    @param controller   Activation controller.
*/
- (void)activationControllerWillChangeActivationStep:(DMActivationController *)controller;

/*! @brief Informs delegate that activation controller has already changed activation step.
    @discussion Will be called after \p currentStep and \p currentStepController properties were changed to new ones
                and step view was moved to controller container view.
    @discussion Controller's window size will be changed right after this method call to fit currentStepController's view.
    @param controller   Activation controller.
*/
- (void)activationControllerDidChangeActivationStep:(DMActivationController *)controller;

/*! @brief Returns activation info that will be used for activation process
    @discussion Delegate can customize dictionary with activation info to add/remove some values.
    @param controller   Activation controller.
    @param proposedInfo Proposed activation info.
    @return Customized activation info or \p proposedInfo.
*/
- (NSDictionary *)activationController:(DMActivationController *)controller activationInfoWithProposedInfo:(NSDictionary *)proposedInfo;

/*! @brief Returns confirmation for showing activation dialog.
 *  @discussion If delegate doesn't implement this method, dialog will be shown with \p proposedMode and without any completion handler.
 *  @discussion In case of \p DMShowReasonLicenseExpired reason \p sharedController will be used.
                If you want to use other controller, just return \p NO and run your own session with \p DMActivationStepExpired step.
 *  @param controller       Activation controller.
 *  @param reason           Activation dialog show reason.
 *  @param additionalInfo   Additional information for show reason that can be analyzed.
 *  @param ioProposedMode   Pointer to in-out activation mode that will be used by activation controller.
 *  @param handlerSetter    Special block for setting completion handler that will be called at the end of activation process.
 */
- (BOOL)activationController:(DMActivationController *)controller shouldShowDialogForReason:(DMShowDialogReason)reason
          withAdditionalInfo:(NSDictionary *)additionalInfo proposedActivationMode:(inout DMActivationMode *)ioProposedMode
     completionHandlerSetter:(void (^)(DMCompletionHandler))handlerSetter;

/*!
 Deprecated.
 */
- (BOOL)activationController:(DMActivationController *)controller shouldShowDialogForReason:(DMShowDialogReason)reason
          withAdditionalInfo:(NSDictionary *)additionalInfo proposedActivationMode:(inout DMActivationMode *)ioProposedMode
           completionHandler:(out DMCompletionHandler *)pHandlerCopy DM_DEPRECATED("Use -activationController:shouldShowDialogForReason:withAdditionalInfo:proposedActivationMode:completionHandlerSetter: instead");

/*! @brief Returns confirmation about application termination.
    @discussion If this method is not implemented, application will be terminated.
    @param  controller Activation controller.
    @param  reason Termination reason.
    @return \p YES in case app should be terminated, \p NO otherwise.
 */
- (BOOL)activationController:(DMActivationController *)controller shouldTerminateAppWithReason:(DMTerminationReason)reason;

/*! @brief Returns additional key-value pairs for store request via GET method.
 *  @param controller   Activation controller.
 *  @return Dictionary with key-value pairs. Can be \p nil.
 */
- (NSDictionary *)additionalStoreURLParameters:(DMActivationController *)controller;

@end

@protocol DMFsprgEmbeddedStoreDelegate <NSObject>
@optional

/*! @brief Returns FastSpring embedded store type if application supports it.
 *  @param controller Activation controller.
 *  @return One of DMFsprgEmbeddedStoreType types.
 */
- (DMFsprgEmbeddedStoreType)fsprgEmbeddedStoreTypeForActivationController:(DMActivationController *)controller;

/*! @brief Should be implemented by delegate in case of DMFsprgEmbeddedStoreNative embedded store type.
 *  @param controller Activation controller.
 *  @param storeParameters Embedded store parameters that should be updated according to store adjustments. At least storeId and productId should be set.
 */
- (void)activationController:(DMActivationController *)controller willStartNativeFsprgEmbeddedStore:(id<DMFsprgStoreParameters>)storeParameters;

/*! @brief Returns if window can be resizable for native embedded store implementation.
 *  @param controller Activation controller.
 *  @param ioInitialSize initial embedded store window size. This size will be set as min window content size.
 *  @return YES if window should be resizable, NO otherwise.
 */
- (BOOL)activationController:(DMActivationController *)controller canResizeNativeFsprgEmbeddedStoreWindowWithInitialSize:(inout NSSize *)ioInitialSize;

/*! @brief Delegate methods that informs about loaded web page in native embedded store implementation.
 *  @param controller Activation controller.
 *  @param pageURL Page URL that was loaded.
 */
- (void)activationController:(DMActivationController *)controller didLoadNativeFsprgEmbeddedStorePage:(NSURL *)pageURL;

/*! @brief Delegate methods that informs about cleared window web objects for concrete frame.
 *  @see -webView:didClearWindowObject:forFrame:
 *  @param controller Activation controller.
 *  @param windowObject The cleared JavaScript window object.
 *  @param frame The frame containing the JavaScript window object.
 */
- (void)activationController:(DMActivationController *)controller didClearNativeFsprgEmbededStoreWindowObject:(WebScriptObject *)windowObject forFrame:(WebFrame *)frame;

/*! @brief Should be implemented by delegate in case when need to correct menu items for web element.
 *  @see -webView:contextMenuItemsForElement:defaultMenuItems:
 *  @param controller Activation controller.
 *  @param element A dictionary that describes the element that was clicked.
 *  @param menuItems The menu items included by default in the element’s contextual menu.
 *  @return Corrected array of menu items.
 */
- (NSArray *)activationController:(DMActivationController *)controller contextMenuItemsForNativeFsprgEmbeddedStoreElement:(NSDictionary *)element defaultMenuItems:(NSArray *)menuItems;

/*! @brief Should be implemented by delegate in case of DMFsprgEmbeddedStoreCustom embedded store type.
 *  @param controller Activation controller.
 *  @param customStoreCompletionHandler Block handler that should be called after custom embedded store will be ended.
 */
- (void)activationController:(DMActivationController *)controller waitsForCustomFsprgEmbeddedStore:(void (^)(id<DMFsprgOrder> orderOrNil))customStoreCompletionHandler;

@end

@protocol DMTrialDelegate <NSObject>
@optional

/*! @brief Returns confirmation to continue last saved trial.
    @discussion If this method not implemented, new trial will continue last saved one.
    @param controller   Activation controller.
    @return \p YES in case when you want to continue trial that was started earlier, \p NO otherwise.
*/
- (BOOL)trialControllerShouldContinueLastSavedTrial:(DMActivationController *)controller;

/*! @brief Returns confirmation for starting trial even if user canceled trial dialog (e.g. by closing dialog window).
    @discussion Method will be called in case when result is not \p DMActivationResultAppActivated or \p DMActivationResultTrialStarted.
    @discussion If delegate does not implement this method trial will be started.
    @param controller   Activation controller.
    @param result       Activation process result (standard or custom).
 */
- (BOOL)trialController:(DMActivationController *)controller shouldStartTrialWithUserFailedResult:(DMActivationProcessResult)result;

@end

/*! @protocol DMActivationControllerDelegate
    @brief Protocol of activation controller delegate.
 */
@protocol DMActivationControllerDelegate <DMActivationDelegate, DMTrialDelegate, DMFsprgEmbeddedStoreDelegate>
@end
