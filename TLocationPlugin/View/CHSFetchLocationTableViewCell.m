//
//  CHSFetchLocationTableViewCell.m
//  CHSLocationPlugin
//
//  Created by stone on 2022/4/14.
//  Copyright © 2022 TBD. All rights reserved.
//

#import "CHSFetchLocationTableViewCell.h"
#import "UITableView+CHSLocationPlugin.h"
#import "UIImage+CHSLocationPlugin.h"
#import "UIColor+CHSLocationPlugin.h"
#import "Masonry.h"
#import "CHSImageHelper.h"

@interface CHSFetchLocationTableViewCell() {
    
}

@property (nonatomic, strong) UIImageView *selectImageView;

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UILabel *detailLabel;

@property (nonatomic, strong) UIImageView *separatorView;

@end

@implementation CHSFetchLocationTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectedBackgroundView = [[UIView alloc] init];
        self.selectionStyle = UITableViewCellSelectionStyleGray;
        self.backgroundColor = [UIColor whiteColor];
        self.contentView.backgroundColor = [UIColor whiteColor];
        [self setUI];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setUI {
    [self.contentView addSubview:self.selectImageView];
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.detailLabel];
    [self.contentView addSubview:self.separatorView];
    
    [self setMas];
}

- (void)setMas {
    [self.selectImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.left.equalTo(self.contentView.mas_left).offset(16);
    }];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView.mas_top).offset(16);
        make.left.equalTo(self.contentView.mas_left).offset(64);
        make.right.equalTo(self.contentView.mas_right).offset(-16);
    }];
    [self.detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLabel.mas_bottom).offset(16);
        make.left.equalTo(self.contentView.mas_left).offset(64);
        make.right.equalTo(self.contentView.mas_right).offset(-16);
    }];
    [self.separatorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.contentView);
        make.left.equalTo(self.titleLabel.mas_left);
        make.right.equalTo(self.contentView.mas_right);
        make.height.equalTo(@(2));
    }];
    [CHSImageHelper drawLineByImageView:self.separatorView withColor:[UIColor color_OCHexStr:@"3B71E8"]];
}

- (void)setModel:(CHSLocationModel *)model {
    self->_model = model;
    if (model.isSelect) {
        self.selectImageView.image = [UIImage t_imageNamed:@"checked_location"];
    } else {
        self.selectImageView.image = [UIImage t_imageNamed:@"none"];
    }
    self.titleLabel.text = model.name;
    self.detailLabel.text = model.locationText;
    self.separatorView.hidden = model.hidden;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:16];
        _titleLabel.textColor = [UIColor color_OCHexStr:@"#303133"];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.numberOfLines = 1;
    }
    return _titleLabel;
}

- (UILabel *)detailLabel {
    if (!_detailLabel) {
        _detailLabel = [[UILabel alloc] init];
        _detailLabel.font = [UIFont systemFontOfSize:14];
        _detailLabel.textColor = [UIColor color_OCHexStr:@"#303133"];
        _detailLabel.textAlignment = NSTextAlignmentLeft;
        _detailLabel.numberOfLines = 0;
    }
    return _detailLabel;
}

- (UIImageView *)selectImageView {
    if (!_selectImageView) {
        _selectImageView = [[UIImageView alloc] init];
    }
    return _selectImageView;
}

- (UIImageView *)separatorView {
    if (!_separatorView) {
        _separatorView = [[UIImageView alloc] init];
        _separatorView.hidden = YES;
    }
    return _separatorView;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    if (self.tableView.isEditing || self.tableView.isEditBegining) {
        return;
    }
}

@end




