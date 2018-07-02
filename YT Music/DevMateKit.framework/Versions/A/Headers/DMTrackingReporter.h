//
//  DMTrackingReporter.h
//  DevMateTracking
//
//  Copyright (c) 2013-2018 DevMate Inc. All rights reserved.
//

#import <DevMateKit/DMTrackingBase.h>

@protocol DMTrackingReporterInfoProvider;
@protocol DMTrackingReporterDelegate;

@interface DMTrackingReporter : NSObject

- (instancetype)initWithInfoProvider:(id <DMTrackingReporterInfoProvider>)infoProvider;
+ (instancetype)reporterWithInfoProvider:(id <DMTrackingReporterInfoProvider>)infoProvider;

@property (readonly) id <DMTrackingReporterInfoProvider> infoProvider;
@property (assign) id <DMTrackingReporterDelegate> delegate;

// Passing NO as async parameter is not recommended while calling method from main thread/queue
- (void)sendReport:(BOOL)async;

@end

@protocol DMTrackingReporterInfoProvider <NSObject>
@optional

- (NSUInteger)applicationLaunchCount:(DMTrackingReporter *)reporter;
- (BOOL)isApplicationFirstInstall:(DMTrackingReporter *)reporter;
- (DMAppActivationStatus)applicationActivationStatus:(DMTrackingReporter *)reporter;
- (DMAppTrialValue)applicationTrialValue:(DMTrackingReporter *)reporter;

@end

@protocol DMTrackingReporterDelegate <NSObject>
@optional

- (void)trackingReporter:(DMTrackingReporter *)reporter didFinishSendingReportWithSuccess:(BOOL)success;

@end
