# 并发容器&工具类

## 同步容器类

同步容器包括Vector和Hashtable，二者是早期JDK的一部分，目前已经基本上不使用了。此外还包括由Collections.synchronizedXxx等工厂方法封装的容器，这些类实现线程安全的方式是： 将它们的状态封装起来，并对每个公有方法都进行同步，使得每次都只有一个线程能访问容器的状态。

## 并发容器类

Java 5 提供了多种并发容器类来改进同步容器的性能。

> 通过并发容器来代替同步容器，可以极大地提高伸缩性并降低风险

并发容器主要包括：

+ ConcurrentHashMap，用于替代同步且基于散列的Map
+ CopyOnWriteArrayList， 用于在遍历操作为主要操作的情况下代替同步的List
+ BlockingQueue(阻塞队列)，ConcurrentLinkedQueue
+ ConcurrentSkipMap 和 ConcurrentSkipListSet，分别作为同步的SortedMap和SortedSet的并发替代品

### ConcurrentHashMap