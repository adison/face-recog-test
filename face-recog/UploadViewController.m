//
//  UploadViewController.m
//  face-recog
//
//  Created by senao.mis on 2014/7/28.
//  Copyright (c) 2014年 senao.mis. All rights reserved.
//

#import "UploadViewController.h"

@interface UploadViewController ()

@end

@implementation UploadViewController
@synthesize xImgView;

#pragma mark - 上傳
-(IBAction)tapShowPhoto:(id)sender {
    if (pUrl == nil) {
        // 沒東西
    }
    else {
        if ([[UIApplication sharedApplication] canOpenURL:pUrl]) {
            [[UIApplication sharedApplication] openURL:pUrl];
        }
        else {
            NSLog(@" 不該出現");
        }
    }
}

-(IBAction)tapUpload:(id)sender {
    // 把圖片更改尺寸、壓縮，改名字為 xx.png
    pUrl = nil;
    
    CGSize newSize = CGSizeMake(320, 480);
    UIGraphicsBeginImageContext(newSize);
    [pImg drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* vImg= UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    NSData *dataToUpload = UIImagePNGRepresentation(vImg);
    
    NSURL *url = [NSURL URLWithString:@"http://adison-murmur.herokuapp.com/"];
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    
    NSURLRequest *request = [httpClient
                             multipartFormRequestWithMethod:@"POST"
                             path:@"upload_file.php"
                             parameters:@{}
                             constructingBodyWithBlock: ^(id <AFMultipartFormData> formData) {
                                 [formData appendPartWithFileData:dataToUpload
                                                             name:@"file"
                                                         fileName:NSPRINTF(@"%i.png", (arc4random()%100))
                                                         mimeType:@"image/png"];
                             }];

    
    // 上傳到空間
    AFJSONRequestOperation *operation = [[AFJSONRequestOperation alloc] initWithRequest:request];
    [operation setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
        
        NSLog(@"Sent %lld of %lld bytes", totalBytesWritten, totalBytesExpectedToWrite);
        CGFloat progress = ((CGFloat)totalBytesWritten) / totalBytesExpectedToWrite * 100;

        [SVProgressHUD showProgress:50
                             status:[NSString stringWithFormat:@"%0.1f %%", progress]
                           maskType:SVProgressHUDMaskTypeBlack];
        
        NSLog(@"%0.1f %%", progress);
    }];
    
    // 檢查是否上傳成功？, 顯示心檔名
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id response) {
        [SVProgressHUD dismiss];
        NSLog(@"response string: %@", operation.responseString);
        if (response != nil) {
            NSDictionary *json = (NSDictionary*)response;
            
            [UIAlertView bk_showAlertViewWithTitle:@"上傳成功"
                                           message:NSPRINTF(@"檔案名稱%@, 位置: %@",
                                                            [json objectForKey:@"Upload"],
                                                            [json objectForKey:@"link"])
                                 cancelButtonTitle:@"關閉"
                                 otherButtonTitles:nil
                                           handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                               
                                           }];
            pUrl = [NSURL URLWithString:[json objectForKey:@"link"]];
            
        } else {
            [UIAlertView bk_showAlertViewWithTitle:@"上傳失敗"
                                           message:@"檔案儲存失敗"
                                 cancelButtonTitle:@"關閉"
                                 otherButtonTitles:nil
                                           handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                               
                                           }];
            NSLog(@"Data Error: %@", response);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [SVProgressHUD dismiss];
        [UIAlertView bk_showAlertViewWithTitle:@"上傳失敗"
                                       message:NSPRINTF(@"Error: %@", [error localizedDescription])
                             cancelButtonTitle:@"關閉"
                             otherButtonTitles:nil
                                       handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                           
                                       }];
    }];
    [httpClient enqueueHTTPRequestOperation:operation];
}


#pragma mark - 相片
-(IBAction)tapPickPhoto:(id)sender {
    UIImagePickerController *cameraUI = [[UIImagePickerController alloc] init];
    cameraUI.modalPresentationStyle = UIModalPresentationCurrentContext;
    if (isFromGallery) {
        cameraUI.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    else {
        cameraUI.sourceType = UIImagePickerControllerSourceTypeCamera;
        // 前鏡頭
//        cameraUI.cameraDevice = UIImagePickerControllerCameraDeviceFront;
        cameraUI.cameraDevice = UIImagePickerControllerCameraDeviceRear;
    }
    cameraUI.delegate = self;
    
    [self presentViewController:cameraUI animated:YES completion:^{
        
    }];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    // 取照片
    UIImage* picture = [info objectForKey:UIImagePickerControllerOriginalImage];
    pImg = picture;
    xImgView.image = picture;
    
    
    // 存起來照片
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    if (!isFromGallery
        && [mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        UIImage *image = picture;
        UIImageWriteToSavedPhotosAlbum(image,
                                       self,
                                       @selector(image:finishedSavingWithError:contextInfo:), // 要照標準命名
                                       nil);
    }
    else if ([mediaType isEqualToString:(NSString *)kUTTypeMovie]) {
        
    }
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
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

#pragma mark - 基本
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
