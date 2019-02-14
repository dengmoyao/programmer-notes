# Spring 常见问题

### Spring 基础

#### 谈谈Spring框架，以及使用Spring带来的好处

Spring是一个开源框架，用于简化Java企业级应用开发。提供了依赖注入，面向切面编程，事务管理，Web应用，数据访问，消息以及测试等功能。

使用Spring主要是可以简化Java应用开发，比如

+ Spring提供IoC容器，可以通过依赖注入更方便实现松散耦合；
+ Spring支持面向切面编程，这样能把应用业务逻辑和系统服务分开，让开发者聚焦业务；

#### BeanFactory 和 ApplicationContext 有什么区别，ApplicationContext有哪些常用实现类

BeanFactory 是Spring 中 Bean工厂的顶级接口，具有bean定义、bean关联关系设置，根据请求分发bean的功能；

ApplicationContext 继承了 BeanFactory，在 BeanFactory 的基础上增加一些功能，主要包括：

+ 提供国际化的消息访问
+ 统一的资源文件读取方式
+ 事件传播

ApplicationContext 几个常用的实现类：

+ ClassPathXmlApplicationContext: 类路径加载
+ FileSystemXmlApplicationContext: 文件系统路径加载
+ AnnotationConfigApplicationContext: 用于基于注解的配置
+ WebApplicationContext: 专门为web应用准备的，从相对于Web根目录的路径中装载配置文件完成初始化。

#### Spring有几种配置方式

将Spring配置到应用开发中有以下三种方式(不冲突，可搭配使用)：

+ 基于XML的配置
+ 基于注解的配置
+ 基于Java的配置

#### Spring框架中有哪些不同类型的事件

Spring ApplicationContext 提供了支持事件和代码中监听器的功能

+ 上下文更新事件（ContextRefreshedEvent）：该事件会在ApplicationContext被初始化或者更新时发布。也可以在调用ConfigurableApplicationContext 接口中的refresh()方法时被触发。
+ 上下文开始事件（ContextStartedEvent）：当容器调用 ConfigurableApplicationContext 的Start()方法开始/重新开始容器时触发该事件。
+ 上下文停止事件（ContextStoppedEvent）：当容器调用 ConfigurableApplicationContext 的Stop()方法停止容器时触发该事件。
+ 上下文关闭事件（ContextClosedEvent）：当ApplicationContext被关闭时触发该事件。容器被关闭时，其管理的所有单例Bean都被销毁。
+ 请求处理事件（RequestHandledEvent）：在Web应用中，当一个http请求（request）结束触发该事件。

### Spring IoC

#### :star2: 什么是控制反转，什么是依赖注入，什么是Spring IoC 容器？

IoC,即控制反转，是一种软件设计思想，用于解决对象之间耦合度过高的问题。IoC的主要思想是借助“第三方”来实现具有依赖关系的对象之间的解耦。反转，转移的是创建对象的主动权，即针对所依赖的对象，不再自己new，而是转移到“第三方”，也是IoC容器来统一进行装配和管理。

Spring IoC的实现原理主要是：反射 + 工厂模式。IoC容器可以看成是一个高级工厂，工厂生成的对象在配置文件中定义，然后再利用反射根据配置文件中的类名来生成相应的对象。

#### 依赖注入的方式有哪些，怎么选择？

+ 构造器依赖注入
+ Setter注入

用构造器参数实现强制依赖，setter方法实现可选依赖。

#### :star2: Spring Bean 的生命周期

简单来说，Bean的生命周期就是Bean从初始化到被使用，再到被销毁的过程。

1. 首先是进行实例化，就是根据Bean定义实例化出一个对象来，并通过BeanWrapper进行包装
2. 然后是依赖注入Bean的属性，这儿是借助BeanWrapper提供的方法来操作Bean的
3. 接下来是对Bean进行初始化，初始化就是调用各种实例化后置方法，包括各种Aware接口方法，BeanPostProcessor的方法，以及init方法
4. 完成Bean的初始化后，会按需注册一些Bean销毁的前置方法
5. 到这一步，Bean就已经准备就绪可以使用了
6. 对于prototype的Bean，Spring便不再管理它的生命周期了，但对于singleton的Bean，会一直驻留在Spring容器中，直到容器关闭。并且，Spring 会在容器关闭时调用Bean的销毁前置方法

#### Spring Bean 的作用域是什么， 有哪些

在Spring容器中是指其创建的Bean对象相对于其他Bean对象的请求可见范围，Spring一共提供了5种作用域类型：

+ singleton：这种bean范围是默认的，这种范围确保不管接受到多少个请求，每个容器中只有一个bean的实例，单例的模式
+ prototype：原形范围与单例范围相反，为每一个bean请求提供一个实例
+ request：每次http请求都会创建一个bean，该作用域仅在基于web的ApplicationContext情形下有效
+ session：在一个HTTP Session中，一个bean定义对应一个实例。该作用域仅在基于web的ApplicationContext情形下有效
+ global-session：在一个全局的HTTP Session中，一个bean定义对应一个实例。该作用域仅在基于web的ApplicationContext情形下有效。

#### 自动装配模式的区别

在Spring框架中共有5种自动装配：

+ no: 默认的方式是不进行自动装配，通过显式设置ref 属性来进行装配
+ byName: 通过参数名 自动装配
+ byType: 通过参数类型自动装配
+ constructor: 这个方式类似于byType， 但是要提供给构造器参数
+ autodetect：首先尝试使用constructor来自动装配，如果无法工作，则使用byType方式

#### Spring 的 BeanPostProcessor接口起到什么作用？

BeanPostProcessor 接口的作用是在Spring完成实例化后，对Spring容器实例化的Bean添加一些自定义的逻辑。其作用域是容器级的，会对该容器中的每个Bean做处理。

BeanPostProcessor 接口定义了两个方法，分别在Bean初始化的前后进行调用。包括基于注解的配置，AOP等都是基于实现BeanPostProcessor的接口或者子接口来搞定的。

#### Spring 的循环依赖是什么？ 怎么解决的？

循环依赖就是循环引用，也就是两个或者两个以上的bean相互持有对方的引用，最终形成闭环。Spring的循环依赖包括构造器循环依赖和setter循环依赖，Spring只解决了singleton的setter循环依赖，singleton的构造器依赖和prototype循环依赖后会抛出BeanCurrentlyInCreatingException。

Spring循环依赖的理论依据其实是基于Java的引用传递，当我们获取到对象的引用时，对象的field或属性是可以延迟设置的(但是构造器必须是在获取引用之前)

Spring为了解决单例的循环依赖问题，使用了三级缓存：

1. singletonObjects： 单例对象的cache
2. earlySingletonObjects： 提前曝光的单例对象的cache
3. singletonFactories： 单例对象工厂的cache

### Spring AOP

#### :star2: 解释一下AOP？ Spring AOP的原理？

AOP，即面向切面编程， 可以算是对OOP的一种补充。当需要为多个不具有继承关系的对象引入同一个公共行为时，例如记录日志，安全校验等，就可以使用AOP来避免再程序中引入大量的重复的代码。

Spring AOP 框架主要要实现：

1. 找到指定的引入公共行为的位置： 这一步的实现基础是Spring IoC
2. 完成公共行为的织入： 这一步是利用了动态代理

#### :star2: JDK动态代理和CGLib动态代理区别

JDK动态代理只能为接口创建动态代理实例，而不能对类创建动态代理。CGLib能够对类创建动态代理。

JDK动态代理是由Java内部的反射机制来实现的。CGLib动态代理需要依赖ASM包，把被代理对象类的class文件加载进来，修改其字节码生成子类。

JDK动态代理使用方法和CGLib使用方法：

TODO

#### AOP术语详解

+ __连接点(JoinPoint)__: 程序执行的某个特定位置，如类开始初始化前、类初始化后、类某个方法调用前、调用后、方法抛出异常后。这些代码中的特定点，称为“连接点”。Spring仅支持方法的连接点，即仅能在方法调用前、方法调用后、方法抛出异常时以及方法调用前后这些程序执行点织入增强。

+ __切点(Pointcut)__: AOP通过“切点”定位特定的连接点，即筛选出来的一组连接点。用数据库类比： 连接点相当于数据库中的记录，而切点相当于查询条件

+ __增强/通知(Advice)__: 增强是织入到目标类连接点上的一段程序代码，比如日志记录，安全控制

+ __目标对象(Target)__: 增强逻辑的织入目标类

+ __织入(Weaving)__: 织入是将增强添加到目标类具体连接点(切点)上的过程，Spring采用动态代理织入，AspectJ采用编译期织入和类装载期织入

+ __切面(Aspect)__: 切面由切点和增强组成，它既包括了横切逻辑的定义，也包括了连接点的定义，Spring AOP就是负责实施切面的框架，它将切面所定义的横切逻辑织入到切面所指定的连接点中。

#### Spring AOP 切点表达式

+ execution: 匹配连接点的执行方法
+ args(): 限制连接点匹配参数为执行类型的执行方法
+ @args(): 限制连接点匹配参数由执行注解标注的执行
+ target() 限制连接点匹配目标对象为指定类型的类
+ @target(): 限制连接点匹配目标对象被指定的注解标注的类
+ within(): 限制连接点匹配匹配指定的类型
+ @within(): 限制连接点匹配指定注解标注的类型

#### Spring AOP 通知类型

+ @Before：前置通知，在一个方法执行前被调用。
+ @After: 在方法执行之后调用的通知，无论方法执行是否成功。
+ @AfterReturning: 仅当方法成功完成后执行的通知。
+ @AfterThrowing: 在方法抛出异常退出时执行的通知。
+ @Around: 在方法执行之前和之后调用的通知。

### Spring 其他

#### Spring 是怎么管理事务的？

Spring 提供了统一一致的事务抽象，无论是全局事务还是本地事务，JTA，JDBC，Hibernate 还是 JPA，Spring 都使用统一的编程模型，使得应用程序可以很容易在全局事务与本地事务，或者不同的事务框架之间切换。

PlatformTransactionManager 接口定义了事务操作行为，具体的事务处理交由子类去实现。TransactionDefinition 接口为事务属性定义，主要包括传播属性、隔离级别、超时时间和是否只读等。而 TransactionStatus 接口则是当前事务状态。

Spring 事务注解本质上在事务方法上加入一个Around切面，在方法开始之前开始事务，在方法结束之后提交事务或者在抛出异常后回滚事务。

#### :star2: Spring 框架中使用了哪些设计模式

+ 工厂模式： BeanFactory用来创建对象的实例
+ 单例模式： Spring 下默认的bean均为 singleton
+ 代理模式： Spring AOP 中 Jdk 动态代理就是利用代理模式技术实现的
+ 策略模式： Spring 的代理方式有两个 Jdk 动态代理和 CGLIB 代理。这两个代理方式的使用正是使用了策略模式
+ 模板方法:  用来解决代码重复的问题。比如 RestTemplate, JpaTemplate
