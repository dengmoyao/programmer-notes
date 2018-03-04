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
