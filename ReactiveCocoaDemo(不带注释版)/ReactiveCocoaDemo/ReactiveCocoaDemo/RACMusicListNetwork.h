//
//  RACMusicListNetwork.h
//
//  Created by 刘小壮 on 2016/11/21.
//  Copyright © 2016年 刘小壮. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface RACMusicListNetwork : NSObject

- (RACSignal *)fetchMusiclistWithIndex:(NSNumber *)index;

@end
