#import "../../Localization/SPKLocalization.h"
#import "SPKGallerySettingsProvider.h"
#import "../SPKSetting.h"
#import "../SPKTopicSettingsSupport.h"

#import "../../Shared/Gallery/SPKGallerySettingsViewController.h"
#import "../../Shared/Gallery/SPKGalleryViewController.h"
#import "../../Utils.h"

@implementation SPKGallerySettingsProvider

+ (SPKSetting *)rootSetting {
    SPKSetting *gallerySettings = [SPKSetting navigationCellWithTitle:SPKLocalizedString(@"Gallery Settings")
                                                             subtitle:nil
                                                                 icon:SPKSettingsIcon(@"settings")
                                                       viewController:[[SPKGallerySettingsViewController alloc] init]];
    gallerySettings.searchSectionsProvider = ^NSArray * {
        return [SPKGallerySettingsViewController searchSections];
    };

    return SPKTopicNavigationSetting(SPKLocalizedString(@"Gallery"), @"sparkle_gallery", 24.0, @[
        SPKTopicSection(@"Access", @[
            [SPKSetting buttonCellWithTitle:SPKLocalizedString(@"Open Gallery")
                                   subtitle:@""
                                       icon:SPKSettingsIcon(@"sparkle_gallery")
                                     action:^(void) {
                                         [SPKGalleryViewController presentGallery];
                                     }],
            SPKSettingApplySelectedMenuIcon([SPKSetting menuCellWithTitle:SPKLocalizedString(@"Quick Gallery Access") icon:SPKSettingsIcon(@"circle_off") menu:SPKGalleryShortcutTargetMenu()], SPKSettingsIcon(@"circle_off"))
        ],
                        SPKLocalizedString(@"Choose the tab that opens Gallery on long press. None disables the action.")),
        SPKTopicSection(SPKLocalizedString(@"Settings"), @[
            gallerySettings
        ],
                        SPKLocalizedString(@"The same screen you reach from inside Gallery."))
    ]);
}

@end
