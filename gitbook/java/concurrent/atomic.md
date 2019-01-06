# 原子操作类

JDK 1.5 引入了atomic包，这个包中的原子操作类提供了一种用法简单、性能高效、线程安全地更新变量地方式

### 分类

atomic 包中的类可以分成如下几组：

+ 标量类： `AtomicBoolean`，`AtomicInteger`，`AtomicLong`，`AtomicReference`
+ 数组类： `AtomicIntegerArray`，`AtomicLongArray`，`AtomicReferenceArray`
+ 更新器类： `AtomicLongFieldUpdater`，`AtomicIntegerFieldUpdater`，`AtomicReferenceFieldUpdater`
+ 复合变量类: `AtomicMarkableReference`，`AtomicStampedReference`

此外还有JDK 8 新增的 `LongAdder` 和 `DoubleAdder`

### CAS

atomic包下的这些类都是采用的是乐观锁策略去原子更新数据，具体实现则是使用Unsafe实现CAS更新。

CAS比较交换的过程可以通俗的理解为CAS(V,O,N)，包含三个值分别为：V 内存地址存放的实际值；O 预期的值（旧值）；N 更新的新值。CAS的实现需要硬件指令集的支撑，在JDK1.5后虚拟机才可以使用处理器提供的CMPXCHG指令实现。

#### LongAdder 高效原理

AtomicLong的实现方式是内部有个value 变量，当多线程并发自增，自减时，均通过CAS 指令从机器指令级别操作保证并发的原子性。唯一会制约AtomicLong高效的原因是高并发，高并发意味着CAS的失败几率更高， 重试次数更多，越多线程重试，CAS失败几率又越高，变成恶性循环，AtomicLong效率降低。

而LongAdder将把一个value拆分成若干cell，把所有cell加起来，就是value。所以对LongAdder进行加减操作，只需要对不同的cell来操作，不同的线程对不同的cell进行CAS操作，CAS的成功率便提高。

在 netty 中，针对Java 8 以上的版本便通过LongAdder 来实现 LongCounter，Java 8 以下的版本则使用 AtomicLong。