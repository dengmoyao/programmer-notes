# List

## List概述

List继承了Collection接口，是一种有序的Collection，List集合代表一个元素有序、可重复的集合，集合中每个元素都有其对应的顺序索引。

接口定义:

```java
public interface List<E> extends Collection<E> {}
```

## API

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
