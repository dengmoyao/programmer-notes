# Java

## 书单

### 基础

+ [《Java核心技术(卷1):基础知识(原书第10版)》 - 凯 S.霍斯特曼 ](https://www.amazon.cn/dp/B01M06CLQM/ref=pd_bxgy_14_img_2?_encoding=UTF8&psc=1&refRID=KT0NFY9CTMKKNMCN7GNZ)
+ [《Java编程思想(第4版)》 - 埃史尔](https://www.amazon.cn/dp/B0011F7WU4/ref=pd_bxgy_14_img_3?_encoding=UTF8&psc=1&refRID=CNDMVA68EGX7RBFB3Y46)
+ [《Effective Java中文版(第2版)》 - Joshua Bloch](https://www.amazon.cn/dp/B001PTGR52/ref=pd_bxgy_14_img_3?_encoding=UTF8&psc=1&refRID=GTF5J33PK7XMBJN5TMH3)

### 并发

+ [《Java并发编程的艺术》-方腾飞](https://www.amazon.cn/dp/B012QIKPGM/ref=pd_sim_351_2?_encoding=UTF8&psc=1&refRID=BN9AWYWJ8ANKZ80K49SZ)
+ [《Java并发编程实战》 - 盖茨 (Brian Goetz)](https://www.amazon.cn/dp/B0077K9XHW/ref=pd_bxgy_14_img_2?_encoding=UTF8&psc=1&refRID=VFXA1N7FN4D37DAZ7CPD)

### JVM

+ [《深入理解Java虚拟机:JVM高级特性与最佳实践(第2版)》 - 周志明](https://www.amazon.cn/dp/B00D2ID4PK/ref=pd_bxgy_14_2?_encoding=UTF8&psc=1&refRID=MT6DXSTQF8N3V7KQAY59)

### 其他

+ [《写给大忙人看的Java SE 8》 - 霍斯曼 (Horstmann C.S.)](https://www.amazon.cn/dp/B00PYLOFWY/ref=pd_bxgy_14_2?_encoding=UTF8&psc=1&refRID=1PQZATG7DZHFW311Q5WF)

## Java 常见问题

### 谈谈对Java平台的理解？

在我看来，Java平台主要就是Java语言和Java虚拟机。

Java本身是一种面向对象的静态强类型编程语言，拥有包括反射，泛型，Lambda在内的多种高级特性，并且提供了很多易用、高性能的类库，包括IO/NIO，网络，集合框架，并发包等。

Java虚拟机就是实现Java语言平台无关性的手段，Java源码通过编译器编译生成统一的字节码放到不同的Java虚拟器上去执行的。

(Java生态：目前Java/JVM广泛应用在：1. Web服务器后端开发，典型的框架技术有Spring全家桶；2. 大数据开发，典型框架和技术有Hadoop，Flink，Spark姑且也算(用Scala开发的))

### Exception 和 Error 有什么区别？ RuntimeException 与一般异常区别？

Exception 和 Error 都继承了 Thowable 类，在Java中， Throwable 可以被抛出或者捕获。Exception 是程序正常运行中，可以预料的意外情况，可能并且应该被捕获，然后进行相应的处理。而 Error 指正常情况下，不大可能的出现的情况，绝大部分的Error都会导致程序处于非正常的，不可恢复的状态，比如OOM。

Exception 又分为受检异常(Checked Exception)和运行时异常(RuntimeException)，受检异常在源码中必须显示地进行捕获处理，这是编译期检查的一部分。运行时异常通常是可以编码避免的逻辑错误，具体应根据需要来判断是否需要捕获，不会再编译期强制要求。

*扩展部分*

异常处理原则：

1. 尽量不要捕获类似 Exception 这样的通用异常，而是应该捕获特定异常
2. 不要生吞异常
3. Throw early, catch late

受检异常缺点：

1. Checked Exception 的假设是，捕获了异常，然后恢复程序。但是，其实在大多数情况下，根本不可能恢复，这实际上已经偏离了最初的设计目的
2. Checked Exception 不兼容函数式编程

异常的性能开销：

1. try-catch 代码段会产生额外的性能开销，主要是因为它往往会影响JVM对代码进行优化。
2. Java 每实例化一个 Exception，都会对当时的栈进行快照

### 谈谈 final、finally、finalize 有什么不同？

final 可以用来修饰类、方法和变量，分别有不同的意义。final修饰的类代表不可以被继承；final修饰的方法代表不可以被 override；final修饰的变量代表不可以被修改。

finally则是Java保证重点代码一定要被执行的一种机制。一般在finally里释放资源或者锁。

finalize是Object类的一个实例方法，其设计目的是保证对象在被垃圾回收前完成特定资源的回收。这个方法在JDK 9 已经被标记为 deprecated 了（无法保证什么时候被执行，以及执行是否会符合预期）

### 强引用、软引用、弱引用和虚引用有什么区别？具体使用场景是什么？

不同的引用类型主要体现的是对象不同的可达性(reachable)状态和对垃圾收集的影响

强引用，是最常见的对象引用，只要还有强引用指向一个对象，就能表明对象还“活着”，垃圾收集器宁愿抛出OOM也不会回收这种对象。

软引用，是一种相对强引用弱化一些的引用，可以让对象豁免一些垃圾收集，只有当JVM认为内存不足的时候，才会去试图回收软引用指向的对象。

弱引用，也是用来指向非必需对象的，强度比软引用更弱，被弱引用关联的对象只能生存到下一次垃圾收集之前。当垃圾收集器工作时，无论当前内存是否足够，都会回收掉只有被弱引用关联的对象。

虚引用（幻象引用），是最弱的引用关系，不能通过它访问对象。虚引用主要用来跟踪对象被垃圾回收器回收的活动，必须结合引用队列使用。

### String、StringBuffer 和 StringBuilder 有什么区别？

String 是 Java 中非常重要的类，提供了构造和管理字符串的各种逻辑，使用非常普遍。String 是一个不可变类，类似拼接、裁剪字符串等方法都会产生新的字符串。

StringBuilder 是为解决因字符串拼接而产生太多中间对象的问题而提供的一个类。可以通过其append或者add方法，将字符串添加到已有序列的末尾或指定位置。

StringBuffer 是 StringBuilder 的线程安全版本。

*扩展*

1. 不要在循环体中拼接字符串，因为这样会产生很多中间StringBuilder对象

2. JDK 9 之后，String 的内部实现从char数组变成了byte数组 + Coder

### 谈谈反射机制？ 动态代理是基于什么原理？

反射机制是Java语言提供的一种基础功能，赋予程序在运行时自省的能力。通过反射，可以在运行时直接操作类或对象，即使是对象的类型在编译期未知。比如在运行时获取某个对象的类定义，获得类声明的属性和方法，调用方法或构造对象，甚至可以运行时修改类定义。

动态代理是一种方便运行时动态构建代理对象，动态处理代理方法调用的机制。很多场景都是利用动态代理来实现的，比如包装RPC调用，面向切面编程。

动态代理的方式现在主要有两种：一种是JDK自身提供的动态代理，它是对接口进行动态代理；另一种是cglib，主要是通过字节码操作技术来进行动态代理，它是基于扩展子类来实现的，所以能对类进行代理。

*扩展*

通过代理可以让调用者和实现者之间解耦。比如RPC调用，框架内部的寻址，序列化，反序列化等，对于调用者往往是没有太大意义的。通过代理，可以提供更加友善的界面。

### int 和 Integer 有什么区别？ Integer 的值缓存范围是多少？

int 是 Java 中的基本数据类型之一(不是对象)。Integer 是 int 的包装类型，它有一个 int 类型的字段存储数据，并提供了基本操作，比如数学运算，以及int和字符串之间的转换。 JDK 5 之后，Java 引入了自动装箱和自动拆箱的机制， Java 可以根据上下文，自动进行转换。 Integer 的缓存值范围是-128到127之间。

*扩展*

自动装箱和拆箱实际上是Java提供的一种语法糖，发生在编译阶段。自动装箱为Integer.valueOf()，自动拆箱为 Integer.intValue()

### 对比 Vector，ArrayList 和 LinkedList 有什么区别？

首先，这三个都实现了集合框架中的 List 接口，是有序列表。

Vector 是 Java 早期提供的线程安全的List实现，它是基于动态数组实现的。其同步方式是简单的在所有公有方法上加上synchronized关键字，同步效率比较低，目前已经不推荐使用了。

ArrayList 是基于动态数组实现的List，非线程安全，是平时使用的最多的一种容器类型。ArrayList 具有很好的随机访问性，能够自动扩容，除了在尾部插入和删除元素，在其他地方操作往往性能较差，因为涉及到数据移动。

LinkedList 是基于双向链表的List，也是非线程安全的，特点是插入和删除节点高效，随机访问性较差。

## JVM 相关的常见问题

### 类加载

#### NoClassDefFoundError 和 ClassNotFoundException 区别？

NoClassDefFoundError 表示该类在编译阶段还可以找到，但是在运行Java应用的时候招不到了。 ClassNotFoundException 和编译器没有什么关系，在显示的使用类名称去加载类时，便有可能抛出该受检异常。主要涉及到的方法有： Class.forName， ClassLoader.findSystemClass 和 ClassLoader.loadClass。