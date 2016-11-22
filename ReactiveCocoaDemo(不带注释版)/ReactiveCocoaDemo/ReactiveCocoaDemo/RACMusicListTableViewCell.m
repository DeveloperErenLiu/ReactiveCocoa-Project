//
//  RACMusicListTableViewCell.m
//
//  Created by 刘小壮 on 2016/11/21.
//  Copyright © 2016年 刘小壮. All rights reserved.
//

#import "RACMusicListTableViewCell.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <ReactiveCocoa/RACEXTScope.h>

@implementation RACMusicListTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupSubscribeion];
    }
    return self;
}

- (void)setupSubscribeion {
    
    @weakify(self);
    [RACObserve(self, cellModel) subscribeNext:^(RACMusicListModel *model) {
        if (!model) return;
        @strongify(self);
        
        self.textLabel.text       = model.worksName;
        self.detailTextLabel.text = model.worksText;
        BOOL useImage             = (arc4random() % 10) % 2;
        self.imageView.image = useImage ? [UIImage imageNamed:@"lufy"] : [UIImage imageNamed:@"boy"];
    }];
}

@end


















