//
//  HLMineViewController.m
//  VipVideo-iPhone
//
//  Created by LHL on 2018/9/17.
//  Copyright © 2018 SV. All rights reserved.
//

#import "HLMineViewController.h"
#import "Masonry.h"

@interface HLMineViewController ()
@property (weak, nonatomic) IBOutlet UISwitch *uaSwitch;

@end

@implementation HLMineViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.title = @"我的";
    
    UILabel *uaLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    uaLabel.font = [UIFont systemFontOfSize:15];
    uaLabel.textColor = [UIColor blackColor];
    uaLabel.text = @"使用PC版UsarAgent";
    [self.view addSubview:uaLabel];
    
    UISwitch *uaSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
    BOOL isOn = [[NSUserDefaults standardUserDefaults] boolForKey:HLVideoIphoneUAisOn];
    uaSwitch.on = isOn;
    [uaSwitch addTarget:self action:@selector(swichChange:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:uaSwitch];
    
    [uaLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(64+15);
        make.left.equalTo(self.view).offset(15);
    }];
    
    [uaSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(uaLabel);
        make.left.equalTo(uaLabel.mas_right).offset(20);
        make.height.mas_equalTo(30);
        make.width.mas_equalTo(50);
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)swichChange:(UISwitch *)sender {
    [[NSUserDefaults standardUserDefaults] setBool:sender.isOn forKey:HLVideoIphoneUAisOn];
    [[NSNotificationCenter defaultCenter] postNotificationName:HLVideoIphoneUAChange object:nil];
}


@end
