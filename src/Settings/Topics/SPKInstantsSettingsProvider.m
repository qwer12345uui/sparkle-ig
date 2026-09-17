#import "../../Localization/SPKLocalization.h"
#import "SPKInstantsSettingsProvider.h"
#include <UIKit/UIKit.h>

#import "../../Shared/ActionButton/ActionButtonCore.h"
#import "../../Shared/ActionButton/SPKActionButtonConfiguration.h"
#import "../../Utils.h"
#import "../SPKPreferenceAvailability.h"
#import "../SPKSettingsViewController.h"
#import "../SPKTopicSettingsSupport.h"

static NSString *const kSPKInstantsActionButtonEnabledKey = @"instants_action_btn";

static NSArray *SPKInstantsSettingsSections(void);

@interface SPKInstantsSettingsViewController : SPKSettingsViewController
@end

@implementation SPKInstantsSettingsViewController
- (instancetype)init {
    return [super initWithTitle:SPKLocalizedString(@"Instants") sections:SPKInstantsSettingsSections() reduceMargin:NO];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self replaceSections:SPKInstantsSettingsSections()];
}
@end

static NSArray *SPKInstantsSettingsSections(void) {
    return @[
        SPKTopicSection(SPKLocalizedString(@"Action Button"), @[
            [SPKSetting switchCellWithTitle:SPKLocalizedString(@"Instants Action Button")
                                       icon:SPKSettingsIcon(@"action")
                                defaultsKey:kSPKInstantsActionButtonEnabledKey],
            SPKActionButtonDefaultActionNavigationSetting(SPKActionButtonSourceInstants),
            SPKActionButtonConfigurationNavigationSetting(SPKActionButtonSourceInstants, SPKLocalizedString(@"Instants"), SPKActionButtonSupportedActionsForSource(SPKActionButtonSourceInstants), SPKActionButtonDefaultSectionsForSource(SPKActionButtonSourceInstants))
        ],
                        SPKLocalizedString(@"Choose what tapping the action button does. Long press opens the full menu.")),
        SPKTopicSection(@"Privacy", @[
            [SPKSetting switchCellWithTitle:SPKLocalizedString(@"Allow Screenshots")
                                       icon:SPKSettingsIcon(@"warning")
                                defaultsKey:@"instants_allow_screenshot"],
        ],
                        SPKLocalizedString(@"Bypass screenshot and screen recording detection in the Instants viewer.")),
        SPKTopicSection(@"Creation", @[
            ({
                SPKSetting *s = [SPKSetting switchCellWithTitle:SPKLocalizedString(@"Disable Instants Creation") icon:SPKSettingsIcon(@"instants") defaultsKey:@"instants_disable_creation"];
                s.switchChangeHandler = ^(BOOL isOn) {
                    SPKPreferenceSetObject(@(isOn), @"instants_disable_creation");
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"SPKQuickSnapCreationPrefChangedNotification" object:nil];
                };
                s;
            }),
            [SPKSetting switchCellWithTitle:SPKLocalizedString(@"Skip Camera After Instants")
                                       icon:SPKSettingsIcon(@"camera")
                                defaultsKey:@"instants_skip_camera_after_viewing"],
            ({
                BOOL cameraControlAvailable = SPKPrefIsAvailable(@"instants_disable_camera_control");
                SPKSetting *s = [SPKSetting switchCellWithTitle:SPKLocalizedString(@"Disable Camera Control")
                                                       subtitle:cameraControlAvailable ? @"" : SPKLocalizedString(@"Requires an iPhone with Camera Control")
                                                           icon:SPKSettingsSystemIcon(@"button.vertical.right.press", SPKSettingsCellIconPointSize, UIImageSymbolWeightSemibold)
                                                    defaultsKey:@"instants_disable_camera_control"];
                s;
            }),
        ],
                        [[SPKLocalizedString(@"1. Blocks Instant capture (photo and video) without disabling received Instants. The shutter is darkened.\n") stringByAppendingString:SPKLocalizedString(@"2. Skips the camera page Instagram opens after viewing the last Instant.\n")] stringByAppendingString:SPKLocalizedString(@"3. Stops the hardware Camera Control button (iPhone 16/17) from taking an Instant.")]),
        SPKTopicSection(@"", @[
            // Same glyph the button itself wears: the global "Open Menu Icon" choice.
            [SPKSetting switchCellWithTitle:SPKLocalizedString(@"Camera View Button")
                                       icon:SPKSettingsIcon(SPKActionButtonOpenMenuIconName())
                                defaultsKey:@"instants_camera_btn"],
        ],
                        SPKLocalizedString(@"Adds a Sparkle button to the Instants camera view to upload a photo from Photos, Files, or Gallery, and to browse the Instants you have saved.")),
        SPKTopicSection(@"Confirmation", @[
            ({
                SPKSetting *s = [SPKSetting switchCellWithTitle:SPKLocalizedString(@"Confirm Instant Capture")
                                                           icon:SPKSettingsIcon(@"instants_burst")
                                                    defaultsKey:@"instants_confirm_capture"];
                s.enabledProvider = ^BOOL {
                    return NO;
                };
                s;
            }),
            [SPKSetting switchCellWithTitle:SPKLocalizedString(@"Confirm Instant Reaction")
                                       icon:SPKSettingsIcon(@"reactions")
                                defaultsKey:@"instants_confirm_reaction"],
        ],
                        [SPKLocalizedString(@"1. Asks for confirmation when you send a captured Instant. Temporarily unavailable.\n") stringByAppendingString:SPKLocalizedString(@"2. Shows a confirmation alert before an Instant reaction is sent.")]),
    ];
}

@implementation SPKInstantsSettingsProvider

+ (UIViewController *)makeSettingsViewController {
    return [[SPKInstantsSettingsViewController alloc] init];
}

+ (SPKSetting *)rootSetting {
    SPKSetting *setting = [SPKSetting navigationCellWithTitle:SPKLocalizedString(@"Instants")
                                                     subtitle:@""
                                                         icon:SPKSettingsIcon(@"instants")
                                               viewController:[[SPKInstantsSettingsViewController alloc] init]];
    setting.searchSectionsProvider = ^NSArray * {
        return SPKInstantsSettingsSections();
    };
    return SPKSettingApplyIconTint(setting, [SPKUtils SPKColor_InstagramPrimaryText]);
}

@end
