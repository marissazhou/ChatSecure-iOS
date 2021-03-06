//
//  OTRXMPPBuddy.m
//  Off the Record
//
//  Created by David Chiles on 3/28/14.
//  Copyright (c) 2014 Chris Ballinger. All rights reserved.
//

#import "OTRXMPPBuddy.h"
#import "XMPPvCardTemp.h"
#import "NSData+XMPP.h"

@interface OTRXMPPBuddy ()

@property (nonatomic, strong) NSDictionary <NSString *,NSNumber *>*resourceInfo;

@end


@implementation OTRXMPPBuddy

- (id)init
{
    if (self = [super init]) {
        self.pendingApproval = NO;
        self.hasIncomingSubscriptionRequest = NO;
        self.waitingForvCardTempFetch = NO;
    }
    return self;
}

#pragma - mark setters & getters

- (void)setVCardTemp:(XMPPvCardTemp *)vCardTemp
{
    _vCardTemp = vCardTemp;
    if ([self.vCardTemp.photo length]) {
        self.avatarData = self.vCardTemp.photo;
    }
}

- (void)setAvatarData:(NSData *)avatarData
{
    [super setAvatarData:avatarData];
    if ([self.avatarData length]) {
        self.photoHash = [[self.avatarData xmpp_sha1Digest] xmpp_hexStringValue];
    }
    else {
        self.photoHash = nil;
    }
}

- (void)setStatus:(OTRThreadStatus)status forResource:(NSString *)resource
{
    if (!resource) {
        return;
    }
    
    NSDictionary <NSString *,NSNumber *>*newDictionary = @{resource:@(status)};
    
    if (!self.resourceInfo) {
        self.resourceInfo = newDictionary;
    } else {
        self.resourceInfo = [self.resourceInfo mtl_dictionaryByAddingEntriesFromDictionary:newDictionary];
    }
}

- (void)setStatus:(OTRThreadStatus)status
{
    if (status == OTRThreadStatusOffline) {
        self.resourceInfo = nil;
    }
}

- (OTRThreadStatus)status {
    if (!self.resourceInfo) {
        return OTRThreadStatusOffline;
    } else {
        __block OTRThreadStatus status = OTRThreadStatusOffline;
        [self.resourceInfo enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSNumber * _Nonnull obj, BOOL * _Nonnull stop) {
            OTRThreadStatus resourceStatus = obj.intValue;
            // Check if it less than becauase OTRThreadStatusAvailable == 0 and the closer you are to OTRThreadStatusAvailable the more 'real' it is.
            if (resourceStatus < status) {
                status = resourceStatus;
            }
            
            if (status == OTRThreadStatusAvailable) {
                *stop = YES;
            }
            
        }];
        return status;
    }
}

#pragma - mark Class Methods

+ (NSString *)collection
{
    return [OTRBuddy collection];
}



@end
