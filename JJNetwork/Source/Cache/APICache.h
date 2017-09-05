//
//  APICache.h
//  JJNetwork
//
//  Created by Jezz on 2017/9/3.
//  Copyright © 2017年 jezz. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol APICache <NSObject>

@required

- (BOOL)saveCacheWithData:(id)data withKey:(NSString*)key;

- (id)cacheWithKey:(NSString*)key;

@optional

- (BOOL)removeCacheWithKey:(NSString*)key;

- (void)clearCache;

@end
