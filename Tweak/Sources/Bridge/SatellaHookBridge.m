#import "SatellaHookBridge.h"

#import <StoreKit/StoreKit.h>
#import <objc/message.h>
#import <objc/runtime.h>
#import <rootless.h>
#import <substrate.h>

@interface SATRuntime : NSObject
+ (BOOL)runtimeActive;
+ (BOOL)priceOverrideEnabled;
+ (BOOL)receiptOverrideEnabled;
+ (BOOL)observerOverrideEnabled;
+ (nullable NSData *)receiptForTransaction:(SKPaymentTransaction *)transaction;
+ (nullable id)observerProxyForObserver:(id)observer;
@end

static BOOL SATRuntimeAvailable(void) {
    return objc_getClass("SATRuntime") != Nil;
}

static BOOL SATRuntimeActive(void) {
    return SATRuntimeAvailable() && [SATRuntime runtimeActive];
}

typedef BOOL (*SATBoolMethod)(id, SEL);
typedef NSInteger (*SATIntegerMethod)(id, SEL);
typedef id _Nullable (*SATObjectMethod)(id, SEL);
typedef void (*SATAddObserverMethod)(id, SEL, id);

static SATBoolMethod originalCanMakePayments;
static SATIntegerMethod originalTransactionState;
static SATObjectMethod originalTransactionIdentifier;
static SATObjectMethod originalTransactionError;
static SATObjectMethod originalTransactionDate;
static SATObjectMethod originalProductPrice;
static SATObjectMethod originalTransactionReceipt;
static SATAddObserverMethod originalAddTransactionObserver;

static BOOL replacementCanMakePayments(id self, SEL selector) {
    if (SATRuntimeActive()) {
        return YES;
    }
    return originalCanMakePayments ? originalCanMakePayments(self, selector) : NO;
}

static NSInteger replacementTransactionState(id self, SEL selector) {
    if (SATRuntimeActive()) {
        return SKPaymentTransactionStatePurchased;
    }
    return originalTransactionState ? originalTransactionState(self, selector) : SKPaymentTransactionStateFailed;
}

static id replacementTransactionIdentifier(id self, SEL selector) {
    if (SATRuntimeActive()) {
        return NSUUID.UUID.UUIDString;
    }
    return originalTransactionIdentifier ? originalTransactionIdentifier(self, selector) : nil;
}

static id replacementTransactionError(id self, SEL selector) {
    if (SATRuntimeActive()) {
        return nil;
    }
    return originalTransactionError ? originalTransactionError(self, selector) : nil;
}

static id replacementTransactionDate(id self, SEL selector) {
    if (SATRuntimeActive()) {
        return NSDate.date;
    }
    return originalTransactionDate ? originalTransactionDate(self, selector) : nil;
}

static id replacementProductPrice(id self, SEL selector) {
    if (SATRuntimeActive() && [SATRuntime priceOverrideEnabled]) {
        return [NSDecimalNumber decimalNumberWithString:@"0.01"];
    }
    return originalProductPrice ? originalProductPrice(self, selector) : nil;
}

static id replacementTransactionReceipt(id self, SEL selector) {
    if (SATRuntimeActive() && [SATRuntime receiptOverrideEnabled]) {
        NSData *receipt = [SATRuntime receiptForTransaction:self];
        if (receipt != nil) {
            return receipt;
        }
    }
    return originalTransactionReceipt ? originalTransactionReceipt(self, selector) : nil;
}

static void replacementAddTransactionObserver(id self, SEL selector, id observer) {
    if (SATRuntimeActive() && [SATRuntime observerOverrideEnabled]) {
        id proxy = [SATRuntime observerProxyForObserver:observer];
        if (proxy != nil && originalAddTransactionObserver) {
            originalAddTransactionObserver(self, selector, proxy);
            return;
        }
    }
    if (originalAddTransactionObserver) {
        originalAddTransactionObserver(self, selector, observer);
    }
}

static BOOL SATHookInstanceMethod(Class cls, SEL selector, IMP replacement, IMP *original) {
    Method method = class_getInstanceMethod(cls, selector);
    if (method == NULL || method_getTypeEncoding(method) == NULL) {
        return NO;
    }
    MSHookMessageEx(cls, selector, replacement, original);
    return *original != NULL;
}

static BOOL SATHookClassMethod(Class cls, SEL selector, IMP replacement, IMP *original) {
    Method method = class_getClassMethod(cls, selector);
    Class metaClass = object_getClass(cls);
    if (method == NULL || metaClass == Nil || method_getTypeEncoding(method) == NULL) {
        return NO;
    }
    MSHookMessageEx(metaClass, selector, replacement, original);
    return *original != NULL;
}

void SatellaInstallHooks(void) {
    NSUInteger installed = 0;

    installed += SATHookClassMethod(SKPaymentQueue.class,
                                    @selector(canMakePayments),
                                    (IMP)replacementCanMakePayments,
                                    (IMP *)&originalCanMakePayments);
    installed += SATHookInstanceMethod(SKPaymentTransaction.class,
                                       @selector(transactionState),
                                       (IMP)replacementTransactionState,
                                       (IMP *)&originalTransactionState);
    installed += SATHookInstanceMethod(SKPaymentTransaction.class,
                                       @selector(transactionIdentifier),
                                       (IMP)replacementTransactionIdentifier,
                                       (IMP *)&originalTransactionIdentifier);
    installed += SATHookInstanceMethod(SKPaymentTransaction.class,
                                       @selector(error),
                                       (IMP)replacementTransactionError,
                                       (IMP *)&originalTransactionError);
    installed += SATHookInstanceMethod(SKPaymentTransaction.class,
                                       @selector(transactionDate),
                                       (IMP)replacementTransactionDate,
                                       (IMP *)&originalTransactionDate);
    installed += SATHookInstanceMethod(SKProduct.class,
                                       @selector(price),
                                       (IMP)replacementProductPrice,
                                       (IMP *)&originalProductPrice);
    installed += SATHookInstanceMethod(SKPaymentTransaction.class,
                                       NSSelectorFromString(@"transactionReceipt"),
                                       (IMP)replacementTransactionReceipt,
                                       (IMP *)&originalTransactionReceipt);
    installed += SATHookInstanceMethod(SKPaymentQueue.class,
                                       @selector(addTransactionObserver:),
                                       (IMP)replacementAddTransactionObserver,
                                       (IMP *)&originalAddTransactionObserver);

    NSLog(@"[Satella] Installed %lu of 8 StoreKit 1 hooks", (unsigned long)installed);
}

NSString *SatellaRootPath(NSString *path) {
    return ROOT_PATH_NS(path);
}

NSArray<NSString *> *SatellaAuthorizedBundleIdentifiers(void) {
    NSString *filterPath = ROOT_PATH_NS(@"/Library/MobileSubstrate/DynamicLibraries/Satella.plist");
    NSDictionary *propertyList = [NSDictionary dictionaryWithContentsOfFile:filterPath];
    id bundles = propertyList[@"Filter"][@"Bundles"];
    if (![bundles isKindOfClass:NSArray.class]) {
        return @[];
    }

    NSMutableArray<NSString *> *validated = [NSMutableArray array];
    for (id value in (NSArray *)bundles) {
        if ([value isKindOfClass:NSString.class] && ![value hasPrefix:@"com.apple."]) {
            [validated addObject:value];
        }
    }
    return validated.copy;
}
