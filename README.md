##XTSafeCollection

###背景
`NSArray``NSMutableArray``NSDictionary``NSMutableDictionary`是我们的在`iOS`开发中非常常用的类。当然，在享受这些类的便利的同时，它们也给我们带来一些困扰。粗心我们可能会调用`addObject`传入一个`nil`, 也有可能是会`objectAtIndex`传入一个越界的index。尤其是在数据基本依赖于服务端返回的的情况，这种crash大幅增加。最近项目上经常出现`NSDictionary`的`setObject:forKey:`的`nil object`的崩溃。我们希望能够用一个统一的方法解决粗心的程序员可能传入的`nil object`。我们最先想到的想法是对这些函数进行一个包装，比如`objectAtIndex`，我们写一个如下的函数

```Objective-C
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
不过，这显然不是我想要的，我不希望改变现有的调用方式，大家可能是通过`[]`或`objectAtIndex`（不推荐）的方式获取数组元素，如果要做替换的话改动势必非常大，而且不便于以后的移植。于是，就有了`XTSafeCollection`。
###使用
直接把`XTSafeCollection.h``XTSafeCollection.m`拖入工程，`NSArray``NSMutableArray``NSDictionary``NSMutableDictionary`这些类的API以前是怎么调用的，还怎么写，完全不用修改。Demo里，我全部以传统的会引起crash的方式调用代码，以下是我的Demo的代码和输出

```
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

###安装
`pod ~> XTSafeCollection`
###TODO
兼容更多的crash情况