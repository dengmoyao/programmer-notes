# MyBatis 常见问题

### MyBatis 基础

#### MyBatis 有哪些优点，解决了什么问题

+ 将SQL语句配置在mapper.xml文件中与java代码分离，便于统一管理和优化
+ 提供映射标签，支持对象与数据库的orm字段关系映射
+ 提供xml标签，支持编写动态sql（主要优势之一），(if, choose, trim, foreach)

#### MyBatis 中 #{} 和 ${} 区别

是Mybatis中两种占位符：

+ `#{}`解析传递进来的参数数据，是预编译处理；
+ `${}`对传递进来的参数原样拼接在SQL中，是字符串替换

使用#{}可以有效的防止SQL注入，提高系统安全性

#### 当实体类中的属性名和表中的字段名不一样，如何处理

有两种解决办法：

+ 在SQL语句中定义别名
+ 在resultMap 中配置字段名和实体类属性名的映射关系

#### Mybatis动态sql是做什么的，有哪些

Mybatis动态sql可以让我们在Xml映射文件内，以标签的形式编写动态sql，完成逻辑判断和动态拼接sql的功能

主要有以下几种:

+ if
+ choose(搭配 when, otherwise 使用)
+ trim (where, set 自带trim功能，可以自定义trim)
+ foreach

其执行原理为，使用OGNL从sql参数对象中计算表达式的值，根据表达式的值动态拼接sql，以此来完成动态sql的功能

#### MyBatis 缓存

MyBatis 支持一级缓存和二级缓存：

+ 一级缓存，其存储作用域是Session，一级缓存采用 PerpetualCache，HashMap存储，(CacheKey 包含 Statement Id + Offset + Limmit + Sql + Params)
+ 二级缓存，其存储作用为Mapper(Namespace)，是跨Session的，默认也是PerpetualCache，但可以自定义数据源

对于缓存数据更新机制，当某一个作用域(一级缓存Session/二级缓存Namespaces)的进行了 C/U/D 操作后，默认该作用域下所有 select 中的缓存将被clear。