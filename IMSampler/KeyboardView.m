//
//  KeyboardView.m
//  IMSampler
//
//  Created by LongJunYan on 2018/3/27.
//  Copyright © 2018年 onelcat. All rights reserved.
//

#import "KeyboardView.h"

// 匿名分类
@interface KeyboardView()

@property (nonatomic, strong, nonnull) UICollectionViewFlowLayout *layout;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, copy) NSArray<NSString *> *title;
@property (nonatomic, nonnull, strong, getter=reuseIdentifier) NSString *reuseIdentifier;

-(NSString*)reuseIdentifier;
-(void)viewInit;
-(void)layoutInit;
@end

// 住类
@implementation KeyboardView

- (NSString *)reuseIdentifier {
    return @"reuseIdentifier";
}

- (void)viewInit {
    CGFloat w = [[UIScreen mainScreen] bounds].size.width - 5 / 3;
//    CGFloat h = [[UIScreen mainScreen] bounds].size.height;
    
    CGSize itemSize = CGSizeMake(w, w);
    _layout = [UICollectionViewFlowLayout init];
    _layout.itemSize = itemSize;
    _layout.minimumLineSpacing = 1;
    _layout.minimumInteritemSpacing = 1;
    
    CGRect frame = CGRectMake(0, 200, w, 200);
    _collectionView.delegate = self;
    _collectionView.dataSource = self;

    _collectionView = [[UICollectionView alloc] initWithFrame:frame collectionViewLayout:_layout];
    [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier: _reuseIdentifier];
    [self addSubview:_collectionView];
}

- (void)layoutInit {
    
}



- (instancetype)init
{
    self = [super init];
    if (self) {
        _title = [[NSArray alloc] initWithObjects:@"1",@"2",@"3",@"4", nil];
        [self viewInit];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self layoutInit];
}

# pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _title.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPat {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[self reuseIdentifier] forIndexPath:indexPat];
    CGRect f = CGRectMake(0, 0, 100, 30);
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:f];
    NSUInteger row = indexPat.row;
    titleLabel.text = [_title objectAtIndex:row];
    titleLabel.backgroundColor = [UIColor redColor];
    [[cell contentView] addSubview:titleLabel];
    return cell;
}

@end




