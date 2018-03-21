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
