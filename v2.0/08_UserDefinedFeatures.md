Slick 2.0.0 documentation - 08 User-Defined Features

[Permalink to User-Defined Features — Slick 2.0.0 documentation](http://slick.typesafe.com/doc/2.0.0/userdefined.html)

User-Defined Features
=====================

ここでは[Lifted Embedding](http://slick.typesafe.com/doc/2.0.0/introduction.html#lifted-embedding) APIにおいて、カスタムしたデータ型やデータベース関数をどのようにして用いるのか、についての説明を行う。

<!-- This chapter describes how to use custom data types and database -->
<!-- functions in the Lifted Embedding \<lifted-embedding\> API. -->

Scala Database functions
------------------------

もしデータベースシステムがSlickにおける関数として利用できないスカラー関数をサポートしていたのならば、それは`SimpleFunction`として別途定義する事が出来る。パラメータや返却型が固定されたunary, binary, ternaryな関数を生成するための関数が事前に用意されている。

<!-- If your database system supports a scalar function that is not available -->
<!-- as a method in Slick you can define it as a -->
<!-- scala.slick.lifted.SimpleFunction. There are predefined methods for -->
<!-- creating unary, binary and ternary functions with fixed parameter and -->
<!-- return types. -->

```scala
// H2 has a day_of_week() function which extracts the day of week from a timestamp
val dayOfWeek = SimpleFunction.unary[Date, Int]("day_of_week")
...
// Use the lifted function in a query to group by day of week
val q1 = for {
  (dow, q) <- salesPerDay.map(s => (dayOfWeek(s.day), s.count)).groupBy(_._1)
} yield (dow, q.map(_._2).sum)
```

より柔軟に型を取り扱いたいのなら、型の不定なインスタンスを取得し、適切な型チェックを行う独自のラッパー関数を書くために`SimpleFunction.apply`を用いる事ができる。

<!-- If you need more flexibility regarding the types (e.g. for varargs, -->
<!-- polymorphic functions, or to support Option and non-Option types in a -->
<!-- single function), you can use `SimpleFunction.apply` to get an untyped -->
<!-- instance and write your own wrapper function with the proper -->
<!-- type-checking: -->

```scala
def dayOfWeek2(c: Column[Date]) =
  SimpleFunction[Int]("day_of_week").apply(Seq(c))
```

[SimpleBinaryOperator](http://slick.typesafe.com/doc/2.0.0/api/#scala.slick.lifted.SimpleBinaryOperator)や[SimpleLiteral](http://slick.typesafe.com/doc/2.0.0/api/#scala.slick.lifted.SimpleLiteral)も同様に扱う事ができる。より柔軟なものを求めるのならば、[SimpleExpression](http://slick.typesafe.com/doc/2.0.0/api/#scala.slick.lifted.SimpleExpression)を使うと良い。

<!-- scala.slick.lifted.SimpleBinaryOperator and -->
<!-- scala.slick.lifted.SimpleLiteral work in a similar way. For even more -->
<!-- flexibility (e.g. function-like expressions with unusual syntax), you -->
<!-- can use scala.slick.lifted.SimpleExpression. -->

Other Database functions and stored procedures
----------------------------------------------

完全なテーブル(complete tables)やストアドプロシージャを返却するデータベース関数を扱うのならば、[Plain SQL Queries](http://slick.typesafe.com/doc/2.0.0/sql.html)を使えば良い。複数の結果を返却するストアドプロシージャは現在サポートしていない。

<!-- For database functions that return complete tables or stored procedures -->
<!-- please use sql. Stored procedures that return multiple result sets are -->
<!-- currently not supported. -->

Scalar Types
------------

もしカスタムされたカラムが必要ならば、[ColumnType](http://slick.typesafe.com/doc/2.0.0/api/#scala.slick.driver.JdbcProfile@ColumnType[T]:JdbcDriver.ColumnType[T])を実装する事で扱える。最も一般的な利用法として、アプリケーション固有な型をデータベースに存在している型へとマッピングする事などが挙げられる。これは[MappedColumnType](http://slick.typesafe.com/doc/2.0.0/api/#scala.slick.driver.JdbcProfile@MappedColumnType:JdbcDriver.MappedJdbcType.type)を用いることでよりシンプルに書ける。

<!-- If you need a custom column type you can implement -->
<!-- ColumnType \<scala.slick.driver.JdbcProfile@ColumnType[T]:JdbcDriver.ColumnType[T]\>. -->
<!-- The most common scenario is mapping an application-specific type to an -->
<!-- already supported type in the database. This can be done much simpler by -->
<!-- using -->
<!-- MappedColumnType \<scala.slick.driver.JdbcProfile@MappedColumnType:JdbcDriver.MappedJdbcType.type\> -->
<!-- which takes care of all the boilerplate: -->

```scala
// An algebraic data type for booleans
sealed trait Bool
case object True extends Bool
case object False extends Bool
...
// And a ColumnType that maps it to Int values 1 and 0
implicit val boolColumnType = MappedColumnType.base[Bool, Int](
  { b => if(b == True) 1 else 0 },    // map Bool to Int
  { i => if(i == 1) True else False } // map Int to Bool
)
...
// You can now use Bool like any built-in column type (in tables, queries, etc.)
```

より柔軟なものを用いたいのならば、[MappedjdbcType](http://slick.typesafe.com/doc/2.0.0/api/#scala.slick.driver.JdbcProfile@MappedJdbcType)のサブクラスを用いれば良い。

<!-- You can also subclass -->
<!-- MappedJdbcType \<scala.slick.driver.JdbcProfile@MappedJdbcType\> for a -->
<!-- bit more flexibility. -->

もしある型を基礎とした独自のラッパークラスを持っているなら、マクロで生成された暗黙的な`ColumnType`を自由に取得するために、そのクラスを[MappedTo](http://slick.typesafe.com/doc/2.0.0/api/#scala.slick.lifted.MappedTo)へと拡張させれる。そのようなラッパークラスは一般的に型安全でテーブル固有な主キー型のために用いられる。

<!-- If you have a wrapper class (which can optionally be a case class and/or -->
<!-- value class) for an underlying value of some supported type, you can -->
<!-- make it extend scala.slick.lifted.MappedTo to get a macro-generated -->
<!-- implicit `ColumnType` for free. Such wrapper classes are commonly used -->
<!-- for type-safe table-specific primary key types: -->

```scala
// A custom ID type for a table
case class MyID(value: Long) extends MappedTo[Long]
...
// Use it directly for this table's ID -- No extra boilerplate needed
class MyTable(tag: Tag) extends Table[(MyID, String)](tag, "MY_TABLE") {
  def id = column[MyID]("ID")
  def data = column[String]("DATA")
  def * = (id, data)
}
```

Record Types
------------

レコード型は個別に宣言された型を持つ複数の混合物を含んだデータ構造となっている。 Slickは(引数限度が22の)ScalaタプルとSLick独自の実験的な実装である*HList*(引数制限が無いが、25個の引数を超えると異様にコンパイルが遅くなるもの)をサポートしている。レコード型はSlickにおいて恣意的にネストされ、混合されたものとして扱われている。

<!-- Record types are data structures containing a statically known number of -->
<!-- components with individually declared types. Out of the box, Slick -->
<!-- supports Scala tuples (up to arity 22) and Slick's own experimental -->
<!-- scala.slick.collection.heterogenous.HList implementation (without any -->
<!-- size limit, but currently suffering from long compilation times for -->
<!-- arities \> 25). Record types can be nested and mixed arbitrarily in -->
<!-- Slick. -->

もし柔軟性を必要とするなら、暗黙的な[Shape](http://slick.typesafe.com/doc/2.0.0/api/#scala.slick.lifted.Shape)定義を行う事で、独自のものをサポートする事が出来る。`Pair`を用いた例は以下のようになる。

<!-- If you need more flexibility, you can add support for your own by -->
<!-- defining an implicit scala.slick.lifted.Shape definition. Here is an -->
<!-- example for a type `Pair`: -->

```scala
// A custom record class
case class Pair[A, B](a: A, b: B)
```

レコード型のための`Scape`の実装は[MappedScaleProductShape](http://slick.typesafe.com/doc/2.0.0/api/#scala.slick.lifted.MappedScalaProductShape)を拡張する事で行う。一般的にこの実装はシンプルになるが、全ての型に関連するボイラープレートをいくつか必要とする。`MappedScaleProductShape`は要素に対するShapeの配列を引数に取り、`buildValue`(与えられた要素からレコード型のインスタンスを作成するもの)や`copy`(この`Shape`をコピーして新しい`Shape`を作るもの)オペレーションを提供する。

<!-- `Shape` implementations for record types extend -->
<!-- scala.slick.lifted.MappedScalaProductShape. They are are generally very -->
<!-- simple but they require some boilerplate for all the types involved. A -->
<!-- `MappedScalaProductShape` takes a sequence of Shapes for its elements -->
<!-- and provides the operations `buildValue` (for creating an instance of -->
<!-- the record type given its elements) and `copy` (for creating a copy of -->
<!-- this `Shape` with new element Shapes): -->

```scala
// A Shape implementation for Pair
final class PairShape[Level <: ShapeLevel, M <: Pair[_,_], U <: Pair[_,_], P <: Pair[_,_]](
  val shapes: Seq[Shape[_, _, _, _]])
extends MappedScalaProductShape[Level, Pair[_,_], M, U, P] {
  def buildValue(elems: IndexedSeq[Any]) = Pair(elems(0), elems(1))
  def copy(shapes: Seq[Shape[_, _, _, _]]) = new PairShape(shapes)
}
...
implicit def pairShape[Level <: ShapeLevel, M1, M2, U1, U2, P1, P2](
  implicit s1: Shape[_ <: Level, M1, U1, P1], s2: Shape[_ <: Level, M2, U2, P2]
) = new PairShape[Level, Pair[M1, M2], Pair[U1, U2], Pair[P1, P2]](Seq(s1, s2))
```

この例では、暗黙的な関数である`pairShape`が、2つの要素型を取る`Pair`のためのShapeを提供している。

<!-- The implicit method `pairShape` in this example provides a Shape for a -->
<!-- `Pair` of two element types whenever Shapes for the inidividual element -->
<!-- types are available. -->

これらの定義を用いて、タプルや`HList`を用いる事の出来るどんな場所においてでも`Pair`のレコード型を用いる事が出来る。

<!-- With these definitions in place, we can use the `Pair` record type in -->
<!-- every location in Slick where a tuple or `HList` would be acceptable: -->

```scala
// Use it in a table definition
class A(tag: Tag) extends Table[Pair[Int, String]](tag, "shape_a") {
  def id = column[Int]("id", O.PrimaryKey)
  def s = column[String]("s")
  def * = Pair(id, s)
}
val as = TableQuery[A]
as.ddl.create
...
// Insert data with the custom shape
as += Pair(1, "a")
as += Pair(2, "c")
as += Pair(3, "b")
...
// Use it for returning data from a query
val q2 = as
  .map { case a => Pair(a.id, (a.s ++ a.s)) }
  .filter { case Pair(id, _) => id =!= 1 }
  .sortBy { case Pair(_, ss) => ss }
  .map { case Pair(id, ss) => Pair(id, Pair(42 , ss)) }
```
