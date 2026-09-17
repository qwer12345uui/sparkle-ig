#import "../../Localization/SPKLocalization.h"
#import "SPKHookBisectSettingsProvider.h"

#if SPK_DEV

#import <UIKit/UIKit.h>

#import "../../App/SPKHookBisect.h"
#import "../../App/SPKPerfMeter.h"
#import "../../Utils.h"
#import "../SPKSettingsViewController.h"
#import "../SPKTopicSettingsSupport.h"

// The bulk buttons flip many switches at once, so the visible rows have to be
// re-read. Same shape as the settings-lock rows in SPKToolsSettingsProvider.
static void SPKHookBisectReloadVisibleSettings(void) {
    UIViewController *presenter = UIApplication.sharedApplication.keyWindow.rootViewController;
    while (presenter.presentedViewController)
        presenter = presenter.presentedViewController;

    SPKSettingsViewController *settingsVC = nil;
    if ([presenter isKindOfClass:SPKSettingsViewController.class]) {
        settingsVC = (SPKSettingsViewController *)presenter;
    } else if ([presenter isKindOfClass:UINavigationController.class]) {
        UIViewController *top = ((UINavigationController *)presenter).topViewController;
        if ([top isKindOfClass:SPKSettingsViewController.class])
            settingsVC = (SPKSettingsViewController *)top;
    }
    [settingsVC.tableView reloadData];
}

static SPKSetting *SPKHookBisectInstallerRow(NSString *installerName) {
    BOOL essential = SPKHookBisectInstallerIsEssential(installerName);
    // ON = installed. Reading "turn the hook off" matches what the user is
    // doing; the underlying pref stores the inverse (skipped).
    SPKSetting *row = [SPKSetting switchCellWithTitle:SPKHookBisectDisplayName(installerName)
                                             subtitle:essential ? SPKLocalizedString(@"Always installed") : @""
                                          defaultsKey:@""];
    row.requiresRestart = YES;
    row.switchValueProvider = ^BOOL {
        return !SPKHookBisectInstallerIsSkipped(installerName);
    };
    row.switchChangeHandler = ^(BOOL isOn) {
        SPKHookBisectSetInstaller(installerName, !isOn);
    };
    if (essential) {
        row.enabledProvider = ^BOOL {
            return NO;
        };
    }
    return row;
}

// The meter is what makes a bisect round decidable: "feels smoother" is not a
// result, "180ms blocked instead of 4.2s" is.
static NSArray<SPKSetting *> *SPKPerfMeterRows(void) {
    SPKSetting *meter = [SPKSetting switchCellWithTitle:SPKLocalizedString(@"Performance Meter") defaultsKey:@""];
    meter.switchValueProvider = ^BOOL {
        return SPKPerfMeterIsEnabled();
    };
    meter.switchChangeHandler = ^(BOOL isOn) {
        SPKPreferenceSetObject(@(isOn), kSPKPerfMeterEnabledKey);
        SPKPerfMeterSetEnabled(isOn);
        if (isOn && [SPKUtils getBoolPref:kSPKPerfMeterHUDKey])
            SPKPerfMeterSetHUDVisible(YES);
        SPKHookBisectReloadVisibleSettings();
    };

    SPKSetting *hud = [SPKSetting switchCellWithTitle:SPKLocalizedString(@"On-screen HUD") defaultsKey:@""];
    hud.switchValueProvider = ^BOOL {
        return [SPKUtils getBoolPref:kSPKPerfMeterHUDKey];
    };
    hud.switchChangeHandler = ^(BOOL isOn) {
        SPKPreferenceSetObject(@(isOn), kSPKPerfMeterHUDKey);
        SPKPerfMeterSetHUDVisible(isOn && SPKPerfMeterIsEnabled());
    };
    hud.enabledProvider = ^BOOL {
        return SPKPerfMeterIsEnabled();
    };

    SPKSetting *summary = [SPKSetting buttonCellWithTitle:SPKLocalizedString(@"Blocked Time")
                                                 subtitle:@""
                                                     icon:nil
                                                   action:^{
                                                       SPKHookBisectReloadVisibleSettings();
                                                   }];
    summary.accessoryTextProvider = ^NSString * {
        return SPKPerfMeterSummary();
    };

    // The whole point of the scope timers: the answer is readable here, without
    // attaching a console.
    SPKSetting *worst = [SPKSetting buttonCellWithTitle:SPKLocalizedString(@"Most Expensive Hook")
                                               subtitle:@""
                                                   icon:nil
                                                 action:^{
                                                     SPKPerfMeterLogSnapshot(@"worst hook");
                                                     SPKHookBisectReloadVisibleSettings();
                                                 }];
    worst.accessoryTextProvider = ^NSString * {
        return SPKPerfMeterWorstScopeSummary();
    };

    SPKSetting *reset = [SPKSetting buttonCellWithTitle:SPKLocalizedString(@"Start New Measurement")
                                               subtitle:@""
                                                   icon:nil
                                                 action:^{
                                                     SPKPerfMeterLogSnapshot(@"before reset");
                                                     SPKPerfMeterReset();
                                                     SPKHookBisectReloadVisibleSettings();
                                                 }];
    reset.enabledProvider = ^BOOL {
        return SPKPerfMeterIsEnabled();
    };

    SPKSetting *log = [SPKSetting buttonCellWithTitle:SPKLocalizedString(@"Log Snapshot")
                                             subtitle:@""
                                                 icon:nil
                                               action:^{
                                                   SPKPerfMeterLogSnapshot(@"manual");
                                               }];
    log.enabledProvider = ^BOOL {
        return SPKPerfMeterIsEnabled();
    };

    return @[ meter, hud, summary, worst, reset, log ];
}

@implementation SPKHookBisectSettingsProvider

+ (SPKSetting *)rootSetting {
    NSArray<NSDictionary *> *groups = SPKHookBisectRegisteredGroups();

    // Button rather than static: the live count comes from accessoryTextProvider,
    // which the table only honours for button and navigation cells. Tapping just
    // re-reads the counters.
    SPKSetting *status = [SPKSetting buttonCellWithTitle:SPKLocalizedString(@"Skipped Installers")
                                                subtitle:@""
                                                    icon:nil
                                                  action:^{
                                                      SPKHookBisectReloadVisibleSettings();
                                                  }];
    status.accessoryTextProvider = ^NSString * {
        return [NSString stringWithFormat:SPKLocalizedString(@"%lu of %lu"),
                                          (unsigned long)SPKHookBisectSkippedCount(),
                                          (unsigned long)SPKHookBisectRegisteredInstallerCount()];
    };

    SPKSetting *skipHalf = [SPKSetting buttonCellWithTitle:SPKLocalizedString(@"Skip Half of Remaining")
                                                  subtitle:@""
                                                      icon:nil
                                                    action:^{
                                                        NSUInteger skipped = SPKHookBisectSkipHalfOfRemaining();
                                                        SPKHookBisectReloadVisibleSettings();
                                                        if (skipped > 0)
                                                            [SPKUtils showRestartConfirmation];
                                                    }];

    SPKSetting *skipAll = [SPKSetting buttonCellWithTitle:SPKLocalizedString(@"Skip All")
                                                 subtitle:@""
                                                     icon:nil
                                                   action:^{
                                                       SPKHookBisectSetAll(YES);
                                                       SPKHookBisectReloadVisibleSettings();
                                                       [SPKUtils showRestartConfirmation];
                                                   }];

    SPKSetting *restoreAll = [SPKSetting buttonCellWithTitle:SPKLocalizedString(@"Restore All")
                                                    subtitle:@""
                                                        icon:nil
                                                      action:^{
                                                          SPKHookBisectSetAll(NO);
                                                          SPKHookBisectReloadVisibleSettings();
                                                          [SPKUtils showRestartConfirmation];
                                                      }];

    // Individual switches use switchChangeHandler, which returns before the
    // table's own requiresRestart prompt, and prompting per row would fight the
    // workflow (a bisect round flips many rows at once). One explicit relaunch.
    SPKSetting *relaunch = [SPKSetting buttonCellWithTitle:SPKLocalizedString(@"Relaunch Instagram")
                                                  subtitle:@""
                                                      icon:nil
                                                    action:^{
                                                        [SPKUtils showRestartConfirmation];
                                                    }];

    NSMutableArray *sections = [NSMutableArray array];
    [sections addObject:SPKTopicSection(@"Measurement",
                                        SPKPerfMeterRows(),
                                        [[[[[[[[[SPKLocalizedString(@"Measures how long the main thread is blocked, which is what \"laggy\" ") stringByAppendingString:@"actually is, and counts the view controllers, views and gesture "] stringByAppendingString:@"recognizers alive in the current window.\n\n"] stringByAppendingString:@"Numbers that climb as you navigate and never drop back are a leak: "] stringByAppendingString:@"screens or recognizers are piling up and every one of them keeps doing "] stringByAppendingString:@"work. Start a new measurement before each run so rounds compare.\n\n"] stringByAppendingString:@"Every Sparkle hook that runs during layout is timed, so Most Expensive "] stringByAppendingString:SPKLocalizedString(@"Hook names the one eating the main thread. Turn the meter on, browse ")] stringByAppendingString:SPKLocalizedString(@"until it feels slow, then come back and read it. The full ranking goes ")] stringByAppendingString:SPKLocalizedString(@"to the log every 15 seconds.")])];
    [sections addObject:SPKTopicSection(@"Bisect",
                                        @[ status, skipHalf, skipAll, restoreAll, relaunch ],
                                        [[[[[[SPKLocalizedString(@"Turn an installer off to keep its hooks from being installed on the next launch. ") stringByAppendingString:@"This is not the same as turning the feature off: most installers run regardless of "] stringByAppendingString:@"their own preference, so a disabled feature can still have its hooks (and their "] stringByAppendingString:@"per-layout work) in place.\n\n"] stringByAppendingString:@"To find a regression: Skip Half of Remaining, relaunch, test. If the problem is gone "] stringByAppendingString:@"the cause is in the half that was skipped, so Restore All and skip the other half "] stringByAppendingString:@"instead. Repeat until one installer is left. Every change needs a relaunch."])];

    for (NSDictionary *group in groups) {
        NSArray<NSString *> *installers = group[@"installers"];
        NSMutableArray *rows = [NSMutableArray array];
        for (NSString *installerName in installers) {
            [rows addObject:SPKHookBisectInstallerRow(installerName)];
        }
        if (rows.count > 0)
            [sections addObject:SPKTopicSection(group[@"surface"], rows, nil)];
    }

    if (groups.count == 0) {
        [sections addObject:SPKTopicSection(@"",
                                            @[ [SPKSetting staticCellWithTitle:SPKLocalizedString(@"No installers recorded yet")
                                                                      subtitle:SPKLocalizedString(@"Reopen this page a moment after launch.")
                                                                          icon:nil] ],
                                            nil)];
    }

    return [SPKSetting navigationCellWithTitle:SPKLocalizedString(@"Hook Bisect")
                                      subtitle:@""
                                          icon:SPKSettingsIcon(@"beaker")
                                   navSections:sections];
}

@end

#endif // SPK_DEV
