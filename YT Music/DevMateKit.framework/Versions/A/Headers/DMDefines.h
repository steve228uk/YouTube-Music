//
//  DMDefines.h
//  DevMateKit
//
//  Copyright (c) 2013-2018 DevMate Inc. All rights reserved.
//

#ifndef DevMateKit_DMDefines_h
#define DevMateKit_DMDefines_h

#include <AvailabilityMacros.h>

#ifndef MAC_OS_X_VERSION_10_7
#   define MAC_OS_X_VERSION_10_7 1070
#endif

#ifndef MAC_OS_X_VERSION_10_8
#   define MAC_OS_X_VERSION_10_8 1080
#endif

#ifndef MAC_OS_X_VERSION_10_9
#   define MAC_OS_X_VERSION_10_9 1090
#endif

#ifndef MAC_OS_X_VERSION_10_10
#   define MAC_OS_X_VERSION_10_10 101000
#endif

#ifndef MAC_OS_X_VERSION_10_11
#   define MAC_OS_X_VERSION_10_11 101100
#endif

#if !__has_feature(objc_instancetype) && !defined(instancetype)
#   define instancetype id
#endif

#ifndef CF_ENUM
#   define CF_ENUM(_type, _name) _type _name; enum
#endif

#ifndef NS_ENUM
#   define NS_ENUM(_type, _name) CF_ENUM(_type, _name)
#endif

#if defined(__cplusplus)
#   define DM_INLINE static inline
#else
#   define DM_INLINE static __inline__ __attribute__((always_inline))
#endif

#define DM_DEPRECATED(_msg) DEPRECATED_MSG_ATTRIBUTE(_msg)

#endif // DevMateKit_DMDefines_h
