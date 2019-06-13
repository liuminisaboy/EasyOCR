//
//  ViewController.m
//  OCRTest
//
//  Created by Sen on 2019/6/4.
//  Copyright © 2019年 ocrtest. All rights reserved.
//

#import "ViewController.h"
#import "ScanningViewController.h"



//opencv 图像处理
#import <opencv2/opencv.hpp>
#import <opencv2/imgproc/types_c.h>
#import <opencv2/imgcodecs/ios.h>

//本地识别
#import <TesseractOCR/TesseractOCR.h>

@interface ViewController ()

@property (nonatomic, strong) UIImageView* catchImageView;
@property (nonatomic, strong) UITextField* resultField;

@property (nonatomic, copy) NSString* resultCode;

@end

@implementation ViewController


- (void)loadView{
    [super loadView];
    
    [self setupUI];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.


    
    /*
     
     
     opencv 图像处理 https://github.com/Haloing/IDCNRecognize/blob/master/OpencvDemo/ViewController.mm
     本地识别库 https://github.com/gali8/Tesseract-OCR-iOS
     eng.traineddata 文件直接从上面工程查找下载 Tesseract-OCR-iOS/Template Framework Project/Template Framework Project/tessdata/eng.traineddata
     
     */
    
}

#pragma mark - camera
- (void)btnOfCamera:(UIButton*)sender{
    
    UIAlertController* vc = [UIAlertController alertControllerWithTitle:@"OCR" message:@"拍照的话用真机弄" preferredStyle:UIAlertControllerStyleActionSheet];
    [vc addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [vc addAction:[UIAlertAction actionWithTitle:@"OpenCV + TesseractOCRiOS 识别" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self identifyWithType:1];
    }]];
    
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)identifyWithType:(int)type{
    
    self.resultField.text = nil;
    
    ScanningViewController* vc = [[ScanningViewController alloc] init];
    [self presentViewController:vc animated:YES completion:nil];
    [vc setBlockCatchPhoto:^(UIImage * _Nonnull img) {
        
        if (type == 0) {
            self.catchImageView.image = img;
        }else {
            UIImage* tmpimg = [self opencvScanCard:img];
            self.catchImageView.image = tmpimg;
            
        }
        
    }];
    
}

#pragma mark - OpenCV + TesseractOCRiOS 本地识别
//扫描身份证图片，并进行预处理，定位号码区域图片并返回
- (UIImage *)opencvScanCard:(UIImage *)image {
    
    //将UIImage转换成Mat
    cv::Mat resultImage;
    UIImageToMat(image, resultImage);
    
    //转为灰度图
    cvtColor(resultImage, resultImage, cv::COLOR_BGR2GRAY);
    
    //利用阈值二值化
    cv::adaptiveThreshold(resultImage, resultImage, 255, CV_ADAPTIVE_THRESH_GAUSSIAN_C, CV_THRESH_BINARY, 31, 40);

    //腐蚀，填充（腐蚀是让黑色点变大）
    cv::Mat erodeElement = getStructuringElement(cv::MORPH_RECT, cv::Size(25,25));
    cv::erode(resultImage, resultImage, erodeElement);
    
    //轮廊检测
    std::vector<std::vector<cv::Point>> contours;//定义一个容器来存储所有检测到的轮廊
    cv::findContours(resultImage, contours, CV_RETR_TREE, CV_CHAIN_APPROX_NONE, cvPoint(0, 0));
    
    //取出身份证号码区域
    std::vector<cv::Rect> rects;
    cv::Rect numberRect = cv::Rect(0,0,0,0);
    std::vector<std::vector<cv::Point>>::const_iterator itContours = contours.begin();
    for ( ; itContours != contours.end(); ++itContours) {
        cv::Rect rect = cv::boundingRect(*itContours);
        rects.push_back(rect);
        //算法原理
        if (rect.width > numberRect.width && rect.width > rect.height * 5) {
            numberRect = rect;
        }
    }
    //身份证号码定位失败
    if (numberRect.width == 0 || numberRect.height == 0) {
        return nil;
    }
    
    //定位成功成功，去原图截取身份证号码区域，并转换成灰度图、进行二值化处理
    cv::Mat matImage;
    UIImageToMat(image, matImage);
    resultImage = matImage(numberRect);
    
    cvtColor(resultImage, resultImage, cv::COLOR_BGR2GRAY);
    cv::threshold(resultImage, resultImage, 70, 255, CV_THRESH_BINARY);
    
    //将Mat转换成UIImage
    UIImage* endImage = MatToUIImage(resultImage);
    
    //识别
    [self tesseractRecognizeImage:endImage compleate:^(NSString *text) {
         self.resultField.text = text;
    }];
    
    return endImage;
}

- (void)tesseractRecognizeImage:(UIImage *)image compleate:(void (^)(NSString* text))compleate {
    
    G8Tesseract *tesseract = [[G8Tesseract alloc]initWithLanguage:@"eng"];
    //模式
    tesseract.engineMode = G8OCREngineModeTesseractOnly;
    tesseract.maximumRecognitionTime = 10;
    tesseract.pageSegmentationMode = G8PageSegmentationModeAuto;
    tesseract.image = image;
    
    [tesseract recognize];
    
    //执行回调
    NSLog(@"激活码 %@",tesseract.recognizedText);
    compleate(tesseract.recognizedText);
}

#pragma mark - ui
- (void)setupUI {
    
    _catchImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.width*5/8)];
    _catchImageView.backgroundColor = [UIColor lightGrayColor];
    _catchImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:_catchImageView];
    
    
    UILabel* activation = [[UILabel alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(_catchImageView.frame), 60, 50)];
    activation.text = @"激活码";
    activation.font = [UIFont systemFontOfSize:14];
    [self.view addSubview:activation];
    
    _resultField = [[UITextField alloc] initWithFrame:CGRectMake(CGRectGetMaxX(activation.frame), CGRectGetMaxY(_catchImageView.frame), self.view.bounds.size.width-CGRectGetMaxX(activation.frame)-10-44, 50)];
    _resultField.keyboardType = UIKeyboardTypeNumberPad;
    _resultField.placeholder = @"填写激活码";
    _resultField.font = [UIFont systemFontOfSize:14];
    [self.view addSubview:_resultField];
    
    UIButton* camera = [UIButton buttonWithType:UIButtonTypeSystem];
    camera.frame = CGRectMake(CGRectGetMaxX(_resultField.frame), CGRectGetMaxY(_catchImageView.frame), 44, 50);
    [camera setTitle:@"相机" forState:UIControlStateNormal];
    [camera addTarget:self action:@selector(btnOfCamera:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:camera];
    
}


@end
