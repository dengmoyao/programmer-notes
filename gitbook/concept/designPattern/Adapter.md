# 适配器模式

## 类图

{% plantuml %}
interface Target
class Adaptee
class Adapter

Adaptee <|-- Adapter
Target <|.. Adapter
{% endplantuml %}

*plantuml*

```plantuml
interface Target
class Adaptee
class Adapter

Adaptee <|-- Adapter
Target <|.. Adapter
```

各角色描述如下：

+ Target: 目标接口，所要转换的所期待的接口
+ Adaptee： 源角色，需要适配的接口
+ Adapter： 适配器，将源接口适配成目标接口，继承源接口，实现目标接口
