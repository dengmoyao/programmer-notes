# 类文件结构

## 类文件整体结构

Class文件由__顺序__的8位字节为基础单位构成的二进制流。各个项目严格按照顺序紧凑排列，无分割符。需要用8位字节以上空间数据项时按照高位在前分割成若干个8位字节存储(Big-Endian)。

只包含两种数据结构:

+ 无符号数
+ 表

__无符号数__

属于基本数据类型。以u1,u2,u4,u8分别代表1个字节，2个，4个，8个字节的无符号数。可以用来描述数字、索引引用、数量值、以UTF-8编码构成的字符串。

__表__

由多个无符号数或其他表作为数据项构成的复合数据类型，用于描述具有层次关系的复合结构数据。所有表习惯性以"-info"结尾。class文件本质就是一张表。


无论是无符号数还是表，当需要描述同一个类型但数量补丁的多个数据时，经常会使用一个前置的容量计数器加若干个连续的数据项的形式。有点类似与协议中的TLV结构。

整个Class文件由魔数，文件版本,常量池，访问标识，类索引、父类索引与接口索引集合，字段表集合，方法表集合，属性表集合等构成。

[*ClassFile Structure*](https://docs.oracle.com/javase/specs/jvms/se8/html/jvms-4.html)

```
ClassFile {
    u4             magic;
    u2             minor_version;
    u2             major_version;
    u2             constant_pool_count;
    cp_info        constant_pool[constant_pool_count-1];
    u2             access_flags;
    u2             this_class;
    u2             super_class;
    u2             interfaces_count;
    u2             interfaces[interfaces_count];
    u2             fields_count;
    field_info     fields[fields_count];
    u2             methods_count;
    method_info    methods[methods_count];
    u2             attributes_count;
    attribute_info attributes[attributes_count];
}
```

### 魔数(magic)--u4

Java的魔数统一为 `0xCAFEBABE`。唯一作用是确定一个文件是否是虚拟机可接受的Class文件。

### 版本号(minor_version & major_version)--u2+u2 

前两字节为次版本号，后两字节为主版本号。高版本的JDK只能向前兼容。

### 常量池

紧接着版本号后就是常量池入口。是第一个出现的表类型的数据项目。由常量池容量计数值`constant_pool_count`及常量池`constant_pool`组成。常量池中的常量的数量是不固定的，由`constant_pool_count`指示常量的数量，常量的数量为`constant_pool_count`的值减一。Class文件结构中，只有常量池的容量计数是从1开始的。

常量池主要存放两大类常量: 字面量(Literal)和符号引用(Symbolic References)

字面量主要是文本字符串，或声明为final的常量值等。

符号引用包括：

+ 类或接口全限定名 Full Qualified Name
+ 字段名称和描述符 Descriptor
+ 方法名称和描述符

常量池中每一项常量都是一个表，JDK7后共有14种表，每个表开始的第一位是u1类型的标志位，表示当前常量是哪种常量类型。

|Constant Type|Value|
|--|--|
|CONSTANT_Class|7|
|CONSTANT_Fieldref|9|
|CONSTANT_Methodref|10|
|CONSTANT_InterfaceMethodref|11|
|CONSTANT_String|8|
|CONSTANT_Integer|3|
|CONSTANT_Float|4|
|CONSTANT_Long|	5|
|CONSTANT_Double|6|
|CONSTANT_NameAndType|12|
|CONSTANT_Utf8|1|
|CONSTANT_MethodHandle|15|
|CONSTANT_MethodType|16|
|CONSTANT_InvokeDynamic|18|

### 访问标识

u2类型,识别类或接口层次的访问信息，如class是接口或类，是否public，是否abstract，是否final等。

### 类索引、父类索引与接口索引集合

类索引`this_class`及父类索引`super_class`均是u2类型，接口索引集合`interfaces`是一组u2类型的集合。确定类的继承关系.按照顺序排列在访问标志之后。`this_class`,`super_class`指向`CONSTANT_CLASS_info`常量。通过该常量可以找到定义在`CONSTANT_Utf8_info`的全限定名字符串。

### 字段表集合

字段表(field_info)用于描述接口或者类中声明的变量。字段(field)包括类变量及实例变量，不包括在 方法中声明的局部变量。信息包含：字段作用域(public, private, protected)、字段类型(类变量还是实例变量 static)、可变性(final)、并发可见性(volatile)、可否序列化(transient)、字段数据类型(基本类型，对象，数组)、字段名称等。

```
field_info {
    u2             access_flags;
    u2             name_index;
    u2             descriptor_index;
    u2             attributes_count;
    attribute_info attributes[attributes_count];
}
```

+ access_flags: 字段修饰符, u2
+ name_index: 字段的简单名称索引，是对常量池的引用，u2
+ descriptor_index: 字段描述符引用，u2
+ 在后面是attributes_count和attributes,分别表示属性计数器和属性信息，用来表示字段的额外属性，如果属性计数器为0，表示无额外属性

### 方法表集合

方法表(methods_info)中对方法的描述与字段表中对字段的描述几乎采用了完全一致的方式，其数据项目的含义也非常类似，仅在访问标志和属性表集合的可选项中有所区别。

访问标志中没有了`ACCVOLATILE`和`ACCTRANSIENT`标志。增加了`ACCSYNCHRONIZED`,`ACCNATIVE`,`ACCSTRICTFP`,`ACCABSTRAT`.

方法里代码经过编译器编译成字节码指令之后，存放在方法属性表集合中Code的属性里面。

java中方法都有一个特征签名，指的就是一个方法中各参数在常量池中字段符号引用的集合。这里并不包含返回值，所以java中重载不能仅仅依靠返回值不同。但对于class文件，只要描述符不同的方法就可以共存在一个class文件中，所以两个方法有相同的名称和特征签名，但返回值不同，在class文件中可以共存。

### 属性表集合

class文件中最后的部分是属性，它给出了在该文件类或者接口所定义的属性的基本信息。

属性表用来表示专用场景的专有信息，比如前面的字段表、方法表都有自己的属性信息。这里不要求严格的顺序，只要不与已有属性名重复，任何人实现的编译器都可以向属性表写入自定义的属性信息。jvm运行时会忽略掉不认别的属性。

## 参考资料

+ [《深入理解Java虚拟机:JVM高级特性与最佳实践(第2版)》，周志明著](https://www.amazon.cn/gp/product/B00D2ID4PK/ref=pd_bxgy_14_img_2?ie=UTF8&psc=1&refRID=K62CDWYDMVM80WXKTYQ4)
