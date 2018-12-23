# MyBatis 基础

## 架构篇

MyBatis的整体架构：

![](img/mybaits.png)

## 配置解析篇

解析两种配置文件： 配置文件和Mapper文件

### 流程

1. 调用 `SqlSessionFactoryBuilder.build()` 来生成 `SqlSessionFactory`
2. `SqlSessionFactoryBuilder` 会调用 `XMLConfigBuilder.parse()` 来生成 `Configuration`
3. `Mapper` 文件的解析委托给 `XMLMapperBuilder` 来完成的
4. `Mapper` 文件中的 Statement 部分的解析委托给 `XMLStatementBuilder` 来完成的

配置解析过程就是将配置文件解析为 `Configuration` 对象，在整个生命周期可以通过该对象获取配置

## SQL执行篇

### 关键对象

+ `MappedStatement`: 保存Mapper的一个节点，包括配置的SQL、SQL的id、缓存信息、resultMap、parameterMap和resultType
+ `SqlSource`： 是 `MappedStatement` 的一个属性，主要作用是根据参数和其他规则组装SQL
+ `BoundSql`： 对于参数和sql，主要反映在 `BoundSql` 对象上

### Mapper 接口调用过程

1. 配置解析阶段，读取 `Mapper` 的XML文件，完成 `MapperProxyFactory` 注册到 `MapperRegistry`。`Mapper` 的XML文件的命名空间对应的就是整个接口的全路径名，根据全路径名和方法名，便能够将接口和 `Mapper` 文件绑定起来。

2. 获取 `Mapper` 阶段，实际上获取的是 `mapperProxyFactory.newInstance()` 创建的动态代理对象。

3. 调用 Mapper 接口的某个方法时，其实调用的是 `MapperProxy#invoke` 方法。根据方法名，定位到sql，最后使用SqlSession的接口方法来执行查询。

### SqlSession 下重要对象

+ Executor： 执行器，具体的查询动作委托给执行器
+ StatementHandler： 使用数据库的Statement执行操作
+ ParameterHandler： 用于SQL参数处理
+ ResultHandler: 用于最后数据集的封装返回处理

## 缓存篇

### 一级缓存

每个 `SqlSession` 中持有了 `Executor`， 每个 `Executor` 中有一个 `LocalCache`

+ 一级缓存的生命周期和 `SqlSession` 一致
+ 一级缓存是一个没有容量限定的HashMap， key为CacheKey(Statement id, offset, limit, sql, params)
+ 一级缓存最大范围是 `SqlSession` 内部，有多个 `SqlSession` 或者分布式的环境下，数据的操作会引起脏数据

### 二级缓存

开启二级缓存后，会使用 `CachingExecutor` 装饰 `Executor`，在进入一级缓存的流程前，先在 `CachingExecutor` 中进行二级缓存的查询

二级缓存的作用域是 namespace