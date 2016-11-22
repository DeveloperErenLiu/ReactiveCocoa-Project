//
//  RACMusicListViewModel.h
//
//  Created by 刘小壮 on 2016/11/21.
//  Copyright © 2016年 刘小壮. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "RACMusicListModel.h"

// viewModel，在MVVM设计模式中非常重要的角色，担当着数据处理的功能。
@interface RACMusicListViewModel : NSObject

// 返回的模型数组，在代码中会讲解为什么不用NSMutableArray
@property (nonatomic, copy) NSArray *dataList;

// 定义error的信号，注意是RACSubject类型的，因为可能需要订阅多个信号，在Demo中就是这么做的。
@property (nonatomic, strong) RACSubject *errorSubject;
// 是否有更多数据的信号，信号返回参数是一个BOOL类型的，通过这个信号来决定控制器的item是否可用。
@property (nonatomic, strong) RACSignal  *hasMoreSignal;
// 取消的command，由控制器来调用执行。可以用来取消网络请求等。
@property (nonatomic, strong) RACCommand *cancelCommand;
// 获取更多的command，由控制器来调用执行。
@property (nonatomic, strong) RACCommand *fetchMoreDataCommand;
// 刷新页面的command，由控制器来调用执行。
@property (nonatomic, strong) RACCommand *reloadDataCommand;

// 普通的方法调动
- (RACMusicListModel *)itemModelOfIndexPath:(NSIndexPath *)indexPath;

@end

