# Map

__源码均基于JDK 8__

## Map概述

Map是Java提供的映射容器，Map接口定义了一个保存key-value的对象，该对象中key值是不存在重复的，每个key值至多对应一个value。

接口定义：

```java
public interface Map<K,V> {}
```

## API & 源码分析

### 基础API

|返回类型|方法签名|描述|
|---|---|---|
|boolean|containsKey(Object key)|如果此映射包含指定键的映射关系，则返回true|
|boolean|containsValue(Object value)|如果此映射将一个或多个键映射到指定值，则返回 true。|
|V|get(Object key)|返回指定键所映射的值；如果此映射不包含该键的映射关系，则返回 null|
|V|put(K key, V value)|将指定的值与此映射中的指定键关联|
|V|remove(Object key)|如果存在一个键的映射关系，则将其从此映射中移除|
|void|putAll(Map<? extends K, ? extends V> m)|从指定映射中将所有映射关系复制到此映射中|
|`Set<K>`|keySet()|回此映射中包含的键的Set|
|`Collection<V>`|values()|返回此映射中包含的值的 Collection|
|`Set<Map.Entry<K, V>>`|entrySet()|返回此映射中包含的映射关系的 Set |

### JDK 8 后新增方法

Java 8中，Map接口新增了一些default方法，提升了对key和value操作的便利性。

下面先构造一个Map并举例说明新增方法的使用。

```java
Map<String, String> map = new HashMap<>();
map.put("Artoria", "Saber");
map.put("Ishtar", "Archer");
map.put("Scáthach","Lancer");
```

#### getOrDefault

如果指定的key存在，则返回该key对应的value，如果不存在，则返回指定的值

```java
default V getOrDefault(Object key, V defaultValue) {
    V v;
    return (((v = get(key)) != null) || containsKey(key))
        ? v
        : defaultValue;
}
```

#### forEach

遍历Map中的所有Entry, 对key, value进行处理，接收参数 `(K, V) -> void`

```java
default void forEach(BiConsumer<? super K, ? super V> action) {
    Objects.requireNonNull(action);
    for (Map.Entry<K, V> entry : entrySet()) {
        K k;
        V v;
        try {
            k = entry.getKey();
            v = entry.getValue();
        } catch(IllegalStateException ise) {
            // this usually means the entry is no longer in the map.
            throw new ConcurrentModificationException(ise);
        }
        action.accept(k, v);
    }
}
```

例子：

```java
map.forEach((k,v) -> System.out.println(k + ": " + v));
```

#### replaceAll

替换Map中所有Entry的value值，这个值由旧的key和value计算得出，接收参数 `(K, V) -> V`

```java
default void replaceAll(BiFunction<? super K, ? super V, ? extends V> function) {
    Objects.requireNonNull(function);
    for (Map.Entry<K, V> entry : entrySet()) {
        K k;
        V v;
        try {
            k = entry.getKey();
            v = entry.getValue();
        } catch(IllegalStateException ise) {
            // this usually means the entry is no longer in the map.
            throw new ConcurrentModificationException(ise);
        }

        // ise thrown from function is not a cme.
        v = function.apply(k, v);

        try {
            entry.setValue(v);
        } catch(IllegalStateException ise) {
            // this usually means the entry is no longer in the map.
            throw new ConcurrentModificationException(ise);
        }
    }
}
```

例子：

```java
map.replaceAll((k, v) -> "5 star " + v + " " + k);
```

#### putIfAbsent

如果key关联的value不存在，则关联新的value值，返回key关联的旧的值

```java
default V putIfAbsent(K key, V value) {
    V v = get(key);
    if (v == null) {
        v = put(key, value);
    }

    return v;
}
```

例子：

```java
map.putIfAbsent("Artoria", "Lancer");
map.putIfAbsent("Mashu", "Shielder");

System.out.println(map.get("Artoria")); // Saber
System.out.println(map.get("Mashu")); // Shielder
```

#### remove

接收2个参数，key和value，如果key关联的value值与指定的value值相等（equals)，则删除这个元素

```java
default boolean remove(Object key, Object value) {
    Object curValue = get(key);
    if (!Objects.equals(curValue, value) ||
        (curValue == null && !containsKey(key))) {
        return false;
    }
    remove(key);
    return true;
}
```

例子：

```java
map.remove("Ishtar", "Saber");
System.out.println(map.get("Artoria")); // 未删除成功， 输出 Saber
map.remove("Ishtar", "Archer");
System.out.println(map.get("Ishtar")); // 删除成功， 输出 null
```

#### replace(K key, V oldValue, V newValue)

如果key关联的值与指定的oldValue的值相等，则替换成新的newValue

```java
default boolean replace(K key, V oldValue, V newValue) {
    Object curValue = get(key);
    if (!Objects.equals(curValue, oldValue) ||
        (curValue == null && !containsKey(key))) {
        return false;
    }
    put(key, newValue);
    return true;
}
```

例子：

```java
map.replace("Artoria", "Lancer", "SSR");
System.out.println(map.get("Artoria")); // 未替换成功，输出 Saber
map.replace("Artoria", "Saber", "SSR");
System.out.println(map.get("Artoria")); // 替换成功，输出 SSR
```

#### replace(K key, V value)

如果map中存在key，则替换成value值，否则返回null

```java
default V replace(K key, V value) {
    V curValue;
    if (((curValue = get(key)) != null) || containsKey(key)) {
        curValue = put(key, value);
    }
    return curValue;
}
```

#### computeIfAbsent

如果指定的key不存在，则通过指定的K -> V计算出新的值设置为key的值

```java
default V computeIfAbsent(K key,
            Function<? super K, ? extends V> mappingFunction) {
    Objects.requireNonNull(mappingFunction);
    V v;
    if ((v = get(key)) == null) {
        V newValue;
        if ((newValue = mappingFunction.apply(key)) != null) {
            put(key, newValue);
            return newValue;
        }
    }

    return v;
}
```

#### computeIfPresent

如果指定的key存在，则根据旧的key和value计算新的值newValue, 如果newValue不为null，则设置key新的值为newValue, 如果newValue为null, 则删除该key的值

```java
default V computeIfPresent(K key,
            BiFunction<? super K, ? super V, ? extends V> remappingFunction) {
    Objects.requireNonNull(remappingFunction);
    V oldValue;
    if ((oldValue = get(key)) != null) {
        V newValue = remappingFunction.apply(key, oldValue);
        if (newValue != null) {
            put(key, newValue);
            return newValue;
        } else {
            remove(key);
            return null;
        }
    } else {
        return null;
    }
}
```

#### compute

compute方法是computeIfAbsent与computeIfPresent的结合体

```java
default V compute(K key,
        BiFunction<? super K, ? super V, ? extends V> remappingFunction) {
    Objects.requireNonNull(remappingFunction);
    V oldValue = get(key);

    V newValue = remappingFunction.apply(key, oldValue);
    if (newValue == null) {
        // delete mapping
        if (oldValue != null || containsKey(key)) {
            // something to remove
            remove(key);
            return null;
        } else {
            // nothing to do. Leave things as they were.
            return null;
        }
    } else {
        // add or replace old mapping
        put(key, newValue);
        return newValue;
    }
}
```

#### merge

如果指定的key不存在，则设置指定的value值，否则根据key的旧的值oldvalue和value计算出新的值newValue, 如果newValue为null, 则删除该key，否则设置key的新值newValue

```java
default V merge(K key, V value,
        BiFunction<? super V, ? super V, ? extends V> remappingFunction) {
    Objects.requireNonNull(remappingFunction);
    Objects.requireNonNull(value);
    V oldValue = get(key);
    V newValue = (oldValue == null) ? value :
                remappingFunction.apply(oldValue, value);
    if(newValue == null) {
        remove(key);
    } else {
        put(key, newValue);
    }
    return newValue;
}
```

### Map的实现类对比

Map接口常用的实现类有：

|实现类|线程安全|遍历顺序|是否允许键为null|其他|
|---|---|---|---|---|
|HashMap|非线程安全|遍历顺序不确定|最多允许一个null键|最常用|
|Hashtable|线程安全|遍历顺序不确定|不允许null键|不建议使用，线程安全场景用ConcurrentHashMap替换|
|LinkedHashMap|非线程安全|遍历次序为插入的顺序|最多允许一个null键|HashMap的一个子类，保存了记录的插入顺序|
|TreeMap|非线程安全|默认顺序是键值的升序，可以指定比较器|不允许null键|TreeMap实现SortedMap接口|

## HashMap

HashMap是Java程序员使用频率最高的用于映射(键值对)处理的数据类型。从结构实现来讲，HashMap是数组+链表+红黑树（JDK1.8增加了红黑树部分）实现的。

### 继承关系

```java
public class HashMap<K,V> extends AbstractMap<K,V>
    implements Map<K,V>, Cloneable, Serializable {}
```

HashMap继承了AbstractMap<K,V>抽象类，实现了Map<K,V>的方法

### 字段

```java
// 默认容量
static final int DEFAULT_INITIAL_CAPACITY = 1 << 4;

// 最大容量
static final int MAXIMUM_CAPACITY = 1 << 30;

// 默认加载因子
static final float DEFAULT_LOAD_FACTOR = 0.75f;

// 链表转成红黑树的阈值
static final int TREEIFY_THRESHOLD = 8;

// 红黑树转为链表的阈值
static final int UNTREEIFY_THRESHOLD = 6;

// 存储方式由链表转成红黑树的容量的最小阈值
static final int MIN_TREEIFY_CAPACITY = 64;

/* ---------------- Fields -------------- */

// 哈希桶数组，用于存放数据
transient Node<K,V>[] table;

//
transient Set<Map.Entry<K,V>> entrySet;

// HashMap中存储的键值对的数量
transient int size;

// 修改次数
transient int modCount;

// 扩容阈值，当size>=threshold时，就会扩容
int threshold;

// 负载因子
final float loadFactor;
```

### 构造器

```java
// 指定初始容量和负载因子
public HashMap(int initialCapacity, float loadFactor) {
    if (initialCapacity < 0)
        throw new IllegalArgumentException("Illegal initial capacity: " +
                                            initialCapacity);
    if (initialCapacity > MAXIMUM_CAPACITY)
        initialCapacity = MAXIMUM_CAPACITY;
    if (loadFactor <= 0 || Float.isNaN(loadFactor))
        throw new IllegalArgumentException("Illegal load factor: " +
                                            loadFactor);
    this.loadFactor = loadFactor;
    this.threshold = tableSizeFor(initialCapacity);
}

// 指定初始容量，负载因子为默认值(0.75)
public HashMap(int initialCapacity) {
    this(initialCapacity, DEFAULT_LOAD_FACTOR);
}

// 无参数构造器，初始容量为默认值(16)，负载因子为默认值(0.75)
public HashMap() {
    this.loadFactor = DEFAULT_LOAD_FACTOR; // all other fields defaulted
}

public HashMap(Map<? extends K, ? extends V> m) {
    this.loadFactor = DEFAULT_LOAD_FACTOR;
    putMapEntries(m, false);
}
```

由源码可以看出，HashMap的构造函数其实就是对loadFactor和threshold赋值的过程。

### Node--存放数据的内部类

Node是HashMap的一个内部类，实现了Map.Entry接口，本质是一个映射(键值对)，封装了Key和Value

```java
static class Node<K,V> implements Map.Entry<K,V> {
    final int hash; // 用于定位数组索引位置
    final K key;
    V value;
    Node<K,V> next; // 链表的下一个Node

    Node(int hash, K key, V value, Node<K,V> next) {
        this.hash = hash;
        this.key = key;
        this.value = value;
        this.next = next;
    }

    public final K getKey()        { return key; }
    public final V getValue()      { return value; }
    public final String toString() { return key + "=" + value; }

    public final int hashCode() {
        return Objects.hashCode(key) ^ Objects.hashCode(value);
    }

    public final V setValue(V newValue) {
        V oldValue = value;
        value = newValue;
        return oldValue;
    }

    public final boolean equals(Object o) {
        if (o == this)
            return true;
        if (o instanceof Map.Entry) {
            Map.Entry<?,?> e = (Map.Entry<?,?>)o;
            if (Objects.equals(key, e.getKey()) &&
                Objects.equals(value, e.getValue()))
                return true;
        }
        return false;
    }
}
```

### hash--确定hash桶数组索引位置

Hash，一般翻译做“散列”，就是把任意长度的输入，通过散列算法，变换成固定长度的输出，该输出就是散列值。

根据同一散列函数计算出的散列值如果不同，那么输入值肯定也不同。但是，根据同一散列函数计算出的散列值如果相同，输入值不一定相同。

__两个不同的输入值，根据同一散列函数计算出的散列值相同的现象叫做碰撞__

HashMap就是使用哈希表来存储的，为了解决碰撞，HashMap采用了链地址法，哈希桶数组中每个元素都是一个链表。hash函数就是用于计算数据在哈希桶数组中的索引，为了数据在哈希桶中分布均匀，Jdk 8中使用了hashCode()的高16位异或低16位来实现：

```java
static final int hash(Object key) {
    int h;
    return (key == null) ? 0 : (h = key.hashCode()) ^ (h >>> 16);
}
```

对key进行hash之后，再对hash值取模即可得到key对应的数组索引，JDK中并不是直接使用模运算符来计算，而是使用了性能更好的与运算来替代，能这样替代的原因是，Hash桶数组的大小都是2的n次幂

```java
int i = (table.length - 1) & hash;
```

### get--指定key快速查找

HashMap中get方法用于获取指定Key的Value，如果map中没有对应的键值映射，则返回null。

下面是HashMap get方法的源码分析：

```java
public V get(Object key) {
    Node<K,V> e;
    // 计算key的hash值，并调用getNode方法在map中查找key
    return (e = getNode(hash(key), key)) == null ? null : e.value;
}

final Node<K,V> getNode(int hash, Object key) {
    Node<K,V>[] tab; Node<K,V> first, e; int n; K k;
    // 这里有三个判断条件与，任意一个为false都代表table中不可能存在key的映射
    // a. table 不为null
    // b. table的length 大于 0
    // c. key的hash值计算出的索引在table中对应的头节点不为null
    if ((tab = table) != null && (n = tab.length) > 0 &&
        (first = tab[(n - 1) & hash]) != null) {
        // 这里已经找到了key的hash值对应链的首结点，首先判断首结点的key和要查找的key是否相等
        if (first.hash == hash && // always check first node
            ((k = first.key) == key || (key != null && key.equals(k))))
            return first;
        // 从首结点的后继节点开始遍历
        if ((e = first.next) != null) {
            // 如果是红黑树，则调用红黑树的查找方法
            if (first instanceof TreeNode)
                return ((TreeNode<K,V>)first).getTreeNode(hash, key);
            // 如果是链表，直接遍历链表，找到了相等的key就返回对应的value
            do {
                if (e.hash == hash &&
                    ((k = e.key) == key || (key != null && key.equals(k))))
                    return e;
            } while ((e = e.next) != null);
        }
    }
    return null;
}
```

### put--插入新的映射关系

HashMap中的方法用于向map容器中插入映射(键值对)，如果key在map中已经存在了，则会用新的值替换旧值。

HashMap put方法源码分析如下

```java
public V put(K key, V value) {
    // 这里通过hash函数计算key的hash值
    return putVal(hash(key), key, value, false, true);
}

final V putVal(int hash, K key, V value, boolean onlyIfAbsent,
                boolean evict) {
    Node<K,V>[] tab; Node<K,V> p; int n, i;
    // 1. 判断tab（hash桶数组）为空时，扩容
    if ((tab = table) == null || (n = tab.length) == 0)
        n = (tab = resize()).length;
    // 2. 计算索引i，并获取i位置上的头节点p，若p为null，直接插入新的结点
    if ((p = tab[i = (n - 1) & hash]) == null)
        tab[i] = newNode(hash, key, value, null);
    else { // 索引i对应的位置上存在数据的情况
        Node<K,V> e; K k;
        // 3. 如果头节点p的key和插入的key一样，则覆盖p结点的value，否则进行步骤4
        // 这里并不是直接对p的value进行赋值，而是把p赋值给e变量，e代表最后要赋值value的结点
        // 具体把value写入到结点的操作延迟到 步骤6 完成。
        if (p.hash == hash &&
            ((k = p.key) == key || (key != null && key.equals(k))))
            e = p;
        // 4. 判断是否该链是否为红黑树，若为红黑树，调用红黑树的插入方法，否则进行步骤5
        else if (p instanceof TreeNode)
            e = ((TreeNode<K,V>)p).putTreeVal(this, tab, hash, key, value);
        // 5. 索引i处的链为链表
        else {
            // 遍历链表
            for (int binCount = 0; ; ++binCount) {
                // 若遍历到链表尾，则插入一个新结点
                if ((e = p.next) == null) {
                    p.next = newNode(hash, key, value, null);
                    // 插入完成后，判断链表长度是否大于8，大于8的话把链表转换为红黑树
                    if (binCount >= TREEIFY_THRESHOLD - 1) // -1 for 1st
                        treeifyBin(tab, hash);
                    break;
                }
                // 若遍历过程中，发现key已经存在，直接覆盖
                if (e.hash == hash &&
                    ((k = e.key) == key || (key != null && key.equals(k))))
                    break;
                p = e;
            }
        }
        // 6. 具体执行写value的动作
        if (e != null) { // existing mapping for key
            V oldValue = e.value;
            if (!onlyIfAbsent || oldValue == null)
                e.value = value;
            afterNodeAccess(e);
            return oldValue;
        }
    }
    ++modCount;
    // 7. 判断实际存在的键值对数量size是否超多了最大容量threshold，如果超过，进行扩容
    if (++size > threshold)
        resize();
    afterNodeInsertion(evict);
    return null;
}
```

### resize--扩容机制

不停向HashMap中添加元素，当HashMap对象内部的数组无法装载更多的元素时，对象就需要扩大内部数组的长度，以便能装入更多的元素。

HashMap中使用resize()函数来完成扩容动作，下面是源码分析：

```java
final Node<K,V>[] resize() {
    Node<K,V>[] oldTab = table;
    // 这里将当前容量赋值给oldCap， 当前阈值赋值给oldThr
    int oldCap = (oldTab == null) ? 0 : oldTab.length;
    int oldThr = threshold;
    int newCap, newThr = 0;
    // 此分支对应HashMap已经完成了初次扩容的情况
    if (oldCap > 0) {
        // 超过最大值，就不再扩充了
        if (oldCap >= MAXIMUM_CAPACITY) {
            threshold = Integer.MAX_VALUE;
            return oldTab;
        }
        // 没有超过最大值，就扩充为原来的2倍
        else if ((newCap = oldCap << 1) < MAXIMUM_CAPACITY &&
                    oldCap >= DEFAULT_INITIAL_CAPACITY)
            newThr = oldThr << 1; // double threshold
    }
    // 此分支对应指定初始容量构造HashMap首次扩容的情况
    // 指定初始容量构造HashMap会将计算出来的容量(2的n次幂)赋值给threshold
    else if (oldThr > 0) // initial capacity was placed in threshold
        newCap = oldThr;
    // 此分支对应无参数构造HashMap首次扩容的情况
    else {               // zero initial threshold signifies using defaults
        newCap = DEFAULT_INITIAL_CAPACITY;
        newThr = (int)(DEFAULT_LOAD_FACTOR * DEFAULT_INITIAL_CAPACITY);
    }
    // 计算新的扩容阈值
    if (newThr == 0) {
        float ft = (float)newCap * loadFactor;
        newThr = (newCap < MAXIMUM_CAPACITY && ft < (float)MAXIMUM_CAPACITY ?
                    (int)ft : Integer.MAX_VALUE);
    }
    threshold = newThr;
    // 这里开始创建新的哈希桶数组
    @SuppressWarnings({"rawtypes","unchecked"})
        Node<K,V>[] newTab = (Node<K,V>[])new Node[newCap];
    table = newTab;
    if (oldTab != null) {
        //  把每个bucket都移动到新的bucket中
        for (int j = 0; j < oldCap; ++j) {
            Node<K,V> e;
            if ((e = oldTab[j]) != null) {
                // 避免游离
                oldTab[j] = null;
                // bucket中首结点无后继结点，直接重新计算该结点在新数组中的索引，并放入新数组中
                if (e.next == null)
                    newTab[e.hash & (newCap - 1)] = e;
                // bucket中是红黑树，调用红黑树中分割方法
                else if (e instanceof TreeNode)
                    ((TreeNode<K,V>)e).split(this, newTab, j, oldCap);
                else { // preserve order
                    // 链表优化的重计算索引的过程，这里会将原来的链表中所有结点分到新的两条链表中，lo和high
                    // 这没用求模(与n-1)的方式计算新索引，而是看hash值在原mask范围的高一位是0还是1来判断新索引的
                    // a. 若为0，新索引仍保持不变(结点加入lo链表)，
                    // b. 若为1，新索引为原索引+oldCap(结点加入hi链表)
                    Node<K,V> loHead = null, loTail = null;
                    Node<K,V> hiHead = null, hiTail = null;
                    Node<K,V> next;
                    do {
                        next = e.next;
                        // a. 原索引
                        if ((e.hash & oldCap) == 0) {
                            if (loTail == null)
                                loHead = e;
                            else
                                loTail.next = e;
                            loTail = e;
                        }
                        // b. 原索引+oldCap
                        else {
                            if (hiTail == null)
                                hiHead = e;
                            else
                                hiTail.next = e;
                            hiTail = e;
                        }
                    } while ((e = next) != null);
                    // lo链表放入新数组中，索引为原索引
                    if (loTail != null) {
                        // 新链表尾结点可能为原链表中的中间结点，需要把尾结点的后继结点置为null
                        loTail.next = null;
                        newTab[j] = loHead;
                    }
                    // high链表放入新数组中，索引为原索引+oldCap
                    if (hiTail != null) {
                        hiTail.next = null;
                        newTab[j + oldCap] = hiHead;
                    }
                }
            }
        }
    }
    return newTab;
}
```

### HashMap遍历

HashMap的遍历可以分为对key的遍历，对value的遍历，以及对entry的遍历，这些遍历底层的逻辑实现都是由HashMap中的内部类HashIterator的nextNode方法来实现的。下面是源码分析

```java
final Node<K,V> nextNode() {
    Node<K,V>[] t;
    Node<K,V> e = next;
    if (modCount != expectedModCount)
        throw new ConcurrentModificationException();
    if (e == null)
        throw new NoSuchElementException();
    // 对桶中的结点进行遍历
    if ((next = (current = e).next) == null && (t = table) != null) {
        // 遍历下一个桶
        do {} while (index < t.length && (next = t[index++]) == null);
    }
    return e;
}
```

### 红黑树与TreeNode

待分析
