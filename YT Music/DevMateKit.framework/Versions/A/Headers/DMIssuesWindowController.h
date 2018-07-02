//
//  DMIssuesWindowController.h
//  DevMateIssues
//
//  Copyright 2009-2018 DevMate Inc. All rights reserved.
//

#import <DevMateKit/DMIssueReportWindowController.h>

@interface DMIssuesWindowController : DMIssueReportWindowController

+ (instancetype)defaultController;

// IBOutlets & IBActions
@property (nonatomic, assign) IBOutlet NSImageView *appIcon;
@property (nonatomic, assign) IBOutlet NSTextField *titleField;
@property (nonatomic, assign) IBOutlet NSTextField *messageField;

@property (nonatomic, assign) IBOutlet NSTextField *userNameField;
@property (nonatomic, assign) IBOutlet NSTextField *userEmailField;

@property (nonatomic, assign) IBOutlet NSTextView *commentView;
@property (nonatomic, assign) IBOutlet NSButton *attachmentButton;

@property (nonatomic, assign) IBOutlet NSTextField *anonymousInfoField;
@property (nonatomic, assign) IBOutlet NSButton *sysInfoButton;

@property (nonatomic, assign) IBOutlet NSBox *separatorLine;

@property (nonatomic, assign) IBOutlet NSButton *sendButton;
@property (nonatomic, assign) IBOutlet NSButton *sendRestartButton;
@property (nonatomic, assign) IBOutlet NSProgressIndicator *progressIndicator;

- (IBAction)showSysInfo:(id)sender;
- (IBAction)attachFile:(id)sender;
- (IBAction)sendReport:(id)sender;
- (IBAction)sendAndRelaunch:(id)sender;
// -------------------------------

//! User comment that will be sent. Can be overriden by subclasses.
- (NSString *)userComment;

//! User attached file URLs that will be sent. Can be overriden by subclasses.
- (NSArray *)userAttachmentURLs;

@end
