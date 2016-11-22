//
//  RACMusicListNetwork.m
//
//  Created by 刘小壮 on 2016/11/21.
//  Copyright © 2016年 刘小壮. All rights reserved.
//

#import "RACMusicListNetwork.h"
#import <AFNetworking/AFNetworking.h>
#import <AFNetworking-RACExtensions/RACAFNetworking.h>

#define MUSIC_URL @"http://lovebizhiapp.kuyinxiu.com/LovebizhiPhoneApp/content/getprogcontent?r=0.5562476110286179&nekot=&pno=021&pi=%ld&ps=15&ringType=1%%257C2%%257C3&pd=1"

@implementation RACMusicListNetwork

- (RACSignal *)fetchMusiclistWithIndex:(NSNumber *)index {
    
    return [[[AFHTTPSessionManager manager] rac_GET:[self urlWithIndex:index] parameters:nil] catch:^RACSignal *(NSError *error) {
        return [RACSignal error:[NSError errorWithDomain:@"Network error"
                                                    code:1001
                                                userInfo:nil]];
    }];
}

- (NSString *)urlWithIndex:(NSNumber *)index {
    return [NSString stringWithFormat:MUSIC_URL, index.integerValue];
}

@end












