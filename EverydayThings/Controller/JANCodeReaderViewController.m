//
//  JANCodeReaderViewController.m
//  AmazonProductAdvertisingAPI
//
//  Created by Daisuke Hirata on 2014/05/01.
//  Copyright (c) 2014 Daisuke Hirata. All rights reserved.
//

#import "JANCodeReaderViewController.h"
#import "AmazonSearchResultTableViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface JANCodeReaderViewController () <AVCaptureMetadataOutputObjectsDelegate>
@property (strong, nonatomic) AVCaptureSession *session;
@property (weak, nonatomic) IBOutlet UIView *captureView;
@property (weak, nonatomic) IBOutlet UILabel *captureOverlayLabel;
@end

@implementation JANCodeReaderViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.session = [[AVCaptureSession alloc] init];
    
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    AVCaptureDevice *device = nil;
    AVCaptureDevicePosition camera = AVCaptureDevicePositionBack; // Back or Front
    for (AVCaptureDevice *d in devices) {
        device = d;
        if (d.position == camera) {
            break;
        }
    }
    
    NSError *error = nil;
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device
                                                                        error:&error];
    if (input) {
        [self.session addInput:input];
        
        AVCaptureMetadataOutput *output = [AVCaptureMetadataOutput new];
        [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
        [self.session addOutput:output];
        
        // EAN13 EAN8
        output.metadataObjectTypes = @[AVMetadataObjectTypeEAN13Code];
        // QR code
        //output.metadataObjectTypes = @[AVMetadataObjectTypeQRCode];
        // All
        //output.metadataObjectTypes = output.availableMetadataObjectTypes;
        
        NSLog(@"%@", output.availableMetadataObjectTypes);
        NSLog(@"%@", output.metadataObjectTypes);
        
        [self.session startRunning];
        
        AVCaptureVideoPreviewLayer *preview = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
        preview.frame = self.captureView.bounds;
        preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
        [self.captureView.layer addSublayer:preview];
        
        // overlay
        [self.captureView addSubview:self.captureOverlayLabel];
        
        self.navigationItem.rightBarButtonItem = nil;
    } else {
        // for iOS simulator
        NSLog(@"%@ %ld %@",[error domain],(long)[error code],[[error userInfo] description]);
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.tabBarController.tabBar.hidden = YES;
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    NSLog(@"==");
    for (AVMetadataObject *metadata in metadataObjects) {
        if ([metadata.type isEqualToString:AVMetadataObjectTypeQRCode]) {
            NSString *qrcode = [(AVMetadataMachineReadableCodeObject *)metadata stringValue];
            NSLog(@"%@", qrcode);
        } else if ([metadata.type isEqualToString:AVMetadataObjectTypeEAN13Code]) {
            [self.session stopRunning];
            NSString *ean13 = [(AVMetadataMachineReadableCodeObject *)metadata stringValue];
            NSLog(@"%@", ean13);
            AmazonSearchResultTableViewController *controller =
            [[self storyboard] instantiateViewControllerWithIdentifier:@"AmazonSearchResultTableViewController"];
            controller.janCode = ean13;
            [self.navigationController pushViewController:controller animated:YES];
        }
    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // for iOS simulator
    if ([segue.destinationViewController isKindOfClass:[AmazonSearchResultTableViewController class]]) {
        AmazonSearchResultTableViewController *controller =
        [segue destinationViewController];
        [self.session stopRunning];
        if ([self.captureOverlayLabel.text isEqualToString:@"Scanning a bar code"]) {
            controller.janCode = @"4901340184527";
        }
    }
}

@end
