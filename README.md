##XTSafeCollection

[![CI Status](https://travis-ci.org/wuwen1030/XTSafeCollection.svg?branch=master)](https://travis-ci.org/wuwen1030/XTSafeCollection)
[![Version](https://img.shields.io/cocoapods/v/XTSafeCollection.svg?style=flat)](http://cocoapods.org/pods/XTSafeCollection)
[![License](https://img.shields.io/cocoapods/l/XTSafeCollection.svg?style=flat)](http://cocoapods.org/pods/XTSafeCollection)
[![Platform](https://img.shields.io/cocoapods/p/XTSafeCollection.svg?style=flat)](http://cocoapods.org/pods/XTSafeCollection)

###背景
`NSArray``NSMutableArray``NSDictionary``NSMutableDictionary`是我们的在`iOS`开发中非常常用的类。当然，在享受这些类的便利的同时，它们也给我们带来一些困扰。粗心我们可能会调用`addObject`传入一个`nil`, 也有可能是会`objectAtIndex`传入一个越界的index。尤其是在数据基本依赖于服务端返回的的情况，这种crash大幅增加。最近项目上经常出现`NSDictionary`的`setObject:forKey:`的`nil object`的崩溃。
###解决方案
####函数包装
我们希望能够用一个统一的方法解决粗心的程序员可能传入的`nil object`。我们最先想到的想法是对这些函数进行一个包装，比如`objectAtIndex`，我们写一个如下的函数

```objc
- (id)safeObjectAtIndex:(NSUInteger)index
{	
	if (index >= self.count)
	{
		return nil;
	}
	return [self objectAtIndex:index];
}
```
以后所有调用`objectAtIndex`的地方统统替换为`safeObjectAtIndex`。
不过，这显然不是我想要的，我不希望改变现有的调用方式，大家可能是通过`[]`或`objectAtIndex`（不推荐）的方式获取数组元素，如果要做替换的话改动势必非常大，而且不便于以后的移植。我们希望代码调用`objectAtIndex`的时候，能够被我们先捕获到，进行处理之后再调用Cocoa的这个方法。`Objective-C`作为一门动态语言，有强大的动态加载的能力，提供了[`Method swizzling`](http://nshipster.com/method-swizzling/)实现这样的功能。现在，黑魔法起飞。
####Method swizzling
关于`Method swizzling`的具体实现，不打算多说，这里谈一下我遇到的问题。最初在做`Method swizzling`的时候，我尝试去替换`NSArrat`的`objectAtIndex:`，但我始终没有办法替换掉这个方法。后来，搞了半天才发现，我们使用的`NSAarray`或者`NSMutableArray`并不是我们所看到样子，它们是[`class cluster`](https://developer.apple.com/library/ios/documentation/General/Conceptual/CocoaEncyclopedia/ClassClusters/ClassClusters.html)。`objectAtIndex:`并不是他们的方法，而是他们背后的`concrete class`: `__NSArrayI` `__NSArrayM`的方法。解决了这个问题，剩下的就很简单了。
###使用
直接把`XTSafeCollection.h``XTSafeCollection.m`拖入工程，`NSArray``NSMutableArray``NSDictionary``NSMutableDictionary`这些类的API以前是怎么调用的，还怎么写，完全不用修改。Demo里，我全部以传统的会引起crash的方式调用代码，以下是我的Demo的代码和输出

```objc
NSArray *array = @[@"a", @"b"];
NSMutableArray *mutableArray = [@[@"aa", @"bb"] mutableCopy];
    
// Object at index
NSLog(@"%@", array[10]);
NSLog(@"%@", mutableArray[100]);
    
// add object
[mutableArray addObject:nil];
    
// Insert object
[mutableArray insertObject:nil atIndex:0];
[mutableArray insertObject:@"cc" atIndex:10];
    
// Replace object
[mutableArray replaceObjectAtIndex:0 withObject:nil];
[mutableArray replaceObjectAtIndex:10 withObject:@"cc"];
    
// Dictionary
NSMutableDictionary *mutableDictionary = [NSMutableDictionary dictionary];
mutableDictionary[nil] = @"1";
mutableDictionary[@"1"] = nil;
```

```
2015-08-25 18:10:23.932 XTSafeCollection[29067:443479] [__NSArrayI objectAtIndex:] index {10} beyond bounds [0...1]
2015-08-25 18:10:23.933 XTSafeCollection[29067:443479] (null)
2015-08-25 18:10:23.933 XTSafeCollection[29067:443479] [__NSArrayM objectAtIndex:] index {100} beyond bounds [0...1]
2015-08-25 18:10:23.933 XTSafeCollection[29067:443479] (null)
2015-08-25 18:10:23.934 XTSafeCollection[29067:443479] [__NSArrayM addObject:], NIL object.
2015-08-25 18:10:23.934 XTSafeCollection[29067:443479] [__NSArrayM insertObject:atIndex:] NIL object.
2015-08-25 18:10:23.934 XTSafeCollection[29067:443479] [__NSArrayM insertObject:atIndex:] index {10} beyond bounds [0...1].
2015-08-25 18:10:23.934 XTSafeCollection[29067:443479] [__NSArrayM replaceObjectAtIndex:withObject:] NIL object.
2015-08-25 18:10:23.934 XTSafeCollection[29067:443479] [__NSArrayM replaceObjectAtIndex:withObject:] index {10} beyond bounds [0...1].
2015-08-25 18:10:23.934 XTSafeCollection[29067:443479] [__NSDictionaryM setObject:forKey:] NIL key.
2015-08-25 18:10:23.934 XTSafeCollection[29067:443479] [__NSDictionaryM setObject:forKey:] NIL object.
```
###版本：

* 1.0.0

```objc
NSArray:
- (id)objectAtIndex:(NSUInteger)index;

NSMutableArray:
- (id)objectAtIndex:(NSUInteger)index;
- (void)insertObject:(id)anObject atIndex:(NSUInteger)index;
- (void)addObject:(id)object;
- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject;

NSMutableDictionary:
- (void)setObject:(id)anObject forKey:(id <NSCopying>)aKey;
```

* 1.0.2

```objc
NSArray:
+ (instancetype)arrayWithObjects:(const id [])objects count:(NSUInteger)cnt; ( @[] )

NSDictionary:
+ (instancetype)dictionaryWithObjects:(const id [])objects forKeys:(const id <NSCopying> [])keys count:(NSUInteger)cnt; ( @{} )

```

###安装
`pod "XTSafeCollection"`

###TODO
兼容更多的crash情况

###Known Issues
替换`NSMuatbelArray`的`objectAtIndex:`引起键盘展示状态态切换后台的崩溃，抛出
```objc
*** -[UIKeyboardLayoutStar release]: message sent to deallocated instance 0x7f883beac9c0
```
在这里
[http://huang.sh/2015/02/%E4%B8%80%E4%B8%AA%E5%A5%87%E6%80%AA%E7%9A%84crash-uikeyboardlayoutstar-release/](http://huang.sh/2015/02/%E4%B8%80%E4%B8%AA%E5%A5%87%E6%80%AA%E7%9A%84crash-uikeyboardlayoutstar-release/)找到了解决方法
![issue image](http://i3.tietuku.com/77deed8f74fa1ec2.jpg)
