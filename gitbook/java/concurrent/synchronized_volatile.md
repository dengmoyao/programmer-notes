# synchronized与volatile

在讨论多线程并发编程时，总会讨论到原子性和内存可见性:

+ 原子性是指一个操作或者多个操作要么全部执行并且执行的过程不会被任何因素打断，要么全部不执行
+ 可见性是指当多个线程访问同一个变量时，一个线程修改了这个变量的值，其他线程能够立即看得到修改的值

__volatile提供了内存可见性，但是不具备原子性，synchronized能同时提供原子性和内存可见性的保证__。


## volatile

### 定义

__如果一个字段被声明成volatile，Java内存模型保证所有的线程看到这个变量是一致的__。

从Java内存模型的抽象结构去解释：每次读取volatile 变量时将从电脑的主内存中读取而不是从CPU缓存中读取，每次对一个 volatile 变量进行写操作时，将会写入到主内存中而不是写入到CPU缓存中。

### 实现原理

volatile的内存可见性是由[Java内存模型(JMM)](JMM.md)保证的，JMM的happen-before原则中的volatile规则保证了对volatile域的写入操作happens-before于每一个后续对同一个域的读写操作。JVM为实现volatile规则会通过插入内存屏障来禁止重排序。

### 使用场景

如果volatile变量使用恰当的话，它比synchronized的使用和执行成本更低，因为它不会引起线程上下文的切换和调度。

《Java并发编程实战》中提到，当且仅当满足以下条件时，才应该使用volatile变量：

+ 对变量的写入操作不一起变量的当前值，或者你能确保只有单个线程更新变量的值
+ 该变量不会与其他状态变量一起纳入不变性条件中
+ 在访问变量时不需要加锁

此外Brian Goetz还给出了几种正确使用volatile的模式： [正确使用 Volatile 变量](https://www.ibm.com/developerworks/cn/java/j-jtp06197.html)

## 参考资料

+ [正确使用 Volatile 变量，Brian Goetz](https://www.ibm.com/developerworks/cn/java/j-jtp06197.html)
