//
//  DMTrial.h
//  DevMateActivations
//
//  Copyright (c) 2013-2018 DevMate Inc. All rights reserved.
//

#ifndef DevMateActivations__DMTrial_h
#define DevMateActivations__DMTrial_h

#include <CoreFoundation/CoreFoundation.h>

CF_EXTERN_C_BEGIN

typedef CF_ENUM(CFIndex, DMTrialState)
{
    kDMTrialStateUndefined = 0,
    kDMTrialStateNotInitialized = kDMTrialStateUndefined,
    kDMTrialStateValid,
    kDMTrialStateInvalid
};

enum
{
    kDMTrialTypeManual = 0,
    kDMTrialTypeTime,
    
    kDMTrialTypeDefault = kDMTrialTypeManual
};
typedef CFIndex DMTrialType;

typedef CF_ENUM(CFIndex, DMTrialArea)
{
    kDMTrialAreaPerOneUser = 0,
    kDMTrialAreaForAllUsers, // to support in sandboxed app, add com.apple.security.temporary-exception.files.absolute-path.read-write with "/Users/Shared/" to your entitlements file
    
    kDMTrialAreaDefault = kDMTrialAreaPerOneUser
};

/*! @brief Callback block for getting MAX trial value that application supports
    @param context Parameter from \p DMTrialCallbacks structure.
    @return MAX trial value that application supports.
 */
typedef CFIndex (^DMTrialGetEndValueBlock)(void *context);

/*! @brief Callback block for changing current trial value.
    @param currentTrialValue    Trial value that is currently saved for application.
    @param changeValue          Value from \p DMTrialChangeValue function call.
    @param context              Parameter from \p DMTrialCallbacks structure.
    @return New changed trial value that should be saved for application.
 */
typedef CFIndex (^DMTrialChangeValueBlock)(CFIndex currentTrialValue, CFIndex changeValue, void *context);

/*! @brief Callback block for informing about application trial did end (became invalid).
    @param context Parameter from \p DMTrialCallbacks structure.
 */
typedef void (^DMTrialDidEndBlock)(void *context);

/*! @brief Callback block that will be called while initializing trial object.
    @param context Parameter from \p DMTrialCallbacks structure.
 */
typedef void (^DMTrialInitializeBlock)(void *context);

/*! @brief Callback block for cleaning up.
    @param context Parameter from \p DMTrialCallbacks structure.
 */
typedef void (^DMTrialFinalizeBlock)(void *context);


/*! @brief Structure of callback parameters used for informing about different trial changes.
    @discussion Be informed that some of structure parameters are required and can not be \p NULL.
    @discussion All callback blocks will be copied with \p Block_copy() by trial while initializing and released with \p Block_release() later.
 */
typedef struct __DMTrialCallbacks
{
    CFIndex version; // version number of the structure. Current structure version is 0.
    __unsafe_unretained DMTrialGetEndValueBlock getEndValue; // required
    __unsafe_unretained DMTrialChangeValueBlock changeValue; // required
    __unsafe_unretained DMTrialDidEndBlock didEndTrial; // optional
    __unsafe_unretained DMTrialInitializeBlock initialize; // optional
    __unsafe_unretained DMTrialFinalizeBlock finalize; // optional
    void *context; // optional
} DMTrialCallbacks;

//! Notification name for cases when application trial did end (became invalid). Notification object is \p trialId.
CF_EXPORT const CFStringRef kDMTrialDidEndNotification;

typedef struct __DMTrial * DMTrialRef;

/*******************************************************/
/*** Function defines for quick trial implementation ***/

CF_EXPORT DMTrialRef gDMUnidentifiedTrial;

#define DMTrialInitialize(_trialType_, _trialArea_, _callbacks_, _shouldContinue_) \
    ({ \
        gDMUnidentifiedTrial = DMTrialCreate(NULL, _trialType_, _trialArea_, _callbacks_); \
        Boolean success = DMTrialInitializeTrial(gDMUnidentifiedTrial, _shouldContinue_); \
        success; \
    })

#define DMTrialIsInitialized() DMTrialIsTrialInitialized(gDMUnidentifiedTrial)
#define DMTrialGetType() DMTrialGetTrialType(gDMUnidentifiedTrial)
#define DMTrialGetArea() DMTrialGetTrialArea(gDMUnidentifiedTrial)
#define DMTrialGetState() DMTrialGetTrialState(gDMUnidentifiedTrial)
#define DMTrialHasHistory() DMTrialHasTrialHistory(gDMUnidentifiedTrial)
#define DMTrialGetCurrentValue() DMTrialGetTrialCurrentValue(gDMUnidentifiedTrial)
#define DMTrialGetValueLeft() DMTrialGetTrialValueLeft(gDMUnidentifiedTrial)
#define DMTrialChangeValue(_changeValue_) DMTrialChangeTrialValue(gDMUnidentifiedTrial, _changeValue_)
#define DMTrialInvalidate() DMTrialInvalidateTrial(gDMUnidentifiedTrial)

#define DMTimeTrialInitialize(_trialArea_, _timeInterval_, _shouldContinue_) \
    DMTimeTrialInitializeTrial(NULL, _trialArea_, _timeInterval_, _shouldContinue_, &gDMUnidentifiedTrial)

/*******************************************************/

/*! @brief Function for creating trial for application.
    @param trialId          Trial identifier.
    @param trialType        Type of application trial. You can use your own types.
    @param trialArea        Trial area. See \p DMTrialArea enum for details.
    @param callbacks        Structure of callbacks.
    @return Created trial object.
 */
CF_EXPORT DMTrialRef DMTrialCreate(CFStringRef trialId, DMTrialType trialType, DMTrialArea trialArea, DMTrialCallbacks callbacks);

/*! @brief Function for initializing concrete trial.
    @param trial            Concrete trial to initialize.
    @param shouldContinue   \p true in case when trial should use previously saved value as start value. \p false in case when trial should invalidate all previous data and start new trial count.
    @return Success result. \p true in case when trial was initialized successfully.
 */
CF_EXPORT Boolean DMTrialInitializeTrial(DMTrialRef trial, Boolean shouldContinue);

//! Returns \p true in case trial is initialized, \p false otherwise.
CF_EXPORT Boolean DMTrialIsTrialInitialized(DMTrialRef trial);

//! Returns trial identifier
CF_EXPORT CFStringRef DMTrialGetTrialIdentifier(DMTrialRef trial) CF_RETURNS_NOT_RETAINED;

//! Returns trial type. Undefined behavior for uninitialized trial.
CF_EXPORT DMTrialType DMTrialGetTrialType(DMTrialRef trial);

//! Returns trial area. Undefined behavior for uninitialized trial.
CF_EXPORT DMTrialArea DMTrialGetTrialArea(DMTrialRef trial);

//! Returns trial state. Undefined behavior for uninitialized trial.
CF_EXPORT DMTrialState DMTrialGetTrialState(DMTrialRef trial);

//! Returns \p true in case trial has ever been initialized, \p false otherwise.
CF_EXPORT Boolean DMTrialHasTrialHistory(DMTrialRef trial);

/*! @brief Returns current trial value.
    @discussion Trial value always will be in range of [0, MAX_TRIAL_VALUE] for valid trial where MAX_TRIAL_VALUE is a result of \p getEndValue callback block.
    @discussion Will return LONG_MAX for invalid trial.
 */
CF_EXPORT CFIndex DMTrialGetTrialCurrentValue(DMTrialRef trial);

/*! @brief Returns trial value that left until it becomes invalid.
    @discussion Will return 0 for invalid or non-initalized trial.
 */
CF_EXPORT CFIndex DMTrialGetTrialValueLeft(DMTrialRef trial);

/*! @brief Function to change current trial value manually.
    @discussion Input value will be one of the arguments of callback block \p changeValue.
    @param changeValue Delta value for incrementing current trial value. For simple case formula is \p newTrialValue=\p currentTrialValue+\p changeValue.
 */
CF_EXPORT void DMTrialChangeTrialValue(DMTrialRef trial, CFIndex changeValue);

//! Function to invalidate application trial. Does nothing for already invalid trial.
CF_EXPORT void DMTrialInvalidateTrial(DMTrialRef trial);

//========================== Time trial functions ==========================//

static const CFTimeInterval kDMTrialMinute  = 60;
static const CFTimeInterval kDMTrialHour    = 60 * kDMTrialMinute;
static const CFTimeInterval kDMTrialDay     = 24 * kDMTrialHour;
static const CFTimeInterval kDMTrialWeek    = 7 * kDMTrialDay;
static const CFTimeInterval kDMTrialMonth   = 30 * kDMTrialDay;
static const CFTimeInterval kDMTrialYear    = 365 * kDMTrialDay;

/*! @brief Function to create time trial object.
    @discussion To initialize created time trial use standard \p DMTrialInitializeTrial function.
    @param timeTrialId      Time trial identifier.
    @param trialArea        Trial area. See \p DMTrialArea for more details.
    @param timeInterval     Time interval in seconds (trial MAX time).
    @return Created trial object.
 */
 CF_EXPORT DMTrialRef DMTimeTrialCreate(CFStringRef timeTrialId, DMTrialArea trialArea, CFTimeInterval timeInterval);

/*! @brief Function to initialize time trial.
    @discussion Trial will be valid for \p timeInterval seconds and then will send notification about invalidation. Trial time will be counted starting from the first initialization (even when application is not running).
    @param timeTrialId      Time trial identifier.
    @param trialArea        Trial area. See \p DMTrialArea for more details.
    @param timeInterval     Time interval in seconds (trial MAX time).
    @param shouldContinue   \p false if you want to restart time trial, \p true otherwise.
    @param outTrial         Initialized trial object
    @return Success result.
 */
CF_EXPORT Boolean DMTimeTrialInitializeTrial(CFStringRef timeTrialId, DMTrialArea trialArea, CFTimeInterval timeInterval, Boolean shouldContinue, DMTrialRef *outTrial);

CF_EXTERN_C_END

#endif // DevMateActivations__DMTrial_h
