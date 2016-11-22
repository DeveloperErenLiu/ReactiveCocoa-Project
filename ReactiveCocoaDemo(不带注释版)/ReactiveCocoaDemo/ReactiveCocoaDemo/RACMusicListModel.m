//
//  RACMusicListModel.m
//
//  Created by 刘小壮 on 2016/11/21.
//  Copyright © 2016年 刘小壮. All rights reserved.
//

#import "RACMusicListModel.h"
#import <MJExtension/MJExtension.h>

@implementation RACMusicListModel

+ (NSDictionary *)replacedKeyFromPropertyName {
    return @{@"worksName" : @"WorksName",
             @"worksText" : @"WorksText"};
}

@end

