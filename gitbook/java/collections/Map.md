# Map

## Map概述

Map是Java提供的映射容器，Map接口定义了一个保存key-value的对象，该对象中key值是不存在重复的，每个key值至多对应一个value

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
|Set<K>|keySet()|回此映射中包含的键的Set|
|Collection<V>|values()|返回此映射中包含的值的 Collection|
|Set<Map.Entry<K, V>>|entrySet()|返回此映射中包含的映射关系的 Set |

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

### Node

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
