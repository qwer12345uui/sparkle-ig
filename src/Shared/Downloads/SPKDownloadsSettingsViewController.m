#import "../../Localization/SPKLocalization.h"
#import "SPKDownloadsSettingsViewController.h"

#import "../../App/SPKStartupHooks.h"
#import "../../AssetUtils.h"
#import "../../Settings/SPKSetting.h"
#import "../../Settings/SPKTopicSettingsSupport.h"
#import "../../Utils.h"
#import "../AutoSave/SPKAutoSaveSettingsViewController.h"
#import "../MediaDownload/SPKMediaFFmpeg.h"
#import "../MediaDownload/SPKMediaQualityManager.h"
#import "SPKDownloadTypes.h"

@implementation SPKDownloadsSettingsViewController

+ (UIMenu *)audioPageDefaultActionMenu {
    NSArray<NSDictionary *> *items = @[
        @{@"title" : SPKLocalizedString(@"Save Audio to Files"), @"value" : @"files", @"icon" : @"audio_download"},
        @{@"title" : SPKLocalizedString(@"Share Audio"), @"value" : @"share", @"icon" : @"share"},
        @{@"title" : SPKLocalizedString(@"Save Audio to Gallery"), @"value" : @"gallery", @"icon" : @"sparkle_gallery"},
        @{@"title" : SPKLocalizedString(@"Play Audio"), @"value" : @"play", @"icon" : @"play"},
        @{@"title" : SPKLocalizedString(@"Copy Audio Download URL"), @"value" : @"copy_url", @"icon" : @"link"},
        @{@"title" : SPKLocalizedString(@"Open Menu"), @"value" : @"none", @"icon" : @"action"}
    ];
    NSMutableArray<UICommand *> *commands = [NSMutableArray array];
    for (NSDictionary *item in items) {
        [commands addObject:[UICommand commandWithTitle:item[@"title"]
                                                  image:[SPKAssetUtils menuIconNamed:item[@"icon"]]
                                                 action:@selector(menuChanged:)
                                           propertyList:@{@"defaultsKey" : @"downloads_audio_page_default_action", @"value" : item[@"value"], @"iconName" : item[@"icon"]}]];
    }
    return [UIMenu menuWithChildren:commands];
}

+ (NSArray *)contentSections {
    BOOL ffmpegAvailable = [SPKMediaFFmpeg isAvailable];
    if (!ffmpegAvailable) {
        // No FFmpeg = no DASH merge for ANY account, so this is a hard global
        // constraint, not a per-account choice. Write it globally (direct).
        [[NSUserDefaults standardUserDefaults] setObject:@"high_ignore_dash" forKey:@"downloads_video_quality"];
    }

    SPKSetting *videoQualitySetting = [SPKSetting menuCellWithTitle:SPKLocalizedString(@"Default Video Quality")
                                                           subtitle:(ffmpegAvailable ? @"" : SPKLocalizedString(@"Requires FFmpegKit"))
                                                           icon:SPKSettingsIcon(@"video")
                                                               menu:SPKMediaVideoQualityMenu()];
    videoQualitySetting.userInfo = @{@"enabled" : @(ffmpegAvailable)};

    SPKSetting *encodingSettings = [SPKSetting navigationCellWithTitle:SPKLocalizedString(@"Encoding Settings")
                                                              subtitle:(ffmpegAvailable ? @"" : SPKLocalizedString(@"Requires FFmpegKit"))
                                                              icon:SPKSettingsIcon(@"settings")
                                                        viewController:[SPKMediaQualityManager encodingSettingsViewController]];
    encodingSettings.userInfo = @{@"enabled" : @(ffmpegAvailable)};
    encodingSettings.searchSectionsProvider = ^NSArray * {
        return [SPKMediaQualityManager encodingSettingsSearchSections];
    };

    SPKSetting *encodingLogs = [SPKSetting navigationCellWithTitle:SPKLocalizedString(@"View Encoding Logs")
                                                          subtitle:@""
                                                              icon:SPKSettingsIcon(@"logs")
                                                    viewController:[SPKMediaFFmpeg logsViewController]];
    encodingLogs.userInfo = @{@"enabled" : @YES};

    NSString *qualityFooter = ffmpegAvailable
        ? SPKLocalizedString(@"1. Request 4K image candidates by mimicking a web browser (extra call to the web API).\n")
          SPKLocalizedString(@"2. Fetch the highest-resolution variant Instagram exposes for photos and videos.\n")
          SPKLocalizedString(@"3. Preferred quality for downloaded photos.\n")
          SPKLocalizedString(@"4. \"High\" merges DASH files for best quality, \"Default\" uses ready-to-play files, \"Always Ask\" prompts for selection each time.\n")
          SPKLocalizedString(@"5. Configure how merged videos are re-encoded (codec, container, bitrate).\n")
          SPKLocalizedString(@"6. Review the FFmpeg output from recent encoding jobs.")
        : SPKLocalizedString(@"1. Request 4K image candidates by mimicking a web browser (extra call to the web API).\n")
          SPKLocalizedString(@"2. Fetch the highest-resolution variant Instagram exposes for photos and videos.\n")
          SPKLocalizedString(@"FFmpegKit is required for video quality options and encoding features.");

    SPKSetting *autoSave = [SPKSetting navigationCellWithTitle:SPKLocalizedString(@"Auto-Save")
                                                      subtitle:@""
                                                          icon:SPKSettingsIcon(@"download")
                                                viewController:[SPKAutoSaveSettingsViewController new]];
    autoSave.searchSectionsProvider = ^NSArray * {
        return [SPKAutoSaveSettingsViewController searchSections];
    };

    return @[
        SPKTopicSection(SPKLocalizedString(@"Auto-Save"), @[ autoSave ],
                        SPKLocalizedString(@"Automatically download media as you view it.")),
        SPKTopicSection(@"Behavior", @[
            [SPKSetting switchCellWithTitle:SPKLocalizedString(@"Detect Duplicate Downloads")
                                       icon:SPKSettingsIcon(@"duplicate")
                                defaultsKey:kSPKDownloadDetectDuplicatesKey],
            [SPKSetting stepperCellWithTitle:SPKLocalizedString(@"Parallel Downloads")
                                    subtitle:SPKLocalizedString(@"%@ concurrent %@")
                                        icon:SPKSettingsIcon(@"parallel")
                                 defaultsKey:kSPKDownloadMaxConcurrentKey
                                         min:1
                                         max:4
                                        step:1
                                       label:@"downloads"
                               singularLabel:@"download"],
            [SPKSetting stepperCellWithTitle:SPKLocalizedString(@"History Limit")
                                    subtitle:SPKLocalizedString(@"%@ saved %@")
                                        icon:SPKSettingsIcon(@"history")
                                 defaultsKey:kSPKDownloadHistoryLimitKey
                                         min:50
                                         max:1000
                                        step:50
                                       label:@"entries"
                               singularLabel:@"entry"],
            ({
                SPKSetting *toggle = [SPKSetting switchCellWithTitle:SPKLocalizedString(@"Save to Custom Album")
                                                                icon:SPKSettingsIcon(@"photo_gallery")
                                                         defaultsKey:@"downloads_photos_album_enabled"];
                toggle.reloadsTableOnSwitchChange = YES;
                toggle;
            }),
            ({
                SPKSetting *album = [SPKSetting textFieldCellWithTitle:SPKLocalizedString(@"Album Name")
                                                           placeholder:@"Sparkle"
                                                          keyboardType:UIKeyboardTypeDefault
                                                           defaultsKey:@"downloads_photos_album"];
                album.icon = SPKSettingsIcon(@"folder");
                album.enabledProvider = ^BOOL {
                    return [SPKUtils getBoolPref:@"downloads_photos_album_enabled"];
                };
                album;
            }),
        ],
                        SPKLocalizedString(@"1. Check before downloading and skip media already saved. Gallery checks are exact; Photos checks cover media Sparkle saved while tracking is enabled.\n")
                        SPKLocalizedString(@"2. How many downloads may run at the same time.\n")
                        SPKLocalizedString(@"3. How many finished entries the download history keeps before trimming the oldest.\n")
                        SPKLocalizedString(@"4. Group saved Photos media under a specific custom album.")),
        SPKTopicSection(@"Quality", @[
            ({
                SPKSetting *toggle = [SPKSetting switchCellWithTitle:SPKLocalizedString(@"Fetch 4K Images")
                                                                icon:SPKSettingsIcon(@"web")
                                                         defaultsKey:@"downloads_fetch_4k_images"];
                toggle.switchChangeHandler = ^(BOOL isOn) {
                    [[NSUserDefaults standardUserDefaults] setBool:isOn forKey:SPKEffectivePreferenceKey(@"downloads_fetch_4k_images")];
                    if (!isOn) {
                        NSString *qualityKey = SPKEffectivePreferenceKey(@"downloads_photo_quality");
                        NSString *quality = [[NSUserDefaults standardUserDefaults] stringForKey:qualityKey];
                        if ([quality isEqualToString:@"max"]) {
                            [[NSUserDefaults standardUserDefaults] setObject:@"high" forKey:qualityKey];
                        }
                    }
                };
                toggle.reloadsTableOnSwitchChange = YES;
                toggle;
            }),
            [SPKSetting switchCellWithTitle:SPKLocalizedString(@"Enhanced Media Resolution")
                                       icon:SPKSettingsIcon(@"hd")
                                defaultsKey:@"downloads_enhanced_media_resolution"],
            [SPKSetting menuCellWithTitle:SPKLocalizedString(@"Default Photo Quality")
                                     icon:SPKSettingsIcon(@"photo")
                                     menu:SPKMediaPhotoQualityMenu()],
            videoQualitySetting,
            encodingSettings,
            encodingLogs
        ],
                        qualityFooter),
        [self audioSection]
    ];
}

// The "Audio Downloads" master toggle gates every other audio action tweak-wide.
// The dependent cells stay visible (and keep their stored value) but are disabled
// while the master is off.
+ (NSDictionary *)audioSection {
    BOOL (^audioEnabled)(void) = ^BOOL {
        return [SPKUtils getBoolPref:@"downloads_audio_enabled"];
    };

    SPKSetting *master = [SPKSetting switchCellWithTitle:SPKLocalizedString(@"Audio Downloads") icon:SPKSettingsIcon(@"audio_download") defaultsKey:@"downloads_audio_enabled"];
    master.switchChangeHandler = ^(BOOL isOn) {
        [[NSUserDefaults standardUserDefaults] setBool:isOn forKey:SPKEffectivePreferenceKey(@"downloads_audio_enabled")];
        if (isOn)
            SPKInstallEnabledFeatureHooks();
    };
    master.reloadsTableOnSwitchChange = YES; // grey out / re-enable the dependents live

    SPKSetting *pageButton = [SPKSetting switchCellWithTitle:SPKLocalizedString(@"Audio Page Button") icon:SPKSettingsIcon(@"audio_page") defaultsKey:@"downloads_audio_page_button"];
    pageButton.enabledProvider = audioEnabled;

    SPKSetting *pageDefault = SPKSettingApplySelectedMenuIcon([SPKSetting menuCellWithTitle:SPKLocalizedString(@"Audio Page Default Action") icon:SPKSettingsIcon(@"action") menu:[self audioPageDefaultActionMenu]], SPKSettingsIcon(@"action"));
    pageDefault.enabledProvider = audioEnabled;

    return SPKTopicSection(@"Audio", @[ master, pageButton, pageDefault ],
                           SPKLocalizedString(@"Adds audio actions for audio pages and media action buttons."));
}

+ (NSArray *)searchSections {
    return [self contentSections];
}

- (instancetype)init {
    return [super initWithTitle:SPKLocalizedString(@"Downloads Settings") sections:[[self class] contentSections] reduceMargin:NO];
}

@end
