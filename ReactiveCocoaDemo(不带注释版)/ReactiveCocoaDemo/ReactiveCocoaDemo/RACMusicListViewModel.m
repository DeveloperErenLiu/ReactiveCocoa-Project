//
//  RACMusicListViewModel.m
//
//  Created by 刘小壮 on 2016/11/21.
//  Copyright © 2016年 刘小壮. All rights reserved.
//

#import "RACMusicListViewModel.h"
#import "RACMusicListNetwork.h"
#import <ReactiveCocoa/RACEXTScope.h>
#import <MJExtension/MJExtension.h>

@interface RACMusicListViewModel ()
@property (nonatomic, strong) NSNumber            *currentIndex;
@property (nonatomic, strong) RACMusicListNetwork *network;
@end

@implementation RACMusicListViewModel

#pragma mark - ----- Life Cycle ------

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setupSignal];
        [self setupSubscriber];
    }
    return self;
}

#pragma mark - ----- Private Method ------

- (void)setupSignal {
    @weakify(self);
    self.fetchMoreDataCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id inputValue) {
        @strongify(self);
        return [[self.network fetchMusiclistWithIndex:self.currentIndex]
                                            takeUntil:self.cancelCommand.executionSignals];
    }];
    
    self.reloadDataCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id inputValue) {
        @strongify(self);
        return [[self.network fetchMusiclistWithIndex:@1]
                                            takeUntil:self.cancelCommand.executionSignals];
    }];
    
    self.hasMoreSignal = [RACObserve(self, currentIndex) map:^id(NSNumber *value) {
        return value.integerValue >= 100 ? @NO : @YES;
    }];
    
    self.cancelCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(NSString *inputStr) {
        NSLog(@"%@", inputStr);
        return [RACSignal empty];
    }];
}

- (void)setupSubscriber {
    
    @weakify(self);
    [[self.fetchMoreDataCommand.executionSignals switchToLatest] subscribeNext:^(RACTuple *tuple) {
        @strongify(self);
        [self reloadDataWithTuple:tuple isMore:YES];
    }];
    
    [[self.reloadDataCommand.executionSignals switchToLatest] subscribeNext:^(RACTuple *tuple) {
        @strongify(self);
        [self reloadDataWithTuple:tuple isMore:NO];
    }];
    
    [[RACSignal merge:@[self.fetchMoreDataCommand.errors,
                        self.reloadDataCommand.errors]] subscribe:self.errorSubject];
}

- (void)reloadDataWithTuple:(RACTuple *)tuple isMore:(BOOL)isMore {
    
    NSDictionary *dict      = tuple.first;
    NSDictionary *modelData = dict[@"model"];
    self.currentIndex       = @([modelData[@"cindex"] integerValue] + 15);
    NSMutableArray *array   = [RACMusicListModel objectArrayWithKeyValuesArray:modelData[@"list"]];
    
    if (isMore) {
        self.dataList = [self.dataList arrayByAddingObjectsFromArray:array];
    } else {
        self.dataList = array;
    }
}

#pragma mark - ----- Public Method ------

- (RACMusicListModel *)itemModelOfIndexPath:(NSIndexPath *)indexPath {
    return self.dataList[indexPath.row];
}

#pragma mark - ----- Setter && Getter ------

- (RACMusicListNetwork *)network {
    if (!_network) {
        _network = [[RACMusicListNetwork alloc] init];
    }
    return _network;
}

- (RACSubject *)errorSubject {
    if (!_errorSubject) {
        _errorSubject = [RACSubject subject];
    }
    return _errorSubject;
}

@end










