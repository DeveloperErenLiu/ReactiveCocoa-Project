//
//  RACMusicListModel.m
//
//  Created by 刘小壮 on 2016/11/21.
//  Copyright © 2016年 刘小壮. All rights reserved.
//

#import "RACMusicListModel.h"
#import <MJExtension/MJExtension.h>

@implementation RACMusicListModel

// 这里设置一下使用MJExtension进行模型转换时，替换键值对的字典。因为服务器返回值都是大写开头，而属性定义标准写法都是小写开头，所以需要在这里进行声明。
+ (NSDictionary *)replacedKeyFromPropertyName {
    return @{@"worksName" : @"WorksName",
             @"worksText" : @"WorksText"};
}

@end

