//
//  ScanningViewController.h
//  OCRTest
//
//  Created by Sen on 2019/6/5.
//  Copyright © 2019年 ocrtest. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ScanningViewController : UIViewController

@property (nonatomic, copy) void (^blockCatchPhoto)(UIImage* img);

@end

NS_ASSUME_NONNULL_END
