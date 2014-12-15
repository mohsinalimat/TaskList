//
//  STDSettingsViewController.m
//  STD
//
//  Created by Lasha Efremidze on 5/25/14.
//  Copyright (c) 2014 More Voltage Inc. All rights reserved.
//

#import "STDSettingsViewController.h"

#import "iRate.h"
#import <MessageUI/MessageUI.h>

@interface STDSettingsViewController () <UITableViewDataSource, UITableViewDelegate, MFMailComposeViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation STDSettingsViewController

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"TableViewCellStyleDefault";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
        cell.textLabel.textColor = [UIColor colorWithHue:(210.0f / 360.0f) saturation:0.94f brightness:1.0f alpha:1.0f];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:18.0f];
    }
    
    if (indexPath.row == 0) {
        cell.textLabel.text = @"Rate Us";
    } else if (indexPath.row == 1) {
        cell.textLabel.text = @"Contact Us";
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 0) {
        [[iRate sharedInstance] promptForRating];
    } else if (indexPath.row == 1) {
        if ([MFMailComposeViewController canSendMail]) {
            MFMailComposeViewController *mailComposeViewController = [MFMailComposeViewController new];
            mailComposeViewController.mailComposeDelegate = self;
            [mailComposeViewController setToRecipients:@[@"support@morevoltage.com"]];
            [self presentViewController:mailComposeViewController animated:YES completion:nil];
        }
    }
}

#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
