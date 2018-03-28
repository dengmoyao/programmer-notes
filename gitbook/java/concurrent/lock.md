# 显示锁

Java 5 之前，在协调对共享对象的访问时可以使用的机制只有synchronized和volatile。Java 5 提供了显示锁机制，它提供了与synchronized关键字类似的同步功能，只是在使用时需要显示地获取和释放锁。虽然synchronized提供了便捷性的隐式获取锁释放锁机制（基于JVM机制），但是它却缺少了获取锁与释放锁的可操作性，可中断、超时获取锁。

## Lock接口

Lock的使用方法如下：

```java
Lock lock = new ReentrantLock();
lock.lock();

try {
    // do something
} finally {
    lock.unlock();
}
```

Lock接口提供的synchronized关键字不具备的主要特性

|特性|描述|
|---|---|
|尝试非阻塞地获取锁|当前线程尝试获取锁，如果这一时刻锁没有被其他线程获取到，则成功获取并持有锁|
|能被中断地获取锁|与synchronized不同，获取到锁地线程能够响应中断，当获取到锁的线程被中断时，中断异常将会被抛出，同时锁会被释放|
|超时获取锁|在指定的截止时间之前获取锁，如果截止时间到了仍旧无法获取锁，则返回|

### API

|方法|描述|
|---|---|
|void lock()|获取锁，调用该方法当前线程会获取锁，当锁获得后，从该方法返回|
|void lockInterruptibly() throws InterruptedException|可中断地获取锁，和lock()方法的不同之处在于该方法会响应中断，即在锁的获取中可以中断当前线程|
|boolean tryLock()|尝试非阻塞的获取锁，调用该方法后立即返回，如果能够获取到则返回true，否则返回false|
|boolean tryLock(long time, TimeUnit unit) throws InterruptedException|超时获取锁，当前线程在一下3种情况会返回：</br>1.当前线程在超时时间内获得了锁</br>2.当前线程在超时时间内被中断</br>3.超时时间结束，返回false|
|void unlock()|释放锁|
|Condition newCondition()|获取等待通知组件，该组件和当前的锁绑定，当前线程只有获得了锁，才能调用该组件的wait()方法，而调用后，当前线程将释放锁|

## 队列同步器(AQS)

队列同步器(AbstractQueuedSynchronizer, AQS)，是用来构建锁和其他同步组件的基础框架（如ReentrantLock、ReentrantReadWriteLock、Semaphore等），它使用了一个int成员变量表示同步状态，通过内置的FIFO队列来完成资源获取线程的排队工作。

AQS的主要使用方式是继承，子类通过继承AQS并实现它的抽象方法来管理同步状态。

### API

同步器使用一个int类型的成员变量来表示同步状态，当state>0时表示已经获得了锁，当state=0时表示释放了锁，重写同步器指定的方法时，__需要使用同步器提供如下三个(protected final)方法来访问或修改同步状态__：

|方法|描述|
|---|---|
|int getState()|获取当前同步状态|
|void setState(int newState)|设置当前同步状态|
|boolean compareAndSetState(int expect, int update)|使用CAS设置当前状态，该方法能够保证状态设置的原子性|

__同步器可以重写的方法(protected)：__

|方法|描述|
|---|---|
|boolean tryAcquire(int arg)|独占式获取同步状态，实现该方法需要查询当前状态并判断同步状态是否符合预期，然后再进行CAS设置同步状态|
|boolean tryRelease(int arg)|独占式释放同步状态，等待获取同步状态的线程将有机会获取同步状态|
|int tryAcquireShared(int arg)|共享式获取同步状态，返回大于等于0的值，表示获取获取成功，反之，获取失败|
|boolean tryReleaseShared(int arg)|共享式释放同步状态|
|boolean isHeldExclusively()|当前同步器是否在独占式模式下被线程占用，一般该方法表示是否被当前线程所独占|

__实现自定义同步组件时，将会调用同步器提供的模板方法(public final)：__

|方法|描述|
|---|---|
|void acquire(int arg)|独占式获取同步状态，如果当前线程获取同步状态成功，则由该方法返回，否则，将会进入同步队列等待，该方法将会调用可重写的tryAcquire(int arg)方法|
|void acquireInterruptibly(int arg) throws InterruptedException|与acquire(int arg)相同，但是该方法响应中断，当前线程为获取到同步状态而进入到同步队列中，如果当前线程被中断，则该方法会抛出InterruptedException异常并返回|
|boolean tryAcquireNanos(int arg, long nanosTimeout) throws InterruptedException|超时获取同步状态，如果当前线程在nanos时间内没有获取到同步状态，那么将会返回false，已经获取则返回true；|
|void acquireShared(int arg)|共享式获取同步状态，如果当前线程未获取到同步状态，将会进入同步队列等待，与独占式的主要区别是在同一时刻可以有多个线程获取到同步状态；|
|void acquireSharedInterruptibly(int arg) throws InterruptedException|共享式获取同步状态，响应中断|
|boolean tryAcquireSharedNanos(int arg, long nanosTimeout) throws InterruptedException|共享式获取同步状态，增加超时限制|
|boolean release(int arg)|独占式释放同步状态，该方法会在释放同步状态之后，将同步队列中第一个节点包含的线程唤醒；|
|boolean releaseShared(int arg)|共享式释放同步状态|
|Collection<Thread> getQueuedThreads()|获取等待在同步队列上的线程集合|

模板方法大概分为三类：

+ 独占式获取与释放同步状态
+ 共享式获取与释放同步状态
+ 查询同步队列中的等待线程情况

### CLH同步队列

同步器中维护着一个FIFO双向队列，来完成同步状态的管理。当前线程如果获取同步状态失败时，AQS则会将当前线程已经等待状态等信息构造成一个节点（Node）并将其加入到CLH同步队列队尾，同时会阻塞当前线程，当同步状态释放时，会把首节点唤醒，使其再次尝试获取同步状态。

同步队列中的结点(Node)用于保存获取同步状态失败的线程引用、等待状态以及前驱和后继结点：

```java


static final class Node {
    static final Node SHARED = new Node(); // 共享
    static final Node EXCLUSIVE = null; // 独占

    /** 该节点的线程可能由于超时或被中断而处于被取消(作废)状态,
    一旦处于这个状态,节点状态将一直处于CANCELLED(作废),因此应该从队列中移除 */
    static final int CANCELLED =  1;
    /** 当前节点为SIGNAL时,后继节点会被挂起,
    因此在当前节点释放锁或被取消之后必须被唤醒(unparking)其后继结点 */
    static final int SIGNAL    = -1;
    /** 该节点的线程处于等待条件状态,不会被当作是同步队列上的节点,
    直到被唤醒(signal),设置其值为0,重新进入阻塞状态 */
    static final int CONDITION = -2;
    /** 表示下一次共享式同步状态获取将会无条件地传播下去 */
    static final int PROPAGATE = -3;

    volatile int waitStatus; //等待状态
    volatile Node prev; //前驱结点
    volatile Node next; //后继结点
    volatile Thread thread; //获取同步状态的线程
    Node nextWaiter; //等待队列中的后继结点

    final boolean isShared() {
        return nextWaiter == SHARED;
    }

    final Node predecessor() throws NullPointerException {
        Node p = prev;
        if (p == null)
            throw new NullPointerException();
        else
            return p;
    }

    Node() {    // Used to establish initial head or SHARED marker
    }

    Node(Thread thread, Node mode) {     // Used by addWaiter
        this.nextWaiter = mode;
        this.thread = thread;
    }

    Node(Thread thread, int waitStatus) { // Used by Condition
        this.waitStatus = waitStatus;
        this.thread = thread;
    }
}
```

同步器拥有首结点(head)和尾结点(tail)，没有成功获取同步状态的线程将会成为结点加入该队列的尾部

```java
private transient volatile Node head;
private transient volatile Node tail;
private volatile int state;
```

![](img/aqs-set-tail.png)

同步队列遵循FIFO，首结点时获取同步状态成功的结点，首结点的线程在释放同步状态时，将会唤醒后继结点，而后继结点将会在获取同步状态成功时将自己设置为首结点。

![](img/aqs-set-head.png)

### 同步状态获取和释放

#### 独占式同步状态获取

通过调用同步器的`acquire(int arg)`方法可以获取同步状态，该方法主要完成了同步状态的获取、结点构造，加入同步队列以及在同步队列中自旋等待的相关工作

```java
public final void acquire(int arg) {
    if (!tryAcquire(arg) &&
        acquireQueued(addWaiter(Node.EXCLUSIVE), arg))
        selfInterrupt();
}
```

1. 首先尝试获取锁（`tryAcquire(arg`)的具体实现定义在了子类中），如果获取到，则执行完毕；否则进行步骤2
2. 通过`addWaiter(Node.EXCLUSIVE)`方法将当前线程包装成独占模式结点加入到CLH队列队尾，
3. 最后调用`acquireQueued(Node node, int arg)`方法，使得该结点以“死循环”的方式获取同步状态；如果获取不到则阻塞结点中的线程，而被阻塞线程的唤醒主要依靠前驱结点的出列或着阻塞线程被中断来实现

__结点构造和加入同步队列__

```java
private Node addWaiter(Node mode) {
    //把当前线程包装为node,设为独占模式
    Node node = new Node(Thread.currentThread(), mode);
    // 快速尝试添加尾结点
    Node pred = tail;
    if (pred != null) {
        node.prev = pred;
        // CAS设置尾结点
        if (compareAndSetTail(pred, node)) {
            pred.next = node;
            return node;
        }
    }
    // 多次尝试
    enq(node);
    return node;
}

private Node enq(final Node node) {
    // 循环尝试，直到入列成功
    for (;;) {
        Node t = tail;
        // tail不存在，设置为首结点
        if (t == null) { // Must initialize
            if (compareAndSetHead(new Node()))
                tail = head;
        } else {
            // 设置尾结点
            node.prev = t;
            if (compareAndSetTail(t, node)) {
                t.next = node;
                return t;
            }
        }
    }
}
```

__acquireQueued自旋获取同步状态__

结点进入同步队列中后，就进入了一个自旋过程，每个结点（或者说每个线程）都在自省地观察，当条件满足，获取到了同步状态，就可以从这个自旋过程中退出，否则依旧留在这个自旋过程中（并会阻塞结点地线程）

```java
final boolean acquireQueued(final Node node, int arg) {
    boolean failed = true;
    try {
        //中断标志
        boolean interrupted = false;
        /** 自旋过程，其实就是一个死循环而已 */
        for (;;) {
            //当前线程的前驱节点
            final Node p = node.predecessor();
            //当前线程的前驱节点是头结点，且同步状态成功
            if (p == head && tryAcquire(arg)) {
                setHead(node);
                p.next = null; // help GC
                failed = false;
                return interrupted;
            }
            //获取失败，则判断是否应该挂起,
            //而这个判断则得通过它的前驱节点的waitStatus来确定--具体后面介绍
            if (shouldParkAfterFailedAcquire(p, node) &&
                    parkAndCheckInterrupt())
                interrupted = true;
        }
    } finally {
        if (failed)
            cancelAcquire(node);
    }
}

private static boolean shouldParkAfterFailedAcquire(Node pred, Node node) {
    int ws = pred.waitStatus;
    if (ws == Node.SIGNAL)
        /*
        * SIGNAL,则返回true表示应该挂起当前线程,挂起该线程,并等待被唤醒,
        * 被唤醒后进行中断检测,如果发现当前线程被中断，
        * 那么抛出InterruptedException并退出循环
        */
        return true;
    if (ws > 0) {
        // >0, 将前驱节点踢出队列,返回false（循环地将ws大于0地前驱结点都踢出队列）
        do {
            node.prev = pred = pred.prev;
        } while (pred.waitStatus > 0);
        pred.next = node;
    } else {
        // <0,也是返回false,不过先将前驱节点waitStatus设置为SIGNAL,
        // 使得下次判断时,将当前节点挂起
        compareAndSetWaitStatus(pred, ws, Node.SIGNAL);
    }
    return false;
}

private final boolean parkAndCheckInterrupt() {
    LockSupport.park(this); // 阻塞线程
    return Thread.interrupted(); // 检查中断
}
```

#### 独占式同步状态释放

当前线程获取同步状态并执行了相应地逻辑之后，就需要释放同步状态，使得后续的结点能够继续地获取同步状态。通过调用同步器地`release(int arg)`方法可以释放同步状态，该方法在释放了同步状态之后，会唤醒器后继结点（进而使后继结点重新尝试获取同步状态）

```java
public final boolean release(int arg) {
    // 首先调用子类的tryRelease()方法释放锁
    if (tryRelease(arg)) {
        Node h = head;
        if (h != null && h.waitStatus != 0)
            unparkSuccessor(h); // 然后唤醒后继节点
        return true;
    }
    return false;
}

private void unparkSuccessor(Node node) {
    int ws = node.waitStatus;
    // 如果当前状态 < 0 则设置为 0
    if (ws < 0)
        compareAndSetWaitStatus(node, ws, 0);

    /*
    * 如果node的后继节点不为空且不是作废状态,则唤醒这个后继节点,
    * 否则从末尾开始寻找合适的节点,如果找到,则唤醒
    */
    Node s = node.next;
    if (s == null || s.waitStatus > 0) {
        s = null;
        for (Node t = tail; t != null && t != node; t = t.prev)
            if (t.waitStatus <= 0)
                s = t;
    }
    if (s != null)
        LockSupport.unpark(s.thread);
}
```

#### 共享式同步状态获取

共享式获取与独占式获取主要的区别在于同一时刻能否有多个线程同时获取到同步状态。AQS提供`acquireShared(int arg)`方法共享式获取同步状态：

```java
public final void acquireShared(int arg) {
    // 共享式获取同步状态的标志是返回 >= 0 的值表示获取成功
    if (tryAcquireShared(arg) < 0) 
        //获取失败，自旋获取同步状态
        doAcquireShared(arg);
}

private void doAcquireShared(int arg) {
    // 共享式节点
    final Node node = addWaiter(Node.SHARED);
    boolean failed = true;
    try {
        boolean interrupted = false;
        for (;;) {
            //前驱节点
            final Node p = node.predecessor();
            //如果其前驱节点为头节点，尝试获取同步状态
            if (p == head) {
                //尝试获取同步
                int r = tryAcquireShared(arg);
                if (r >= 0) {
                    setHeadAndPropagate(node, r);
                    p.next = null; // help GC
                    if (interrupted)
                        selfInterrupt();
                    failed = false;
                    return;
                }
            }
            if (shouldParkAfterFailedAcquire(p, node) &&
                    parkAndCheckInterrupt())
                interrupted = true;
        }
    } finally {
        if (failed)
            cancelAcquire(node);
    }
}
```

#### 共享式同步状态释放

通过调用`releaseShared(int arg)`方法可以释放同步状态：

```java
public final boolean releaseShared(int arg) {
    if (tryReleaseShared(arg)) {
        doReleaseShared();
        return true;
    }
    return false;
}

private void doReleaseShared() {
    // 为确保同步状态线程安全释放，通过循环和CAS来保证
    // （因为释放同步状态的操作会同时来自多个线程）
    for (;;) {
        Node h = head;
        if (h != null && h != tail) {
            int ws = h.waitStatus;
            if (ws == Node.SIGNAL) {
                if (!compareAndSetWaitStatus(h, Node.SIGNAL, 0))
                    continue;            // loop to recheck cases
                unparkSuccessor(h);
            }
            else if (ws == 0 &&
                        !compareAndSetWaitStatus(h, 0, Node.PROPAGATE))
                continue;                // loop on failed CAS
        }
        if (h == head)                   // loop if head changed
            break;
    }
}
```

## 重入锁--ReentrantLock

重入锁ReentrantLock，就是支持重入的锁，表示该锁支持一个线程对资源的重复加锁。除此之外，还支持获取锁时公平和非公平性选择。公平锁是指等待时间最长的线程最优先获取锁。公平锁的机制往往没有非公平锁的效率高。

### 类图

{% plantuml %}
interface Lock
abstract class AbstractQueuedSynchronizer
abstract class Sync
class ReentrantLock

Lock <|.. ReentrantLock
ReentrantLock *-- Sync
AbstractQueuedSynchronizer <|-- Sync

class FairSync
class NonfairSync
Sync <|-- FairSync
Sync <|-- NonfairSync
{% endplantuml %}

*plantuml*

```plantuml
interface Lock
abstract class AbstractQueuedSynchronizer
abstract class Sync
class ReentrantLock

Lock <|.. ReentrantLock
ReentrantLock *-- Sync
AbstractQueuedSynchronizer <|-- Sync

class FairSync
class NonfairSync
Sync <|-- FairSync
Sync <|-- NonfairSync
```
Sync为ReentrantLock里面的一个内部类，它继承AQS（AbstractQueuedSynchronizer），它有两个子类：公平锁FairSync和非公平锁NonfairSync。

### 获取锁

通过调用ReentrantLock的lock()方法可以获取锁：

```java
public void lock() {
    sync.lock();
}
```

ReentrantLock里面大部分的功能都是委托给Sync来实现的，同时Sync内部定义了lock()抽象方法由其子类去实现。

#### 非公平锁实现

```java
// NonfairSync中的lock方法
final void lock() {
    // 首先会第一次尝试快速获取锁
    if (compareAndSetState(0, 1))
        setExclusiveOwnerThread(Thread.currentThread());
    else // 获取失败
        //调用AQS中的acquire(int arg)方法
        acquire(1);
}

// AQS中的acquire方法
public final void acquire(int arg) {
    // 调用子类中实现的tryAcquire
    if (!tryAcquire(arg) &&
        acquireQueued(addWaiter(Node.EXCLUSIVE), arg))
        selfInterrupt();
}

// NonfairSync中的tryAcquire方法
protected final boolean tryAcquire(int acquires) {
    return nonfairTryAcquire(acquires);
}

// Sync中的nonfairTryAcquire方法
final boolean nonfairTryAcquire(int acquires) {
    // 获取当前线程
    final Thread current = Thread.currentThread();
    // 获取同步状态
    int c = getState();
    if (c == 0) { // 0表示没有该锁，处于空闲状态
        // 获取锁成功，设置为当前线程所有
        if (compareAndSetState(0, acquires)) {
            setExclusiveOwnerThread(current);
            return true;
        }
    }
    // 判断重入，查看持有锁的线程是否为当前线程
    else if (current == getExclusiveOwnerThread()) {
        int nextc = c + acquires;
        if (nextc < 0) // overflow
            throw new Error("Maximum lock count exceeded");
        setState(nextc);
        return true;
    }
    return false;
}
```

#### 公平锁实现

```java
// FairSync中的lock方法（和非公平锁有区别）
final void lock() {
    // 调用AQS中的acquire(int arg)方法
    acquire(1);
}

// AQS中的acquire方法
public final void acquire(int arg) {
    // 调用子类中实现的tryAcquire
    if (!tryAcquire(arg) &&
        acquireQueued(addWaiter(Node.EXCLUSIVE), arg))
        selfInterrupt();
}

// FairSync中的tryAcquire方法
protected final boolean tryAcquire(int acquires) {
    // 获取当前线程
    final Thread current = Thread.currentThread();
    // 获取同步状态
    int c = getState();
    if (c == 0) {
        // 此处和非公平锁有区别
        // 公平锁只有等待前驱线程获取并释放锁之后才能继续获取锁
        if (!hasQueuedPredecessors() &&
            compareAndSetState(0, acquires)) {
            setExclusiveOwnerThread(current);
            return true;
        }
    }
    else if (current == getExclusiveOwnerThread()) {
        int nextc = c + acquires;
        if (nextc < 0)
            throw new Error("Maximum lock count exceeded");
        setState(nextc);
        return true;
    }
    return false;
}

// AQS中的hasQueuedPredecessors方法
/* 判断当前线程是否位于同步队列中的第一个。如果是则返回true，否则返回false */
public final boolean hasQueuedPredecessors() {
    Node t = tail; // Read fields in reverse initialization order
    Node h = head;
    Node s;
    //头节点 != 尾节点
    //同步队列第一个节点不为null
    //当前线程是同步队列第一个节点
    return h != t &&
        ((s = h.next) == null || s.thread != Thread.currentThread());
}
```

公平锁与非公平锁的区别在于获取锁的时候是否按照FIFO的顺序来。

### 释放锁

ReentrantLock使用unlock()方法释放锁：

```java
public void unlock() {
    // 调用Sync(AQS)中的release方法
    sync.release(1);
}

// AQS中的release方法
public final boolean release(int arg) {
    // 调用子类实现的tryRelease方法
    if (tryRelease(arg)) {
        Node h = head;
        if (h != null && h.waitStatus != 0)
            unparkSuccessor(h);
        return true;
    }
    return false;
}

// Sync中的tryRelease的方法
protected final boolean tryRelease(int releases) {
    // 减掉releases
    int c = getState() - releases;
    // 如果释放的不是持有锁的线程，抛出异常
    if (Thread.currentThread() != getExclusiveOwnerThread())
        throw new IllegalMonitorStateException();
    boolean free = false;
    //state == 0 表示已经释放完全了，其他线程可以获取同步状态了
    if (c == 0) {
        // 只有当同步状态彻底释放后该方法才会返回true
        free = true;
        setExclusiveOwnerThread(null);
    }
    setState(c);
    return free;
}
```

## 读写锁--ReentrantReadWriteLock

重入锁ReentrantLock是排他锁，在同一时刻仅有一个线程可以访问。在读多写少的场景下，读服务不存在数据竞争问题，如果一个线程在读时禁止其他线程读势必会导致性能降低。因此提供了读写锁。

读写锁维护着一对锁，一个读锁和一个写锁。通过分离读锁和写锁，使得并发性比一般的排他锁有了较大的提升：在同一时间可以允许多个读线程同时访问，但是在写线程访问时，所有读线程和写线程都会被阻塞。

JDK中读写锁的接口是ReadWriteLock：

```java
public interface ReadWriteLock {
    Lock readLock(); // 返回读锁
    Lock writeLock(); // 返回写锁
}
```

JUC中读写锁的实现是ReentrantReadWriteLock，提供了如下的特性：

1. 公平性选择： 支持非公平（默认）和公平的锁获取方式，吞吐量非公平优于公平
2. 重入： 该锁支持重入
3. 锁降级： 遵循获取写锁、获取读锁在释放写锁的次序，写锁能够降级成为读锁

### 源码分析

```java
 /** 内部类  读锁 */
private final ReentrantReadWriteLock.ReadLock readerLock;
/** 内部类  写锁 */
private final ReentrantReadWriteLock.WriteLock writerLock;
/** 内部类， AQS的子类 */
final Sync sync;

/**
使用默认（非公平）的排序属性创建一个新的 ReentrantReadWriteLock
*/
public ReentrantReadWriteLock() {
    this(false);
}

/**
* 使用给定的公平策略创建一个新的 ReentrantReadWriteLock
*/
public ReentrantReadWriteLock(boolean fair) {
    sync = fair ? new FairSync() : new NonfairSync();
    readerLock = new ReadLock(this);
    writerLock = new WriteLock(this);
}

/** 返回用于写入操作的锁 */
public ReentrantReadWriteLock.WriteLock writeLock() { return writerLock; }
/** 返回用于读取操作的锁 */
public ReentrantReadWriteLock.ReadLock  readLock()  { return readerLock; }
```
