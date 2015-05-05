Slick 3.0.0 documentation - 09 User-Defined Features

[Permalink to User-Defined Features — Slick 3.0.0 documentation](http://slick.typesafe.com/doc/3.0.0/userdefined.html)

ユーザ定義機能
=====================

本章では、どのようにしてカスタマイズしたデータ型をSlickのScala APIを通して利用するのか、ということについて説明する。
<!-- This chapter describes how to use custom data types and database functions with Slick's Scala API.  -->

Scalar Database Functions
-------------------------

もしデータベースシステムがSlickで利用できないメソッドを関数としてサポートしているのならば、[SimpleFunction](http://slick.typesafe.com/doc/3.0.0/api/index.html#slick.lifted.SimpleFunction)を通してその関数を利用することが出来る。固定されたパラメータと返り値を用いる1つ・2つ・3つ組といった関数が様々なデータベースに存在している。
<!-- If your database system supports a scalar function that is not available as a method in Slick you can define it as a slick.lifted.SimpleFunction. There are predefined methods for creating unary, binary and ternary functions with fixed parameter and return types. -->

```scala
// H2データベースでは day_of_week() 関数により、timestampから曜日を取得することが出来る
val dayOfWeek = SimpleFunction.unary[Date, Int]("day_of_week")
...
// 曜日別にグループ化したクエリを用いたクエリは以下のようになる
val q1 = for {
  (dow, q) <- salesPerDay.map(s => (dayOfWeek(s.day), s.count)).groupBy(_._1)
} yield (dow, q.map(_._2).sum)
```

もっと柔軟に型を変形したい場合（複数引数であったり、OptionとNon-Optionの型を使い分けたい）などには、`SimpleFunction.apply`を使って、適切な型チェックを行うラッパー関数を書く事が出来る。
<!-- If you need more flexibility regarding the types (e.g. for varargs, polymorphic functions, or to support Option and non-Option types in a single function), you can use `SimpleFunction.apply` to get an untyped instance and write your own wrapper function with the proper type-checking:  -->

```scala
def dayOfWeek2(c: Rep[Date]) =
  SimpleFunction[Int]("day_of_week").apply(Seq(c))
```

[SimpleBinaryOperator](http://slick.typesafe.com/doc/3.0.0/api/index.html#slick.lifted.SimpleBinaryOperator)と[SimpleLiteral](http://slick.typesafe.com/doc/3.0.0/api/index.html#slick.lifted.SimpleLiteral)も同じように扱うことが出来る。もっと柔軟な操作を行いたい場合には、[SimpleExpression](http://slick.typesafe.com/doc/3.0.0/api/index.html#slick.lifted.SimpleExpression)を用いると良い。
<!-- slick.lifted.SimpleBinaryOperator and slick.lifted.SimpleLiteral work in a similar way. For even more flexibility (e.g. function-like expressions with unusual syntax), you can use slick.lifted.SimpleExpression.  -->

```scala
val current_date = SimpleLiteral[java.sql.Date]("CURRENT_DATE")
salesPerDay.map(_ => current_date)
```

Other Database Functions And Stored Procedures
----------------------------------------------

全てのテーブルを返すようなデータベースの関数を利用したり、ストアドプロシージャを用いたいといった場合には、[Plain SQLクエリ](http://slick.typesafe.com/doc/3.0.0/sql.html)を用いて欲しい。
<!-- For database functions that return complete tables or stored procedures please use sql. Stored procedures that return multiple result sets are currently not supported.  -->

Using Custom Scalar Types in Queries
------------------------------------

もしカラムに対しカスタマイズした型を適用したいのなら、[ColumnType](http://slick.typesafe.com/doc/3.0.0/api/index.html#slick.driver.JdbcProfile@ColumnType[T]:JdbcDriver.ColumnType[T])を実装して欲しい。アプリケーション特有の型を、データベースにおいて既にサポートされた型へマッピングする事はよくある事例だろう。これを実現するには、[MappedColumnType](http://slick.typesafe.com/doc/3.0.0/api/index.html#slick.driver.JdbcProfile@MappedColumnType:JdbcDriver.MappedJdbcType.type)を用いて、これに対するボイラープレートを実装するだけで済む。これはドライバをimportする中に含まれており、[JdbcDriver](http://slick.typesafe.com/doc/3.0.0/api/index.html#slick.driver.JdbcDriver\$)のシングルトンオブジェクトから別途importしなくても良い。
<!-- If you need a custom column type you can implement ColumnType \<slick.driver.JdbcProfile@ColumnType[T]:JdbcDriver.ColumnType[T]\>. The most common scenario is mapping an application-specific type to an already supported type in the database. This can be done much simpler by using MappedColumnType \<slick.driver.JdbcProfile@MappedColumnType:JdbcDriver.MappedJdbcType.type\> which takes care of all the boilerplate. It comes with the usual import from the driver. Do not import it from the JdbcDriver \<slick.driver.JdbcDriver\$\> singleton object.  -->

```scala
// booleanの代数的表現
sealed trait Bool
case object True extends Bool
case object False extends Bool
...
// BoolをIntの1と0にマッピングするためのColumnType
implicit val boolColumnType = MappedColumnType.base[Bool, Int](
  { b => if(b == True) 1 else 0 },    // map Bool to Int
  { i => if(i == 1) True else False } // map Int to Bool
)
...
// この状態で、Boolをビルトインされた型としてテーブルやクエリで利用出来る。
```

[MappedJdbcType](http://slick.typesafe.com/doc/3.0.0/api/index.html#slick.driver.JdbcProfile@MappedJdbcType)を使うと、もっと柔軟なマッピングが行える。
<!-- You can also subclass MappedJdbcType \<slick.driver.JdbcProfile@MappedJdbcType\> for a bit more flexibility.  -->

もし既にサポートされた型のラッパークラス（ケースクラスやバリュークラスになりえるもの）があるのなら、マクロで生成される暗黙的な`ColumnType`を自由に取得出来る[MappedTo](http://slick.typesafe.com/doc/3.0.0/api/index.html#slick.lifted.MappedTo)を継承したものを利用する。そのようなラッパークラスは一般的に、型安全でテーブル特有な主キーの型に用いられる。
<!-- If you have a wrapper class (which can optionally be a case class and/or value class) for an underlying value of some supported type, you can make it extend slick.lifted.MappedTo to get a macro-generated implicit `ColumnType` for free. Such wrapper classes are commonly used for type-safe table-specific primary key types:  -->

```scala
// カスタマイズされたテーブルのID型
case class MyID(value: Long) extends MappedTo[Long]
...
// MyIDをテーブルのID型としてそのまま用いる -- 特別なボイラープレートは必要ない
class MyTable(tag: Tag) extends Table[(MyID, String)](tag, "MY_TABLE") {
  def id = column[MyID]("ID")
  def data = column[String]("DATA")
  def * = (id, data)
}
```

Using Custom Record Types in Queries
------------------------------------

レコード型は、個々に宣言された型のコンポーネントをいくつか含んだデータ構造として表される。SlickはScalaのタプルをサポートしている以外にも、22個より大きい数のカラム数に対応するためにSlick独自に[HList](http://slick.typesafe.com/doc/3.0.0/api/index.html#slick.collection.heterogeneous.HList)というものを用意している。
<!-- Record types are data structures containing a statically known number of components with individually declared types. Out of the box, Slick supports Scala tuples (up to arity 22) and Slick's own slick.collection.heterogeneous.HList implementation. Record types can be nested and mixed arbitrarily.  -->

カスタマイズされたレコード型（ケースクラス、カスタマイズされたHLists、タプルに似た型など...）を用いるために、Slickに対しどのようにしてクエリと結果型をマッピングするのかというのを伝える必要がある。これに対しては、[MappedScalaProductShape](http://slick.typesafe.com/doc/3.0.0/api/index.html#slick.lifted.MappedScalaProductShape)を継承した[Shape](http://slick.typesafe.com/doc/3.0.0/api/index.html#slick.lifted.Shape)を用いると良い。
<!-- In order to use custom record types (case classes, custom HLists, tuple-like types, etc.) in queries you need to tell Slick how to map them between queries and results. You can do that using a slick.lifted.Shape extending slick.lifted.MappedScalaProductShape.  -->

### Polymorphic Types (e.g. Custom Tuple Types or HLists)

ポリモーフィックなレコード型は、は要素となる型を抽象化する。つまりここでは、持ち上げられた要素の型と生の要素の型の双方で同じレコード型を用いることが出来るようになる。カスタマイズしたポリモーフィックなレコード型を利用するには、適切な暗黙的[Shape](http://slick.typesafe.com/doc/3.0.0/api/index.html#slick.lifted.Shape)を用意してあげたら良い。
<!-- The distinguishing feature of a *polymorphic* record type is that it abstracts over its element types, so you can use the same record type for both, lifted and plain element types. You can add support for custom polymorphic record types using an appropriate implicit slick.lifted.Shape.  -->

`Pair`というクラスを使う例は以下のようになる。
<!-- Here is an example for a type `Pair`:  -->

```scala
// カスタマイズされたレコード型
case class Pair[A, B](a: A, b: B)
...
// PairのためのShape実装
final class PairShape[Level <: ShapeLevel, M <: Pair[_,_], U <: Pair[_,_] : ClassTag, P <: Pair[_,_]](
  val shapes: Seq[Shape[_, _, _, _]])
extends MappedScalaProductShape[Level, Pair[_,_], M, U, P] {
  def buildValue(elems: IndexedSeq[Any]) = Pair(elems(0), elems(1))
  def copy(shapes: Seq[Shape[_ <: ShapeLevel, _, _, _]]) = new PairShape(shapes)
}
...
implicit def pairShape[Level <: ShapeLevel, M1, M2, U1, U2, P1, P2](
  implicit s1: Shape[_ <: Level, M1, U1, P1], s2: Shape[_ <: Level, M2, U2, P2]
) = new PairShape[Level, Pair[M1, M2], Pair[U1, U2], Pair[P1, P2]](Seq(s1, s2))
```

この例における暗黙的なメソッドである`pairShape`は、2つの要素型を持つ`Pair`のためのShapeを提供している（個々の要素型のためのShapeは、いつでも利用可能となる）。
<!-- The implicit method `pairShape` in this example provides a Shape for a `Pair` of two element types whenever Shapes for the individual element types are available.  -->

これらの定義を用いれば、Slickを利用するどの場所においても`Pair`をレコード型として利用出来る。
<!-- With these definitions in place, we can use the `Pair` record type in every location in Slick where a tuple or `HList` would be acceptable:  -->

```scala
// テーブル定義にPairを利用する
class A(tag: Tag) extends Table[Pair[Int, String]](tag, "shape_a") {
  def id = column[Int]("id", O.PrimaryKey)
  def s = column[String]("s")
  def * = Pair(id, s)
}
val as = TableQuery[A]
...
// カスタマイズされた型のデータを挿入する
val insertAction = DBIO.seq(
  as += Pair(1, "a"),
  as += Pair(2, "c"),
  as += Pair(3, "b")
)
...
// クエリからPairを返却してもらう
val q2 = as
  .map { case a => Pair(a.id, (a.s ++ a.s)) }
  .filter { case Pair(id, _) => id =!= 1 }
  .sortBy { case Pair(_, ss) => ss }
  .map { case Pair(id, ss) => Pair(id, Pair(42 , ss)) }
// returns: Vector(Pair(3,Pair(42,"bb")), Pair(2,Pair(42,"cc")))
```

### Monomorphic Case Classes

カスタマイズされたケースクラスが単一的なレコード型としてしばしば用いられる（要素型が固定されたレコード型など）。Slickにおいてこのようなケースクラスを用いるためには、レコードの生の値を取り扱うケースクラスを定義するのに加えて、持ち上げられたレコードの値を取り扱うケースクラスを定義する必要がある。
<!-- Custom *case classes* are frequently used as monomorphic record types (i.e. record types where the element types are fixed). In order to use them in Slick, you need to define the case class for a record of plain values (as usual) plus an additional case class for a matching record of lifted values.  -->

カスタマイズしたケースクラスの[Shape](http://slick.typesafe.com/doc/3.0.0/api/index.html#slick.lifted.Shape)を提供するためには、[CaseClassShape](http://slick.typesafe.com/doc/3.0.0/api/index.html#slick.lifted.CaseClassShape)を用いると良い。
<!-- In order to provide a slick.lifted.Shape for a custom case class, you can use slick.lifted.CaseClassShape:  -->

```scala
// 2つのケースクラスを用意
case class LiftedB(a: Rep[Int], b: Rep[String])
case class B(a: Int, b: String)
...
// 定義したケースクラスに対するマッピング
implicit object BShape extends CaseClassShape(LiftedB.tupled, B.tupled)
...
class BRow(tag: Tag) extends Table[B](tag, "shape_b") {
  def id = column[Int]("id", O.PrimaryKey)
  def s = column[String]("s")
  def * = LiftedB(id, s)
}
val bs = TableQuery[BRow]
...
val insertActions = DBIO.seq(
  bs += B(1, "a"),
  bs.map(b => (b.id, b.s)) += ((2, "c")),
  bs += B(3, "b")
)
...
val q3 = bs
  .map { case b => LiftedB(b.id, (b.s ++ b.s)) }
  .filter { case LiftedB(id, _) => id =!= 1 }
  .sortBy { case LiftedB(_, ss) => ss }
...
// returns: Vector(B(3,"bb"), B(2,"cc"))
```

このメカニズムは、_<>_ オペレータを用いたクライアントサイドマッピングの代わりとして用いられている。これにはすこしばかりボイラープレートが必要になるが、生のレコードと持ち上げられたレコードの双方において同じフィールド名を持たせてくれる。
<!-- Note that this mechanism can be used as an alternative to client-side mappings with the \<\> operator. It requires a bit more boilerplate but allows you to use the same field names in both, plain and lifted records.  -->

### Combining Mapped Types

以下の例では、マッピングされたケースクラスと、他でマッピングされたケースクラスでマッピングされた`Pair`の2つを組み合わせている。
<!-- In the following example we are combining a mapped case class and the mapped `Pair` type in another mapped case class.  -->

```scala
// 複数のマッピングされた型を組み合わせている
case class LiftedC(p: Pair[Rep[Int],Rep[String]], b: LiftedB)
case class C(p: Pair[Int,String], b: B)
...
implicit object CShape extends CaseClassShape(LiftedC.tupled, C.tupled)
...
class CRow(tag: Tag) extends Table[C](tag, "shape_c") {
  def id = column[Int]("id")
  def s = column[String]("s")
  def projection = LiftedC(
    Pair(column("p1"),column("p2")), // (cols defined inline, type inferred)
    LiftedB(id,s)
  )
  def * = projection
}
val cs = TableQuery[CRow]
...
val insertActions2 = DBIO.seq(
  cs += C(Pair(7,"x"), B(1,"a")),
  cs += C(Pair(8,"y"), B(2,"c")),
  cs += C(Pair(9,"z"), B(3,"b"))
)
...
val q4 = cs
  .map { case c => LiftedC(c.projection.p, LiftedB(c.id,(c.s ++ c.s))) }
  .filter { case LiftedC(_, LiftedB(id,_)) => id =!= 1 }
  .sortBy { case LiftedC(Pair(_,p2), LiftedB(_,ss)) => ss++p2 }
...
// returns: Vector(C(Pair(9,"z"),B(3,"bb")), C(Pair(8,"y"),B(2,"cc")))
```
