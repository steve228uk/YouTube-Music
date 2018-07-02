//
//  DevMateInlines.h
//  DevMateKit
//
//  Copyright (c) 2014-2018 DevMate Inc. All rights reserved.
//

#import <objc/runtime.h>
#import <DevMateKit/DMFeedbackController.h>
#import <DevMateKit/DMIssuesController.h>
#import <DevMateKit/DMTrackingReporter.h>
#import <DevMateKit/DMActivationController.h>
#import <DevMateKit/DevMateSparkle.h>

// --------------------------------------------------------------------------
// Most inline functions here should be used only for DEBUG configuration.
// You can easily modify any implementation to cover your needs.
// --------------------------------------------------------------------------

#if !__has_feature(objc_arc)
#   define DM_AUTORELEASE(v) ([v autorelease])
#   pragma clang diagnostic push
#   pragma clang diagnostic ignored "-Wreserved-id-macro"
#   define __bridge
#   pragma clang diagnostic pop
#else // -fobjc-arc
#   define DM_AUTORELEASE(v) (v)
#endif

DM_INLINE void DMKitSetupSandboxLogSystem(void)
{
    // As you know, ASL API has no access to system log in sandboxed application.
    // Thats why we override standard stdout and stderr with our file that will be
    // accessible in sandbox.
    
#ifdef DEBUG
    // No need to do that in DEBUG to be available to see our logs in console.
    return;
#endif

    NSString *appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:(__bridge NSString *)kCFBundleNameKey];
    NSString *logFilePath = [NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) lastObject];
    logFilePath = [logFilePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@.log", appName, appName]];

    NSString *parentDirectory = [logFilePath stringByDeletingLastPathComponent];
    if (![[NSFileManager defaultManager] fileExistsAtPath:parentDirectory])
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:parentDirectory withIntermediateDirectories:YES attributes:nil error:NULL];
    }

    const char *logFilePathStr = [logFilePath fileSystemRepresentation];
    freopen(logFilePathStr, "a+", stderr);
    freopen(logFilePathStr, "a+", stdout);

    printf("\n\n");
    fflush(stdout);
    NSLog(@"==============================================================");
    NSLog(@"NEW LAUNCH (%@)", [[NSDate date] description]);

    NSArray *allLogFiles = [NSArray arrayWithObject:[NSURL fileURLWithPath:logFilePath]];
    [DMFeedbackController sharedController].logURLs = allLogFiles;
    [DMIssuesController sharedController].logURLs = allLogFiles;
}

#pragma mark - DevMate Debug Menu

@protocol DevMateKitDelegate <  DMTrackingReporterDelegate,
                                DMFeedbackControllerDelegate,
                                DMActivationControllerDelegate,
#ifndef USED_CUSTOM_SPARKLE_FRAMEWORK
                                SUUpdaterDelegate,
#endif // USED_CUSTOM_SPARKLE_FRAMEWORK
                                DMIssuesControllerDelegate >
@end

#ifndef DEBUG

#define DMKitDebugGetDevMateMenu() (nil)
#define DMKitDebugGetDevMateMenuItem(a,b,c) (nil)
#define DMKitDebugAddFeedbackMenu()
#define DMKitDebugAddIssuesMenu()
#define DMKitDebugAddActivationMenu()
#define DMKitDebugAddTrialMenu()
#define DMKitDebugAddUpdateMenu()
#define DMKitDebugAddDevMateMenu()

#else // defined(DEBUG)

@interface NSApplication (com_devmate_DebugExtensions)
- (IBAction)com_devmate_ShowFeedback:(id)sender;
- (IBAction)com_devmate_ThrowException:(id)sender;
- (IBAction)com_devmate_CrashApp:(id)sender;
- (IBAction)com_devmate_StartActivation:(id)sender;
- (IBAction)com_devmate_InvalidateActivation:(id)sender;
- (IBAction)com_devmate_InvalidateTrial:(id)sender;
- (IBAction)com_devmate_ResetTrial:(id)sender;
- (IBAction)com_devmate_CheckForUpdates:(id)sender;
@end


DM_INLINE NSMenu *DMKitDebugGetDevMateMenu(void)
{
    static NSString *debugMenuTitle = @"DevMate Debug";

    NSMenu *mainMenu = [[NSApplication sharedApplication] mainMenu];
    NSMenuItem *debugMenuItem = [mainMenu itemWithTitle:debugMenuTitle];
    if (nil == debugMenuItem)
    {
        debugMenuItem = DM_AUTORELEASE([[NSMenuItem alloc] initWithTitle:debugMenuTitle action:NULL keyEquivalent:@""]);
        debugMenuItem.submenu = DM_AUTORELEASE([[NSMenu alloc] initWithTitle:debugMenuTitle]);
        [mainMenu addItem:debugMenuItem];
    }
    
    return debugMenuItem.submenu;
}

typedef void (^DMKitDebugActionBlock)(id self, id sender);
DM_INLINE NSMenuItem *DMKitDebugGetDevMateMenuItem(NSString *title, SEL appAction, DMKitDebugActionBlock impBlock)
{
    NSMenuItem *menuItem = DM_AUTORELEASE([[NSMenuItem alloc] initWithTitle:title action:appAction keyEquivalent:@""]);
    menuItem.target = [NSApplication sharedApplication];

    const char *types = method_getTypeEncoding(class_getInstanceMethod([NSApplication class], @selector(terminate:)));
    class_addMethod([NSApplication class], appAction, imp_implementationWithBlock(impBlock), types);

    return menuItem;
}

DM_INLINE void DMKitDebugAddFeedbackMenu(void)
{
    static NSString *menuItemTitle = @"Show Feedback Dialog";
    
    NSMenu *debugMenu = DMKitDebugGetDevMateMenu();
    if (nil == [debugMenu itemWithTitle:menuItemTitle])
    {
        NSMenuItem *feedbackMenuItem = DMKitDebugGetDevMateMenuItem(menuItemTitle, @selector(com_devmate_ShowFeedback:), ^(id self, id sender) {
            [[DMFeedbackController sharedController] showWindow:nil];
        });
        [debugMenu addItem:feedbackMenuItem];
    }
}

DM_INLINE void DMKitDebugAddIssuesMenu(void)
{
    static NSString *exceptionMenuTitle = @"Throw Test Exception";
    static NSString *crashMenuTitle = @"Crash Application";
    
    NSMenu *debugMenu = DMKitDebugGetDevMateMenu();
    if (nil == [debugMenu itemWithTitle:exceptionMenuTitle])
    {
        NSMenuItem *exceptionMenuItem = DMKitDebugGetDevMateMenuItem(exceptionMenuTitle, @selector(com_devmate_ThrowException:), ^(id self, id sender) {
            [NSException raise:@"Test exception" format:@"This exception was thrown to test DevMate issues feature."];
        });
        [debugMenu addItem:exceptionMenuItem];
        
        NSMenuItem *crashMenuItem = DMKitDebugGetDevMateMenuItem(crashMenuTitle, @selector(com_devmate_CrashApp:), ^(id self, id sender) {
            *(int *)1 = 0;
        });
        [debugMenu addItem:crashMenuItem];
    }
}

DM_INLINE void DMKitDebugAddActivationMenu(void)
{
    static NSString *activateMenuTitle = @"Activate Application";
    static NSString *resetMenuTitle = @"Invalidate Application License";
    
    NSMenu *debugMenu = DMKitDebugGetDevMateMenu();
    if (nil == [debugMenu itemWithTitle:activateMenuTitle])
    {
    #ifndef KEVLAR_VERSION
        NSLog(@"WARNING: For correct work import DMKevlarApplication.h header before master include header of DevMateKit framework.");
    #endif // KEVLAR_VERSION
        
        NSMenuItem *activationMenuItem = DMKitDebugGetDevMateMenuItem(activateMenuTitle, @selector(com_devmate_StartActivation:), ^(id self, id sender) {
        #ifndef KEVLAR_VERSION
            NSLog(@"WARNING: Need Kevlar library for correct work.");
        #else
            if (!DMKIsApplicationActivated(NULL))
            {
                DMActivationController *controller = [DMActivationController currentTrialController];
                if (nil == controller)
                    controller = [DMActivationController sharedController];
                
                [controller runActivationWindowInMode:DMActivationModeFloating
                                initialActivationInfo:nil
                                withCompletionHandler:nil];
            }
            else
            {
                NSAlert *alert = DM_AUTORELEASE([[NSAlert alloc] init]);
                alert.messageText = @"Your copy of application is already activated";
                alert.informativeText = [NSString stringWithFormat:@"Try to invalidate previous license using \"%@\" menu item from DevMate Debug menu and than try again.", resetMenuTitle];
                [alert runModal];
            }
        #endif
        });
        [debugMenu addItem:activationMenuItem];

        NSMenuItem *resetMenuItem = DMKitDebugGetDevMateMenuItem(resetMenuTitle, @selector(com_devmate_InvalidateActivation:), ^(id self, id sender) {
        #ifndef KEVLAR_VERSION
            NSLog(@"WARNING: Need Kevlar library for correct work.");
        #else
            [NSApp invalidateLicense];
        #endif
        });
        [debugMenu addItem:resetMenuItem];
    }
}

DM_INLINE void DMKitDebugAddTrialMenu(void)
{
    static NSString *invalidateMenuTitle = @"Invalidate Trial";
    static NSString *resetMenuTitle = @"Reset Trial";
    
    NSMenu *debugMenu = DMKitDebugGetDevMateMenu();
    if (nil == [debugMenu itemWithTitle:invalidateMenuTitle])
    {
        NSMenuItem *invalidateMenuItem = DMKitDebugGetDevMateMenuItem(invalidateMenuTitle, @selector(com_devmate_InvalidateTrial:), ^(id self, id sender) {
            DMTrialRef trial = [DMActivationController currentTrialController].trialObject;
            if (NULL != trial)
            {
                DMTrialInvalidateTrial(trial);
            }
            else
            {
                NSLog(@"No trial is started at this time.");
            }
        });
        [debugMenu addItem:invalidateMenuItem];

        NSMenuItem *resetMenuItem = DMKitDebugGetDevMateMenuItem(resetMenuTitle, @selector(com_devmate_ResetTrial:), ^(id self, id sender) {
            // --- NOTE!!! ---
            // Next portion of code should be compiled only in DEBUG build configuration because
            // it's not secure to have an ability to reset trial in application for distribution
            typedef BOOL (*DMTrialResetFuncPtr)(DMTrialRef);
            static DMTrialResetFuncPtr __DMTrialReset = NULL;
            
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                DMTrialHasTrialHistory(NULL);
                NSBundle *bundle = [NSBundle bundleForClass:[DMActivationController class]];
                CFBundleRef cfBundle = CFBundleGetBundleWithIdentifier((__bridge CFStringRef)[bundle bundleIdentifier]);
                void *variablePtr = CFBundleGetDataPointerForName(cfBundle, CFSTR("dm_rtfp"));
                __DMTrialReset = variablePtr ? *(DMTrialResetFuncPtr *)variablePtr : NULL;
            });
            
            if (NULL != __DMTrialReset)
            {
                __DMTrialReset([DMActivationController currentTrialController].trialObject);
            }
            else
            {
                NSLog(@"Necessary API is absent");
            }
        });
        [debugMenu addItem:resetMenuItem];
    }
}

DM_INLINE void DMKitDebugAddUpdateMenu(void)
{
#ifdef SUUPDATER_H
    static NSString *updateMenuTitle = @"Check for Updates";
    
    NSMenu *debugMenu = DMKitDebugGetDevMateMenu();
    if (nil == [debugMenu itemWithTitle:updateMenuTitle])
    {
        NSMenuItem *updateMenuItem = DMKitDebugGetDevMateMenuItem(updateMenuTitle, @selector(com_devmate_CheckForUpdates:), ^(id self, id sender) {
            [[SUUpdater sharedUpdater] checkForUpdates:nil];
        });
        [debugMenu addItem:updateMenuItem];
    }
#endif
}

DM_INLINE void DMKitDebugAddDevMateMenu(void)
{
    DMKitDebugAddFeedbackMenu();
    DMKitDebugAddIssuesMenu();
    DMKitDebugAddActivationMenu();
    DMKitDebugAddTrialMenu();
    DMKitDebugAddUpdateMenu();
}

#endif // DEBUG
