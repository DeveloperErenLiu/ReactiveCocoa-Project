//
//  RACMusicListNetwork.h
//
//  Created by 刘小壮 on 2016/11/21.
//  Copyright © 2016年 刘小壮. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface RACMusicListNetwork : NSObject

// 发送网络请求的方法，传入从第几个获取的下标，每次获取15个。
- (RACSignal *)fetchMusiclistWithIndex:(NSNumber *)index;

@end
