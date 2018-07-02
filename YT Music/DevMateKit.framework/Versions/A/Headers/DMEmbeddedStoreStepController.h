//
//  DMEmbeddedStoreStepController.h
//  DevMateActivations
//
//  Copyright (c) 2015-2018 DevMate Inc. All rights reserved.
//

#import <DevMateKit/DMStepController.h>

@class WebView;

@interface DMEmbeddedStoreStepController : DMStepController

@property (nonatomic, assign) IBOutlet WebView *storeWebView;
@property (nonatomic, assign) IBOutlet NSProgressIndicator *loadingProgressIndicator;
@property (nonatomic, retain) IBOutlet NSButton *secureSessionButton;

@property (nonatomic, assign) IBOutlet NSView *errorViewContainer;
@property (nonatomic, assign) IBOutlet NSTextField *errorTitleField;
@property (nonatomic, assign) IBOutlet NSTextField *errorDescriptionField;
@property (nonatomic, assign) IBOutlet NSButton *webStoreButton;
@property (nonatomic, assign) IBOutlet NSButton *tryAgainButton;

- (IBAction)showCertificates:(id)sender; // will be sent by secureSessionButton
- (IBAction)reloadStore:(id)sender;
- (IBAction)openWebStore:(id)sender;
- (IBAction)cancelEmbeddedStore:(id)sender;

@end
