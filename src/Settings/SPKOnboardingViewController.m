#import "../Localization/SPKLocalization.h"
#import "SPKOnboardingViewController.h"

@implementation SPKOnboardingViewController

- (NSArray<SPKPagedSheetPage *> *)buildPages {
    return @[
        [SPKPagedSheetPage pageWithTitle:SPKLocalizedString(@"Welcome to Sparkle")
                                    body:SPKLocalizedString(@"Everything you love about Instagram, with the controls it never gave you — built right in for a seamless experience.")
                                    rows:nil],
        [SPKPagedSheetPage pageWithTitle:SPKLocalizedString(@"What you can do")
                                    body:@""
                                    rows:@[
                                        @{ @"icon": @"download", @"text": SPKLocalizedString(@"Download anything in high quality") },
                                        @{ @"icon": @"sparkle_gallery", @"text": SPKLocalizedString(@"Save media to a private Gallery") },
                                        @{ @"icon": @"profile_analyzer", @"text": SPKLocalizedString(@"Track followers, unfollowers, and profile changes") },
                                        @{ @"icon": @"channels", @"text": SPKLocalizedString(@"Keep messages even after they're deleted") },
                                        @{ @"icon": @"eye", @"text": SPKLocalizedString(@"Control read receipts and typing status") },
                                        @{ @"icon": @"ads", @"text": SPKLocalizedString(@"Get rid of ads and annoyances") },
                                        @{ @"icon": @"", @"text": SPKLocalizedString(@"... and so much more!") },
                                    ]],
        [SPKPagedSheetPage pageWithTitle:SPKLocalizedString(@"Find Sparkle anytime")
                                    body:SPKLocalizedString(@"You can open Sparkle settings anytime by:")
                                    rows:@[
                                        @{ @"icon": @"settings_menu", @"text": SPKLocalizedString(@"Long pressing the menu on your profile") },
                                        @{ @"icon": @"home", @"text": SPKLocalizedString(@"Long pressing the Home tab") },
                                        @{ @"icon": @"action", @"text": SPKLocalizedString(@"Enabling the feed header button") },
                                    ]],
    ];
}

@end
