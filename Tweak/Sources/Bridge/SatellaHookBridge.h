#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT void SatellaInstallHooks(void);
FOUNDATION_EXPORT NSString *SatellaRootPath(NSString *path);
FOUNDATION_EXPORT NSArray<NSString *> *SatellaAuthorizedBundleIdentifiers(void);
FOUNDATION_EXPORT NSSet<NSString *> *SatellaProductIdentifiersForRequest(SKProductsRequest *request);

NS_ASSUME_NONNULL_END
