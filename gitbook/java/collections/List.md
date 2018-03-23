# List

## List概述

List继承了Collection接口，是一种有序的Collection，List集合代表一个元素有序、可重复的集合，集合中每个元素都有其对应的顺序索引。

接口定义:

```java
public interface List<E> extends Collection<E> {}
```

## API & 源码分析

### 基础API

List继承了[Collection的接口方法](Collection.md#API)，并扩展定义了如下的接口方法:

|   返回类型   |                   方法签名                   |                                     描述                                     |
| :----------- | :------------------------------------------- | :--------------------------------------------------------------------------: |
| void         | add(int index, E element)                    |                     将元素element 添加到List集合index处                      |
| boolean      | addAll(int index, Collection<? extends E> c) |                  将集合c所包含的所有元素插入到List的index处                  |
| E            | get(int index)                               |                          返回集合index索引处的元素                           |
| int          | indexOf(Object o)                            |           返回对象o在List中第一次出现的位置索引，若不存在则返回-1            |
| int          | lastIndexOf(Object o)                        |          返回对象o在List中最后一次出现的位置索引，若不存在则返回-1           |
| ListIterator | listIterator()                               |                              返回一个List迭代器                              |
| ListIterator | listIterator(int index)                      |                      返回一个从指定索引开始的List迭代器                      |
| E            | remove(int index)                            |                         删除并返回index索引出的元素                          |
| E            | set(int index, E element)                    |           将index索引处的元素替换成element对象，返回被替换的旧元素           |
| List<E>      | subList(int fromIndex, int toIndex)          | 返回从索引fromIndex（包含）到索引toIndex（不包含）处所有集合元素组成的子List |


### JDK8后新增接口方法

我们先看下在JDK8中新增的两个默认接口方法replaceAll和sort:

replaceAll方法会根据operator指定的计算规则重新设置List集合的所有元素。

```java
default void replaceAll(UnaryOperator<E> operator) {
    Objects.requireNonNull(operator);
    final ListIterator<E> li = this.listIterator();
    while (li.hasNext()) {
        li.set(operator.apply(li.next()));
    }
}
```

下面这个例子就是使用replaceAll方法将List中的元素均换成了大写。

```java
/*
* Example to show the replaceAll method of List interface
*/
List<String> list = new ArrayList<>(Arrays.asList("saber", "lancer", "archer"));
list.replaceAll(String::toUpperCase);
list.forEach(System.out::println);
/*output*/
//SABER
//LANCER
//ARCHER
```

sort方法提供了List排序的默认实现，能根据Comparator参数对List集合的元素排序。

```java
default void sort(Comparator<? super E> c) {
    Object[] a = this.toArray();
    Arrays.sort(a, (Comparator) c);
    ListIterator<E> i = this.listIterator();
    for (Object e : a) {
        i.next();
        i.set((E) e);
    }
}
```

从源码中可以看出，List的sort方法是先将List转换成数组，再调用Arrays.sort进行排序，最后将排好序的数组元素重新设置到List中。

接下来看下JDK9中新加入的静态接口方法of。

of方法主要用于产生不可变List，这儿的不可变List是指除了不能增加删除元素外，也不能修改不可变List中的元素。这与Arrays.asList生成的不可变List不同，Arrays.asList生成的List是Arrays的一个私有内部类，支持get和set，但是不能增加和删除。

```java
/*
* Example to show that an immutable List created by the of method cannot be changed
*/
List<String> immutableList = List.of("Saber", "Lancer");
try {
    immutableList.add("Archer");
}
catch (UnsupportedOperationException e)
{
    System.out.println("Oops, It is a wrong operation to modify a immutable List!!");
}
```

## ArrayList

ArrayList估计是平时开发过程中用到最多的容器了。顾名思义，ArrayList是使用数组实现的列表容器，接下来就具体分析下ArrayList的内部实现原理。

### 继承关系

```java
public class ArrayList<E> extends AbstractList<E>
        implements List<E>, RandomAccess, Cloneable, java.io.Serializable {}
```

+ ArrayList 继承了AbstractList，实现了List。它是一个数组队列，提供了相关的添加、删除、修改、遍历等功能。

+ ArrayList 实现了RandmoAccess接口，即提供了随机访问功能。类似于RandmoAccess这种没有定义抽象方法的接口，叫做"Marker interface"。RandmoAccess是java中用来被List实现，为List提供快速访问功能的。

+ ArrayList 实现了Cloneable接口，即覆盖了函数`clone()`，能被克隆。

+ ArrayList 实现java.io.Serializable接口，这意味着ArrayList支持序列化，能通过序列化去传输。

### 字段

```java
// 默认容量
private static final int DEFAULT_CAPACITY = 10;

// 空数组
private static final Object[] EMPTY_ELEMENTDATA = {};

// 默认构造器里的空数组
private static final Object[] DEFAULTCAPACITY_EMPTY_ELEMENTDATA = {};

// 存储集合元素的底层实现：真正存放元素的数组
transient Object[] elementData;

// 元素个数
private int size;
```

### 构造器

ArrayList提供三种构造器:

```java
// 默认构造器，构造一个默认空ArrayList，当第一个元素被添加时，容量被直接扩展到默认值10
public ArrayList() {
    // 默认构造方法只是简单的将 空数组赋值给了elementData
    this.elementData = DEFAULTCAPACITY_EMPTY_ELEMENTDATA;
}

// 构造一个指定初始容量的空ArrayList
public ArrayList(int initialCapacity) {
    if (initialCapacity > 0) {
        this.elementData = new Object[initialCapacity];
    } else if (initialCapacity == 0) { //如果容量为0，直接将EMPTY_ELEMENTDATA赋值给elementData
        this.elementData = EMPTY_ELEMENTDATA;
    } else {
        throw new IllegalArgumentException("Illegal Capacity: "+
                                            initialCapacity);
    }
}

// 通过一个指定Collection来构造ArrayList
public ArrayList(Collection<? extends E> c) {
    elementData = c.toArray();
    if ((size = elementData.length) != 0) {
        if (elementData.getClass() != Object[].class)
            elementData = Arrays.copyOf(elementData, size, Object[].class);
    } else {
        // 如果集合c元素数量为0，则将空数组EMPTY_ELEMENTDATA赋值给elementData
        this.elementData = EMPTY_ELEMENTDATA;
    }
}
```

构造方法中使用到了常用的两个方法：首先看`Collection.toArray()`，这个方法是`Collection`接口中定义的方法，用于将容器转化为`Object`数组，在`Collection`子类各大集合的源码中，高频使用了这个方法去获得某`Collection`的所有元素。

下面看下调用的`Arrays.copyOf(elementData, size, Object[].class)`，用于拷贝生成新的数组。源码如下：

```java
public static <T,U> T[] copyOf(U[] original, int newLength, Class<? extends T[]> newType) {
    @SuppressWarnings("unchecked")
    // 根据传入的class类型来决定是new 还是反射去构造一个泛型数组
    T[] copy = ((Object)newType == (Object)Object[].class)
        ? (T[]) new Object[newLength]
        : (T[]) Array.newInstance(newType.getComponentType(), newLength);
    // 复制元素至新数组中
    System.arraycopy(original, 0, copy, 0,
                        Math.min(original.length, newLength));
    return copy;
}
```

`System.arraycopy`是一个native函数，用于实现数组拷贝，JDK源码中使用的频率较高。

```java
public static native void arraycopy(Object src,  int  srcPos,
                                    Object dest, int destPos,
                                    int length);
```

### 常用方法实现

#### add & addAll

```java
// 在List末尾添加一个元素
public boolean add(E e) {
    modCount++;
    add(e, elementData, size);
    return true;
}

// 从add(E)中抽出来的帮助方法，??优化C1编译器内联
private void add(E e, Object[] elementData, int s) {
    //判断是否需要扩容
    if (s == elementData.length)
        elementData = grow();
    elementData[s] = e;
    size = s + 1;
}

// 指定位置插入元素
public void add(int index, E element) {
    rangeCheckForAdd(index); // 检查下标是否在[0,size]
    modCount++;
    final int s;
    Object[] elementData;
    // 判断是否需要扩容
    if ((s = size) == (elementData = this.elementData).length)
        elementData = grow();
    // 将index开始的数据 向后移动一位
    System.arraycopy(elementData, index,
                        elementData, index + 1,
                        s - index);
    elementData[index] = element;
    size = s + 1;
}

// 向List的末尾插入Collection中的所有元素
public boolean addAll(Collection<? extends E> c) {
    Object[] a = c.toArray();
    modCount++;
    int numNew = a.length;
    if (numNew == 0)
        return false;
    Object[] elementData;
    final int s;
    // 判断是否需要扩容
    if (numNew > (elementData = this.elementData).length - (s = size))
        elementData = grow(s + numNew);
    // 将c中的元素拷贝到elementData
    System.arraycopy(a, 0, elementData, s, numNew);
    size = s + numNew;
    return true;
}

// 向List的指定位置插入Collection中的所有元素
public boolean addAll(int index, Collection<? extends E> c) {
    rangeCheckForAdd(index); // 检查下标是否在[0,size]

    Object[] a = c.toArray();
    modCount++;
    int numNew = a.length;
    if (numNew == 0)
        return false;
    Object[] elementData;
    final int s;
    // 判断是否需要扩容
    if (numNew > (elementData = this.elementData).length - (s = size))
        elementData = grow(s + numNew);

    int numMoved = s - index;
    // 将index开始的数据 向后移动numNew位
    if (numMoved > 0)
        System.arraycopy(elementData, index,
                            elementData, index + numNew,
                            numMoved);
    // 将c中的元素拷贝到elementData
    System.arraycopy(a, 0, elementData, index, numNew);
    size = s + numNew;
    return true;
}
```

modCount是从AbstractList继承的，用于记录容器结构变更次数。下面总结一下add和addAll的流程：

+ 检查越界(指定位置插入)
+ modCount++
+ 判断是否扩容
+ 设置对应下标元素值

接下来看下扩容的具体实现：

```java
private static final int MAX_ARRAY_SIZE = Integer.MAX_VALUE - 8;

// 指定最小期望容量扩容
private Object[] grow(int minCapacity) {
    return elementData = Arrays.copyOf(elementData,
                                    newCapacity(minCapacity));
}

// 默认扩容，最小期望容量为当前List元素个数加1
private Object[] grow() {
    return grow(size + 1);
}

// 扩容策略的具体实现
private int newCapacity(int minCapacity) {
    // overflow-conscious code
    int oldCapacity = elementData.length;
    // 默认扩容一半
    int newCapacity = oldCapacity + (oldCapacity >> 1);
    // 若扩容后的值比最小期望容量还小
    if (newCapacity - minCapacity <= 0) {
        // 如果是默认构造函数初始化的空数组， max(10,minCapacity)
        if (elementData == DEFAULTCAPACITY_EMPTY_ELEMENTDATA)
            return Math.max(DEFAULT_CAPACITY, minCapacity);
        if (minCapacity < 0) // overflow
            throw new OutOfMemoryError();
        return minCapacity;
    }
    // 判断扩容后的之后是否超过了最大数组元素个数
    return (newCapacity - MAX_ARRAY_SIZE <= 0)
        ? newCapacity
        : hugeCapacity(minCapacity);
}
```

#### remove & removeAll & retainAll

```java
// 移除对应下标的元素
public E remove(int index) {
    Objects.checkIndex(index, size); // 下标检查

    modCount++;
    E oldValue = elementData(index); // 取出要移除的元素

    int numMoved = size - index - 1;
    if (numMoved > 0)
        System.arraycopy(elementData, index+1, elementData, index,
                            numMoved); // 移动数据
    elementData[--size] = null; // clear to let GC do its work

    return oldValue;
}

@SuppressWarnings("unchecked")
E elementData(int index) {
    return (E) elementData[index];
}

// 删除该元素在数组中第一次出现的位置上的数据。 如果有该元素返回true，否则返回false
public boolean remove(Object o) {
    if (o == null) {
        for (int index = 0; index < size; index++)
            if (elementData[index] == null) {
                fastRemove(index); // 根据index快速删除元素
                return true;
            }
    } else {
        for (int index = 0; index < size; index++)
            if (o.equals(elementData[index])) {
                fastRemove(index);
                return true;
            }
    }
    return false;
}

// 不用判断越界 ，也不需要取出该元素。
private void fastRemove(int index) {
    modCount++;
    int numMoved = size - index - 1;
    if (numMoved > 0)
        System.arraycopy(elementData, index+1, elementData, index,
                            numMoved);
    elementData[--size] = null; // clear to let GC do its work
}

// 移除交集
public boolean removeAll(Collection<?> c) {
    return batchRemove(c, false, 0, size);
}

// 保留交集
public boolean retainAll(Collection<?> c) {
    return batchRemove(c, true, 0, size);
}

// 批量删除，根据complement的值执行不同的操作，true的时候移除差集，false的时候移除交集
boolean batchRemove(Collection<?> c, boolean complement,
                    final int from, final int end) {
    Objects.requireNonNull(c);
    final Object[] es = elementData;
    final boolean modified;
    int r;
    // Optimize for initial run of survivors
    for (r = from; r < end && c.contains(es[r]) == complement; r++)
        ;
    if (modified = (r < end)) {
        int w = r++;
        try {
            for (Object e; r < end; r++)
                if (c.contains(e = es[r]) == complement)
                    es[w++] = e;
        } catch (Throwable ex) {
            // Preserve behavioral compatibility with AbstractCollection,
            // even if c.contains() throws.
            System.arraycopy(es, r, es, w, end - r);
            w += end - r;
            throw ex;
        } finally {
            modCount += end - w;
            shiftTailOverGap(es, w, end);
        }
    }
    return modified;
}
```

#### get & set

get和set比较简单，就是取出数组中对应的下标的元素，以及设置对应下标的元素

```java
public E set(int index, E element) {
    Objects.checkIndex(index, size);
    // 这个方法在remove的时候已经见过了
    E oldValue = elementData(index);
    elementData[index] = element;
    return oldValue;
}

public E get(int index) {
    Objects.checkIndex(index, size);
    return elementData(index);
}
```


### 待分析

+ ListItr
+ ArrayListSpliterator


## LinkedList

### 继承关系

```java
public class LinkedList<E>
    extends AbstractSequentialList<E>
    implements List<E>, Deque<E>, Cloneable, java.io.Serializable {}
```

+ `AbstractSequentialList`继承自`AbstractList`，提供了通过索引访问队列的API
+ `LinkedList`实现了`Deque`接口，能将LinkedList当作双端队列使用


在`LinkedList`中除了本身自己的方法外，还提供了一些可以使其作为栈、队列或者双端队列的方法。这些方法可能彼此之间只是名字不同，以使得这些名字在特定的环境中显得更加合适。

`LinkedList`实际上就是采用[双向链表](../../dsa/ds/linkedList.md)来实现的。
