//
//  ScanningViewController.m
//  OCRTest
//
//  Created by Sen on 2019/6/5.
//  Copyright © 2019年 ocrtest. All rights reserved.
//

#import "ScanningViewController.h"
#import "LFCamera.h"

@interface ScanningViewController ()

@property (strong, nonatomic) LFCamera *lfCamera;

@end

@implementation ScanningViewController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.lfCamera = [[LFCamera alloc] initWithFrame:self.view.bounds];
    
    CGFloat ww = self.view.bounds.size.width-40;
    CGFloat hh = ww*5/8;
    self.lfCamera.effectiveRect = CGRectMake(20, (self.view.bounds.size.height-hh)*0.5, ww, hh);
    [self.view insertSubview:self.lfCamera atIndex:0];
    
    //请将卡片置于此区域，以便于更好的识别
    UILabel* alertlb = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.lfCamera.effectiveRect), self.view.bounds.size.width, 40)];
    alertlb.text = @"请将卡片置于此区域，以便于更好的识别";
    alertlb.font = [UIFont systemFontOfSize:14];
    alertlb.textAlignment = 1;
    alertlb.textColor = [UIColor whiteColor];
    [self.view addSubview:alertlb];
    
    UIButton* cancel = [UIButton buttonWithType:UIButtonTypeSystem];
    cancel.frame = CGRectMake(20, self.view.bounds.size.height-100, 60, 44);
    [cancel setTitle:@"取消" forState:UIControlStateNormal];
    [cancel addTarget:self action:@selector(btnOfCancel:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cancel];
    
    UIButton* done = [UIButton buttonWithType:UIButtonTypeSystem];
    done.backgroundColor = [UIColor whiteColor];
    done.layer.cornerRadius = 40;
    done.frame = CGRectMake((self.view.bounds.size.width-80)*0.5, self.view.bounds.size.height-80-56, 80, 80);
    [done setTitle:@"拍照" forState:UIControlStateNormal];
    [done addTarget:self action:@selector(btnOfDone:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:done];
    
    UIButton* photo = [UIButton buttonWithType:UIButtonTypeSystem];
    photo.frame = CGRectMake(self.view.bounds.size.width-60-20, self.view.bounds.size.height-100, 60, 44);
    [photo setTitle:@"照片" forState:UIControlStateNormal];
    [photo addTarget:self action:@selector(btnOfPhoto:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:photo];
}

- (void)btnOfCancel:(UIButton*)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)btnOfDone:(UIButton*)sender{
    
    __weak typeof(self) weakSelf = self;
    [self.lfCamera takePhoto:^(UIImage *img) {
        
        __strong typeof(self) strongSelf = weakSelf;
        if (strongSelf.blockCatchPhoto) {
            strongSelf.blockCatchPhoto(img);
            [self dismissViewControllerAnimated:YES completion:nil];
        }
        
    }];
}
- (void)btnOfPhoto:(UIButton*)sender{
    if (self.blockCatchPhoto) {
        self.blockCatchPhoto([UIImage imageNamed:@"222.jpg"]);
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
