//
//  ViewController.h
//  face-recog
//
//  Created by senao.mis on 2014/7/16.
//  Copyright (c) 2014年 senao.mis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <KGModal/KGModal.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "UploadViewController.h"

@interface ViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate> {
    UIImage *pImage;
    CGFloat scale;
}

@property (nonatomic) IBOutlet UIImageView *imageView;
@property (nonatomic) IBOutlet UISegmentedControl *seg;
-(IBAction)tapPhoto:(id)sender;
-(IBAction)tapGoMoview:(id)sender;
-(IBAction)tapGoUpload:(id)sender;
@end
