//
//  ListTableViewCell.m
//  MVideo
//
//  Created by LHL on 17/2/15.
//  Copyright © 2017年 LHL. All rights reserved.
//

#import "ListTableViewCell.h"
#import "Masonry.h"

@implementation ListTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleBlue;
        [self createUI];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self createUI];
}

- (void)createUI{
    
    [self addSubview:self.nameLabel];
//    [self addSubview:self.urlLabel];
    [self addSubview:self.canPlayLabel];

    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.equalTo(@(10));
        make.right.equalTo(self).offset(-10);
        make.height.mas_equalTo(20);
    }];
    
//    [self.urlLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.right.equalTo(self.nameLabel);
//        make.top.equalTo(self.nameLabel.mas_bottom).offset(10);
//        make.bottom.equalTo(self).offset(-20);
//    }];
    
    [self.canPlayLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.height.mas_equalTo(20);
        make.width.mas_equalTo(50);
        make.right.equalTo(self).offset(-20);
    }];
}

- (void)setObject:(MMovieModel *)anObject{
    _object = anObject;
//    self.urlLabel.text = [anObject.url stringByReplacingOccurrencesOfString:@"[url]" withString:@""];

}

- (void)checkIsCanPlay:(NSString *)url fileName:(NSString *)fileName{
    NSDictionary *canPlaylistDict = [[NSUserDefaults standardUserDefaults] objectForKey:fileName];
   NSString *tmpUrl = [canPlaylistDict objectForKey:url];
    self.canPlayLabel.hidden = !tmpUrl;
    if (self.canPlayLabel.hidden == NO) {
        self.object.canPlay = YES;
    }
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated{
    [super setHighlighted:highlighted animated:animated];
    if (highlighted) {
        _canPlayLabel.backgroundColor = [UIColor darkGrayColor];
    }
    else {
        _canPlayLabel.backgroundColor = [UIColor greenColor];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    if (selected) {
        _canPlayLabel.backgroundColor = [UIColor darkGrayColor];
    }
    else {
        _canPlayLabel.backgroundColor = [UIColor greenColor];
    }
}

#pragma mark - 
- (UILabel *)canPlayLabel{
    if (!_canPlayLabel) {
        _canPlayLabel = [[UILabel alloc] init];
        _canPlayLabel.backgroundColor = [UIColor greenColor];
        _canPlayLabel.textAlignment = NSTextAlignmentCenter;
        _canPlayLabel.text = @"可播";
        _canPlayLabel.font = [UIFont systemFontOfSize:14];
        _canPlayLabel.hidden = YES;

    }
    return _canPlayLabel;
}

- (UILabel *)nameLabel{
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.font = [UIFont boldSystemFontOfSize:15];
    }
    return _nameLabel;
}

//- (UILabel *)urlLabel{
//    if (!_urlLabel) {
//        _urlLabel = [[UILabel alloc] init];
//        _urlLabel.font = [UIFont systemFontOfSize:13];
//        _urlLabel.numberOfLines = 0;
//    }
//    return _urlLabel;
//}

@end
