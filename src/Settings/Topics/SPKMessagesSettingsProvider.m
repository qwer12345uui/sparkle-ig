#import "../../Localization/SPKLocalization.h"
#import "SPKMessagesSettingsProvider.h"

#import "../../Features/Messages/DeletedMessagesLog/SPKDeletedMessagesViewController.h"
#import "../../Shared/ActionButton/SPKActionButtonConfiguration.h"
#import "../../Shared/Messages/SPKDirectSeenContext.h"
#import "../../Utils.h"
#import "../SPKSettingsViewController.h"
#import "../SPKTopicSettingsSupport.h"

static NSString *const kSPKMessagesActionButtonEnabledKey = @"msgs_action_btn";
static NSString *const kSPKMessagesActionButtonChatMediaKey = @"msgs_action_btn_chat_media";
static NSString *const kSPKMessagesAudioCallConfirmKey = @"msgs_confirm_audio_call";
static NSString *const kSPKMessagesVideoCallConfirmKey = @"msgs_confirm_video_call";

static NSArray *SPKMessagesSettingsSections(void);

// A switch cell that stays visible but is disabled while the "Audio Downloads"
// master toggle is off (keeping its stored value).
static SPKSetting *SPKAudioGatedSwitch(NSString *title, UIImage *icon, NSString *defaultsKey) {
    SPKSetting *setting = [SPKSetting switchCellWithTitle:title icon:icon defaultsKey:defaultsKey];
    setting.enabledProvider = ^BOOL {
        return [SPKUtils getBoolPref:@"downloads_audio_enabled"];
    };
    return setting;
}

@interface SPKMessagesSettingsViewController : SPKSettingsViewController
@end

@implementation SPKMessagesSettingsViewController
- (instancetype)init {
    return [super initWithTitle:SPKLocalizedString(@"Messages") sections:SPKMessagesSettingsSections() reduceMargin:NO];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self replaceSections:SPKMessagesSettingsSections()];
}

- (void)switchChanged:(UISwitch *)sender {
    SPKSetting *row = [self settingForSender:sender];
    [super switchChanged:sender];
    if ([row.defaultsKey isEqualToString:@"msgs_manual_seen"] ||
        [row.defaultsKey isEqualToString:@"msgs_manual_visual_seen"]) {
        [self replaceSections:SPKMessagesSettingsSections()];
    }
}
@end

static NSArray *SPKMessagesSettingsSections(void) {
    BOOL manualSeen = [SPKUtils getBoolPref:@"msgs_manual_seen"];
    SPKSetting *manualSeenList = [SPKSetting navigationCellWithTitle:SPKDirectManualSeenListTitle(manualSeen)
                                                            subtitle:@""
                                                                icon:SPKSettingsIcon(@"users")
                                                      viewController:SPKDirectManualSeenListViewController()];
    manualSeenList.userInfo = @{@"accessoryText" : [NSString stringWithFormat:@"%lu", (unsigned long)SPKDirectManualSeenThreadCount(manualSeen)]};

    // Auto-seen triggers only act while manual seen is on. Keep their stored value
    // but lock the cells when manual seen is off.
    SPKSetting *seenOnSend = [SPKSetting switchCellWithTitle:SPKLocalizedString(@"Mark Seen on Message Send") icon:SPKSettingsIcon(@"messages") defaultsKey:@"msgs_seen_on_send"];
    SPKSetting *seenOnReply = [SPKSetting switchCellWithTitle:SPKLocalizedString(@"Mark Seen on Message Reply") icon:SPKSettingsIcon(@"reply") defaultsKey:@"msgs_seen_on_reply"];
    SPKSetting *seenOnReaction = [SPKSetting switchCellWithTitle:SPKLocalizedString(@"Mark Seen on Reaction") icon:SPKSettingsIcon(@"reactions") defaultsKey:@"msgs_seen_on_reaction"];
    SPKSetting *seenOnTyping = [SPKSetting switchCellWithTitle:SPKLocalizedString(@"Mark Seen on Typing") icon:SPKSettingsIcon(@"keyboard") defaultsKey:@"msgs_seen_on_typing"];
    seenOnSend.enabledProvider = ^BOOL {
        return [SPKUtils getBoolPref:@"msgs_manual_seen"];
    };
    seenOnReply.enabledProvider = ^BOOL {
        return [SPKUtils getBoolPref:@"msgs_manual_seen"];
    };
    seenOnReaction.enabledProvider = ^BOOL {
        return [SPKUtils getBoolPref:@"msgs_manual_seen"];
    };
    seenOnTyping.enabledProvider = ^BOOL {
        return [SPKUtils getBoolPref:@"msgs_manual_seen"];
    };

    // Chooses where the manual-seen eye button lives: the top nav bar, or a
    // draggable bubble above the composer. Only meaningful while manual seen is on.
    // Up/Down arrows mirror the placement on both the menu items and the cell.
    SPKSetting *seenButtonPosition = SPKSettingApplySelectedMenuIcon([SPKSetting menuCellWithTitle:SPKLocalizedString(@"Seen Button Position")
                                                                                              icon:SPKSettingsIcon(@"arrow_up")
                                                                                              menu:SPKSeenButtonPositionMenu()],
                                                                     SPKSettingsIcon(@"arrow_up"));
    seenButtonPosition.enabledProvider = ^BOOL {
        return [SPKUtils getBoolPref:@"msgs_manual_seen"];
    };

    // Advancing after a manual seen only applies while visual manual seen is on.
    SPKSetting *advanceVisual = [SPKSetting switchCellWithTitle:SPKLocalizedString(@"Advance After Manual Seen") icon:SPKSettingsIcon(@"autoscroll") defaultsKey:@"msgs_advance_visual_on_seen"];
    advanceVisual.enabledProvider = ^BOOL {
        return [SPKUtils getBoolPref:@"msgs_manual_visual_seen"];
    };

    // Tri-state control for reformatting the chat-header last-active presence
    // label: Off / Smart / Date & Time.
    SPKSetting *lastActiveFormat = SPKSettingApplySelectedMenuIcon([SPKSetting menuCellWithTitle:SPKLocalizedString(@"Last Active")
                                                                                            icon:SPKSettingsIcon(@"clock")
                                                                                            menu:SPKLastActiveFormatMenu()],
                                                                   SPKSettingsIcon(@"clock"));

    // Extends the action button to the full-screen viewer for permanent chat media
    // (camera-roll photos/videos, chat-menu media), replacing IG's native Save.
    // Only meaningful while the master action button toggle is on.
    SPKSetting *chatMediaActionButton = [SPKSetting switchCellWithTitle:SPKLocalizedString(@"Also Show on Chat Media")
                                                                  icon:SPKSettingsIcon(@"photo")
                                                           defaultsKey:kSPKMessagesActionButtonChatMediaKey];
    chatMediaActionButton.enabledProvider = ^BOOL {
        return [SPKUtils getBoolPref:kSPKMessagesActionButtonEnabledKey];
    };

    return @[
        SPKTopicSection(SPKLocalizedString(@"Action Button"), @[
            [SPKSetting switchCellWithTitle:SPKLocalizedString(@"Messages Action Button")
                                       icon:SPKSettingsIcon(@"action")
                                defaultsKey:kSPKMessagesActionButtonEnabledKey],
            chatMediaActionButton,
            SPKActionButtonDefaultActionNavigationSetting(SPKActionButtonSourceDirect),
            SPKActionButtonConfigurationNavigationSetting(SPKActionButtonSourceDirect, SPKLocalizedString(@"Messages"), SPKActionButtonSupportedActionsForSource(SPKActionButtonSourceDirect), SPKActionButtonDefaultSectionsForSource(SPKActionButtonSourceDirect))
        ],
                        SPKLocalizedString(@"Choose what tapping the action button does. Long press opens the full menu.\n")
                        SPKLocalizedString(@"\"Also Show on Chat Media\" adds it to camera-roll photos and videos opened in a chat.")),
        SPKTopicSection(@"Messaging", @[
            [SPKSetting switchCellWithTitle:SPKLocalizedString(@"Unlock Message Preview")
                                       icon:SPKSettingsIcon(@"story_preview")
                                defaultsKey:@"msgs_unlock_preview"],
            [SPKSetting switchCellWithTitle:SPKLocalizedString(@"Manually Mark Seen")
                                       icon:SPKSettingsIcon(@"eye")
                                defaultsKey:@"msgs_manual_seen"],
            seenButtonPosition,
            seenOnSend,
            seenOnReply,
            seenOnReaction,
            seenOnTyping,
            manualSeenList,
        ],
                        manualSeen ? SPKLocalizedString(@"1. Unlock \"Message Preview\": the chat long-press menu shows the actual chat preview without marking the messages as seen.\n")
                                     SPKLocalizedString(@"2. Prevents automatic seen receipts and adds an eye button to mark chats as seen.\n")
                                     SPKLocalizedString(@"3. Places the seen button in the top nav bar, or as a draggable bubble above the composer within thumb reach (scroll to snap it back).\n")
                                     SPKLocalizedString(@"4. Marks a chat as seen when you send a message.\n")
                                     SPKLocalizedString(@"5. Marks a chat as seen when you reply.\n")
                                     SPKLocalizedString(@"6. Marks a chat as seen when you react.\n")
                                     SPKLocalizedString(@"7. Marks a chat as seen when you start typing a reply.\n\n")
                                     SPKLocalizedString(@"Excluded Chats keep Instagram's normal seen behavior. Manage them from the eye button, an inbox long press, or the list above.")
                                   : SPKLocalizedString(@"1. Unlock \"Message Preview\": the chat long-press menu shows the actual chat preview without marking the messages as seen.\n")
                                     SPKLocalizedString(@"2. Prevents automatic seen receipts and adds an eye button to mark chats as seen.\n")
                                     SPKLocalizedString(@"3. Places the seen button in the top nav bar, or as a draggable bubble above the composer within thumb reach (scroll to snap it back).\n")
                                     SPKLocalizedString(@"4. Marks a chat as seen when you send a message.\n")
                                     SPKLocalizedString(@"5. Marks a chat as seen when you reply.\n")
                                     SPKLocalizedString(@"6. Marks a chat as seen when you react.\n")
                                     SPKLocalizedString(@"7. Marks a chat as seen when you start typing a reply.\n\n")
                                     SPKLocalizedString(@"Included Chats require the eye button or the auto-seen triggers above. Manage them from the eye button, an inbox long press, or the list above.")),
        SPKTopicSection(SPKLocalizedString(@"Deleted Messages"), @[
            [SPKSetting switchCellWithTitle:SPKLocalizedString(@"Keep Deleted Messages")
                                       icon:SPKSettingsIcon(@"undo_circle")
                                defaultsKey:@"msgs_keep_deleted"],
            [SPKSetting switchCellWithTitle:SPKLocalizedString(@"Confirm Inbox Refresh")
                                       icon:SPKSettingsIcon(@"arrow_cw")
                                defaultsKey:@"msgs_confirm_refresh"],
            [SPKSetting switchCellWithTitle:SPKLocalizedString(@"Log Deleted Messages")
                                       icon:SPKSettingsIcon(@"logs")
                                defaultsKey:@"msgs_deleted_log"],
            [SPKSetting switchCellWithTitle:SPKLocalizedString(@"Log Removed Reactions")
                                       icon:SPKSettingsIcon(@"reactions")
                                defaultsKey:@"msgs_deleted_log_reactions"],
            [SPKSetting switchCellWithTitle:SPKLocalizedString(@"Respect Seen Chat List")
                                       icon:SPKSettingsIcon(@"eye")
                                defaultsKey:@"msgs_deleted_log_respect_seen_list"],
            [SPKSetting navigationCellWithTitle:SPKLocalizedString(@"View Deleted Messages")
                                       subtitle:@""
                                           icon:SPKSettingsIcon(@"channels")
                                 viewController:[SPKDeletedMessagesViewController new]],
        ],
                        SPKLocalizedString(@"1. Preserves remotely unsent messages in the chat, marked with an undo-circle indicator.\n")
                        SPKLocalizedString(@"2. Asks before refreshing the inbox, which reloads threads and drops preserved messages.\n")
                        SPKLocalizedString(@"3. Records message content before removal and keeps view-once/view-twice media until cleared.\n")
                        SPKLocalizedString(@"4. Also logs reactions that are removed.\n")
                        SPKLocalizedString(@"5. Skips log capture and unsent notifications for chats in your manual-seen include/exclude list.\n")
                        SPKLocalizedString(@"6. Opens the captured deleted-message logs.")),
        SPKTopicSection(SPKLocalizedString(@"Interface"), @[
            lastActiveFormat,
            [SPKSetting switchCellWithTitle:SPKLocalizedString(@"Hide Typing Status")
                                       icon:SPKSettingsIcon(@"keyboard")
                                defaultsKey:@"msgs_disable_typing"],
            [SPKSetting switchCellWithTitle:SPKLocalizedString(@"Hide Reels Blend Button")
                                       icon:SPKSettingsIcon(@"blend")
                                defaultsKey:@"msgs_hide_reels_blend"],
            [SPKSetting switchCellWithTitle:SPKLocalizedString(@"Hide Audio Call Button")
                                       icon:SPKSettingsIcon(@"call")
                                defaultsKey:@"msgs_hide_audio_call_btn"],
            [SPKSetting switchCellWithTitle:SPKLocalizedString(@"Hide Video Call Button")
                                       icon:SPKSettingsIcon(@"video")
                                defaultsKey:@"msgs_hide_video_call_btn"],
            [SPKSetting switchCellWithTitle:SPKLocalizedString(@"Hide Flag Button")
                                       icon:SPKSettingsIcon(@"flag")
                                defaultsKey:@"msgs_hide_flag_btn"],
            [SPKSetting switchCellWithTitle:SPKLocalizedString(@"No Suggested Chats")
                                       icon:SPKSettingsIcon(@"question")
                                defaultsKey:@"msgs_hide_suggested_chats"],
        ],
                        SPKLocalizedString(@"1. Shows the exact time someone was last active in the chat header (\"Active at 1:15 AM\") instead of a relative label (\"Active 2h ago\"). ")
                        SPKLocalizedString(@"\"Smart\" uses the time alone for today and adds the date for older days; \"Date & Time\" always shows both. Only reformats presence Instagram already shows.\n")
                        SPKLocalizedString(@"2. Stops sending your typing indicator to others.\n")
                        SPKLocalizedString(@"3. Removes the Reels Blend button from the inbox.\n")
                        SPKLocalizedString(@"4. Hides the audio call button in the chat header.\n")
                        SPKLocalizedString(@"5. Hides the video call button in the chat header.\n")
                        SPKLocalizedString(@"6. Hides the flag button in the chat header.\n")
                        SPKLocalizedString(@"7. Removes suggested chats from the inbox.")),
        SPKTopicSection(SPKLocalizedString(@"Visual Messages"), @[
            [SPKSetting switchCellWithTitle:SPKLocalizedString(@"Manually Mark Seen")
                                       icon:SPKSettingsIcon(@"eye")
                                defaultsKey:@"msgs_manual_visual_seen"],
            advanceVisual,
            [SPKSetting switchCellWithTitle:SPKLocalizedString(@"Stop Auto Advance")
                                       icon:SPKSettingsIcon(@"autoscroll")
                                defaultsKey:@"msgs_stop_visual_auto_advance"],
            [SPKSetting switchCellWithTitle:SPKLocalizedString(@"Disable View-Once Limitations")
                                       icon:SPKSettingsIcon(@"view_once")
                                defaultsKey:@"msgs_disable_view_once"],
            [SPKSetting switchCellWithTitle:SPKLocalizedString(@"Disable Screenshot Detection")
                                       icon:SPKSettingsIcon(@"warning")
                                defaultsKey:@"msgs_disable_screenshot_detection"]
        ],
                        SPKLocalizedString(@"1. Prevents automatic seen receipts and adds a button to mark the chat as seen.\n")
                        SPKLocalizedString(@"2. Moves to the next visual item when available or dismisses.\n")
                        SPKLocalizedString(@"3. Keeps the current visual message on screen instead of auto-advancing when it ends.\n")
                        SPKLocalizedString(@"4. View-once messages behave like normal visual messages.\n")
                        SPKLocalizedString(@"5. Allows screen capture of visual messages.")),
        SPKTopicSection(SPKLocalizedString(@"Vanish Mode"), @[
            [SPKSetting switchCellWithTitle:SPKLocalizedString(@"Disable Swipe-Up Gesture")
                                       icon:SPKSettingsIcon(@"arrow_up")
                                defaultsKey:@"msgs_disable_vanish_swipe_up"],
            [SPKSetting switchCellWithTitle:SPKLocalizedString(@"Disable Screenshot Detection")
                                       icon:SPKSettingsIcon(@"warning")
                                defaultsKey:@"msgs_hide_vanish_screenshot"],
        ],
                        SPKLocalizedString(@"1. Disable the gesture that enables vanish mode.\n")
                        SPKLocalizedString(@"2. Allows screen capture while vanish mode is active.")),
        SPKTopicSection(@"Notes", @[
            [SPKSetting switchCellWithTitle:SPKLocalizedString(@"Hide Notes Tray")
                                       icon:SPKSettingsIcon(@"notes")
                                defaultsKey:@"msgs_hide_notes_tray"],
            [SPKSetting switchCellWithTitle:SPKLocalizedString(@"Hide Friends Map")
                                       icon:SPKSettingsIcon(@"map")
                                defaultsKey:@"msgs_hide_friends_map"],
            SPKAudioGatedSwitch(SPKLocalizedString(@"Download Notes Audio"), SPKSettingsIcon(@"audio"), @"msgs_download_notes_audio"),
            [SPKSetting switchCellWithTitle:SPKLocalizedString(@"Copy Note Text")
                                       icon:SPKSettingsIcon(@"copy")
                                defaultsKey:@"msgs_copy_note_text"]
        ],
                        SPKLocalizedString(@"Long-press a note in the tray to download its audio or copy its text. Each action only appears when the note has that content.")),
        SPKTopicSection(@"Audio", @[
            SPKAudioGatedSwitch(SPKLocalizedString(@"Download Voice Messages"), SPKSettingsIcon(@"audio_download"), @"msgs_download_audio_messages"),
            [SPKSetting switchCellWithTitle:SPKLocalizedString(@"Upload Audio")
                                       icon:SPKSettingsIcon(@"audio_upload")
                                defaultsKey:@"msgs_upload_audio_messages"],
            [SPKSetting switchCellWithTitle:SPKLocalizedString(@"Trim Before Sending")
                                       icon:SPKSettingsIcon(@"trim")
                                defaultsKey:@"msgs_audio_upload_trim"]
        ],
                        SPKLocalizedString(@"1. Adds audio actions to supported voice/audio message views.\n")
                        SPKLocalizedString(@"2. Adds an option to the composer plus (+) menu that sends the selected audio or video as a voice message.\n")
                        SPKLocalizedString(@"3. When uploading, offers to trim the audio before sending it.")),
        SPKTopicSection(@"Media", @[
            [SPKSetting switchCellWithTitle:SPKLocalizedString(@"Upload Photo from Gallery")
                                       icon:SPKSettingsIcon(@"photo")
                                defaultsKey:@"msgs_upload_gallery_media"]
        ],
                        SPKLocalizedString(@"Adds an option to the composer plus (+) menu that sends a photo from the Sparkle Gallery into the chat.")),
        SPKTopicSection(@"Confirmation", @[
            [SPKSetting switchCellWithTitle:SPKLocalizedString(@"Confirm Audio Call")
                                       icon:SPKSettingsIcon(@"call")
                                defaultsKey:kSPKMessagesAudioCallConfirmKey],
            [SPKSetting switchCellWithTitle:SPKLocalizedString(@"Confirm Video Call")
                                       icon:SPKSettingsIcon(@"video")
                                defaultsKey:kSPKMessagesVideoCallConfirmKey],
            [SPKSetting switchCellWithTitle:SPKLocalizedString(@"Confirm Double Tap")
                                       icon:SPKSettingsIcon(@"heart")
                                defaultsKey:@"msgs_confirm_double_tap"],
            [SPKSetting switchCellWithTitle:SPKLocalizedString(@"Confirm Reactions")
                                       icon:SPKSettingsIcon(@"reactions")
                                defaultsKey:@"msgs_confirm_reaction"],
            [SPKSetting switchCellWithTitle:SPKLocalizedString(@"Confirm Voice Messages")
                                       icon:SPKSettingsIcon(@"voice")
                                defaultsKey:@"msgs_confirm_voice_msg"],
            [SPKSetting switchCellWithTitle:SPKLocalizedString(@"Confirm Follow Requests")
                                       icon:SPKSettingsIcon(@"user_request")
                                defaultsKey:@"msgs_confirm_follow_request"],
            [SPKSetting switchCellWithTitle:SPKLocalizedString(@"Confirm Vanish Mode")
                                       icon:SPKSettingsIcon(@"vanish")
                                defaultsKey:@"msgs_confirm_vanish_mode"],
            [SPKSetting switchCellWithTitle:SPKLocalizedString(@"Confirm Changing Theme")
                                       icon:SPKSettingsIcon(@"palette")
                                defaultsKey:@"msgs_confirm_theme_change"]
        ],
                        SPKLocalizedString(@"Shows confirmation alerts before the selected message actions are sent."))
    ];
}

@implementation SPKMessagesSettingsProvider

+ (SPKSetting *)rootSetting {
    SPKSetting *setting = [SPKSetting navigationCellWithTitle:SPKLocalizedString(@"Messages")
                                                     subtitle:@""
                                                         icon:SPKSettingsIcon(@"messages")
                                               viewController:[[SPKMessagesSettingsViewController alloc] init]];
    setting.searchSectionsProvider = ^NSArray * {
        return SPKMessagesSettingsSections();
    };
    return SPKSettingApplyIconTint(setting, [SPKUtils SPKColor_InstagramPrimaryText]);
}

@end
