# 线程

## 基本概念

线程，也称为轻量级进程，是现在操作系统调度的最小单元。每个线程拥有各自的堆栈、程序计数器和局部变量。但是，与分隔的进程相比，线程共享内存、文件句柄和其它每个进程应有的状态。

## Java多线程优势

+ 充分利用多处理器
+ 更快的响应（执行异步或后台处理）
+ 更简单的编程模型

## 线程的生命周期和状态转换

{% plantuml %}
[*] --> NEW:new instance
NEW --> RUNNABLE:Thread.start()

RUNNABLE --> TERMINATED:execute finish,\nException
TERMINATED --> [*]

RUNNABLE --> WAITING:Object.wait(),\nObject.join(),\nLockSupport.park()
WAITING --> RUNNABLE:Object.notify(),\nObject.notifyAll(),\nLockSupport.unpark(Thread)

RUNNABLE --> TIMED_WAITING:Thread.sleep(long),\nObject.wait(long),\nThread.join(long),\nLockSupport.parkNanos(),\nLockSupport.parkUntil()
TIMED_WAITING --> RUNNABLE:Object.notify(),\nObject.notifyAll(),\nLockSupport.unpark(Thread)\ntime elaspted

RUNNABLE --> BLOCKED:wait to enter monitor
BLOCKED --> RUNNABLE:enter monitor

WAITING --> TERMINATED:Exception
TIMED_WAITING --> TERMINATED:Exception

WAITING --> BLOCKED:Object.notify()\nObject.notifyAll()
TIMED_WAITING --> BLOCKED:Object.notify()\nObject.notifyAll()
{% endplantuml %}

*plantuml*
```plantuml
[*] --> NEW:new instance
NEW --> RUNNABLE:Thread.start()

RUNNABLE --> TERMINATED:execute finish,\nException
TERMINATED --> [*]

RUNNABLE --> WAITING:Object.wait(),\nObject.join(),\nLockSupport.park()
WAITING --> RUNNABLE:Object.notify(),\nObject.notifyAll(),\nLockSupport.unpark(Thread)

RUNNABLE --> TIMED_WAITING:Thread.sleep(long),\nObject.wait(long),\nThread.join(long),\nLockSupport.parkNanos(),\nLockSupport.parkUntil()
TIMED_WAITING --> RUNNABLE:Object.notify(),\nObject.notifyAll(),\nLockSupport.unpark(Thread)\ntime elaspted

RUNNABLE --> BLOCKED:wait to enter monitor
BLOCKED --> RUNNABLE:enter monitor

WAITING --> TERMINATED:Exception
TIMED_WAITING --> TERMINATED:Exception

WAITING --> BLOCKED:Object.notify()\nObject.notifyAll()
TIMED_WAITING --> BLOCKED:Object.notify()\nObject.notifyAll()
```

## 线程优先级和守护线程

+ Java 线程中， 通过一个int成员变量priority来控制优先级，优先级的范围从1~10，默认是5。但是，这些优先级如何映射到底层操作系统调度程序取决于实现。在某些实现中，多个甚至全部优先级可能被映射成相同的底层操作系统优先级。

+ 守护线程是一种支持型线程，主要被用于程序中后台调度以及支持性工作。当一个Java虚拟机中不存在非守护线程时，Java虚拟机将会退出。

## 线程类的相关方法

```java
// 当前线程可转让cpu控制权，让别的就绪状态线程运行
public static Thread.yield() 

// 暂停一段时间，不释放锁
public static Thread.sleep()

// 在一个线程中调用other.join()，将等待other执行完成后才继续执行本线程
public join()

//中断，只是设置标志位，由被中断线程自己检查是否被中断
public interrupt()
```

## 常见问题

### Thread类的sleep()方法和对象的wait()方法都可以让线程暂停执行，它们有什么区别?

`sleep()`是Thread的静态方法，调用此方法会让当前线程暂停指定的时间，让出CPU，但是会继续持有对象的锁，休眠结束后自动恢复执行。`wait()`是Object的实例方法，调用对象的`wait()`会使当前线程放弃对象的锁，进入对象等待池，只有其他线程调用了该对象的`notify()`或者`notifyAll()`时，才能唤醒等待池中的线程进入等锁池，若线程重新获取到对象锁就可以继续执行。(参考上面的状态转换图)

## 参考资料&扩展阅读

+ [Java Thread States and Life Cycle](https://www.uml-diagrams.org/java-thread-uml-state-machine-diagram-example.html)
+ [《Java并发编程的艺术》方腾飞,魏鹏,程晓明 著. ](https://www.amazon.cn/dp/B012NDCEA0/ref=sr_1_1?ie=UTF8&qid=1520002234&sr=8-1&keywords=Java%E5%B9%B6%E5%8F%91%E7%BC%96%E7%A8%8B%E7%9A%84%E8%89%BA%E6%9C%AF)

+ [Java 线程简介，Brain Goetz](https://www.ibm.com/developerworks/cn/education/java/j-threads/j-threads.html)
