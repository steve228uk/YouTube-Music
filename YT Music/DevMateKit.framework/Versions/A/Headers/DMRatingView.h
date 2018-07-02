//
//  DMRatingView.h
//  DevMateFeedback
//
//  Copyright (c) 2014-2018 DevMate Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface DMRatingView : NSView

@property (nonatomic, assign) NSUInteger rating;
@property (nonatomic, retain) NSImage *normalImage;
@property (nonatomic, retain) NSImage *activeImage;

@end

NS_ASSUME_NONNULL_END
