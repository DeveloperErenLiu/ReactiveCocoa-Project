//
//  RACMusicListNetwork.m
//
//  Created by 刘小壮 on 2016/11/21.
//  Copyright © 2016年 刘小壮. All rights reserved.
//

#import "RACMusicListNetwork.h"
#import <AFNetworking/AFNetworking.h>
// AFN对RAC的扩展，如果想通过RAC的方式发送网络请求，需要导入这个头文件
#import <AFNetworking-RACExtensions/RACAFNetworking.h>

// 注意：下面URL包含转义字符
#define MUSIC_URL @"http://lovebizhiapp.kuyinxiu.com/LovebizhiPhoneApp/content/getprogcontent?r=0.5562476110286179&nekot=&pno=021&pi=%ld&ps=15&ringType=1%%257C2%%257C3&pd=1"

@implementation RACMusicListNetwork

- (RACSignal *)fetchMusiclistWithIndex:(NSNumber *)index {
    // AFN对RAC支持的很好，并提供了一套RAC版的Category，可以通过CocoaPods获取到。具体的可以看Demo工程的Podfile文件。
    // 支持发送get、post、head等请求，以及获取请求进度。调用AFN的网络请求方法后，返回的是一个RACSignal信号，可以对这个信号做一些RAC支持的操作，最后将这个信号返回给外界订阅。
    return [[[AFHTTPSessionManager manager] rac_GET:[self urlWithIndex:index] parameters:nil] catch:^RACSignal *(NSError *error) {
        // 通过catch捕获异常的信号，其block可以传入一个NSError类型的参数，并且可以接受一个RACSignal类型的返回值。
        // 我觉得catch方法使用起来就和map:方法类似，block会返回一个error，如果这个error不符合自己的要求，也可以返回一个新的error信号来替代这个error。
        // 在这里，我们就创建了一个新的NSError的信号，返回给外界使用。这个return代码一般不会被调用，只有发生错误是才会调用，并将error返回给网络请求订阅方。
        return [RACSignal error:[NSError errorWithDomain:@"Network error" code:1001 userInfo:nil]];
    }];
}

- (NSString *)urlWithIndex:(NSNumber *)index {
    return [NSString stringWithFormat:MUSIC_URL, index.integerValue];
}

@end












