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
            
        default:
        case UIImageOrientationUp:
            exifOrientation = 1;
            break;
    }
    
//    exifOrientation = 1;
    
    NSDictionary *detectorOptions = [[NSDictionary alloc] initWithObjectsAndKeys:CIDetectorAccuracyLow, CIDetectorAccuracy, nil]; //apple
//	NSDictionary *detectorOptions = @{ CIDetectorAccuracy : CIDetectorAccuracyHigh };
	
    CIDetector *faceDetector = [CIDetector detectorOfType:CIDetectorTypeFace
                                                  context:nil
                                                  options:detectorOptions];
    faceDetector = [CIDetector detectorOfType:CIDetectorTypeFace context:nil options:detectorOptions]; // apple
//    imageOptions = [NSDictionary dictionaryWithObject:orientation forKey:CIDetectorImageOrientation];
    NSArray *features = [faceDetector featuresInImage:[CIImage imageWithCGImage:image.CGImage]
                                              options:@{CIDetectorImageOrientation:[NSNumber numberWithInt:exifOrientation]}];
    NSLog(@"Feature size: %d", features.count);
    NSLog(@"Feature size: %@", features);    
    
    
    //    UIImage *faceImage = picture;
    
    //    UIGraphicsBeginImageContextWithOptions(faceImage.size, YES, 0);
    //    [faceImage drawInRect:imageView.bounds];
    
    //    // Get image context reference
    //    CGContextRef context = UIGraphicsGetCurrentContext();
    //
    //    // Flip Context
    //    CGContextTranslateCTM(context, 0, CGRectGetHeight(imageView.bounds));
    //    CGContextScaleCTM(context, 1.0f, -1.0f);
    //
    //    CGFloat scale = [UIScreen mainScreen].scale;
    //
    //    if (scale > 1.0) {
    //        // Loaded 2x image, scale context to 50%
    //        CGContextScaleCTM(context, 0.5, 0.5);
    //    }
    //
    //    for (CIFaceFeature *feature in features) {
    ////        for (CIFeature *ff in features) {
    ////            NSLog(@"類型 %@, 位置 %f", ff.type, ff.bounds.size.width);
    //
    //
    //        CGContextSetRGBFillColor(context, 0.0f, 0.0f, 0.0f, 0.5f);
    //        CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
    //        CGContextSetLineWidth(context, 2.0f * scale);
    //        CGContextAddRect(context, feature.bounds);
    //        CGContextDrawPath(context, kCGPathFillStroke);
    //
    //        // Set red feature color
    //        CGContextSetRGBFillColor(context, 1.0f, 0.0f, 0.0f, 0.4f);
    //
    //        if (feature.hasLeftEyePosition) {
    //            [self drawFeatureInContext:context atPoint:feature.leftEyePosition];
    //        }
    //
    //        if (feature.hasRightEyePosition) {
    //            [self drawFeatureInContext:context atPoint:feature.rightEyePosition];
    //        }
    //
    //        if (feature.hasMouthPosition) {
    //            [self drawFeatureInContext:context atPoint:feature.mouthPosition];
    //        }
    //    }
    //
    //    self.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
    //    UIGraphicsEndImageContext();
    
    [UIAlertView bk_showAlertViewWithTitle:@"結果"
                                   message:NSPRINTF(@"有 %d 頭", features.count)
                         cancelButtonTitle:@"關閉"
                         otherButtonTitles:nil
                                   handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                       
                                   }];
}

-(IBAction)tapPhoto:(id)sender {
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
    imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
//    imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;

    imagePickerController.delegate = self;
    
    [self presentViewController:imagePickerController animated:YES completion:^{
    }];
    
}



#pragma mark - 基本

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIImagePickerControllerDelegate

// This method is called when an image has been chosen from the library or taken from the camera.
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    // 取照片
    UIImage* picture = [info objectForKey:UIImagePickerControllerOriginalImage];
    pImage = picture;
    
    self.imageView.image = pImage;

    
    [self dismissViewControllerAnimated:YES completion:^{
        [self recog];
    }];
    
    // 存照片
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        UIImage *image = picture;
//        [imageView setAutoresizingMask:(UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth)];
        UIImageWriteToSavedPhotosAlbum(image,
                                       self,
                                       @selector(image:finishedSavingWithError:contextInfo:),
                                       nil);
    }
    else if ([mediaType isEqualToString:(NSString *)kUTTypeMovie]) {
        
    }
    
}

// 在指定點畫圖
- (void)drawFeatureInContext:(CGContextRef)context atPoint:(CGPoint)featurePoint {
    CGFloat radius = 20.0f * [UIScreen mainScreen].scale;
    CGContextAddArc(context, featurePoint.x, featurePoint.y, radius, 0, M_PI * 2, 1);
    CGContextDrawPath(context, kCGPathFillStroke);
}


// 按取消
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:NULL];
}


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