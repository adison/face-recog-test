//
//  ViewController.m
//  face-recog
//
//  Created by senao.mis on 2014/7/16.
//  Copyright (c) 2014年 senao.mis. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController
@synthesize imageView;
@synthesize seg;

-(IBAction)tapGoUpload:(id)sender {
    UploadViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"UploadViewController"];
    [self.navigationController pushViewController:vc animated:YES];
}

-(IBAction)tapGoMoview:(id)sender {

//    UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, YES, 0);
    UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, YES, 0);

    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    
    CGAffineTransform tran = CGAffineTransformIdentity;
//    tran = CGAffineTransformScale(tran, 1.0f, -1.0f);
//    tran = CGAffineTransformTranslate(tran, 0.0f, -img.size.height);
    
    
    
    CGPoint pp = CGPointMake(300, 20);
    CGFloat radius = 20;

    CGContextSetLineWidth(ctx, 2.0f);// * scale);

    CGContextSetRGBFillColor(ctx, 1.0f, 0.0f, 0.0f, 0.4f);

    CGContextAddArc(ctx, pp.x, pp.y, radius, 0, M_PI * 2, 1);
    CGContextDrawPath(ctx, kCGPathFillStroke);
    
    CGAffineTransformScale(tran, 0.5f, 0.5f);
    
    self.imageView.image = UIGraphicsGetImageFromCurrentImageContext();

    UIGraphicsEndImageContext();
    
}

#pragma mark - test


-(void)recog {
    UIImage *image = [pImage copy];
    int exifOrientation;

    // 偵測方向
    switch (image.imageOrientation) {
        case UIImageOrientationDown:
            exifOrientation = 3;
            break;
        case UIImageOrientationLeft:
            exifOrientation = 8;
            break;
        case UIImageOrientationRight:
            exifOrientation = 6;
            break;
        case UIImageOrientationUpMirrored:
            exifOrientation = 2;
            break;
        case UIImageOrientationDownMirrored:
            exifOrientation = 4;
            break;
        case UIImageOrientationLeftMirrored:
            exifOrientation = 5;
            break;
        case UIImageOrientationRightMirrored:
            exifOrientation = 7;
            break;
        case UIImageOrientationUp:
            exifOrientation = 1;
            break;
    }
    
    NSDictionary *detectorOptions = @{ CIDetectorAccuracy : CIDetectorAccuracyHigh };
	
    CIDetector *faceDetector = [CIDetector detectorOfType:CIDetectorTypeFace
                                                  context:nil
                                                  options:detectorOptions];
    NSArray *features = [faceDetector featuresInImage:[CIImage imageWithCGImage:image.CGImage]
                                              options:@{CIDetectorImageOrientation:@(exifOrientation)}];
    UIImage *faceImage = image;

//    UIGraphicsBeginImageContextWithOptions(faceImage.size, YES, 0);
    UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, YES, 0);
    [faceImage drawInRect:imageView.bounds];

    // Get image context reference
    CGContextRef context = UIGraphicsGetCurrentContext();

    // Flip Context
    CGContextTranslateCTM(context, 0, CGRectGetHeight(imageView.bounds));
    CGContextScaleCTM(context, 1.0f, -1.0f);

    scale = image.size.height/[UIScreen mainScreen].bounds.size.height;

    CGAffineTransform transform = CGAffineTransformMakeScale(1, -1);
    transform = CGAffineTransformTranslate(transform, 0, -imageView.bounds.size.height);

    
    if (scale > 1.0) {
        // Loaded 2x image, scale context to 50%
        CGContextScaleCTM(context, 0.5, 0.5);
    }
    for (CIFaceFeature *feature in features) {
        // 底層顏色
        CGContextSetRGBFillColor(context, 0.0f, 0.0f, 0.0f, 0.5f);
        // 筆觸顏色
        CGContextSetStrokeColorWithColor(context, [UIColor redColor].CGColor);
        // 線條寬度
        CGContextSetLineWidth(context, 2.0f);// * scale);
        // 加個框
        CGRect b = feature.bounds;
//        b.origin.x /= scale;
//        b.origin.y /= scale;
//        b.origin.y = imageView.bounds.size.height - b.origin.y;
//        b.size.height /=scale;
//        b.size.width /= scale;
        CGContextAddRect(context, b);
        // 畫線
        CGContextDrawPath(context, kCGPathFillStroke);

        // Set red feature color
        CGContextSetRGBFillColor(context, 1.0f, 0.0f, 0.0f, 0.4f);

//        CGPoint c;
        if (feature.hasLeftEyePosition) {
            CGContextSetRGBFillColor(context, 0.0f, 1.0f, 0.0f, 0.8f);
            NSLog(@"x %f, y %f", feature.leftEyePosition.x, feature.leftEyePosition.y);
            const CGPoint leftEyePos = CGPointApplyAffineTransform(feature.leftEyePosition, transform);
            NSLog(@"x %f, y %f", leftEyePos.x, leftEyePos.y);
            [self drawFeatureInContext:context atPoint:leftEyePos];
        }

        if (feature.hasRightEyePosition) {
            CGContextSetRGBFillColor(context, 0.0f, 0.0f, 1.0f, 0.8f);
            const CGPoint rightEyePos = CGPointApplyAffineTransform(feature.rightEyePosition, transform);
            [self drawFeatureInContext:context atPoint:rightEyePos];

//            [self drawFeatureInContext:context atPoint:c];
        }

        if (feature.hasMouthPosition) {
            CGContextSetRGBFillColor(context, 1.0f, 1.0f, 1.0f, 0.8f);
            const CGPoint mouthPos = CGPointApplyAffineTransform(feature.mouthPosition, transform);
            [self drawFeatureInContext:context atPoint:mouthPos];

//            [self drawFeatureInContext:context atPoint:c];
        }
        
        [self xdrawFeatureInContext:context atPoint:CGPointMake(300, 300)];
    }
    
    
    self.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [UIAlertView bk_showAlertViewWithTitle:@"結果"
                                   message:NSPRINTF(@"有 %d 頭", features.count)
                         cancelButtonTitle:@"關閉"
                         otherButtonTitles:nil
                                   handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                       
                                   }];
}

-(IBAction)tapPhoto:(id)sender {
    UIImagePickerController *cameraUI = [[UIImagePickerController alloc] init];
    cameraUI.modalPresentationStyle = UIModalPresentationCurrentContext;
    cameraUI.sourceType = UIImagePickerControllerSourceTypeCamera;
//    imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    // 前鏡頭
    if ([seg selectedSegmentIndex]==1) {
        cameraUI.cameraDevice = UIImagePickerControllerCameraDeviceFront;
//        cameraUI.cameraViewTransform = CGAffineTransformScale(cameraUI.cameraViewTransform, -1, 1);
        
    }
    else {
        cameraUI.cameraDevice = UIImagePickerControllerCameraDeviceRear;
    }
    
    

    cameraUI.delegate = self;
    
    [self presentViewController:cameraUI animated:YES completion:^{

    }];
}

#pragma mark - 基本
-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
}
- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    // 取照片
    UIImage* picture = [info objectForKey:UIImagePickerControllerOriginalImage];
    pImage = picture;
    
    self.imageView.image = pImage;
    
    [self dismissViewControllerAnimated:YES completion:^{
        [self recog];
    }];
    
    // 存起來照片
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        UIImage *image = picture;
        if ([seg selectedSegmentIndex]==1) {
//            image = [UIImage imageWithCGImage:picture.CGImage scale:picture.scale orientation:UIImageOrientationLeftMirrored];
        }

//        [imageView setAutoresizingMask:(UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth)];
        UIImageWriteToSavedPhotosAlbum(image,
                                       self,
                                       @selector(image:finishedSavingWithError:contextInfo:), // 要照標準命名
                                       nil);
    }
    else if ([mediaType isEqualToString:(NSString *)kUTTypeMovie]) {
        
    }
    
}


// 在指定點畫圖
- (void)xdrawFeatureInContext:(CGContextRef)context atPoint:(CGPoint)featurePoint {
    
    //    featurePoint.x /= scale;
    //    featurePoint.y /= scale; //(imageView.bounds.size.height) - (featurePoint.y/scale);
    //    featurePoint.y /= scale; //(imageView.bounds.size.height*2) - (featurePoint.y/scale);
    NSLog(@"x %f, y %f", featurePoint.x, featurePoint.y);
    
    CGFloat radius = 30.0f;// * [UIScreen mainScreen].scale/scale;
    CGContextAddArc(context, featurePoint.x, featurePoint.y, radius, 0, M_PI * 2, 1);
    CGContextDrawPath(context, kCGPathFillStroke);
}


// 在指定點畫圖
- (void)drawFeatureInContext:(CGContextRef)context atPoint:(CGPoint)featurePoint {
    
//    featurePoint.x /= scale;
//    featurePoint.y /= scale; //(imageView.bounds.size.height) - (featurePoint.y/scale);
//    featurePoint.y /= scale; //(imageView.bounds.size.height*2) - (featurePoint.y/scale);
    NSLog(@"x %f, y %f", featurePoint.x, featurePoint.y);
    
    CGFloat radius = 20.0f * [UIScreen mainScreen].scale/scale;
    CGContextAddArc(context, featurePoint.x, featurePoint.y, radius, 0, M_PI * 2, 1);
    CGContextDrawPath(context, kCGPathFillStroke);
}


// 按取消
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

// 照片儲存完成
-(void)image:(UIImage *)image finishedSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if (error) {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle: @"Save failed"
                              message: @"Failed to save image"\
                              delegate: nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
    }
}


@end