//
//  UploadViewController.h
//  face-recog
//
//  Created by senao.mis on 2014/7/28.
//  Copyright (c) 2014年 senao.mis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <AFNetworking/AFNetworking.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import <SVProgressHUD/SVProgressHUD.h>
@interface UploadViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate> {
    BOOL isFromGallery;
    UIImage *pImg;
    NSURL *pUrl;
}

@property (nonatomic) IBOutlet UISegmentedControl *xSeg;
@property (nonatomic) IBOutlet UISegmentedControl *xSegCamera;
@property (nonatomic) IBOutlet UIImageView* xImgView;
/**
 *  上傳
*/
-(IBAction)tapUpload:(id)sender;
-(IBAction)tapPickPhoto:(id)sender;
-(IBAction)tapShowPhoto:(id)sender;
@end
