#import "../../Localization/SPKLocalization.h"
#import "SPKFeedSettingsProvider.h"

#import "../../Features/Feed/HeaderActionButton.h"
#import "../../Shared/ActionButton/SPKActionButtonConfiguration.h"
#import "../SPKTopicSettingsSupport.h"

static NSString *const kSPKFeedActionButtonEnabledKey = @"feed_action_btn";

@implementation SPKFeedSettingsProvider

+ (SPKSetting *)rootSetting {
    return SPKTopicNavigationSetting(SPKLocalizedString(@"Feed"), @"feed", 24.0, @[
        SPKTopicSection(SPKLocalizedString(@"Action Button"), @[
            [SPKSetting switchCellWithTitle:SPKLocalizedString(@"Feed Action Button")
                                       icon:SPKSettingsIcon(@"action")
                                defaultsKey:kSPKFeedActionButtonEnabledKey],
            SPKActionButtonDefaultActionNavigationSetting(SPKActionButtonSourceFeed),
            SPKActionButtonConfigurationNavigationSetting(SPKActionButtonSourceFeed, SPKLocalizedString(@"Feed"), SPKActionButtonSupportedActionsForSource(SPKActionButtonSourceFeed), SPKActionButtonDefaultSectionsForSource(SPKActionButtonSourceFeed))
        ],
                        SPKLocalizedString(@"Choose what tapping the action button does. Long press opens the full menu.")),
        SPKTopicSection(SPKLocalizedString(@"Header Shortcut"), @[
            [SPKSetting switchCellWithTitle:SPKLocalizedString(@"Feed Header Button")
                                       icon:SPKSettingsIcon(@"action")
                                defaultsKey:kSPKHeaderButtonEnabledKey],
            SPKFeedHeaderButtonDefaultActionNavigationSetting(),
            [SPKSetting navigationCellWithTitle:SPKLocalizedString(@"Configure Destinations")
                                       subtitle:@""
                                           icon:SPKSettingsIcon(@"sliders")
                                    navSections:@[
                                        SPKTopicSection(@"Destinations", @[
                                            [SPKSetting switchCellWithTitle:SPKLocalizedString(@"Gallery")
                                                                       icon:SPKSettingsIcon(@"sparkle_gallery")
                                                                defaultsKey:@"feed_header_button_dest_gallery"],
                                            [SPKSetting switchCellWithTitle:SPKLocalizedString(@"Profile Analyzer")
                                                                       icon:SPKSettingsIcon(@"profile_analyzer")
                                                                defaultsKey:@"feed_header_button_dest_analyzer"],
                                            [SPKSetting switchCellWithTitle:SPKLocalizedString(@"Deleted Messages")
                                                                       icon:SPKSettingsIcon(@"channels")
                                                                defaultsKey:@"feed_header_button_dest_deleted"],
                                            [SPKSetting switchCellWithTitle:SPKLocalizedString(@"Downloads")
                                                                       icon:SPKSettingsIcon(@"download")
                                                                defaultsKey:@"feed_header_button_dest_downloads"],
                                            [SPKSetting switchCellWithTitle:SPKLocalizedString(@"Sparkle Settings")
                                                                       icon:SPKSettingsIcon(@"settings")
                                                                defaultsKey:@"feed_header_button_dest_settings"],
                                        ],
                                                        SPKLocalizedString(@"Choose which sheets the header button can open. Enable one for a direct tap, or several to pick from the long-press menu."))
                                    ]],
        ],
                        [SPKLocalizedString(@"Adds a Sparkle button to the home feed header. ") stringByAppendingString:SPKLocalizedString(@"Tap opens the selected destination. Long press opens the menu of enabled destinations.")]),
        SPKTopicSection(@"Layout", @[
            SPKSettingApplySelectedMenuIcon([SPKSetting menuCellWithTitle:SPKLocalizedString(@"Main Feed") icon:SPKSettingsIcon(@"feed") menu:SPKMainFeedModeMenu()], SPKSettingsIcon(@"feed")),
            [SPKSetting switchCellWithTitle:SPKLocalizedString(@"Disable App Icon Gesture")
                                       icon:SPKSettingsIcon(@"app")
                                defaultsKey:@"feed_disable_appicon_gesture"],
            [SPKSetting switchCellWithTitle:SPKLocalizedString(@"Hide Stories Tray")
                                       icon:SPKSettingsIcon(@"story")
                                defaultsKey:@"feed_hide_stories_tray"],
            [SPKSetting switchCellWithTitle:SPKLocalizedString(@"Hide Entire Feed")
                                       icon:SPKSettingsIcon(@"feed")
                                defaultsKey:@"feed_hide_entire_feed"],
            [SPKSetting switchCellWithTitle:SPKLocalizedString(@"Hide Suggested Posts")
                                       icon:SPKSettingsIcon(@"carousel")
                                defaultsKey:@"feed_hide_suggested_posts"],
            [SPKSetting switchCellWithTitle:SPKLocalizedString(@"Hide Suggested Reels")
                                       icon:SPKSettingsIcon(@"reels_gallery")
                                defaultsKey:@"feed_hide_suggested_reels"],
            [SPKSetting switchCellWithTitle:SPKLocalizedString(@"Hide Suggested Threads")
                                       icon:SPKSettingsIcon(@"threads")
                                defaultsKey:@"feed_hide_suggested_threads"],
            [SPKSetting switchCellWithTitle:SPKLocalizedString(@"Hide Repost Button")
                                       icon:SPKSettingsIcon(@"repost")
                                defaultsKey:@"feed_hide_repost_btn"
                            requiresRestart:YES]
        ],
                        [[[[[[[SPKLocalizedString(@"1. Force Instagram's chronological Following feed instead of the algorithmic For You feed. Title stays \"For you\".\n") stringByAppendingString:SPKLocalizedString(@"2. Stop the feed header logo long-press from opening Instagram's app icon picker. Sparkle has its own in Settings.\n")] stringByAppendingString:SPKLocalizedString(@"3. Hide the horizontal stories tray at the top of the feed.\n")] stringByAppendingString:SPKLocalizedString(@"4. Hide the entire home feed, leaving only the header.\n")] stringByAppendingString:SPKLocalizedString(@"5. Remove algorithmically suggested posts from the feed.\n")] stringByAppendingString:SPKLocalizedString(@"6. Remove suggested reels from the feed.\n")] stringByAppendingString:SPKLocalizedString(@"7. Remove suggested Threads posts from the feed.\n")] stringByAppendingString:SPKLocalizedString(@"8. Hide the repost button on feed posts.")]),
        SPKTopicSection(@"Metrics", @[
            [SPKSetting switchCellWithTitle:SPKLocalizedString(@"Hide Like Count")
                                       icon:SPKSettingsIcon(@"heart")
                                defaultsKey:@"feed_hide_like_count"],
            [SPKSetting switchCellWithTitle:SPKLocalizedString(@"Hide Comment Count")
                                       icon:SPKSettingsIcon(@"comment")
                                defaultsKey:@"feed_hide_comment_count"],
            [SPKSetting switchCellWithTitle:SPKLocalizedString(@"Hide Repost Count")
                                       icon:SPKSettingsIcon(@"repost")
                                defaultsKey:@"feed_hide_repost_count"],
            [SPKSetting switchCellWithTitle:SPKLocalizedString(@"Hide Reshare Count")
                                       icon:SPKSettingsIcon(@"messages")
                                defaultsKey:@"feed_hide_reshare_count"]
        ],
                        nil),
        SPKTopicSection(@"Media", @[
            [SPKSetting switchCellWithTitle:SPKLocalizedString(@"Long Press to Expand")
                                       icon:SPKSettingsIcon(@"expand")
                                defaultsKey:@"feed_long_press_expand"],
            [SPKSetting switchCellWithTitle:SPKLocalizedString(@"Disable Video Autoplay")
                                       icon:SPKSettingsIcon(@"autoplay_off")
                                defaultsKey:@"feed_disable_autoplay"
                            requiresRestart:YES],
            [SPKSetting switchCellWithTitle:SPKLocalizedString(@"Start Expanded Videos Muted")
                                       icon:SPKSettingsIcon(@"volume_off")
                                defaultsKey:@"feed_expanded_vid_start_muted"],
        ],
                        SPKLocalizedString(@"Long press media in the feed to open it expanded. Autoplay controls prevent feed videos from playing automatically.")),
        SPKTopicSection(@"Refresh", @[
            [SPKSetting switchCellWithTitle:SPKLocalizedString(@"Disable Home Tab Refresh")
                                       icon:SPKSettingsIcon(@"home")
                                defaultsKey:@"feed_disable_home_refresh"],
            [SPKSetting switchCellWithTitle:SPKLocalizedString(@"Disable Background Refresh")
                                       icon:SPKSettingsIcon(@"arrow_cw")
                                defaultsKey:@"feed_disable_bg_refresh"]
        ],
                        SPKLocalizedString(@"Prevents refreshes from re-tapping the Home tab or from background app activity.")),
        SPKTopicSection(@"Confirmation", @[
            [SPKSetting switchCellWithTitle:SPKLocalizedString(@"Confirm Like")
                                       icon:SPKSettingsIcon(@"heart")
                                defaultsKey:@"feed_confirm_post_like"],
            [SPKSetting switchCellWithTitle:SPKLocalizedString(@"Confirm Double Tap")
                                       icon:SPKSettingsIcon(@"heart")
                                defaultsKey:@"feed_confirm_double_tap_like"],
            [SPKSetting switchCellWithTitle:SPKLocalizedString(@"Confirm Repost")
                                       icon:SPKSettingsIcon(@"repost")
                                defaultsKey:@"feed_confirm_repost"],
            [SPKSetting switchCellWithTitle:SPKLocalizedString(@"Confirm Posting Comment")
                                       icon:SPKSettingsIcon(@"comment")
                                defaultsKey:@"feed_confirm_post_comment"]
        ],
                        SPKLocalizedString(@"Shows confirmation alerts before the enabled feed actions are performed."))
    ]);
}

@end
