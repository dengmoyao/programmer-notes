# 链表

链表是一种递归的数据结构，它或者为空`null`，或者是指向一个结点(node)的引用，该结点含有一个泛型的元素，和一个指向另一条链表的引用。

## Java代码实现

### 单向链表

```java
public class NodeList<E> {
// 1. 使用一个嵌套类来定义结点的抽象数据类型
    private class Node {
        E item;
        Node next;

        Node(E item, Node next) {
            this.item = item;
            this.next = next;
        }
    }

    // 2. 定义头结点和尾结点
    private Node first, last;
    private int size;

    public int size() {
        return size;
    }

    public boolean isEmpty() {
        return size == 0;
    }

    // 从链表头添加结点
    private void addFirst(E item) {
        final Node f = first;
        Node newNode = new Node(item, f);
        first = newNode;
        if (f == null)
            last = newNode;
        size++;
    }

    // 从链表头删除结点
    private E removeFirst() {
        if (first != null) {
            E item = first.item;
            first = first.next;
            if (first == null)
                last = null;
            size--;
            return item;
        }
        return null;
    }

    // 从链表尾添加结点
    private void addLast(E item) {
        final Node l = last;
        Node newNode = new Node(item, null);
        last = newNode;
        if (l == null)
            first = newNode;
        else
            l.next = newNode;
        size++;
    }
}
```

### 双向链表

上面的单向链表没有从链表末尾删除元素的方法，是因为末尾的结点没办法指向前一结点，为了实现“查询某个结点的前一结点”这样的需求，需要使用双向链表：

```java
public class DoubleNodeList<E> {
    // 1. 使用一个嵌套类来定义结点的抽象数据类型
    private static class Node<E> {
        E item;
        Node<E> next, prev;

        Node(Node<E> prev, E item, Node<E> next) {
            this.item = item;
            this.prev = prev; // 前驱结点
            this.next = next; // 后继结点
        }
    }

    private int size;
    private Node<E> first, last;

    public int size() {
        return size;
    }

    public boolean isEmpty() {
        return size == 0;
    }

    private void addFirst(E item) {
        final Node<E> f = first;
        final Node<E> newNode = new Node<>(null, item, f);
        first = newNode;
        if (f == null)
            last = newNode;
        else
            f.prev = newNode;
        size++;
    }

    private E removeFirst() {
        final Node<E> f = first;
        if (f == null)
            return null;
        final E element = f.item;
        final Node<E> next = f.next;
        f.item = null;
        f.next = null; // help GC
        first = next;
        if (next == null)
            last = null;
        else
            next.prev = null;
        size--;
        return element;
    }

    private void addLast(E item) {
        final Node<E> l = last;
        final Node<E> newNode = new Node<>(l, item, null);
        last = newNode;
        if (l == null)
            first = newNode;
        else
            l.next = newNode;
        size++;
    }

    private E removeLast() {
        final Node<E> l = last;
        if (l == null)
            return null;
        final E element = l.item;
        final Node<E> prev = l.prev;
        l.item = null;
        l.prev = null; // help GC
        last = prev;
        if (prev == null)
            first = null;
        else
            prev.next = null;
        size--;
        return element;
    }
}
```
