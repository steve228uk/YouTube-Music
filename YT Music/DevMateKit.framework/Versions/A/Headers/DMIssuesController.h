//
//  DMIssuesController.h
//  DevMateIssues
//
//  Copyright 2013-2018 DevMate Inc. All rights reserved.
//

//! TESTING
// to test crash/exception reporting pass special arguments to the main executable:
//      *main_app_executable* [-test_crash [delay_seconds]] [-test_exception [delay_seconds]]
//  - if you pass -test_crash argument, DMIssuesController instance will crash app after delay_seconds (or immediately)
//  only after controller initialization
//  - if you pass -test_exception argument, DMIssuesController instance will throw an exception after delay_seconds (or immediately)
//  only after controller initialization

#import <DevMateKit/DMIssue.h>

@protocol DMIssuesControllerDelegate;

@interface DMIssuesController : NSObject

+ (instancetype)sharedController;

@property (nonatomic, assign) id<DMIssuesControllerDelegate> delegate;

//! User name/email to use inside the problem reporter
@property (nonatomic, retain) NSDictionary *defaultUserInfo; // look for keys below

//! Array of NSURL instances. Set it in case you have custom log files. By default log is obtained from ASL (default NSLog behaviour) for non-sandboxed apps.
@property (nonatomic, retain) NSArray *logURLs;

/*! @brief Starts sending all unhandled issues to server side.
    @param shouldShowReporterDialog Pass \p YES to show report dialog to user, \p NO otherwise. This flag will be ignored if report dialog is already shown.
    @return \p YES if there are unhandled issues to send. \p NO otherwise.
 */
- (BOOL)reportUnhandledIssuesIfExists:(BOOL)shouldShowReporterDialog;

/*! @brief Method to customize UI controller behavior.
    @discussion For correct work even for crash reporter this class and all other resources/classes should be implemented in separate framework.
    @param  controllerClass class that should be a subclass of DMIssuesWindowController.
 */
- (void)setIssuesWindowControllerClass:(Class)controllerClass;

@end

@interface DMIssuesController (com_devmate_Deprecated)
- (BOOL)reportUnhandledProblemsIfExists DM_DEPRECATED("Use -reportUnhandledIssuesIfExists: instead.");
- (void)enableCrashReporting DM_DEPRECATED("Will be automatically enabled right after initialization.");
- (void)enableUncaughtExceptionReporting DM_DEPRECATED("Will be automatically enabled right after initialization.");
@end

@protocol DMIssuesControllerDelegate <NSObject>
@optional

- (void)reporterWillRestartApplication:(DMIssuesController *)controller;

/*! @brief Asks delegate for permition to show reporter dialog to user right after the issue was caught.
    @discussion To send report silently return NO and call -reportUnhandledProblemsIfExists: passing NO as input param.
    @param controller Issue controller.
    @param issue Issue report that was caught.
    @return YES to start reporter dialog. In case of NO, report will be marked as unhandled and no UI will be shown.
 */
- (BOOL)controller:(DMIssuesController *)controller shouldReportIssue:(id<DMIssue>)issue;

//! Return YES to add current issue to full report that will be sent to server side.
- (BOOL)controller:(DMIssuesController *)controller shouldAddIssueToReport:(id<DMIssue>)issue;

//! DEPRECATED. Use -controller:shouldReportIssue: method instead.
- (BOOL)shouldReportExceptionProblem:(DMIssuesController *)controller;

//! DEPRECATED. Use -controller:shouldReportIssue: method instead.
- (BOOL)shouldReportCrashProblem:(DMIssuesController *)controller;

@end

//! Correctly handles all exceptions that can be thrown in try_block.
FOUNDATION_EXPORT void dm_dispatch_try_block(dispatch_block_t try_block);

//! Keys for defaulUserInfo dictionary
FOUNDATION_EXPORT NSString *const DMIssuesDefaultUserNameKey; // NSString
FOUNDATION_EXPORT NSString *const DMIssuesDefaultUserEmailKey; // NSString
FOUNDATION_EXPORT NSString *const DMIssuesDefaultCommentKey; // NSString
