//
//  RACMusicListViewModel.h
//
//  Created by 刘小壮 on 2016/11/21.
//  Copyright © 2016年 刘小壮. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "RACMusicListModel.h"

@interface RACMusicListViewModel : NSObject

@property (nonatomic, copy)   NSArray    *dataList;
@property (nonatomic, strong) RACSubject *errorSubject;
@property (nonatomic, strong) RACSignal  *hasMoreSignal;
@property (nonatomic, strong) RACCommand *cancelCommand;
@property (nonatomic, strong) RACCommand *fetchMoreDataCommand;
@property (nonatomic, strong) RACCommand *reloadDataCommand;

- (RACMusicListModel *)itemModelOfIndexPath:(NSIndexPath *)indexPath;

@end

