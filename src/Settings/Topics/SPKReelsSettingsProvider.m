#import "../../Localization/SPKLocalization.h"
#import "SPKReelsSettingsProvider.h"

#import "../../Shared/ActionButton/SPKActionButtonConfiguration.h"
#import "../SPKTopicSettingsSupport.h"

static NSString *const kSPKReelsActionButtonEnabledKey = @"reels_action_btn";

@implementation SPKReelsSettingsProvider

+ (SPKSetting *)rootSetting {
    return SPKTopicNavigationSetting(SPKLocalizedString(@"Reels"), @"reels", 24.0, @[
        SPKTopicSection(SPKLocalizedString(@"Action Button"), @[
            [SPKSetting switchCellWithTitle:SPKLocalizedString(@"Reels Action Button")
                                       icon:SPKSettingsIcon(@"action")
                                defaultsKey:kSPKReelsActionButtonEnabledKey],
            SPKActionButtonDefaultActionNavigationSetting(SPKActionButtonSourceReels),
            SPKActionButtonConfigurationNavigationSetting(SPKActionButtonSourceReels, SPKLocalizedString(@"Reels"), SPKActionButtonSupportedActionsForSource(SPKActionButtonSourceReels), SPKActionButtonDefaultSectionsForSource(SPKActionButtonSourceReels))
        ],
                        SPKLocalizedString(@"Choose what tapping the action button does. Long press opens the full menu.")),
        SPKTopicSection(@"Behavior", @[
            [SPKSetting menuCellWithTitle:SPKLocalizedString(@"Tap Controls")
                                     icon:SPKSettingsIcon(@"play")
                                     menu:SPKReelsTapControlMenu()],
            [SPKSetting switchCellWithTitle:SPKLocalizedString(@"Show Progress Scrubber")
                                       icon:SPKSettingsIcon(@"clock")
                                defaultsKey:@"reels_show_scrubber"],
            [SPKSetting switchCellWithTitle:SPKLocalizedString(@"Disable Auto-Unmuting Reels")
                                       icon:SPKSettingsIcon(@"volume_off")
                                defaultsKey:@"reels_disable_auto_unmute"
                            requiresRestart:YES],
            [SPKSetting switchCellWithTitle:SPKLocalizedString(@"Disable Reels Tab Refresh")
                                       icon:SPKSettingsIcon(@"arrow_cw")
                                defaultsKey:@"reels_disable_tab_refresh"]
        ],
                        SPKLocalizedString(@"Tap Controls changes what happens when you tap on a reel. Auto-unmuting controls prevent reels from unmuting when volume or silent mode changes.")),
        SPKTopicSection(@"Limits", @[
            [SPKSetting switchCellWithTitle:SPKLocalizedString(@"Disable Scrolling Reels")
                                       icon:SPKSettingsIcon(@"autoscroll")
                                defaultsKey:@"reels_disable_scrolling"
                            requiresRestart:YES],
            [SPKSetting switchCellWithTitle:SPKLocalizedString(@"Prevent Doom Scrolling")
                                       icon:SPKSettingsIcon(@"arrow_down")
                                defaultsKey:@"reels_prevent_doom_scroll"],
            [SPKSetting stepperCellWithTitle:SPKLocalizedString(@"Doom Scrolling Limit")
                                    subtitle:SPKLocalizedString(@"Only loads %@ %@")
                                 defaultsKey:@"reels_doom_scroll_limit"
                                         min:1
                                         max:100
                                        step:1
                                       label:@"reels"
                               singularLabel:@"reel"]
        ],
                        SPKLocalizedString(@"1. Stop vertical swiping between reels so the current reel stays put.\n")
                        SPKLocalizedString(@"2. Stop loading more reels once the limit below is reached.\n")
                        SPKLocalizedString(@"3. How many reels load before Prevent Doom Scrolling kicks in.")),
        SPKTopicSection(@"Layout", @[
            [SPKSetting switchCellWithTitle:SPKLocalizedString(@"Hide Reels Header")
                                       icon:SPKSettingsIcon(@"reels")
                                defaultsKey:@"reels_hide_header"],
            [SPKSetting switchCellWithTitle:SPKLocalizedString(@"Hide Repost Button")
                                       icon:SPKSettingsIcon(@"repost")
                                defaultsKey:@"reels_hide_repost_btn"
                            requiresRestart:YES]
        ],
                        nil),
        SPKTopicSection(@"Metrics", @[
            [SPKSetting switchCellWithTitle:SPKLocalizedString(@"Hide Like Count")
                                       icon:SPKSettingsIcon(@"heart")
                                defaultsKey:@"reels_hide_like_count"],
            [SPKSetting switchCellWithTitle:SPKLocalizedString(@"Hide Comment Count")
                                       icon:SPKSettingsIcon(@"comment")
                                defaultsKey:@"reels_hide_comment_count"],
            [SPKSetting switchCellWithTitle:SPKLocalizedString(@"Hide Repost Count")
                                       icon:SPKSettingsIcon(@"repost")
                                defaultsKey:@"reels_hide_repost_count"],
            [SPKSetting switchCellWithTitle:SPKLocalizedString(@"Hide Reshare Count")
                                       icon:SPKSettingsIcon(@"messages")
                                defaultsKey:@"reels_hide_reshare_count"],
            [SPKSetting switchCellWithTitle:SPKLocalizedString(@"Hide Save Count")
                                       icon:SPKSettingsIcon(@"save")
                                defaultsKey:@"reels_hide_save_count"]
        ],
                        nil),
        SPKTopicSection(@"Confirmation", @[
            [SPKSetting switchCellWithTitle:SPKLocalizedString(@"Confirm Like")
                                       icon:SPKSettingsIcon(@"heart")
                                defaultsKey:@"reels_confirm_like"],
            [SPKSetting switchCellWithTitle:SPKLocalizedString(@"Confirm Double Tap")
                                       icon:SPKSettingsIcon(@"heart")
                                defaultsKey:@"reels_confirm_double_tap_like"],
            [SPKSetting switchCellWithTitle:SPKLocalizedString(@"Confirm Reel Refresh")
                                       icon:SPKSettingsIcon(@"arrow_cw")
                                defaultsKey:@"reels_confirm_refresh"],
            [SPKSetting switchCellWithTitle:SPKLocalizedString(@"Confirm Repost")
                                       icon:SPKSettingsIcon(@"repost")
                                defaultsKey:@"reels_confirm_repost"]
        ],
                        SPKLocalizedString(@"Shows confirmation alerts before the enabled reels actions are performed."))
    ]);
}

@end
