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
@property (weak, nonatomic) IBOutlet UILabel *janCodeLabel;
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
        output.metadataObjectTypes = @[AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code];
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
        
        UILabel *overlayLabel = [[UILabel alloc] initWithFrame:self.captureOverlayLabel.frame];
        overlayLabel.backgroundColor = [UIColor clearColor];
        overlayLabel.font = [UIFont fontWithName:@"HelveticaNeue" size: 22.0];
        overlayLabel.textColor = [UIColor lightTextColor];
        overlayLabel.textAlignment = NSTextAlignmentCenter;
        overlayLabel.text = @"Scanning a bar code ...";
        [self.captureView addSubview:overlayLabel];
    } else {
        NSLog(@"%@ %ld %@",[error domain],(long)[error code],[[error userInfo] description]);
    }
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    NSLog(@"==");
    for (AVMetadataObject *metadata in metadataObjects) {
        if ([metadata.type isEqualToString:AVMetadataObjectTypeQRCode]) {
            NSString *qrcode = [(AVMetadataMachineReadableCodeObject *)metadata stringValue];
            NSLog(@"%@", qrcode);
        } else if ([metadata.type isEqualToString:AVMetadataObjectTypeEAN13Code]) {
            NSString *ean13 = [(AVMetadataMachineReadableCodeObject *)metadata stringValue];
            NSLog(@"%@", ean13);
            self.janCodeLabel.text = ean13;
        } else if ([metadata.type isEqualToString:AVMetadataObjectTypeEAN8Code]) {
            NSString *ean8 = [(AVMetadataMachineReadableCodeObject *)metadata stringValue];
            NSLog(@"%@", ean8);
            self.janCodeLabel.text = ean8;
        }
    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:[AmazonSearchResultTableViewController class]]) {
        AmazonSearchResultTableViewController *controller =
        [segue destinationViewController];
        if (![self.janCodeLabel.text isEqualToString:@"jan code here"]) {
            controller.janCode = self.janCodeLabel.text;
        } else {
            controller.janCode = @"4901340184527";
        }
    }
}

@end
