//
//  DMFsprgEmbeddedStoreProtocols.h
//  DevMateActivations
//
//  Copyright (c) 2015-2018 DevMate Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, DMFsprgOrderProcessType)
{
    DMFsprgOrderProcessDetail = 0,
    DMFsprgOrderProcessInstant,
    DMFsprgOrderProcessCheckout
};

typedef NS_ENUM(NSUInteger, DMFsprgMode)
{
    DMFsprgModeActive = 0,
    DMFsprgModeActiveTest,
    DMFsprgModeTest
};

//! Protocol for FsprgStoreParameters class
@protocol DMFsprgStoreParameters <NSObject>
@required

- (NSMutableDictionary *)raw;
- (void)setRaw:(NSMutableDictionary *)aRaw;

- (void)setLanguage:(NSString *)aLanguage;

- (void)setOrderProcessType:(NSString *)anOrderProcessType;
- (void)setOrderProcessTypeInt:(DMFsprgOrderProcessType)aType;
- (void)setMode:(NSString *)aMode;
- (void)setModeInt:(DMFsprgMode)aMode;

- (void)setStoreId:(NSString *)aStoreId withProductId:(NSString *)aProductId;
- (void)setStoreId:(NSString *)aStoreId;
- (void)setProductId:(NSString *)aProductId;

- (void)setCampaign:(NSString *)aCampaign;
- (void)setOption:(NSString *)anOption;
- (void)setReferrer:(NSString *)aReferrer;
- (void)setSource:(NSString *)aSource;
- (void)setCoupon:(NSString *)aCoupon;
- (void)setTags:(NSString *)aTags;

- (void)setContactFname:(NSString *)aContactFname;
- (void)setContactLname:(NSString *)aContactLname;
- (void)setContactEmail:(NSString *)aContactEmail;
- (void)setContactCompany:(NSString *)aContactCompany;
- (void)setContactPhone:(NSString *)aContactPhone;

@end

//! Protocol for FsprgLicense class
@protocol DMFsprgLicense <NSObject>
@required

- (NSArray *)licenseCodes;

@end

//! Protocol for FsprgOrderItem class
@protocol DMFsprgOrderItem <NSObject>
@required

- (id<DMFsprgLicense>)license;

- (NSString *)productName;
- (NSString *)productDisplay;
- (NSNumber *)quantity;
- (NSNumber *)itemTotal;
- (NSNumber *)itemTotalUSD;

@end

//! Protocol for FsprgOrder class
@protocol DMFsprgOrder <NSObject>
@required

- (id<DMFsprgOrderItem>)firstOrderItem;
- (NSArray *)orderItems;

- (NSString *)orderReference;
- (NSString *)orderLanguage;
- (NSString *)orderCurrency;
- (NSNumber *)orderTotal;
- (NSNumber *)orderTotalUSD;
- (NSString *)customerFirstName;
- (NSString *)customerLastName;
- (NSString *)customerCompany;
- (NSString *)customerEmail;

@end
