#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT void SatellaInstallHooks(void);
FOUNDATION_EXPORT NSString *SatellaRootPath(NSString *path);
FOUNDATION_EXPORT NSArray<NSString *> *SatellaAuthorizedBundleIdentifiers(void);

NS_ASSUME_NONNULL_END
