# Java 常见问题

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

### NoClassDefFoundError 和 ClassNotFoundException 区别？

NoClassDefFoundError 表示该类在编译阶段还可以找到，但是在运行Java应用的时候招不到了。 ClassNotFoundException 和编译器没有什么关系，在显示的使用类名称去加载类时，便有可能抛出该受检异常。主要涉及到的方法有： Class.forName， ClassLoader.findSystemClass 和 ClassLoader.loadClass。

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

### 对比Hashtable、HashMap、TreeMap 有什么不同？ 谈谈对HashMap的掌握？

Hashtable、HashMap 和 TreeMap 都是最常见的一些Map的实现，是以键值对的形式存储和操作数据的容器。

Hashtable 是早期Java类库提供的一个哈希表的实现，它是线程安全的，不支持null键和值，由于同步性能较低，目前已经不推荐使用了。

HashMap 是应用更广泛的哈希表实现，它是非线程安全的，支持null键和值。

TreeMap 是基于红黑树实现的一种有序Map，有序是指遍历的时候，返回的序列是按键的自然顺序或者指定Comparator排出来的顺序。TreeMap的get、put和remove方法都是O(log(n))的时间复杂度。

[HashMap的源码分析](https://book.tomoyadeng.com/pmnotes/java/collections/Map.html#hashmap)

*扩展*

hashCode 和 equals 的基本约定：

1. equals 相等， hashCode 一定要相等
2. 重写了hashCode 也要重写 equals
3. hashCode 需要保持一致性，状态改变返回的哈希值仍然要一致
4. equals 的对称、反射、传递性

### 如何保证集合是线程安全的？ ConcurrentHashMap 如何实现高效地线程安全？

对于集合框架，Java 提供了不同层面地线程安全支持，主要有三种：

1. Hashtable，Vector这类老的同步容器，这类同步容器的并发性能比较低，已经不推荐使用了。
2. 同步包装器，就是调用Collections的一些静态工厂方法来得到包装后的同步容器，这类容器也是利用在所有公有方法上加synchronized关键字来达到同步的目的，性能也比较低
3. 还有就是使用更广泛地并发包里面提供的高效地线程安全容器

并发包里面提供的线程安全的容器主要包括：

1. Map， ConcurrentHashMap (HashMap的并发版本)，ConcurrentSkipListMap (SortedMap的并发版本)
2. List， CopyOnWriteArrayList (ArrayList的并发版本)
3. Queue，各种阻塞队列，以及并发队列 ConcurrentLinkedQueue
4. Set， ConcurrentSkipListSet，CopyOnWriteArraySet (CopyOnWriteArrayList的马甲)

ConcurrentHashMap 的实现实际上是随着JDK的版本不断演进的，早期的 ConcurrentHashMap 是基于分段锁来实现的。主要有以下的技术点：

1. 分段锁，也就是将内部进行分段(Segment)，Segment里面则是HashEntry的数组，Segment 是通过继承ReentrantLock来实现独占访问的
2. HashEntry 内部则是使用 volatile 的 value 字段来保证可见性

JDK 8 之后 ConcurrentHashMap 的实现特点：

1. 总体结构上，和 HashMap 一致，都是哈希桶 + 链表实现，链表过长时会转化成红黑树
2. 内部仍有Segment定义，但仅仅是保证序列化的兼容性
3. 数据存储使用 volatile 来保证可见性
4. 使用 CAS + synchronized，对哈希桶数组的每一个桶加锁，进一步减小锁粒度

### Java 提供了哪些IO方式？ NIO 如何实现多路复用？

基于不同的IO抽象模型和交互方式，可以将Java 的IO分成三种：

1. 传统的阻塞式IO，也叫BIO，它是基于流模型实现的，交互方式是同步且阻塞的方式，也就是说在读取输入和写入输出时，在读写动作完成之前，线程会一直阻塞在那里。

2. Java 1.4 之后引入了 NIO 框架，提供了Channel，Buffer，Selector 等新的抽象，通过NIO可以构建出多路复用的，同步非阻塞的IO程序。

3. Java 7 之后，对NIO做了新的改进，引入了异步非阻塞的IO方式，也叫AIO。AIO 是基于事件和回调机制实现的。

### Java 有几种文件拷贝方式？ 哪一种最高效？

总的看来有三种：

1. 利用java.io类库，直接为源文件构建一个FileInputStream进行读取，然后再为目标文件构建一个FileOutputStream完成写入动作

2. 利用java.nio类库中FileChannel提供的transferTo或者transferFrom方法来实现

3. 直接调用Files帮助类提供的copy静态方法，但这个的底层实现原理也是利用的FileInputStream和FileOutputStream

总体来说，NIO的FileChannel提供的transferTo/transferFrom的方式可能更高效，因为它能利用现代操作系统的底层机制，避免不必要的内存拷贝和上下文切换。

### 谈谈接口和抽象类有什么区别？

接口和抽象类都是Java面向对象涉及的基础机制。

接口是对行为的抽象，利用接口可以达到API定义和实现分离的目的。接口时不能够实例化的，在Java 8 之前，接口也是不能包含具体的实例实现的，但是 Java 8 引入的接口默认方法放开了这一限制，这样也可以在接口中提供一部分的默认实现，比如Iterable里的forEach方法

抽象类是不能实例化的类，用 abstract 来修饰，抽象类可以有若干个抽象方法，其主要的目的是代码复用。其实，除了不能实例化，抽象类和普通的类没有太大的区别，抽象类一般用于抽取共有的方法实现或者共同的成员变量，然后通过继承的方式到达代码复用的目的。

*扩展*

面向对象的三大特性：

+ 封装： 目的是隐藏内部的实现细节，以便提高安全性和简化编程
+ 继承： 是代码复用的基础机制
+ 多态： 面向对象程序涉及最核心的特征，多态，意味着一个对象能够有多种形态(这里是指父类引用指向子类对象)

多态存在的三个必要条件：

1. 要有继承
2. 要有重写
3. 父类引用指向子类对象
