# 栈和队列

## 栈

栈是一种基于后进先出（LIFO）策略的集合类型。API如下：

```java
public interface Stack<E> extends Iterable<E> {
    void push(E e) // 入栈
    E pop() // 出栈
    boolean isEmpty() // 栈是否为空
    size() // 栈中元素数量
}
```

栈的概念很常见，比如JVM中栈帧，和操作数栈。

java.util.Stack是基于Vector实现的，拥有很多额外的方法，是宽接口的一个典型例子。

### 数组实现栈

新建一个类ArrayStack去实现上面定义的Stack接口，并定义数组`elementData`用于保存栈中元素，int型变量`size`保存当前栈中元素个数

```java
public class ArrayStack<E> implements Stack<E> {
    private E[] elementData;
    private int size;

    public ArrayStack(int cap) {
        // 初始化数组，Java不支持创建泛型数组，只能使用类型转换
        elementData = (E[]) new Object[cap];
    }

    @Override
    public void push(E e) {
        elementData[size++] = e;
    }

    @Override
    public E pop() {
        return elementData[--size];
    }

    @Override
    public boolean isEmpty() {
        return size == 0;
    }

    @Override
    public int size() {
        return size;
    }

    @Override
    public Iterator<E> iterator() {
        return null; // 暂时不实现迭代器
    }
}
```

#### 容量变更

首先新增一个方法实现容量变更

```java
private void resize(int max) {
    // 新建新数组，并把原来的数组数据拷贝到新数组中，实现容量变更
    E[] temp = (E[]) new Object[max];
    System.arraycopy(elementData, 0, temp, 0, Math.min(elementData.length, max));
    elementData = temp;
}
```

然后，修改原来的push和pop方法

```java
public void push(E e) {
    if (size == elementData.length)
        resize(elementData.length * 2);
    elementData[size++] = e;
}

public E pop() {
    if (isEmpty()) {
        return null;
    }
    E item = elementData[--size];
    elementData[size] = null; // 避免对象游离
    if (size > 0 && elementData.length / 4 == size)
        resize(elementData.length / 2);
    return item;
}
```


### 链表实现栈

栈用链表来实现的话，`push`就是从链表头添加一个结点，`pop`就是从链表头删除一个结点，参考[链表](linkedList.md)的实现，就可以写出栈和入栈的代码了

```java
public void push(E e) {
    addFirst(e);
}

public E pop() {
    return removeFirst();
}
```


## 队列

队列是一种基于先进先出（FIFO）策略的集合类型。API如下：

```java
public interface Queue<E> extends Iterable<E> {
    void enqueue(E item); // 入列
    E dequeue(); // 出列
    boolean isEmpty(); // 队列是否为空
    int size(); // 队列中元素数量
}
```

上面是单向队列的API，只能从队尾入列从队头出列，Java类库中，也提供了`Queue`接口：

```java
public interface Queue<E> extends Collection<E> {
    boolean add(E e); // 向队尾添加元素，如果成功，返回true

    boolean offer(E e); // 向队尾添加元素， 同add

    E remove(); // 从队头删除一个元素，空队列抛NoSuchElementException

    E poll(); // 从队头删除一个元素，空队列返回null

    E element(); // 返回队头元素，空队列抛NoSuchElementException

    E peek(); // 返回队头元素，空队列返回null
}
```

### 链表实现队列

队列用链表来实现的话，`enqueue`就是从链表尾添加一个结点，`dequeue`就是从链表头删除一个结点，参考[链表](linkedList.md)的实现，就可以写出列和入列的代码了

```java
public void enqueue(E e) {
    addLast(e);
}

public E dequeue() {
    return removeFirst();
}
```

#### 双端队列

双端队列(Deque)，就是头和尾都支持元素入队，出队的队列。

用链表实现双端队列的话，就要采用双向链表的方式了。
