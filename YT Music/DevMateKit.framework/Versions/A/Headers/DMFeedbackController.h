//
//  DMFeedbackController.h
//  DevMateFeedback
//
//  Copyright (c) 2014-2018 DevMate Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <DevMateKit/DMFeedbackReportWindowController.h>
#import <DevMateKit/DMRatingView.h>

NS_ASSUME_NONNULL_BEGIN

//! Different modes for showing feedback window.
typedef NS_ENUM(NSInteger, DMFeedbackMode)
{
    DMFeedbackIndependentMode = 0,
    DMFeedbackChildMode,
    DMFeedbackModalMode,
    DMFeedbackSheetMode,
    DMFeedbackFloatingMode,
    
    DMFeedbackDefaultMode = DMFeedbackIndependentMode
};

//! Items tags for feedbackTypeButton control
typedef NS_ENUM(NSInteger, DMFeedbackTypeTag)
{
    DMFeedbackTypeFeedback = 0,
    DMFeedbackTypeSupportRequest,
    DMFeedbackTypeBugReport
};

@protocol DMFeedbackControllerDelegate;

@interface DMFeedbackController : DMFeedbackReportWindowController

/*! @brief Method for getting shared controller instance.
    @return Shared controller instance.
 */
+ (instancetype)sharedController;

@property (nonatomic, assign, nullable) id<DMFeedbackControllerDelegate> delegate;
@property (nonatomic, retain, nullable) NSDictionary *defaultUserInfo;

//! Array of NSURL instances. Set it in case you have custom log files. By default log is obtained from ASL (default NSLog behaviour) for non-sandboxed apps.
@property (nonatomic, retain, nullable) NSArray *logURLs;

//! Property to get/change feedback type
@property (nonatomic, assign) DMFeedbackTypeTag currentFeedbackType;

// IBOutlets & IBActions
@property (nonatomic, assign) IBOutlet NSImageView *appIcon;
@property (nonatomic, assign) IBOutlet NSTextField *titleField;
@property (nonatomic, assign) IBOutlet NSTextField *messageField;

@property (nonatomic, assign) IBOutlet NSTextField *userNameField;
@property (nonatomic, assign) IBOutlet NSTextField *userEmailField;

@property (nonatomic, assign) IBOutlet NSPopUpButton *feedbackTypeButton;

@property (nonatomic, assign) IBOutlet NSTextView *commentView;
@property (nonatomic, assign) IBOutlet NSButton *attachmentButton;

@property (nonatomic, assign) IBOutlet NSButton *sendAnonymousButton;
@property (nonatomic, assign) IBOutlet NSTextField *sendAnonymousExplanationField;
@property (nonatomic, assign) IBOutlet NSButton *sysInfoButton;

@property (nonatomic, assign) IBOutlet NSTextField *ratingTextField;
@property (nonatomic, assign) IBOutlet DMRatingView *ratingView;

@property (nonatomic, assign) IBOutlet NSBox *separatorLine;

@property (nonatomic, assign) IBOutlet NSButton *sendButton;
@property (nonatomic, assign) IBOutlet NSProgressIndicator *progressIndicator;

- (IBAction)changeFeedbackType:(nullable id)sender;
- (IBAction)showSysInfo:(nullable id)sender;
- (IBAction)attachFile:(nullable id)sender;
- (IBAction)sendReport:(nullable id)sender;
// -------------------------------

//! User comment that will be sent. Can be overriden by subclasses.
- (NSString *)userComment;

//! User attached file URLs that will be sent. Can be overriden by subclasses.
- (NSArray *)userAttachmentURLs;

/*! @brief Shows feedback window.
    @discussion In case when you use \p DMFeedbackDefaultMode mode and \p nil handler,
                you can use standard \p -showWindow: method instead.
    @param mode     Feedback mode.
    @param handler  Completion handler.
 */
- (void)showFeedbackWindowInMode:(DMFeedbackMode)mode completionHandler:(void (^)(BOOL success))handler;

@end

@protocol DMFeedbackControllerDelegate <NSObject>
@optional

/*! @brief Returns parent window for feedback window.
    @discussion Delegate should implement this method in case when using \p DMFeedbackChildMode or
                \p DMFeedbackSheetMode feedback modes. For other modes dialog will be just centered
                in parent window.
    @param controller   Feedback controller.
    @param mode         Feedback mode.
    @return Parent window for feedback window.
 */
- (NSWindow *)feedbackController:(DMFeedbackController *)controller
     parentWindowForFeedbackMode:(DMFeedbackMode)mode;

@end

//! Keys for defaultUserInfo dictionary
FOUNDATION_EXPORT NSString *const DMFeedbackDefaultUserNameKey; // NSString object
FOUNDATION_EXPORT NSString *const DMFeedbackDefaultUserEmailKey; // NSString object
FOUNDATION_EXPORT NSString *const DMFeedbackDefaultCommentKey; // NSString object

NS_ASSUME_NONNULL_END
