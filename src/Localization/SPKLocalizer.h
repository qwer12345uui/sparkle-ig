//
//  SPKLocalizer.h
//  Sparkle
//
//  Runtime Chinese localization layer for Sparkle.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SPKLocalizer : NSObject

/// Translations currently loaded from Sparkle.bundle (may be nil).
+ (NSDictionary<NSString *, NSString *> * _Nullable)loadedTranslations;

@end

/// Returns the localized (Chinese) form of `text` when a translation is
/// available, otherwise returns `text` unchanged. Never returns nil.
FOUNDATION_EXPORT NSString * _Nonnull SPKLocalizerTranslate(NSString * _Nullable text);

NS_ASSUME_NONNULL_END
