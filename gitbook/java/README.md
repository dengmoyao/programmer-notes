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

## JVM 相关的常见问题

### 类加载

#### NoClassDefFoundError 和 ClassNotFoundException 区别？

NoClassDefFoundError 表示该类在编译阶段还可以找到，但是在运行Java应用的时候招不到了。 ClassNotFoundException 和编译器没有什么关系，在显示的使用类名称去加载类时，便有可能抛出该受检异常。主要涉及到的方法有： Class.forName， ClassLoader.findSystemClass 和 ClassLoader.loadClass。