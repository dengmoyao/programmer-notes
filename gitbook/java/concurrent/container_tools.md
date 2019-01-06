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

#### 为什么要使用 ConcurrentHashMap

1. HashMap 不是线程安全的： HashMap 在并发put操作时会引起死循环，多线程会导致HashMap的Entry链表形成环形数据结构，一旦成环，Entry的next永远不为空，就会产生死循环

2. HashTable效率低下： HashTable 容器使用 synchronized 来保证线程安全，即Hashtable是针对整个table的锁定

#### 原理简述

1. 摒弃1.7版本的分段锁思想，改用 CAS + synchronized，对哈希桶数组的每一个桶加锁，进一步减小锁粒度
2. 防止哈希碰撞导致的拉链过长，采用和HashMap一样的红黑树转化(链表长度大于8)
3. 通过CAS设置sizeCtl与transferIndex变量，协调多个线程对table数组中的node进行迁移，从而实现多线程无锁扩容

### ConcurrentLinkedQueue

常用的并发队列有阻塞队列和非阻塞队列，前者使用锁实现，后者则使用CAS非阻塞算法实现，使用非阻塞队列一般性能比较好，JUC中提供了非阻塞的并发队列 -- ConcurrentLinkedQueue

+ 入队出队函数都是操作volatile变量：head，tail
+ 循环CAS对节点进行赋值
+ 弱一致性，size可能不精确

### 阻塞队列

阻塞队列是一个支持两个附加操作的队列，即支持阻塞的插入和删除方法：

1. 阻塞插入： 当队列满时，队列会阻塞插入元素的线程，直到队列不满
2. 阻塞删除： 当队列为空时，获取元素的线程会等待队列变为非空

实现的原理是线程等待/通知机制，具体是利用ReentrantLock的condition实现的

#### Java 中的阻塞队列

1. ArrayBlockingQueue： 一个由数组结构组成的有界阻塞队列(必须设置容量)
2. LinkedBlockingQueue: 一个由链表结构组成的有界阻塞队列(默认容量为Integer.MAX_VALUE)
3. PriorityBlockingQueue: 支持优先级的无界阻塞队列
4. DelayQueue: 一个支持延时获取元素的无界阻塞队列
5. SynchronousQueue: 一个不存储元素的阻塞队列
6. LinkedTransferQueue： 一个由链表结构组成的无界TransferQueue阻塞队列
7. LinkedBlockingDeque： 一个由链表结构组成的双端阻塞队列

## 并发工具类

JUC中提供了几个非常有用的并发工具类

### CountDownLatch

CountDownLatch 允许一个或者多个线程等待其他线程完成操作

### CyclicBarrier

CyclicBarrier让一组线程到达一个屏障时被阻塞，直到最后一个线程到达屏障，屏障才会开门，所有被拦截的线程才会继续运行

### Semaphore

Semaphore（信号量）是用来控制同时访问特定资源的线程数量，它通过协调各个线程，以保证合理的使用公共资源

### Exchanger

Exchanger 是一个用于线程间协作的工具类。它提供一个同步点，在这个同步点，两个线程可以交换彼此的数据。