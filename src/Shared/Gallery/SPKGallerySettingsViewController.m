#import "../../Localization/SPKLocalization.h"
#import "SPKGallerySettingsViewController.h"
#import "../../AssetUtils.h"
#import "../../Settings/SPKTopicSettingsSupport.h"
#import "../../Utils.h"
#import "../Account/SPKAccountManager.h"
#import "../UI/SPKIGAlertPresenter.h"
#import "SPKGalleryCoreDataStack.h"
#import "SPKGalleryDeleteViewController.h"
#import "SPKGalleryFile.h"
#import "SPKGalleryGridDensity.h"
#import "SPKGalleryHiddenSources.h"
#import "SPKGalleryImportViewController.h"
#import "SPKGalleryLockViewController.h"
#import "SPKGalleryManager.h"

@interface SPKGalleryHiddenSourcesViewController : SPKSettingsViewController
@end

@implementation SPKGalleryHiddenSourcesViewController

- (instancetype)init {
    return [super initWithTitle:SPKLocalizedString(@"Hidden Sources") sections:@[] reduceMargin:NO];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self rebuildSections];
}

- (void)rebuildSections {
    NSMutableArray<SPKSetting *> *rows = [NSMutableArray array];
    NSArray<NSNumber *> *sources = @[
        @(SPKGallerySourceFeed),
        @(SPKGallerySourceStories),
        @(SPKGallerySourceReels),
        @(SPKGallerySourceProfile),
        @(SPKGallerySourceDMs),
        @(SPKGallerySourceThumbnail),
        @(SPKGallerySourceInstants),
        @(SPKGallerySourceAudioPage),
        @(SPKGallerySourceComments),
        @(SPKGallerySourceOther),
    ];
    for (NSNumber *sourceValue in sources) {
        SPKGallerySource source = (SPKGallerySource)sourceValue.integerValue;
        SPKSetting *row = [SPKSetting switchCellWithTitle:[SPKGalleryFile labelForSource:source]
                                                     icon:SPKSettingsIcon([SPKGalleryFile symbolNameForSource:source])
                                              defaultsKey:@""];
        row.switchValueProvider = ^BOOL {
            return SPKGallerySourceIsHidden(source);
        };
        row.switchChangeHandler = ^(BOOL hidden) {
            SPKGallerySetSourceHidden(source, hidden);
        };
        [rows addObject:row];
    }
    [self replaceSections:@[ SPKTopicSection(@"Sources", rows, SPKLocalizedString(@"Hidden sources stay stored in Gallery and remain available to maintenance, export, and duplicate detection.")) ]];
}

@end

static NSString *const kFavoritesAtTopKey = @"gallery_show_favorites_top";
static NSString *const kGalleryLongPressTabKey = @"gallery_quick_access_tab";
static NSString *const kGalleryQuickAccessDisabledValue = @"none";

@interface SPKGalleryStorageStats : NSObject
@property (nonatomic, assign) NSInteger totalFiles;
@property (nonatomic, assign) NSInteger imageCount;
@property (nonatomic, assign) NSInteger videoCount;
@property (nonatomic, assign) NSInteger audioCount;
@property (nonatomic, assign) long long totalSize;
@end

@implementation SPKGalleryStorageStats
@end

@interface SPKGallerySettingsViewController ()
@property (nonatomic, strong) SPKGalleryStorageStats *stats;
@end

@implementation SPKGallerySettingsViewController

+ (NSArray *)searchSections {
    return @[
        SPKTopicSection(SPKLocalizedString(@"Storage"), @[
            [SPKSetting valueCellWithTitle:SPKLocalizedString(@"Total")
                                  subtitle:SPKLocalizedString(@"Gallery storage and file count")
                                      icon:SPKSettingsIcon(@"info")],
            [SPKSetting valueCellWithTitle:@"Images"
                                  subtitle:SPKLocalizedString(@"Saved image count")
                                      icon:SPKSettingsIcon(@"photo")],
            [SPKSetting valueCellWithTitle:@"Videos"
                                  subtitle:SPKLocalizedString(@"Saved video count")
                                      icon:SPKSettingsIcon(@"video")],
            [SPKSetting valueCellWithTitle:@"Audio"
                                  subtitle:SPKLocalizedString(@"Saved audio count")
                                      icon:SPKSettingsIcon(@"audio")]
        ],
                        nil),
        SPKTopicSection(@"Browsing", @[
            [SPKSetting switchCellWithTitle:SPKLocalizedString(@"Show Favorites at Top")
                                       icon:SPKSettingsIcon(@"heart")
                                defaultsKey:kFavoritesAtTopKey],
            [SPKSetting switchCellWithTitle:SPKLocalizedString(@"Show Files From Subfolders")
                                       icon:SPKSettingsIcon(@"folder")
                                defaultsKey:kSPKGalleryFlatBrowsingKey],
            [SPKSetting navigationCellWithTitle:SPKLocalizedString(@"Hidden Sources")
                                       subtitle:@""
                                           icon:SPKSettingsIcon(@"eye_off")
                                 viewController:[SPKGalleryHiddenSourcesViewController new]]
        ],
                        SPKLocalizedString(@"Pin favorites above other files inside the current sort and folder context.")),
        SPKTopicSection(@"Editing", @[
            [SPKSetting switchCellWithTitle:SPKLocalizedString(@"Ask to Replace Original")
                                       icon:SPKSettingsIcon(@"left_right")
                                defaultsKey:@"trim_gallery_prompt_replace"]
        ],
                        SPKLocalizedString(@"When you trim or edit a Gallery item, ask whether to replace the original or save a copy. Off always saves a copy and keeps the original.")),
        SPKTopicSection(@"Preview", @[
            [SPKSetting switchCellWithTitle:SPKLocalizedString(@"Show Media Info")
                                       icon:SPKSettingsIcon(@"info")
                                defaultsKey:@"gallery_preview_show_metadata"]
        ],
                        SPKLocalizedString(@"Overlay the username, source, and saved/posted dates on the expanded photo preview.")),
        SPKTopicSection(@"Lock", @[
            [SPKSetting switchCellWithTitle:SPKLocalizedString(@"Gallery Passcode Lock")
                                       icon:SPKSettingsIcon(@"lock")
                                defaultsKey:@""],
            [SPKSetting buttonCellWithTitle:SPKLocalizedString(@"Change Passcode")
                                   subtitle:nil
                                       icon:SPKSettingsIcon(@"key")
                                     action:^{
                                     }]
        ],
                        SPKLocalizedString(@"Lock the Gallery with a passcode or biometrics.")),
        SPKTopicSection(SPKLocalizedString(@"Import"), @[
            // A navigation row, not a button: this mirror feeds the settings search index, and a
            // button row's action is what search runs on tap — an empty one silently does nothing.
            // The framework pushes navViewController itself, so the result is actually reachable.
            // No folder context from search, so it imports to the gallery root (nil).
            [SPKSetting navigationCellWithTitle:SPKLocalizedString(@"Import Media")
                                       subtitle:nil
                                           icon:SPKSettingsIcon(@"media")
                                 viewController:[[SPKGalleryImportViewController alloc] initWithDestinationFolderPath:nil]]
        ],
                        [SPKLocalizedString(@"Import media from the Files app with full editable metadata.\n") stringByAppendingString:SPKLocalizedString(@"Coming from Regram? Pick your exported folder or MediaVault.zip here to bring your whole Media Vault over.")]),
        SPKTopicSection(@"Delete", @[
            [SPKSetting buttonCellWithTitle:SPKLocalizedString(@"Delete Files")
                                   subtitle:nil
                                       icon:SPKSettingsIcon(@"trash")
                                     action:^{
                                     }]
        ],
                        nil)
    ];
}

- (instancetype)init {
    return [super initWithTitle:SPKLocalizedString(@"Gallery Settings") sections:@[] reduceMargin:NO];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self reloadStats];
    [self rebuildSections];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self reloadStats];
    [self rebuildSections];
}

- (void)reloadStats {
    NSManagedObjectContext *ctx = [SPKGalleryCoreDataStack shared].viewContext;
    NSFetchRequest *req = [[NSFetchRequest alloc] initWithEntityName:@"SPKGalleryFile"];
    NSArray<SPKGalleryFile *> *files = [ctx executeFetchRequest:req error:nil] ?: @[];

    SPKGalleryStorageStats *stats = [SPKGalleryStorageStats new];
    for (SPKGalleryFile *file in files) {
        stats.totalFiles += 1;
        stats.totalSize += file.fileSize;
        if (file.mediaType == SPKGalleryMediaTypeAudio) {
            stats.audioCount += 1;
        } else if (file.mediaType == SPKGalleryMediaTypeVideo) {
            stats.videoCount += 1;
        } else {
            stats.imageCount += 1;
        }
    }
    self.stats = stats;
}

- (NSString *)formattedSize:(long long)bytes {
    return [NSByteCountFormatter stringFromByteCount:bytes countStyle:NSByteCountFormatterCountStyleFile];
}

- (void)rebuildSections {
    NSMutableArray *sections = [NSMutableArray array];

    [sections addObject:SPKTopicSection(SPKLocalizedString(@"Storage"), @[
                  [SPKSetting valueCellWithTitle:SPKLocalizedString(@"Total")
                                        subtitle:[NSString stringWithFormat:SPKLocalizedString(@"%ld files • %@"), (long)self.stats.totalFiles, [self formattedSize:self.stats.totalSize]]
                                            icon:SPKSettingsIcon(@"info")],
                  [SPKSetting valueCellWithTitle:@"Images"
                                        subtitle:[NSString stringWithFormat:@"%ld", (long)self.stats.imageCount]
                                            icon:SPKSettingsIcon(@"photo")],
                  [SPKSetting valueCellWithTitle:@"Videos"
                                        subtitle:[NSString stringWithFormat:@"%ld", (long)self.stats.videoCount]
                                            icon:SPKSettingsIcon(@"video")],
                  [SPKSetting valueCellWithTitle:@"Audio"
                                        subtitle:[NSString stringWithFormat:@"%ld", (long)self.stats.audioCount]
                                            icon:SPKSettingsIcon(@"audio")]
              ],
                                        nil)];

    SPKSetting *favoritesRow = [SPKSetting switchCellWithTitle:SPKLocalizedString(@"Show Favorites at Top") icon:SPKSettingsIcon(@"heart") defaultsKey:kFavoritesAtTopKey];
    favoritesRow.action = ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"SPKGalleryFavoritesSortPreferenceChanged" object:nil];
    };
    // Defaults ON; the backing pref stores the *disabled* state, so the switch inverts.
    SPKSetting *pinFolderRow = [SPKSetting switchCellWithTitle:SPKLocalizedString(@"Pin Folder Bar") icon:SPKSettingsIcon(@"pin") defaultsKey:@""];
    pinFolderRow.switchValueProvider = ^BOOL {
        return ![[NSUserDefaults standardUserDefaults] boolForKey:kSPKGalleryFolderBarPinDisabledKey];
    };
    pinFolderRow.switchChangeHandler = ^(BOOL isOn) {
        [[NSUserDefaults standardUserDefaults] setBool:!isOn forKey:kSPKGalleryFolderBarPinDisabledKey];
        [[NSNotificationCenter defaultCenter] postNotificationName:kSPKGalleryGridControlsChangedNotification object:nil];
    };
    SPKSetting *flatBrowsingRow = [SPKSetting switchCellWithTitle:SPKLocalizedString(@"Show Files From Subfolders") icon:SPKSettingsIcon(@"folder") defaultsKey:kSPKGalleryFlatBrowsingKey];
    flatBrowsingRow.action = ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kSPKGalleryBrowsingScopeChangedNotification object:nil];
    };
    [sections addObject:SPKTopicSection(@"Browsing", @[favoritesRow, pinFolderRow, flatBrowsingRow],
                                        [[SPKLocalizedString(@"1. Pin favorites above other files inside the current sort and folder context.\n") stringByAppendingString:SPKLocalizedString(@"2. Keep the subfolder bar pinned to the top while scrolling.\n")] stringByAppendingString:SPKLocalizedString(@"3. Show files from all folders instead of only the current folder's files. The folders stay in the bar above and still narrow the list.")])];

    [sections addObject:SPKTopicSection(@"Editing", @[
                  [SPKSetting switchCellWithTitle:SPKLocalizedString(@"Ask to Replace Original")
                                             icon:SPKSettingsIcon(@"left_right")
                                      defaultsKey:@"trim_gallery_prompt_replace"]
              ],
                                        SPKLocalizedString(@"When you trim or edit a Gallery item, ask whether to replace the original or save a copy. Off always saves a copy and keeps the original."))];

    SPKSetting *accountFilterRow = [SPKSetting switchCellWithTitle:SPKLocalizedString(@"This Account Only") icon:SPKSettingsIcon(@"user_circle") defaultsKey:@"gallery_filter_current_account"];
    __weak typeof(self) weakAccountSelf = self;
    accountFilterRow.action = ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:SPKGalleryHiddenSourcesDidChangeNotification object:nil];
        if ([SPKUtils getBoolPref:@"gallery_filter_current_account"]) {
            [weakAccountSelf promptClaimUnassignedFiles];
        }
    };
    [sections addObject:SPKTopicSection(@"Visibility", @[
                  accountFilterRow,
                  [SPKSetting navigationCellWithTitle:SPKLocalizedString(@"Hidden Sources")
                                             subtitle:@""
                                                 icon:SPKSettingsIcon(@"eye_off")
                                       viewController:[SPKGalleryHiddenSourcesViewController new]]
              ],
                                        [SPKLocalizedString(@"1. Show only media saved while logged into the current account, plus older unassigned files; reassign a file's account from its details sheet.\n") stringByAppendingString:SPKLocalizedString(@"2. Hide selected sources from Gallery browsing and upload picker sheets without deleting their files.")])];

    // Grid section: pinch-to-zoom toggle. Defaults ON; the backing pref stores
    // the *disabled* state, so the switch inverts.
    SPKSetting *pinchRow = [SPKSetting switchCellWithTitle:SPKLocalizedString(@"Pinch to Zoom") icon:SPKSettingsIcon(@"pinch") defaultsKey:@""];
    pinchRow.switchValueProvider = ^BOOL {
        return ![[NSUserDefaults standardUserDefaults] boolForKey:kSPKGalleryGridPinchDisabledKey];
    };
    pinchRow.switchChangeHandler = ^(BOOL isOn) {
        [[NSUserDefaults standardUserDefaults] setBool:!isOn forKey:kSPKGalleryGridPinchDisabledKey];
        [[NSNotificationCenter defaultCenter] postNotificationName:kSPKGalleryGridControlsChangedNotification object:nil];
    };

    SPKSetting *sourceUsernameRow = [SPKSetting switchCellWithTitle:SPKLocalizedString(@"Show Source & Username") icon:SPKSettingsIcon(@"user_circle") defaultsKey:@""];
    sourceUsernameRow.switchValueProvider = ^BOOL {
        return ![[NSUserDefaults standardUserDefaults] boolForKey:kSPKGalleryGridShowSourceUsernameDisabledKey];
    };
    sourceUsernameRow.switchChangeHandler = ^(BOOL isOn) {
        [[NSUserDefaults standardUserDefaults] setBool:!isOn forKey:kSPKGalleryGridShowSourceUsernameDisabledKey];
        [[NSNotificationCenter defaultCenter] postNotificationName:kSPKGalleryGridControlsChangedNotification object:nil];
    };

    [sections addObject:SPKTopicSection(@"Grid", @[ pinchRow, sourceUsernameRow ],
                                        [SPKLocalizedString(@"1. Pinch the grid to change density (2, 3 or 5 columns).\n") stringByAppendingString:SPKLocalizedString(@"2. Overlay the source icon and username on each grid item; the username shows at lower densities.")])];

    [sections addObject:SPKTopicSection(@"Preview", @[
                  [SPKSetting switchCellWithTitle:SPKLocalizedString(@"Show Media Info")
                                             icon:SPKSettingsIcon(@"info")
                                      defaultsKey:@"gallery_preview_show_metadata"]
              ],
                                        SPKLocalizedString(@"Overlay the username, source, and saved/posted dates on the expanded photo preview. Tap the media to hide it along with the controls."))];

    NSMutableArray *lockRows = [NSMutableArray array];

    __weak typeof(self) weakSelf = self;
    SPKSetting *lockSwitch = [SPKSetting switchCellWithTitle:SPKLocalizedString(@"Gallery Passcode Lock") icon:SPKSettingsIcon(@"lock") defaultsKey:@""];
    lockSwitch.switchValueProvider = ^BOOL {
        return [SPKGalleryManager sharedManager].isLockEnabled;
    };
    lockSwitch.switchChangeHandler = ^(BOOL isOn) {
        [weakSelf handleLockToggleEnabled:isOn];
    };
    [lockRows addObject:lockSwitch];

    SPKSetting *changePasscode = [SPKSetting buttonCellWithTitle:SPKLocalizedString(@"Change Passcode")
                                                        subtitle:nil
                                                            icon:SPKSettingsIcon(@"key")
                                                          action:^{
                                                              [SPKGalleryLockViewController presentMode:SPKGalleryLockModeChangePasscode
                                                                                     fromViewController:self
                                                                                             completion:^(BOOL success){
                                                                                             }];
                                                          }];
    changePasscode.enabledProvider = ^BOOL {
        return [SPKGalleryManager sharedManager].isLockEnabled;
    };
    [lockRows addObject:changePasscode];

    [sections addObject:SPKTopicSection(@"Lock", lockRows, SPKLocalizedString(@"Lock the Gallery with a passcode or biometrics."))];

    SPKSetting *importRow = [SPKSetting buttonCellWithTitle:SPKLocalizedString(@"Import Media")
                                                   subtitle:nil
                                                       icon:SPKSettingsIcon(@"media")
                                                     action:^{
                                                         SPKGalleryImportViewController *vc = [[SPKGalleryImportViewController alloc] initWithDestinationFolderPath:self.importDestinationFolderPath];
                                                         [self.navigationController pushViewController:vc animated:YES];
                                                     }];
    [sections addObject:SPKTopicSection(SPKLocalizedString(@"Import"), @[ importRow ],
                                        [SPKLocalizedString(@"Import media from the Files app with full editable metadata.\n") stringByAppendingString:SPKLocalizedString(@"Coming from Regram? Pick your exported folder or MediaVault.zip here to bring your whole Media Vault over.")])];

    SPKSetting *deleteRow = [SPKSetting buttonCellWithTitle:SPKLocalizedString(@"Delete Files")
                                                   subtitle:nil
                                                       icon:SPKSettingsIcon(@"trash")
                                                     action:^{
                                                         SPKGalleryDeleteViewController *vc = [[SPKGalleryDeleteViewController alloc] initWithMode:SPKGalleryDeletePageModeRoot];
                                                         __weak typeof(self) weakSelf = self;
                                                         vc.onDidDelete = ^{
                                                             [weakSelf reloadStats];
                                                             [weakSelf rebuildSections];
                                                             [[NSNotificationCenter defaultCenter] postNotificationName:@"SPKGalleryFavoritesSortPreferenceChanged" object:nil];
                                                         };
                                                         [self.navigationController pushViewController:vc animated:YES];
                                                     }];
    deleteRow.tintColor = [SPKUtils SPKColor_InstagramDestructive];
    deleteRow.iconTintColor = [SPKUtils SPKColor_InstagramDestructive];

    [sections addObject:SPKTopicSection(@"Delete", @[ deleteRow ], nil)];

    [self replaceSections:sections];
}

- (void)promptClaimUnassignedFiles {
    NSString *pk = [SPKAccountManager currentAccountPK];
    if (pk.length == 0)
        return;
    NSUInteger count = [SPKGalleryFile unassignedFileCount];
    if (count == 0)
        return;

    NSString *username = [SPKAccountManager currentAccountUsername];
    NSString *who = username.length > 0 ? [@"@" stringByAppendingString:username] : SPKLocalizedString(@"this account");
    NSString *message = [NSString stringWithFormat:SPKLocalizedString(@"%lu existing file%@ %@ no account and won't show under This Account Only. Assign %@ to %@?"),
                                                   (unsigned long)count,
                                                   count == 1 ? @"" : @"s",
                                                   count == 1 ? @"has" : @"have",
                                                   count == 1 ? @"it" : @"them",
                                                   who];

    [SPKIGAlertPresenter presentAlertFromViewController:self
                                                  title:SPKLocalizedString(@"Claim Existing Files?")
                                                message:message
                                                actions:@[
                                                    [SPKIGAlertAction actionWithTitle:SPKLocalizedString(@"Not Now")
                                                                                style:SPKIGAlertActionStyleCancel
                                                                              handler:nil],
                                                    [SPKIGAlertAction actionWithTitle:@"Assign"
                                                                                style:SPKIGAlertActionStyleDefault
                                                                              handler:^{
                                                                                  [SPKGalleryFile claimUnassignedFilesForAccountPK:pk username:username];
                                                                                  [[NSNotificationCenter defaultCenter] postNotificationName:SPKGalleryHiddenSourcesDidChangeNotification object:nil];
                                                                              }]
                                                ]];
}

- (void)handleLockToggleEnabled:(BOOL)enabled {
    SPKGalleryManager *mgr = [SPKGalleryManager sharedManager];
    if (enabled && !mgr.isLockEnabled) {
        __weak typeof(self) weakSelf = self;
        [SPKGalleryLockViewController presentMode:SPKGalleryLockModeSetPasscode
                               fromViewController:self
                                       completion:^(BOOL success) {
                                           [weakSelf rebuildSections];
                                       }];
        return;
    }

    if (enabled && mgr.isLockEnabled) {
        [self rebuildSections];
        return;
    }

    if (!enabled && !mgr.isLockEnabled) {
        [self rebuildSections];
        return;
    }

    [SPKIGAlertPresenter presentAlertFromViewController:self
                                                  title:SPKLocalizedString(@"Disable Passcode")
                                                message:SPKLocalizedString(@"The gallery will no longer require authentication to open.")
                                                actions:@[
                                                    [SPKIGAlertAction actionWithTitle:SPKLocalizedString(@"Cancel")
                                                                                style:SPKIGAlertActionStyleCancel
                                                                              handler:^{
                                                                                  [self rebuildSections];
                                                                              }],
                                                    [SPKIGAlertAction actionWithTitle:SPKLocalizedString(@"Disable")
                                                                                style:SPKIGAlertActionStyleDestructive
                                                                              handler:^{
                                                                                  [mgr removePasscode];
                                                                                  [self rebuildSections];
                                                                              }],
                                                ]];
}

@end
