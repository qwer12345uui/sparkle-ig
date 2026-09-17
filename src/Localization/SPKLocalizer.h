//
//  SPKLocalizer.h
//  Sparkle
//
//  Runtime Chinese localization layer for Sparkle.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SPKLocalizer : NSObject

/// Table merged from the embedded translations plus (when present) Sparkle.bundle
/// (may be nil before the first lookup).
+ (NSDictionary<NSString *, NSString *> * _Nullable)loadedTranslations;

@end

/// Translations compiled straight into the binary (see SPKTranslations.m).
/// This is the source of truth when no Sparkle.bundle is installed, and is what
/// lets a bare .dylib injection (TrollFools and friends) render Chinese.
FOUNDATION_EXPORT NSDictionary<NSString *, NSString *> * _Nonnull SPKEmbeddedTranslations(void);

/// Returns the localized (Chinese) form of `text` when a translation is
/// available, otherwise returns `text` unchanged. Never returns nil.
FOUNDATION_EXPORT NSString * _Nonnull SPKLocalizerTranslate(NSString * _Nullable text);

NS_ASSUME_NONNULL_END
