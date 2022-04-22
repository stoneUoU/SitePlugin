//
//  HSADebugTouchTemp.m
//  HSA-DebugTools-iOS
//
//  Created by xiecj1 on 2019/11/1.
//

#import "HSADebugTouchTemp.h"

@interface WYKeychain()

@property (nonatomic, readwrite) NSString *service;

@property (nonatomic, readwrite) NSString *accessGroup;

@end

@implementation WYKeychain

#pragma mark - Lazy Method

+ (WYKeychain *)sharedKeychain{
    static WYKeychain *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
#if DEBUG
        sharedInstance = [[WYKeychain alloc] initWithService:@"com.guahao.keychain" accessGroup:@"8F3KT864KL.com.lvxian.*"];
#else
        sharedInstance = [[WYKeychain alloc] init];
#endif
    });
    return sharedInstance;
}

+ (WYKeychain *)keychain {
    return [[WYKeychain alloc] init];
}

+ (WYKeychain *)keychainWithService:(NSString *)service {
    return [[WYKeychain alloc] initWithService:service];
}

+ (WYKeychain *)keychainWithService:(NSString *)service accessGroup:(NSString *)accessGroup {
    return [[WYKeychain alloc] initWithService:service accessGroup:accessGroup];
}

#pragma mark - Life Cycle
- (instancetype)init {
    NSString *service = @"com.lvxian.keychain";
    service = @"com.guahao.keychain";
    return [self initWithService:service accessGroup:nil];
}

- (instancetype)initWithService:(NSString *)service {
    return [self initWithService:service accessGroup:nil];
}

- (instancetype)initWithService:(NSString *)service accessGroup:(NSString *)accessGroup {
    self = [super init];
    if (self) {
        _service = service;
        _accessGroup = accessGroup;
    }
    return self;
}

#pragma mark - 保存方法

- (void)saveString:(NSString *)string forKey:(NSString *)key{
    NSData *data = key ? [string dataUsingEncoding:NSUTF8StringEncoding] : nil;
    [self saveData:data forKey:key error:nil];
}

- (void)saveString:(NSString *)string forKey:(NSString *)key error:(NSError **)error{
    NSData *data = key ? [string dataUsingEncoding:NSUTF8StringEncoding] : nil;
    [self saveData:data forKey:key error:error];
}

- (void)saveData:(NSData *)data forKey:(NSString *)key{
    [self saveData:data forKey:key error:nil];
}

- (void)saveData:(NSData *)data forKey:(NSString *)key error:(NSError **)error{
    if (!key) {
        [self dealWithError:error status:errSecParam];
    }
    NSDictionary *query = [self queryFindByKey:key];
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, NULL);
    if (status == errSecSuccess) {
        if (data) {
            NSDictionary *updateQuery = [self queryUpdateValue:data];
            status = SecItemUpdate((__bridge CFDictionaryRef)query, (__bridge CFDictionaryRef)updateQuery);
            if (status != errSecSuccess) {
                [self dealWithError:error status:status];
            }
        } else {
            OSStatus status = SecItemDelete((__bridge CFDictionaryRef)query);
            if (status != errSecSuccess) {
                [self dealWithError:error status:status];
            }
        }
    } else {
        NSDictionary *newQuery = [self queryNewKey:key value:data];
        OSStatus status = SecItemAdd((__bridge CFDictionaryRef)newQuery, NULL);
        if (status != errSecSuccess) {
            [self dealWithError:error status:status];
        }
    }
}

#pragma mark - 删除方法
- (void)deleteEntryForKey:(NSString *)key {
    [self deleteEntryForKey:key error:nil];
}

- (void)deleteEntryForKey:(NSString *)key error:(NSError **)error{
    if (!key) {
        [self dealWithError:error status:errSecParam];
    }
    NSDictionary *deleteQuery = [self queryFindByKey:key];
    OSStatus status = SecItemDelete((__bridge CFDictionaryRef)deleteQuery);
    if (status != errSecSuccess) {
        [self dealWithError:error status:status];
    }
}

- (void)clearAll {
    NSDictionary *query = [self queryFindAll];
    CFArrayRef result = nil;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, (CFTypeRef *)&result);
    if (status == errSecSuccess || status == errSecItemNotFound) {
        NSArray *items = [NSArray arrayWithArray:(__bridge NSArray *)result];
        CFBridgingRelease(result);
        for (NSDictionary *item in items) {
            NSMutableDictionary *queryDelete = [[NSMutableDictionary alloc] initWithDictionary:item];
            queryDelete[(__bridge id)kSecClass] = (__bridge id)kSecClassGenericPassword;
            OSStatus status = SecItemDelete((__bridge CFDictionaryRef)queryDelete);
            if (status != errSecSuccess) {
                break;
            }
        }
    }
}

#pragma mark - 查询方法

- (NSArray<NSDictionary<NSString *,id> *> *)fetchAllAccount{
    return [self fetchAllAccount:nil];
}

- (NSArray<NSDictionary<NSString *,id> *> *)fetchAllAccount:(NSError **)error{
    
    NSMutableDictionary *query = [[self queryFindAll] mutableCopy];
    CFTypeRef result = NULL;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, &result);
    if (status != errSecSuccess ) {
        [self dealWithError:error status:status];
        return nil;
    }
    return (__bridge NSArray *)result;
}

- (NSData *)dataForKey:(NSString *)key {
    return [self dataForKey:key error:nil];
}

- (NSString *)stringForKey:(NSString *)key{
    return [self stringForKey:key error:nil];
}

- (NSString *)stringForKey:(NSString *)key error:(NSError **)error{
    NSData *data = [self dataForKey:key error:error];
    NSString *string = nil;
    if (data) {
        string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    return string;
}

- (NSData *)dataForKey:(NSString *)key error:(NSError**)err {
    if (!key) {
        return nil;
    }
    
    NSDictionary *query = [self queryFetchOneByKey:key];
    CFTypeRef data = nil;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, &data);
    if (status != errSecSuccess) {
        [self dealWithError:err status:status];
        return nil;
    }
    
    NSData *dataFound = [NSData dataWithData:(__bridge NSData *)data];
    if (data) {
        CFRelease(data);
    }
    return dataFound;
}

- (BOOL)hasValueForKey:(NSString *)key {
    return [self hasValueForKey:key error:nil];
}

- (BOOL)hasValueForKey:(NSString *)key error:(NSError **)error{
    if (!key) {
        return NO;
    }
    NSDictionary *query = [self queryFindByKey:key];
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, NULL);
    if (status == errSecSuccess) {
        return YES;
    }else{
        [self dealWithError:error status:status];
        return NO;
    }
}


#pragma mark - 查询字典创建方法
- (NSMutableDictionary *)baseQuery {
    NSMutableDictionary *attributes = [@{
                                         (__bridge id)kSecClass: (__bridge id)kSecClassGenericPassword,
                                         (__bridge id)kSecAttrService: self.service,
                                         } mutableCopy];
    if (self.accessGroup) {
        attributes[(__bridge id)kSecAttrAccessGroup] = self.accessGroup;
    }
    return attributes;
}

- (NSDictionary *)queryFindAll {
    NSMutableDictionary *query = [self baseQuery];
    [query addEntriesFromDictionary:@{
                                      (__bridge id)kSecReturnAttributes: @YES,
                                      (__bridge id)kSecMatchLimit: (__bridge id)kSecMatchLimitAll,
                                      }];
    return query;
}

- (NSDictionary *)queryFindByKey:(NSString *)key{
    //    NSAssert(key != nil, @"key 为空值");
    NSMutableDictionary *query = [self baseQuery];
    query[(__bridge id)kSecAttrAccount] = key;
    return query;
}

- (NSDictionary *)queryUpdateValue:(NSData *)data{
    return @{(__bridge id)kSecValueData : data};
}

- (NSDictionary *)queryNewKey:(NSString *)key value:(NSData *)value {
    NSMutableDictionary *query = [self baseQuery];
    query[(__bridge id)kSecAttrAccount] = key;
    query[(__bridge id)kSecValueData] = value;
    query[(__bridge id)kSecAttrAccessible] = (__bridge id)kSecAttrAccessibleAfterFirstUnlock;
    return query;
}

- (NSDictionary *)queryFetchOneByKey:(NSString *)key{
    NSMutableDictionary *query = [self baseQuery];
    [query addEntriesFromDictionary:@{
                                      (__bridge id)kSecReturnData: @YES,
                                      (__bridge id)kSecMatchLimit: (__bridge id)kSecMatchLimitOne,
                                      (__bridge id)kSecAttrAccount: key,
                                      }];
    return query;
}

#pragma mark - 详解
- (NSString *)description{
    NSString *string;
    string = [NSString stringWithFormat:@"地址 = %p\n service = %@\n accessGroup = %@",&self,self.service,self.accessGroup];
    return string;
}

#pragma mark - 处理状态值

- (void)dealWithError:(NSError **)error status:(OSStatus)status{
    if (error != NULL) {
        *error = [NSError errorWithDomain:@"com.wedoctor.keychainInfo" code:status userInfo:@{NSLocalizedDescriptionKey : [self stringForSecStatus:status]}];
    }
}

- (NSString*)stringForSecStatus:(OSStatus)status {
    switch(status) {
        case errSecSuccess:
            return NSLocalizedStringFromTable(@"noErr", @"WYKeychain", @"Possible error from keychain. ");
        case errSecUnimplemented:
            return NSLocalizedStringFromTable(@"errSecUnimplemented: Function or operation not implemented", @"WYKeychain", @"Possible error from keychain. ");
        case errSecParam:
            return NSLocalizedStringFromTable(@"errSecParam: One or more parameters passed to the function were not valid", @"WYKeychain", @"Possible error from keychain. ");
        case errSecAllocate:
            return NSLocalizedStringFromTable(@"errSecAllocate: Failed to allocate memory", @"WYKeychain", @"Possible error from keychain. ");
        case errSecNotAvailable:
            return NSLocalizedStringFromTable(@"errSecNotAvailable: No trust results are available", @"WYKeychain", @"Possible error from keychain. ");
        case errSecAuthFailed:
            return NSLocalizedStringFromTable(@"errSecAuthFailed: Authorization/Authentication failed", @"WYKeychain", @"Possible error from keychain. ");
        case errSecDuplicateItem:
            return NSLocalizedStringFromTable(@"errSecDuplicateItem: The item already exists", @"WYKeychain", @"Possible error from keychain. ");
        case errSecItemNotFound:
            return NSLocalizedStringFromTable(@"errSecItemNotFound: The item cannot be found", @"WYKeychain", @"Possible error from keychain. ");
        case errSecInteractionNotAllowed:
            return NSLocalizedStringFromTable(@"errSecInteractionNotAllowed: Interaction with the Security Server is not allowed", @"WYKeychain", @"Possible error from keychain. ");
        case errSecDecode:
            return NSLocalizedStringFromTable(@"errSecDecode: Unable to decode the provided data", @"WYKeychain", @"Possible error from keychain. ");
        default:
            return [NSString stringWithFormat:NSLocalizedStringFromTable(@"Unknown error code %d", @"WYKeychain", @"Possible error from keychain. "), status];
    }
}


@end


@implementation NSObject (SysFeedBack)

- (void)wy_touchFeedBack {
    if (WY_IOS_AVAILABLE(10.0)) {
        UIImpactFeedbackGenerator *feedBackGenertor = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleMedium];
        [feedBackGenertor impactOccurred];
    }
}

@end

#import <objc/runtime.h>

@implementation NSObject (Runtime)

#pragma mark - Method Swizzle

+ (BOOL)wy_swizzleInstanceMethod:(SEL)originalSel with:(SEL)newSel{
    Method originalMethod = class_getInstanceMethod(self, originalSel);
    Method newMethod = class_getInstanceMethod(self, newSel);
    if (!originalMethod || !newMethod) return NO;
    
    class_addMethod(self,
                    originalSel,
                    class_getMethodImplementation(self, originalSel),
                    method_getTypeEncoding(originalMethod));
    class_addMethod(self,
                    newSel,
                    class_getMethodImplementation(self, newSel),
                    method_getTypeEncoding(newMethod));
    
    method_exchangeImplementations(class_getInstanceMethod(self, originalSel),
                                   class_getInstanceMethod(self, newSel));
    return YES;
}

+ (BOOL)wy_swizzleClassMethod:(SEL)originalSel with:(SEL)newSel{
    Class class = object_getClass(self);
    return [class wy_swizzleInstanceMethod:originalSel with:newSel];
}

+ (BOOL)wy_swizzleInstanceMethodWithOrignalCls:(Class)orignalCls
                                    orignalSel:(SEL)originalSel
                                      newClass:(Class)newCls
                                        newCls:(SEL)newSel {
    Method originalMethod = class_getInstanceMethod(orignalCls, originalSel);
    Method newMethod = class_getInstanceMethod(newCls, newSel);
    if (!originalMethod || !newMethod) return NO;
    
    class_addMethod(orignalCls,
                    originalSel,
                    class_getMethodImplementation(orignalCls, originalSel),
                    method_getTypeEncoding(originalMethod));
    class_addMethod(newCls,
                    newSel,
                    class_getMethodImplementation(newCls, newSel),
                    method_getTypeEncoding(newMethod));
    
    method_exchangeImplementations(class_getInstanceMethod(orignalCls, originalSel),
                                   class_getInstanceMethod(newCls, newSel));
    return YES;
}

#pragma mark - Associate value

- (void)wy_setAssociateValue:(id)value withKey:(void *)key{
    objc_setAssociatedObject(self, key, value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)wy_setAssociateValue:(id)value withKeyString:(NSString *)key {
    [self wy_setAssociateValue:value withKey:(__bridge void *)(key)];
}

- (void)wy_setAssociateWeakValue:(id)value withKey:(void *)key{
    objc_setAssociatedObject(self, key, value, OBJC_ASSOCIATION_ASSIGN);
}

- (void)wy_setAssociateWeakValue:(id)value withKeyString:(NSString *)key {
    [self wy_setAssociateWeakValue:value withKey:(__bridge void *)key];
}

- (void)wy_removeAssociatedValues{
    objc_removeAssociatedObjects(self);
}

- (id)wy_getAssociatedValueForKey:(void *)key{
    return objc_getAssociatedObject(self, key);
}

- (id)wy_getAssociatedValueForKeyString:(NSString *)key {
    return [self wy_getAssociatedValueForKey:(__bridge void *)key];
}

- (BOOL)wy_isMethodOverride:(Class)cls selector:(SEL)sel {
    IMP clsIMP = class_getMethodImplementation(cls, sel);
    IMP superClsIMP = class_getMethodImplementation([cls superclass], sel);
    return clsIMP != superClsIMP;
}

+ (BOOL)wy_isMethodOverride:(Class)cls selector:(SEL)sel {
    IMP clsIMP = class_getMethodImplementation(cls, sel);
    IMP superClsIMP = class_getMethodImplementation([cls superclass], sel);
    return clsIMP != superClsIMP;
}


@end

@implementation NSObject (Selector)

#pragma mark - Public Method

#define INIT_INV(_last_arg_, _return_) \
NSMethodSignature * sig = [self methodSignatureForSelector:sel]; \
if (!sig) { [self doesNotRecognizeSelector:sel]; return _return_; } \
NSInvocation *inv = [NSInvocation invocationWithMethodSignature:sig]; \
if (!inv) { [self doesNotRecognizeSelector:sel]; return _return_; } \
[inv setTarget:self]; \
[inv setSelector:sel]; \
va_list args; \
va_start(args, _last_arg_); \
[NSObject wykit_setInv:inv withSig:sig andArgs:args]; \
va_end(args);

- (id)wy_performSelectorWithArgsWithSelectorName:(NSString *)actionName, ...{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    SEL sel = NSSelectorFromString(actionName);
#pragma clang diagnostic pop
    INIT_INV(actionName, nil);
    [inv invoke];
    return [NSObject wykit_getReturnFromInv:inv withSig:sig];
}


- (id)wy_performSelectorWithArgs:(SEL)sel, ...{
    INIT_INV(sel, nil);
    [inv invoke];
    return [NSObject wykit_getReturnFromInv:inv withSig:sig];
}

- (void)wy_performSelectorWithArgs:(SEL)sel afterDelay:(NSTimeInterval)delay, ...{
    INIT_INV(delay, );
    [inv retainArguments];
    [inv performSelector:@selector(invoke) withObject:nil afterDelay:delay];
}

- (id)wy_performSelectorWithArgsOnMainThread:(SEL)sel waitUntilDone:(BOOL)wait, ...{
    INIT_INV(wait, nil);
    if (!wait) [inv retainArguments];
    [inv performSelectorOnMainThread:@selector(invoke) withObject:nil waitUntilDone:wait];
    return wait ? [NSObject wykit_getReturnFromInv:inv withSig:sig] : nil;
}

- (id)wy_performSelectorWithArgs:(SEL)sel onThread:(NSThread *)thr waitUntilDone:(BOOL)wait, ...{
    INIT_INV(wait, nil);
    if (!wait) [inv retainArguments];
    [inv performSelector:@selector(invoke) onThread:thr withObject:nil waitUntilDone:wait];
    return wait ? [NSObject wykit_getReturnFromInv:inv withSig:sig] : nil;
}

- (void)wy_performSelectorWithArgsInBackground:(SEL)sel, ...{
    INIT_INV(sel, );
    [inv retainArguments];
    [inv performSelectorInBackground:@selector(invoke) withObject:nil];
}

#undef INIT_INV

+ (id)wykit_getReturnFromInv:(NSInvocation *)inv withSig:(NSMethodSignature *)sig {
    NSUInteger length = [sig methodReturnLength];
    if (length == 0) return nil;
    
    char *type = (char *)[sig methodReturnType];
    while (*type == 'r' || // const
           *type == 'n' || // in
           *type == 'N' || // inout
           *type == 'o' || // out
           *type == 'O' || // bycopy
           *type == 'R' || // byref
           *type == 'V') { // oneway
        type++; // cutoff useless prefix
    }
    
#define return_with_number(_type_) \
do { \
_type_ ret; \
[inv getReturnValue:&ret]; \
return @(ret); \
} while (0)
    
    switch (*type) {
        case 'v': return nil; // void
        case 'B': return_with_number(bool);
        case 'c': return_with_number(char);
        case 'C': return_with_number(unsigned char);
        case 's': return_with_number(short);
        case 'S': return_with_number(unsigned short);
        case 'i': return_with_number(int);
        case 'I': return_with_number(unsigned int);
        case 'l': return_with_number(int);
        case 'L': return_with_number(unsigned int);
        case 'q': return_with_number(long long);
        case 'Q': return_with_number(unsigned long long);
        case 'f': return_with_number(float);
        case 'd': return_with_number(double);
        case 'D': { // long double
            long double ret;
            [inv getReturnValue:&ret];
            return [NSNumber numberWithDouble:ret];
        };
            
        case '@': { // id
            void *ret = nil;//2 4 6 8
            [inv getReturnValue:&ret];
            return (__bridge id)ret;
        };
            
        case '#': { // Class
            Class ret = nil;
            [inv getReturnValue:&ret];
            return ret;
        };
            
        default: { // struct / union / SEL / void* / unknown
            const char *objCType = [sig methodReturnType];
            char *buf = calloc(1, length);
            if (!buf) return nil;
            [inv getReturnValue:buf];
            NSValue *value = [NSValue valueWithBytes:buf objCType:objCType];
            free(buf);
            return value;
        };
    }
#undef return_with_number
}

+ (void)wykit_setInv:(NSInvocation *)inv withSig:(NSMethodSignature *)sig andArgs:(va_list)args {
    NSUInteger count = [sig numberOfArguments];
    for (int index = 2; index < count; index++) {
        char *type = (char *)[sig getArgumentTypeAtIndex:index];
        while (*type == 'r' || // const
               *type == 'n' || // in
               *type == 'N' || // inout
               *type == 'o' || // out
               *type == 'O' || // bycopy
               *type == 'R' || // byref
               *type == 'V') { // oneway
            type++; // cutoff useless prefix
        }
        
        BOOL unsupportedType = NO;
        switch (*type) {
            case 'v': // 1: void
            case 'B': // 1: bool
            case 'c': // 1: char / BOOL
            case 'C': // 1: unsigned char
            case 's': // 2: short
            case 'S': // 2: unsigned short
            case 'i': // 4: int / NSInteger(32bit)
            case 'I': // 4: unsigned int / NSUInteger(32bit)
            case 'l': // 4: long(32bit)
            case 'L': // 4: unsigned long(32bit)
            { // 'char' and 'short' will be promoted to 'int'.
                int arg = va_arg(args, int);
                [inv setArgument:&arg atIndex:index];
            } break;
                
            case 'q': // 8: long long / long(64bit) / NSInteger(64bit)
            case 'Q': // 8: unsigned long long / unsigned long(64bit) / NSUInteger(64bit)
            {
                long long arg = va_arg(args, long long);
                [inv setArgument:&arg atIndex:index];
            } break;
                
            case 'f': // 4: float / CGFloat(32bit)
            { // 'float' will be promoted to 'double'.
                double arg = va_arg(args, double);
                float argf = arg;
                [inv setArgument:&argf atIndex:index];
            } break;
                
            case 'd': // 8: double / CGFloat(64bit)
            {
                double arg = va_arg(args, double);
                [inv setArgument:&arg atIndex:index];
            } break;
                
            case 'D': // 16: long double
            {
                long double arg = va_arg(args, long double);
                [inv setArgument:&arg atIndex:index];
            } break;
                
            case '*': // char *
            case '^': // pointer
            {
                void *arg = va_arg(args, void *);
                [inv setArgument:&arg atIndex:index];
            } break;
                
            case ':': // SEL
            {
                SEL arg = va_arg(args, SEL);
                [inv setArgument:&arg atIndex:index];
            } break;
                
            case '#': // Class
            {
                Class arg = va_arg(args, Class);
                [inv setArgument:&arg atIndex:index];
            } break;
                
            case '@': // id
            {
                id arg = va_arg(args, id);
                [inv setArgument:&arg atIndex:index];
            } break;
                
            case '{': // struct
            {
                if (strcmp(type, @encode(CGPoint)) == 0) {
                    CGPoint arg = va_arg(args, CGPoint);
                    [inv setArgument:&arg atIndex:index];
                } else if (strcmp(type, @encode(CGSize)) == 0) {
                    CGSize arg = va_arg(args, CGSize);
                    [inv setArgument:&arg atIndex:index];
                } else if (strcmp(type, @encode(CGRect)) == 0) {
                    CGRect arg = va_arg(args, CGRect);
                    [inv setArgument:&arg atIndex:index];
                } else if (strcmp(type, @encode(CGVector)) == 0) {
                    CGVector arg = va_arg(args, CGVector);
                    [inv setArgument:&arg atIndex:index];
                } else if (strcmp(type, @encode(CGAffineTransform)) == 0) {
                    CGAffineTransform arg = va_arg(args, CGAffineTransform);
                    [inv setArgument:&arg atIndex:index];
                } else if (strcmp(type, @encode(CATransform3D)) == 0) {
                    CATransform3D arg = va_arg(args, CATransform3D);
                    [inv setArgument:&arg atIndex:index];
                } else if (strcmp(type, @encode(NSRange)) == 0) {
                    NSRange arg = va_arg(args, NSRange);
                    [inv setArgument:&arg atIndex:index];
                } else if (strcmp(type, @encode(UIOffset)) == 0) {
                    UIOffset arg = va_arg(args, UIOffset);
                    [inv setArgument:&arg atIndex:index];
                } else if (strcmp(type, @encode(UIEdgeInsets)) == 0) {
                    UIEdgeInsets arg = va_arg(args, UIEdgeInsets);
                    [inv setArgument:&arg atIndex:index];
                } else {
                    unsupportedType = YES;
                }
            } break;
                
            case '(': // union
            {
                unsupportedType = YES;
            } break;
                
            case '[': // array
            {
                unsupportedType = YES;
            } break;
                
            default: // what?!
            {
                unsupportedType = YES;
            } break;
        }
        
        if (unsupportedType) {
            // Try with some dummy type...
            
            NSUInteger size = 0;
            NSGetSizeAndAlignment(type, &size, NULL);
            
#define case_size(_size_) \
else if (size <= 4 * _size_ ) { \
struct dummy { char tmp[4 * _size_]; }; \
struct dummy arg = va_arg(args, struct dummy); \
[inv setArgument:&arg atIndex:index]; \
}
            if (size == 0) { }
            case_size( 1) case_size( 2) case_size( 3) case_size( 4)
            case_size( 5) case_size( 6) case_size( 7) case_size( 8)
            case_size( 9) case_size(10) case_size(11) case_size(12)
            case_size(13) case_size(14) case_size(15) case_size(16)
            case_size(17) case_size(18) case_size(19) case_size(20)
            case_size(21) case_size(22) case_size(23) case_size(24)
            case_size(25) case_size(26) case_size(27) case_size(28)
            case_size(29) case_size(30) case_size(31) case_size(32)
            case_size(33) case_size(34) case_size(35) case_size(36)
            case_size(37) case_size(38) case_size(39) case_size(40)
            case_size(41) case_size(42) case_size(43) case_size(44)
            case_size(45) case_size(46) case_size(47) case_size(48)
            case_size(49) case_size(50) case_size(51) case_size(52)
            case_size(53) case_size(54) case_size(55) case_size(56)
            case_size(57) case_size(58) case_size(59) case_size(60)
            case_size(61) case_size(62) case_size(63) case_size(64)
            else {
                /*
                 Larger than 256 byte?! I don't want to deal with this stuff up...
                 Ignore this argument.
                 */
                struct dummy {char tmp;};
                for (int i = 0; i < size; i++) va_arg(args, struct dummy);
                NSLog(@"performSelectorWithArgs unsupported type:%s (%lu bytes)",
                      [sig getArgumentTypeAtIndex:index],(unsigned long)size);
            }
#undef case_size
            
        }
    }
}

- (void)wy_performSelector:(SEL)sel afterDelay:(NSTimeInterval)delay {
    [self performSelector:sel withObject:nil afterDelay:delay];
}

@end


@implementation HSADebugTouchTemp

@end
