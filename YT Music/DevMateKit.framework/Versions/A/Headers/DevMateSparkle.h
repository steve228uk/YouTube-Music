//
//  DevMateSparkle.h
//  Sparkle
//
//  Created by Dmytro Tretiakov on 10/1/14.
//
//

#ifndef Sparkle_DevMateSparkle_h
#define Sparkle_DevMateSparkle_h

#import <Cocoa/Cocoa.h>

// If you are using your own copy of Sparkle.framework just define
// USED_CUSTOM_SPARKLE_FRAMEWORK macro.
#ifndef USED_CUSTOM_SPARKLE_FRAMEWORK

#define SUUpdater                               DM_SUUpdater
#define SUUpdaterQueue                          DM_SUUpdaterQueue
#define SUAppcast                               DM_SUAppcast
#define SUAppcastItem                           DM_SUAppcastItem
#define SUUpdaterDelegate                       DM_SUUpdaterDelegate
#define SUUpdaterDelegate_DevMateInteraction    DM_SUUpdaterDelegate_DevMateInteraction
#define SUVersionComparison                     DM_SUVersionComparison
#define SUStandardVersionComparator             DM_SUStandardVersionComparator
#define SUVersionDisplay                        DM_SUVersionDisplay

#import <DevMateKit/SUExport.h>
#import <DevMateKit/SUUpdater.h>
#import <DevMateKit/SUUpdaterQueue.h>
#import <DevMateKit/SUUpdaterDelegate.h>
#import <DevMateKit/SUAppcast.h>
#import <DevMateKit/SUAppcastItem.h>
#import <DevMateKit/SUVersionComparisonProtocol.h>
#import <DevMateKit/SUStandardVersionComparator.h>
#import <DevMateKit/SUVersionDisplayProtocol.h>
#import <DevMateKit/SUErrors.h>

#endif // USED_CUSTOM_SPARKLE_FRAMEWORK

#endif // Sparkle_DevMateSparkle_h
