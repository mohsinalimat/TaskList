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
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"TableViewCellStyleDefault";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
        cell.textLabel.textColor = STDColorDefault;
        cell.textLabel.font = STDFontBlack36;
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
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
        if (![MFMailComposeViewController canSendMail]) {
            [UIAlertView showAlertViewWithMessage:@"Your device doesn't support Email!" title:@"Error"];
            return;
        }
        
        MFMailComposeViewController *mailComposeViewController = [MFMailComposeViewController new];
        mailComposeViewController.mailComposeDelegate = self;
        [mailComposeViewController setToRecipients:@[@"support@morevoltage.com"]];
        [self presentViewController:mailComposeViewController animated:YES completion:nil];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger numberOfRows = [self tableView:tableView numberOfRowsInSection:indexPath.section];
    return (CGRectGetHeight(tableView.frame) - 60) / numberOfRows;
}

#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
