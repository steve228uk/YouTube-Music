//
//  SUUpdaterQueue.h
//  Sparkle
//
//  Created by Dmytro Tretiakov on 7/31/14.
//
//

#if __has_feature(modules)
@import Foundation;
#else
#import <Foundation/Foundation.h>
#endif
#import "SUExport.h"

@class SUUpdater;

SU_EXPORT @interface SUUpdaterQueue : NSObject

- (void)addUpdater:(SUUpdater *)updater;
- (void)removeUpdater:(SUUpdater *)updater;

- (void)checkForUpdates;
- (void)checkForUpdatesInBackground;

@property (readonly) BOOL updateInProgress;

@end

