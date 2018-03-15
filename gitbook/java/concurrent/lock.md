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
