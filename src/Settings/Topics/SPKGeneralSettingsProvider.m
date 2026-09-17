#import "../../Localization/SPKLocalization.h"
#import "SPKGeneralSettingsProvider.h"

#import "../../AssetUtils.h"
#import "../../Shared/Account/SPKAccountManager.h"
#import "../../Shared/ActionButton/ActionButtonCore.h"
#import "../../Shared/UI/SPKIGAlertPresenter.h"
#import "../../Utils.h"
#import "../SPKActionSectionIconPickerViewController.h"
#import "../SPKAppIconCatalog.h"
#import "../SPKAppIconPickerViewController.h"
#import "../SPKTopicSettingsSupport.h"

@implementation SPKGeneralSettingsProvider

+ (SPKSetting *)defaultMenuIconSetting {
    SPKActionSectionIconPickerViewController *controller =
        [[SPKActionSectionIconPickerViewController alloc] initWithSelectedIconName:SPKActionButtonOpenMenuIconName()
                                                                          onSelect:^(NSString *iconName) {
                                                                              SPKPreferenceSetObject(iconName.length > 0 ? iconName : @"action", @"general_action_btn_default_menu_icon");
                                                                              [[NSNotificationCenter defaultCenter] postNotificationName:SPKActionButtonConfigurationDidChangeNotification object:nil];
                                                                          }];
    controller.title = SPKLocalizedString(@"Open Menu Icon");

    SPKSetting *setting = [SPKSetting navigationCellWithTitle:SPKLocalizedString(@"Open Menu Icon")
                                                     subtitle:@""
                                                         icon:SPKSettingsIcon(@"action")
                                               viewController:controller];
    // The row's icon mirrors the chosen glyph, so the (cryptic) catalog name is
    // redundant as accessory text — let the adaptive icon convey the selection.
    setting.iconProvider = ^UIImage * {
        return SPKSettingsIcon(SPKActionButtonOpenMenuIconName());
    };
    return setting;
}

+ (SPKSetting *)appIconSetting {
    SPKAppIconPickerViewController *controller = [[SPKAppIconPickerViewController alloc] initWithSelectedIdentifier:[SPKAppIconCatalog currentAppIconIdentifier]
                                                                                                           onSelect:nil];
    SPKSetting *setting = [SPKSetting navigationCellWithTitle:SPKLocalizedString(@"App Icon")
                                                     subtitle:@""
                                                         icon:SPKSettingsIcon(@"app")
                                               viewController:controller];
    setting.accessoryTextProvider = ^NSString * {
        SPKAppIconItem *currentIcon = [SPKAppIconCatalog currentAppIcon];
        return currentIcon.displayName.length > 0 ? currentIcon.displayName : @"Default";
    };
    return setting;
}

+ (SPKSetting *)perAccountSetting {
    SPKSetting *setting = [SPKSetting switchCellWithTitle:SPKLocalizedString(@"Per-Account Settings")
                                                     icon:SPKSettingsIcon(@"user_circle")
                                              defaultsKey:kSPKPrefPerAccountSettings];
    // Changes which key namespace every feature reads, and most enabled-state is
    // captured at hook install, so a restart applies it cleanly.
    setting.requiresRestart = YES;
    return setting;
}

+ (SPKSetting *)perAccountInfoSetting {
    return [SPKSetting buttonCellWithTitle:SPKLocalizedString(@"How It Works")
                                  subtitle:nil
                                      icon:SPKSettingsIcon(@"info")
                                    action:^{
                                        NSString *message =
                                            SPKLocalizedString(@"Each logged-in account gets its own Sparkle settings. A newly seen ")
                                            SPKLocalizedString(@"account starts from your current settings until you change something.\n\n")
                                            SPKLocalizedString(@"These stay shared across all accounts:\n")
                                            SPKLocalizedString(@"•  App icon\n")
                                            SPKLocalizedString(@"•  Appearance & Liquid Glass\n")
                                            SPKLocalizedString(@"•  Tab bar order & visibility\n")
                                            @"•  Quick access shortcuts (Settings & Gallery)\n"
                                            @"•  Main feed mode (For You / Following)\n"
                                            SPKLocalizedString(@"•  Disable video autoplay\n")
                                            SPKLocalizedString(@"•  Reels doom scroll & limits\n")
                                            SPKLocalizedString(@"•  Hide UI on capture\n")
                                            SPKLocalizedString(@"•  Download encoding settings\n")
                                            SPKLocalizedString(@"•  Gallery view, sort & lock\n")
                                            SPKLocalizedString(@"•  Fix duplicate notifications\n")
                                            SPKLocalizedString(@"•  Disable All (master switch)\n\n")
                                            SPKLocalizedString(@"Gallery media ownership is controlled separately in Gallery settings.");

                                        [SPKIGAlertPresenter presentAlertFromViewController:topMostController()
                                                                                      title:SPKLocalizedString(@"Per-Account Settings")
                                                                                    message:message
                                                                                    actions:@[ [SPKIGAlertAction actionWithTitle:SPKLocalizedString(@"OK") style:SPKIGAlertActionStyleCancel handler:nil] ]];
                                    }];
}

+ (SPKSetting *)rootSetting {
    SPKSetting *clearCacheSetting = [SPKSetting buttonCellWithTitle:SPKLocalizedString(@"Clear Cache")
                                                           subtitle:@""
                                                               icon:SPKSettingsIcon(@"trash")
                                                             action:^(void) {
                                                                 unsigned long long freedBytes = [SPKUtils cleanCacheReturningFreedBytes];
                                                                 NSString *subtitle = freedBytes > 0
                                                                                          ? [NSString stringWithFormat:SPKLocalizedString(@"Freed %@"), [NSByteCountFormatter stringFromByteCount:(long long)freedBytes countStyle:NSByteCountFormatterCountStyleFile]]
                                                                                          : SPKLocalizedString(@"Cache was already empty");
                                                                 SPKNotify(kSPKNotificationSettingsClearCache, SPKLocalizedString(@"Cache cleared"), subtitle, @"circle_check_filled", SPKNotificationToneForIconResource(@"circle_check_filled"));
                                                             }];
    clearCacheSetting.tintColor = [SPKUtils SPKColor_InstagramDestructive];
    clearCacheSetting.iconTintColor = [SPKUtils SPKColor_InstagramDestructive];
    clearCacheSetting.accessoryTextProvider = ^NSString * {
        return [SPKUtils formattedCacheSize];
    };

    return SPKTopicNavigationSetting(SPKLocalizedString(@"General"), @"settings", 24.0, @[
        SPKTopicSection(@"Behavior", @[
            [SPKSetting switchCellWithTitle:SPKLocalizedString(@"Copy Text")
                                       icon:SPKSettingsIcon(@"text")
                                defaultsKey:@"general_copy_text"],
            [SPKSetting switchCellWithTitle:SPKLocalizedString(@"No Recent Searches")
                                       icon:SPKSettingsIcon(@"search")
                                defaultsKey:@"general_no_recent_searches"],
            [SPKSetting switchCellWithTitle:SPKLocalizedString(@"Copy Links Without Tracking")
                                       icon:SPKSettingsIcon(@"user_unfollow")
                                defaultsKey:@"general_strip_share_link_tracking"],
            [SPKSetting switchCellWithTitle:SPKLocalizedString(@"Hold Send to Copy Link")
                                       icon:SPKSettingsIcon(@"link")
                                defaultsKey:@"general_hold_send_copy_link"],
        ],
                        SPKLocalizedString(@"1. Long press on text fields across the app to copy.\n")
                        SPKLocalizedString(@"2. Search bars will no longer save recent searches.\n")
                        SPKLocalizedString(@"3. Remove the user and tracking identifiers from copied links.\n")
                        SPKLocalizedString(@"4. Long press the send/share button to copy the post link.")),
        SPKTopicSection(@"Sharing", @[
            [SPKSetting switchCellWithTitle:SPKLocalizedString(@"Hide Create Group Button")
                                       icon:SPKSettingsIcon(@"group")
                                defaultsKey:@"general_hide_create_group"],
            [SPKSetting switchCellWithTitle:SPKLocalizedString(@"Confirm Create Group")
                                       icon:SPKSettingsIcon(@"group")
                                defaultsKey:@"general_confirm_create_group"],
            [SPKSetting switchCellWithTitle:SPKLocalizedString(@"Confirm Sending Post")
                                       icon:SPKSettingsIcon(@"messages")
                                defaultsKey:@"general_confirm_send"],
        ],
                        SPKLocalizedString(@"1. Hide the create group button from the Instagram send/share sheet.\n")
                        SPKLocalizedString(@"2. Show a confirmation alert when you try to create a group.\n")
                        SPKLocalizedString(@"3. Show a confirmation alert when sending a post.")),
        SPKTopicSection(@"Recommendations", @[
            [SPKSetting navigationCellWithTitle:SPKLocalizedString(@"Ads")
                                       subtitle:@""
                                           icon:SPKSettingsIcon(@"ads")
                                    navSections:@[
                                        SPKTopicSection(SPKLocalizedString(@"Ads"), @[
                                            [SPKSetting switchCellWithTitle:SPKLocalizedString(@"Hide Feed Ads")
                                                                defaultsKey:@"general_hide_ads_feed"],
                                            [SPKSetting switchCellWithTitle:SPKLocalizedString(@"Hide Story Ads")
                                                                defaultsKey:@"general_hide_ads_stories"],
                                            [SPKSetting switchCellWithTitle:SPKLocalizedString(@"Hide Reels Ads")
                                                                defaultsKey:@"general_hide_ads_reels"],
                                            [SPKSetting switchCellWithTitle:SPKLocalizedString(@"Hide Explore Ads")
                                                                defaultsKey:@"general_hide_ads_explore"],
                                            [SPKSetting switchCellWithTitle:SPKLocalizedString(@"Hide Reels Shopping CTA")
                                                                defaultsKey:@"general_hide_reels_shopping_cta"]
                                        ],
                                                        nil)
                                    ]],
            [SPKSetting navigationCellWithTitle:SPKLocalizedString(@"Meta AI")
                                       subtitle:@""
                                           icon:SPKSettingsIcon(@"meta_ai")
                                    navSections:@[
                                        SPKTopicSection(@"", @[
                                            [SPKSetting switchCellWithTitle:SPKLocalizedString(@"Hide in Direct")
                                                                defaultsKey:@"general_hide_meta_ai_msgs"],
                                            [SPKSetting switchCellWithTitle:SPKLocalizedString(@"Hide in Explore & Search")
                                                                defaultsKey:@"general_hide_meta_ai_explore"],
                                            [SPKSetting switchCellWithTitle:SPKLocalizedString(@"Hide in Comments")
                                                                defaultsKey:@"general_hide_meta_ai_comments"],
                                            [SPKSetting switchCellWithTitle:SPKLocalizedString(@"Hide in Creation Tools")
                                                                defaultsKey:@"general_hide_meta_ai_creation"],
                                            [SPKSetting switchCellWithTitle:SPKLocalizedString(@"Hide Global AI Chrome")
                                                                defaultsKey:@"general_hide_meta_ai_global"]
                                        ],
                                                        SPKLocalizedString(@"Direct includes inbox, composer, recipients, themes, and message menus. Global chrome covers generic Meta AI buttons, placeholders, and branded entry points."))
                                    ]],
            [SPKSetting navigationCellWithTitle:SPKLocalizedString(@"Suggested Users")
                                       subtitle:@""
                                           icon:SPKSettingsIcon(@"users")
                                    navSections:@[
                                        SPKTopicSection(SPKLocalizedString(@"Suggested Users"), @[
                                            [SPKSetting switchCellWithTitle:SPKLocalizedString(@"Hide Feed Suggestions")
                                                                defaultsKey:@"general_hide_suggested_users_feed"],
                                            [SPKSetting switchCellWithTitle:SPKLocalizedString(@"Hide Reels Suggestions")
                                                                defaultsKey:@"general_hide_suggested_users_reels"],
                                            [SPKSetting switchCellWithTitle:SPKLocalizedString(@"Hide Direct Suggestions")
                                                                defaultsKey:@"general_hide_suggested_users_msgs"],
                                            [SPKSetting switchCellWithTitle:SPKLocalizedString(@"Hide Search Suggestions")
                                                                defaultsKey:@"general_hide_suggested_users_search"],
                                            [SPKSetting switchCellWithTitle:SPKLocalizedString(@"Hide Profile Suggestions")
                                                                defaultsKey:@"general_hide_suggested_users_profile"],
                                            [SPKSetting switchCellWithTitle:SPKLocalizedString(@"Hide Activity Suggestions")
                                                                defaultsKey:@"general_hide_suggested_users_activity"],
                                            [SPKSetting switchCellWithTitle:SPKLocalizedString(@"Hide Follow-List Suggestions")
                                                                defaultsKey:@"general_hide_suggested_users_follow_lists"],
                                            [SPKSetting switchCellWithTitle:SPKLocalizedString(@"Hide Subscription Suggestions")
                                                                defaultsKey:@"general_hide_suggested_users_subscriptions"]
                                        ],
                                                        nil)
                                    ]]
        ],
                        SPKLocalizedString(@"Control ads, AI and suggestions visibility by surface.")),
        SPKTopicSection(SPKLocalizedString(@"Media Preview & Menu"), @[
            [SPKSetting switchCellWithTitle:SPKLocalizedString(@"Show Media Info")
                                       icon:SPKSettingsIcon(@"info")
                                defaultsKey:@"general_preview_show_metadata"],
            [SPKSetting switchCellWithTitle:SPKLocalizedString(@"Show Date in Menu")
                                       icon:SPKSettingsIcon(@"calendar")
                                defaultsKey:@"general_action_btn_show_date"],
        ],
                        SPKLocalizedString(@"1. Overlay the author and post date on the expanded photo preview.\n")
                        SPKLocalizedString(@"2. Show the exact date and time a post was made in the action button menu.")),
        SPKTopicSection(@"Comments", @[
            [SPKSetting switchCellWithTitle:SPKLocalizedString(@"Copy Comment")
                                       icon:SPKSettingsIcon(@"copy")
                                defaultsKey:@"general_comments_copy_text"],
            [SPKSetting switchCellWithTitle:SPKLocalizedString(@"Comment Media Actions")
                                       icon:SPKSettingsIcon(@"action")
                                defaultsKey:@"general_comments_media_actions"],
            [SPKSetting switchCellWithTitle:SPKLocalizedString(@"Upload Photo from Gallery")
                                       icon:SPKSettingsIcon(@"photo")
                                defaultsKey:@"general_comments_gallery_upload"]
        ],
                        SPKLocalizedString(@"1. Adds a copy action to comment menus.\n")
                        SPKLocalizedString(@"2. Adds Photos, Share, Gallery, and link actions for GIF and photo comments.\n")
                        SPKLocalizedString(@"3. Long-press the composer's photo button to attach an image from your Sparkle Gallery.")),
        SPKTopicSection(@"", @[
            [SPKSetting switchCellWithTitle:SPKLocalizedString(@"Swipe to Close Comments")
                                       icon:SPKSettingsIcon(@"left_right")
                                defaultsKey:@"general_comments_swipe_close"],
            SPKSettingApplySelectedMenuIcon([SPKSetting menuCellWithTitle:SPKLocalizedString(@"Swipe Direction") icon:SPKSettingsIcon(@"left_right") menu:SPKSwipeCloseCommentsDirectionMenu()], SPKSettingsIcon(@"left_right")),
        ],
                        SPKLocalizedString(@"Adds a horizontal swipe gesture to close comment sheets, in the chosen direction.")),
        SPKTopicSection(@"", @[
            [SPKSetting switchCellWithTitle:SPKLocalizedString(@"Confirm Comment Like")
                                       icon:SPKSettingsIcon(@"heart")
                                defaultsKey:@"general_comments_confirm_like"],
            [SPKSetting switchCellWithTitle:SPKLocalizedString(@"Hide Comment Shopping")
                                       icon:SPKSettingsIcon(@"shopping_bag")
                                defaultsKey:@"general_comments_hide_shopping"],
            [SPKSetting switchCellWithTitle:SPKLocalizedString(@"Hide Gifts Button")
                                       icon:SPKSettingsIcon(@"gift")
                                defaultsKey:@"general_comments_hide_gifts_button"],
        ],
                        SPKLocalizedString(@"1. Shows a confirmation alert before liking a comment.\n")
                        SPKLocalizedString(@"2. Removes commerce carousels in comment threads.\n")
                        SPKLocalizedString(@"3. Removes the gift shortcut from the comment composer.")),
        SPKTopicSection(@"Accounts", @[
            [self perAccountSetting],
            [self perAccountInfoSetting]
        ],
                        SPKLocalizedString(@"Give each logged-in account its own Sparkle settings.")),
        SPKTopicSection(SPKLocalizedString(@"Storage"), @[
            clearCacheSetting,
            [SPKSetting menuCellWithTitle:SPKLocalizedString(@"Auto Clear Cache")
                                     icon:SPKSettingsIcon(@"clock")
                                     menu:SPKCacheAutoClearMenu()]
        ],
                        SPKLocalizedString(@"Automatic clearing is checked whenever Instagram becomes active.")),
        SPKTopicSection(@"App", @[
            [self appIconSetting],
            [self defaultMenuIconSetting],
            [SPKSetting switchCellWithTitle:SPKLocalizedString(@"Disable App Haptics")
                                       icon:SPKSettingsIcon(@"haptics")
                                defaultsKey:@"general_disable_haptics"]
        ],
                        SPKLocalizedString(@"Choose an app icon directly from the icons exposed by the installed Instagram bundle. Open Menu Icon sets the glyph shown on every action button whose default tap action is Open Menu. Disable App Haptics turns off haptics and vibrations within the app.")),
    ]);
}

@end
