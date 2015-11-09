//
//  XTSafeCollection.m
//  XTSafeCollection
//
//  Created by Ben on 15/8/25.
//  Copyright (c) 2015年 X-Team. All rights reserved.
//

#import "XTSafeCollection.h"
#import <objc/runtime.h>

#if __has_feature(objc_arc)
#error "Should disable arc (-fno-objc-arc)"
#endif

static BOOL logEnabled = NO;

#define XTSCLOG(...) safeCollectionLog(__VA_ARGS__)

void safeCollectionLog(NSString *fmt, ...) NS_FORMAT_FUNCTION(1, 2);

void safeCollectionLog(NSString *fmt, ...)
{
    if (!logEnabled)
    {
        return;
    }
    va_list ap;
    va_start(ap, fmt);
    NSString *content = [[NSString alloc] initWithFormat:fmt arguments:ap];
    NSLog(@"%@", content);
    va_end(ap);
    
    NSLog(@" ============= call stack ========== \n%@", [NSThread callStackSymbols]);
}

#pragma mark - NSArray

@interface NSArray (XTSafe)

@end

@implementation NSArray (XTSafe)

+ (Method)methodOfSelector:(SEL)selector
{
    return class_getInstanceMethod(NSClassFromString(@"__NSArrayI"),selector);
}

- (id)tn_objectAtIndexI:(NSUInteger)index
{
    if (index >= self.count)
    {
        XTSCLOG(@"[%@ %@] index {%lu} beyond bounds [0...%lu]",
                NSStringFromClass([self class]),
                NSStringFromSelector(_cmd),
                (unsigned long)index,
                MAX((unsigned long)self.count - 1, 0));
        return nil;
    }
    
    return [self tn_objectAtIndexI:index];
}

+ (id)tn_arrayWithObjects:(const id [])objects count:(NSUInteger)cnt
{
    id validObjects[cnt];
    NSUInteger count = 0;
    for (NSUInteger i = 0; i < cnt; i++)
    {
        if (objects[i])
        {
            validObjects[count] = objects[i];
            count++;
        }
        else
        {
            XTSCLOG(@"[%@ %@] NIL object at index {%lu}",
                    NSStringFromClass([self class]),
                    NSStringFromSelector(_cmd),
                    (unsigned long)i);
            
        }
    }
    
    return [self tn_arrayWithObjects:validObjects count:count];
}

@end

#pragma mark - NSMutableArray

@interface NSMutableArray (XTSafe)

@end

@implementation NSMutableArray (XTSafe)

+ (Method)methodOfSelector:(SEL)selector
{
    return class_getInstanceMethod(NSClassFromString(@"__NSArrayM"),selector);
}

- (id)tn_objectAtIndexM:(NSUInteger)index
{
    if (index >= self.count)
    {
        XTSCLOG(@"[%@ %@] index {%lu} beyond bounds [0...%lu]",
                NSStringFromClass([self class]),
                NSStringFromSelector(_cmd),
                (unsigned long)index,
                MAX((unsigned long)self.count - 1, 0));
        return nil;
    }
    
    return [self tn_objectAtIndexM:index];
}

- (void)tn_addObject:(id)anObject
{
    if (!anObject)
    {
        XTSCLOG(@"[%@ %@], NIL object.", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
        return;
    }
    [self tn_addObject:anObject];
}

- (void)tn_replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject
{
    if (index >= self.count)
    {
        XTSCLOG(@"[%@ %@] index {%lu} beyond bounds [0...%lu].",
                NSStringFromClass([self class]),
                NSStringFromSelector(_cmd),
                (unsigned long)index,
                MAX((unsigned long)self.count - 1, 0));
        return;
    }
    
    if (!anObject)
    {
        XTSCLOG(@"[%@ %@] NIL object.", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
        return;
    }
    
    [self tn_replaceObjectAtIndex:index withObject:anObject];
}

- (void)tn_insertObject:(id)anObject atIndex:(NSUInteger)index
{
    if (index > self.count)
    {
        XTSCLOG(@"[%@ %@] index {%lu} beyond bounds [0...%lu].",
                NSStringFromClass([self class]),
                NSStringFromSelector(_cmd),
                (unsigned long)index,
                MAX((unsigned long)self.count - 1, 0));
        return;
    }
    
    if (!anObject)
    {
        XTSCLOG(@"[%@ %@] NIL object.", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
        return;
    }
    
    [self tn_insertObject:anObject atIndex:index];
}

@end

#pragma mark - NSDictionary

@interface NSDictionary (XTSafe)

@end

@implementation NSDictionary (XTSafe)

+ (instancetype)tn_dictionaryWithObjects:(const id [])objects forKeys:(const id<NSCopying> [])keys count:(NSUInteger)cnt
{
    id validObjects[cnt];
    id<NSCopying> validKeys[cnt];
    NSUInteger count = 0;
    for (NSUInteger i = 0; i < cnt; i++)
    {
        if (objects[i] && keys[i])
        {
            validObjects[count] = objects[i];
            validKeys[count] = keys[i];
            count ++;
        }
        else
        {
            XTSCLOG(@"[%@ %@] NIL object or key at index{%lu}.",
                    NSStringFromClass(self),
                    NSStringFromSelector(_cmd),
                    (unsigned long)i);
        }
    }
    
    return [self tn_dictionaryWithObjects:validObjects forKeys:validKeys count:count];
}

@end

#pragma mark - NSMutableDictionary

@interface NSMutableDictionary (XTSafe)

@end

@implementation NSMutableDictionary (XTSafe)

+ (Method)methodOfSelector:(SEL)selector
{
    return class_getInstanceMethod(NSClassFromString(@"__NSDictionaryM"),selector);
}

- (void)tn_setObject:(id)anObject forKey:(id<NSCopying>)aKey
{
    if (!aKey)
    {
        XTSCLOG(@"[%@ %@] NIL key.", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
        return;
    }
    if (!anObject)
    {
        XTSCLOG(@"[%@ %@] NIL object.", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
        return;
    }
    
    [self tn_setObject:anObject forKey:aKey];
}

@end

#pragma mark - Mama

@implementation XTSafeCollection

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // NSArray
        [self exchangeOriginalMethod:[NSArray methodOfSelector:@selector(objectAtIndex:)] withNewMethod:[NSArray methodOfSelector:@selector(tn_objectAtIndexI:)]];
        [self exchangeOriginalMethod:class_getClassMethod([NSArray class], @selector(arrayWithObjects:count:))
                       withNewMethod:class_getClassMethod([NSArray class], @selector(tn_arrayWithObjects:count:))];
        // NSMutableArray
        [self exchangeOriginalMethod:[NSMutableArray methodOfSelector:@selector(objectAtIndex:)] withNewMethod:[NSMutableArray methodOfSelector:@selector(tn_objectAtIndexM:)]];
        [self exchangeOriginalMethod:[NSMutableArray methodOfSelector:@selector(replaceObjectAtIndex:withObject:)] withNewMethod:[NSMutableArray methodOfSelector:@selector(tn_replaceObjectAtIndex:withObject:)]];
        [self exchangeOriginalMethod:[NSMutableArray methodOfSelector:@selector(addObject:)] withNewMethod:[NSMutableArray methodOfSelector:@selector(tn_addObject:)]];
        [self exchangeOriginalMethod:[NSMutableArray methodOfSelector:@selector(insertObject:atIndex:)] withNewMethod:[NSMutableArray methodOfSelector:@selector(tn_insertObject:atIndex:)]];
        // NSDictionary
        [self exchangeOriginalMethod:class_getClassMethod([NSDictionary class], @selector(dictionaryWithObjects:forKeys:count:))
                       withNewMethod:class_getClassMethod([NSDictionary class], @selector(tn_dictionaryWithObjects:forKeys:count:))];
        // NSMutableDictionary
        [self exchangeOriginalMethod:[NSMutableDictionary methodOfSelector:@selector(setObject:forKey:)] withNewMethod:[NSMutableDictionary methodOfSelector:@selector(tn_setObject:forKey:)]];
    });
}

+ (void)exchangeOriginalMethod:(Method)originalMethod withNewMethod:(Method)newMethod
{
    method_exchangeImplementations(originalMethod, newMethod);
}

+ (void)setLogEnabled:(BOOL)enabled
{
    logEnabled = enabled;
}

@end
