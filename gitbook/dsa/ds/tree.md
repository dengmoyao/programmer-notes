# 树

## 基本概念

一般用递归的方式的来定义一棵树：

一棵树是一些结点的集合。这个集合可以是空集；若不是空集，则树由称为根(root)的结点r以及0个或多个非空的(子)树$$T_1$$，$$T_2$$，...，$$T_k$$组成，这些字数中的每一棵的根都被来自根r的一条有向的边(edge)所连结。

每一棵子树的根叫做根r的儿子(child)，而r是每一棵子树的根的父亲(parent)

一些树的术语：

+ 树叶(leaf)： 没有儿子的结点
+ 兄弟(siblings): 具有相同父亲的结点
+ 结点的度(degree): 结点所拥有的子树的棵数，叶结点的度是0， 而树的度则是树中各个结点度的最大值
+ 深度(depth): 从根到结点的唯一路径的长，根的深度是0
+ 高(height): 结点到树叶最长路径的长，所有的树叶的高是0，树的高度是根的高

## 二叉查找树

二叉树(Binary Tree)：每个结点都不能有多余两个儿子的树

二叉查找树(Binary Search Tree, BST)：左子结点的值比父结点小，右子结点的值比父结点的值大

在理想的情况下，二叉查找树增删查改的时间复杂度为O(logN)（其中N为节点数），最坏的情况下为O(N)。

### Java代码实现

```java
package dsa.collection;

import java.util.Comparator;

public class BinarySearchTree<E> {
    /**
     * 静态内部类，定义树的结点
     */
    private static class Node<E> {
        E element; // 数据
        Node<E> left; // 左子结点
        Node<E> right; // 右子结点

        Node(E element, Node<E> lt, Node<E> rt) {
            this.element = element;
            this.left = lt;
            this.right = rt;
        }
    }

    private Node<E> root; // 根结点
    private final Comparator<? super E> comparator; // 比较器

    /*========================== 公有API ============================*/

    public BinarySearchTree() {
        this(null);
    }

    public BinarySearchTree(Comparator<? super E> comparator) {
        this.root = null;
        this.comparator = comparator;
    }

    public void clear() {
        this.root = null;
    }

    public boolean isEmpty() {
        return root == null;
    }

    public boolean contains(E e) {
        return contains(e, root);
    }

    public E min() {
        if (isEmpty())
            return null;
        return min(root).element;
    }

    public E max() {
        if (isEmpty())
            return null;
        return max(root).element;
    }

    public void insert(E e) {
        root = insert(e, root);
    }

    public void remove(E e) {
        root = remove(e, root);
    }

    /*========================== 私有方法 ============================*/

    /**
     * 比较方法
     *
     * @param l 前一个值
     * @param r 后一个值
     * @return 比较结果
     */
    private int compare(E l, E r) {
        if (comparator != null)
            return comparator.compare(l, r);
        return ((Comparable) l).compareTo(r);
    }

    /**
     * 在子树中找到对应元素
     *
     * @param e 要找的元素
     * @param t 子树
     * @return 找到了返回true，否则返回false
     */
    private boolean contains(E e, Node<E> t) {
        if (t == null)
            return false;

        int cmp = compare(e, t.element);

        if (cmp < 0)
            return contains(e, t.left);
        else if (cmp > 0)
            return contains(e, t.right);
        else
            return true;
    }

    /**
     * 找到子树中的最小值的结点（递归实现）
     *
     * @param t 子树的根结点
     * @return 含有最小值的结点
     */
    private Node<E> min(Node<E> t) {
        if (t == null)
            return null;
        else if (t.left == null)
            return t;
        return min(t);
    }

    /**
     * 找到子树中的最大值的结点（非递归实现）
     *
     * @param t 子树的根结点
     * @return 含有最大值的结点
     */
    private Node<E> max(Node<E> t) {
        if (t != null)
            while (t.right != null)
                t = t.right;

        return t;
    }

    /**
     * 将元素插入子树
     *
     * @param e 要插入的元素
     * @param t 子树
     * @return 插入后子树的根结点
     */
    private Node<E> insert(E e, Node<E> t) {
        if (t == null)
            return new Node<>(e, null, null);

        int cmp = compare(e, t.element);

        if (cmp < 0)
            t.left = insert(e, t.left);
        else if (cmp > 0)
            t.right = insert(e, t.right);
        else
            ; // 重复值，什么也不做
        return t;
    }

    /**
     * 删除子树中的一个元素，删除策略：
     * 若结点是叶结点，直接删除；
     * 若结点有一个儿子，在其父结点调整自己的链以绕过该结点后被删除
     * 若结点有两个儿子，用其右子树的最小数据代替该结点的数据，并递归删除那个结点
     *
     * @param e 要删除的元素
     * @param t 子树的根结点
     * @return 删除后的子树的根结点
     */
    private Node<E> remove(E e, Node<E> t) {
        if (t == null)
            return t; // 未找到要删除的元素， 什么也不做

        int cmp = compare(e, t.element);

        if (cmp < 0)
            t.left = remove(e, t.left);
        else if (cmp > 0)
            t.right = remove(e, t.right);
        else if (t.left != null && t.right != null) { // 有两个儿子的情况
            t.element = min(t.right).element;
            t.right = remove(t.element, t.right);
        } else
            t = (t.left != null) ? t.left : t.right; // 叶结点和有一个儿子的情况
        return t;
    }
}

```

### BST存在的问题

上面的BST存在的问题是，由于删除操作时，总是用右子树的一个结点来代替删除的结点，这样会导致左子树比右子树深。一种新的树——平衡二叉查找树(Balanced BST)产生了。平衡树在插入和删除的时候，会通过旋转操作将高度保持在logN。其中两款具有代表性的平衡树分别为AVL树和红黑树。

## AVL树

AVL(Adelson-Velskii 和 Landis)树是带有平衡条件的二叉查找树，其每个结点的左子树和右子树的高度最多差1。

为了保持AVL树的平衡性，需要通过旋转来对树的结构进行修正。若把必须重新平衡的结点叫做$$\alpha$$，由于任意结点最多有两个儿子，因此出现高度不平衡就需要$$\alpha$$点的两棵子树的高度差2。可能有四种情况：

1. 对$$\alpha$$的左儿子的左子树进行一次插入
2. 对$$\alpha$$的左儿子的右子树进行一次插入
3. 对$$\alpha$$的右儿子的左子树进行一次插入
4. 对$$\alpha$$的右儿子的右子树进行一次插入

其中，情形1和4是关于$$\alpha$$点的镜像对称，而情形2和3是关于$$\alpha$$点的镜像对称。理论上只有两种情况：

+ 第一种情况发生在“外边”（左-左，或者右-右），该情形通过对树的一次单旋转(single rotation)完成调整
+ 第二种情况发生在“内部”（左-右，或者右-左），该情形通过对树的一次双旋转(double rotation)完成调整

### Java实现

```java
package dsa.collection;

import java.util.Comparator;

/**
 * Project: dsa
 * Author: tomoya
 * Date: 3/11/2018
 */
public class AVLTree<E> {
    /**
     * 静态内部类，定义树的结点
     */
    private static class Node<E> {
        E element; // 结点中的数据
        Node<E> left; // 左子结点
        Node<E> right; // 右子节点
        int height; // 高度

        Node(E element, Node<E> lt, Node<E> rt) {
            this.element = element;
            this.left = lt;
            this.right = rt;
            this.height = 0;
        }
    }

    private Node<E> root; // 根结点
    private final Comparator<? super E> comparator; // 比较器

    public AVLTree(Comparator<? super E> comparator) {
        this.root = null;
        this.comparator = comparator;
    }

    /*========================== 私有方法 ============================*/

    /**
     * 返回结点高度， 如果是null，高度为-1
     * @param t 结点
     * @return 结点高度
     */
    private int height(Node<E> t) {
        return t == null ? -1 : t.height;
    }

    /**
     * 比较方法
     *
     * @param l 前一个值
     * @param r 后一个值
     * @return 比较结果
     */
    private int compare(E l, E r) {
        if (comparator != null)
            return comparator.compare(l, r);
        return ((Comparable) l).compareTo(r);
    }

    /**
     * 找到子树中的最小值的结点（递归实现）
     *
     * @param t 子树的根结点
     * @return 含有最小值的结点
     */
    private Node<E> min(Node<E> t) {
        if (t == null)
            return null;
        else if (t.left == null)
            return t;
        return min(t);
    }

    /**
     * 找到子树中的最大值的结点（非递归实现）
     *
     * @param t 子树的根结点
     * @return 含有最大值的结点
     */
    private Node<E> max(Node<E> t) {
        if (t != null)
            while (t.right != null)
                t = t.right;

        return t;
    }

    /**
     * 将元素插入子树
     *
     * @param e 要插入的元素
     * @param t 子树
     * @return 插入后子树的根结点
     */
    private Node<E> insert(E e, Node<E> t) {
        if (t == null)
            return new Node<>(e, null, null);

        int cmp = compare(e, t.element);

        if (cmp < 0)
            t.left = insert(e, t.left);
        else if (cmp > 0)
            t.right = insert(e, t.right);
        else
            ; // 重复，什么也不做

        return balance(t);
    }

    /**
     * 删除子树中的一个元素，删除策略：
     * 若结点是叶结点，直接删除；
     * 若结点有一个儿子，在其父结点调整自己的链以绕过该结点后被删除
     * 若结点有两个儿子，用其右子树的最小数据代替该结点的数据，并递归删除那个结点
     * 删除完后，重新平衡树
     * 
     * @param e 要删除的元素
     * @param t 子树的根结点
     * @return 删除后的子树的根结点
     */
    private Node<E> remove(E e, Node<E> t) {
        if (t == null)
            return t;

        int cmp = compare(e, t.element);
        if (cmp < 0)
            t.left = remove(e, t.left);
        else if (cmp > 0)
            t.right = remove(e, t.right);
        else if (t.left != null && t.right != null) { // 有两个儿子的情形
            t.element = min(t.right).element;
            t.right = remove(t.element, t.right);
        } else
            t = (t.left != null) ? t.left : t.right; // 叶结点和有一个儿子的情况

        return balance(t);
    }

    private static final int ALLOWED_IMBALANCE = 1;

    /**
     * 重新平衡子树
     * @param t 子树的根结点
     * @return 平衡的子树
     */
    private Node<E> balance(Node<E> t) {
        if (t == null)
            return t;

        if (height(t.left) - height(t.right) > ALLOWED_IMBALANCE)
            if (height(t.left.left) >= height(t.left.right))
                t = rotateWithLeftChild(t);
            else
                t = doubleWithLeftChild(t);
        else if (height(t.right) - height(t.left) > ALLOWED_IMBALANCE)
            if (height(t.right.right) >= height(t.right.left))
                t = rotateWithRightChild(t);
            else
                t = doubleWithRightChild(t);

        t.height = Math.max(height(t.left), height(t.right)) + 1;

        return t;
    }

    /**
     * 左旋（对应左-左情形）
     * @param k2 待左旋的根结点
     * @return 旋转后的子树的根结点
     */
    private Node<E> rotateWithLeftChild(Node<E> k2) {
        Node<E> k1 = k2.left;
        k2.left = k1.right;
        k1.right = k2;
        k2.height = Math.max(height(k2.left), height(k2.right)) + 1;
        k1.height = Math.max(height(k1.left), k2.height) + 1;
        return k1;
    }

    /**
     * 右旋（对应右-右情形）
     * @param k1 待右旋的根结点
     * @return 旋转后的子树的根结点
     */
    private Node<E> rotateWithRightChild(Node<E> k1) {
        Node<E> k2 = k1.right;
        k1.right = k2.left;
        k2.left = k1;
        k1.height = Math.max(height(k1.left), height(k1.right)) + 1;
        k2.height = Math.max(k1.height, height(k2.right)) + 1;
        return k2;
    }

    /**
     * 双旋转（先右旋后左旋，对应左-右情形）
     * @param k3 待旋转的根结点
     * @return 旋转后的子树的根结点
     */
    private Node<E> doubleWithLeftChild(Node<E> k3) {
        k3.left = rotateWithRightChild(k3.left);
        return  rotateWithLeftChild(k3);
    }

    /**
     * 双旋转（先左旋后右旋，对应右-左情形）
     * @param k3 待旋转的根结点
     * @return 旋转后的子树的根结点
     */
    private Node<E> doubleWithRightChild(Node<E> k3) {
        k3.right = rotateWithLeftChild(k3.right);
        return  rotateWithRightChild(k3);
    }
}

```
