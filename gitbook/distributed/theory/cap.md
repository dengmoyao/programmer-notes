# CAP 理论

## 概述

CAP 理论： 一个分布式系统最多只能满足一致性(Consistency)、可用性(Availability)和分区容错性(Partition tolerance)这三项中的两项

### Consistency 一致性

一致性指 “all the node see the same data at the same time”，即更新操作成功并返回客户端完成后，所有节点在同一时间的数据完全一致，所以，一致性，说的是数据的一致性。

对于一致性，可以分为客户端和服务端两个视角来看：

+ 从客户端来看： 一致性主要指的是多并发访问时，更新过的数据如何获取的问题
+ 从服务端来看：更新如何复制分布到整个系统，以保证数据最终一致

三种一致性策略：

+ 对于关系性数据库，要求更新过的数据能被后续的访问都能看到，这是强一致性
+ 如果能容忍后续的部分或者全部访问不到，则是弱一致性
+ 如果要求一段时间后能访问到更新后的数据，则是最终一致性

### Availability 可用性

可用性指 “reads and writes always succeed”，即服务一致可用，而且是正常的响应时间。

一般在衡量一个系统可用性的时候，都是通过停机时间来计算的

### Partition Tolerance 分区容错性

分区容错性是指 “the system continues to operate despite arbitrary message loss or failure of part of the system”，即分布式系统在遇到某节点或者网络分区故障时，仍然能够对外提供满足一致性和可用性的服务。

## CAP 权衡
