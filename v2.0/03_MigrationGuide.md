Slick 2.0.0 documentation - 03 v2.0 移行ガイド

[Permalink to Migration Guide from Slick 1.0 to 2.0 — Slick 2.0.0 documentation](http://slick.typesafe.com/doc/2.0.0/migration.html)

Slick v2.0 Migration Guide
=====================================
<!-- Migration Guide from Slick 1.0 to 2.0 -->
<!-- ===================================== -->

Slick2.0はSlick1.0に互換性のない拡張が含まれている。アプリケーションを1.0から2.0へ移行する際には、以下のような変更が必要になるだろう。

<!-- Slick 2.0 contains some improvements which are not source compatible -->
<!-- with Slick 1.0. When migrating your application from 1.0 to 2.0, you -->
<!-- will likely need to perform changes in the following areas. -->

Code generation
---------------

以前は手で書いていたテーブルへのマッピングを、2.0ではデータベーススキーマを用いて自動的に生成出来るようになった。code-generaterは柔軟にカスタマイズすることも出来るため、より最適化されたものに変更する事も出来る。詳細については、[code-generation](http://slick.typesafe.com/doc/2.0.0/code-generation.html)を参考にして欲しい。

<!-- Instead of writing your table descriptions or plain SQL mappers by hand, -->
<!-- in 2.0 you can now automatically generate them from your database -->
<!-- schema. The code-generator is flexible enough to customize it's output -->
<!-- to fit exactly what you need. -->
<!-- More info on code generation \<code-generation\>. -->

Table descriptions
------------------

Slick1.0では、テーブルは`val`や*table object*と呼ばれる`object`によって定義がなされ、射影`*`では`~`オペレータを用いてタプルを表していた。

<!-- In Slick 1.0 tables were defined by a single `val` or `object` (called -->
<!-- the *table object*) and the `*` projection was limited to a flat tuple -->
<!-- of columns that had to be constructed with the special `~` operator: -->

```scala
// --------------------- Slick 1.0 code -- v2.0では動かない ---------------------
object Suppliers extends Table[(Int, String, String)]("SUPPLIERS") {
  def id = column[Int]("SUP_ID", O.PrimaryKey)
  def name = column[String]("SUP_NAME")
  def street = column[String]("STREET")
  def * = id ~ name ~ street
}
```

Slick2.0では`Tag`を引数にテーブルクラスの定義を行い、実際のデータベーステーブルを表す`TableQuery`のインスタンスを定義します。射影`*`では基本的なタプルを用いて定義を行うことが出来る。

<!-- In Slick 2.0 you need to define your table as a class that takes an -->
<!-- extra `Tag` argument (the *table row class*) plus an instance of a -->
<!-- `TableQuery` of that class (representing the actual database table). -->
<!-- Tuples for the `*` projection can use the standard tuple syntax: -->

```scala
class Suppliers(tag: Tag) extends Table[(Int, String, String)](tag, "SUPPLIERS") {
  def id = column[Int]("SUP_ID", O.PrimaryKey)
  def name = column[String]("SUP_NAME")
  def street = column[String]("STREET")
  def * = (id, name, street)
}
val suppliers = TableQuery[Suppliers]
```

以前に用いていた`~`シンタックスをそのまま使いたい場合には、[TupleMethod._](http://slick.typesafe.com/doc/2.0.0/api/#scala.slick.util.TupleMethods$)をインポートすれば良い。`TableQuery[T]`を用いると、内部的には`new TableQuery(new T(_))`のような処理が行われ、適切なTableQueryインスタンスが作成される。Slick1.0では共通処理に関して、静的メソッドでテーブルオブジェクトに定義がなされていた。2.0においても以下のようにカスタムされた`TableQuery`オブジェクトを用いて、同様の事が出来る。

<!-- You can import TupleMethods \<scala.slick.util.TupleMethods\$\>.\_ to -->
<!-- get support for the old \~ syntax. The simple `TableQuery[T]` syntax is -->
<!-- a macro which expands to a proper TableQuery instance that calls the -->
<!-- table's constructor (`new TableQuery(new T(_))`). In Slick 1.0 it was -->
<!-- common practice to place extra static methods associated with a table -->
<!-- into that table's object. You can do the same in 2.0 with a custon -->
<!-- `TableQuery` object: -->

```scala
object suppliers extends TableQuery(new Suppliers(_)) {
  // put extra methods here
  val findByID = this.findBy(_.id)
}
```

`TableQuery`はデータベーステーブルのための`Query`オブジェクトのことである。予期せぬ場所で適用される`Query`への暗黙的な変換はもはや必要無い。Slick 1.0において生身の *table object* を扱っていた場所は、全て *table query* が代わりに用いられることになる。例として、以下に挙げられる挿入(inserting)や、外部キー関連などがある。

<!-- Note that a `TableQuery` is a `Query` for the table. The implicit -->
<!-- conversion from a table row object to a `Query` that could be applied in -->
<!-- unexpected places is no longer needed or available. All the places where -->
<!-- you had to use the raw *table object* in Slick 1.0 have been changed to -->
<!-- use the *table query* instead, e.g. inserting (see below) or foreign key -->
<!-- references. -->

Profile Hierarchy
-----------------

Slick 1.0では`BasicProfile`と`ExtendedProfile`の2つのプロファイルを提供していた。Slick 2.0ではこれら2つのプロファイルを`JdbcProfile`として統合している。今では`RelationalProfile`に挙げられるようなより抽象的なプロファイルを提供している。`RelationalProfile`は`JdbcProfile`の全ての特徴を持っているわけではないが、新しく出来た`HeapDriver`や`DistributedDriber`といった機能を支えている。Slick 1.0からコードを移植する際、`JdbcProfile`へとプロファイルを変更して欲しい。特にSlick 2.0における`BasicProfile`は1.0における`BasicProfil`と非常に異なったものになっているので注意して欲しい。

<!-- Slick 1.0 provided two *profiles*, `BasicProfile` and `ExtendedProfile`. -->
<!-- These two have been unified in 2.0 as `JdbcProfile`. Slick now provides -->
<!-- more abstract profiles, in particular `RelationalProfile` which does not -->
<!-- have all the features of `JdbcProfile` but is supported by the new -->
<!-- `HeapDriver` and `DistributedDriver`. When porting code from Slick 1.0, -->
<!-- you generally want to switch to `JdbcProfile` when abstracting over -->
<!-- drivers. In particular, pay attention to the fact that `BasicProfile` in -->
<!-- 2.0 is very different from `BasicProfile` in 1.0. -->

Inserting
---------

Slick1.0では挿入時に*table object*の一部を射影していた。

<!-- In Slick 1.0 you used to construct a projection for inserting from the -->
<!-- *table object*: -->

```scala
// --------------------- Slick 1.0 code -- does not compile in 2.0 ---------------------
(Suppliers.name ~ Suppliers.street) insert ("foo", "bar")
```

2.0において生身の*table object*は存在していないため、*table query*から射影しなくてはならない。

<!-- Since there is no raw table object any more in 2.0 you have to use a -->
<!-- projection from the table query: -->

```scala
suppliers.map(s => (s.name, s.street)) += ("foo", "bar")
```

`+=`オペレータはScalaコレクションとの互換性のために用いられており、`insert`という古い名前の関数はエイリアスとして依然用いる事が出来る。

<!-- Note the use of the new `+=` operator for API compatibility with Scala -->
<!-- collections. The old name `insert` is still available as an alias. -->

Slick 2.0ではデータを挿入する際自動的にデフォルトで`AutoInc`のついたカラムを除外する。1.0では、そのようなカラムについて手動で除外した射影関数を別に用意しなくてはならなかった。

<!-- Slick 2.0 will now automatically exclude `AutoInc` fields by default -->
<!-- when inserting data. In 1.0 it was common to have a separate projection -->
<!-- for inserts in order to exclude these fields manually: -->

``` scala
// --------------------- Slick 1.0 code -- does not compile in 2.0 ---------------------
case class Supplier(id: Int, name: String, street: String)
...
object Suppliers extends Table[Supplier]("SUPPLIERS") {
  def id = column[Int]("SUP_ID", O.PrimaryKey, O.AutoInc)
  def name = column[String]("SUP_NAME")
  def street = column[String]("STREET")
  // Map a Supplier case class:
  def * = id ~ name ~ street <> (Supplier.tupled, Supplier.unapply)
  // Special mapping without the 'id' field:
  def forInsert = name ~ street <> (
    { case (name, street) => Supplier(-1, name, street) },
    { sup => (sup.name, sup.street) }
  )
}
...
Suppliers.forInsert.insert(mySupplier)
```

2.0においてこのような冗長な技術は必要無くなる。デフォルトの射影関数を挿入時に用いる事で、自動インクリメントのついた`id`というカラムをSlickが除外してくれる。

<!-- This is no longer necessary in 2.0. You can simply insert using the -->
<!-- default projection and Slick will skip the auto-incrementing `id` -->
<!-- column: -->

逆に`AutoInc`のついたカラムに対し値を挿入したいのならば、新しく出来た`forceInsert`や`forceInsertAll`といった関数を用いる事が出来る。

<!-- If you really want to insert into an `AutoInc` field, you can use the -->
<!-- new methods `forceInsert` and `forceInsertAll`. -->

1.0において双方向マッピングを行っていた`<>`関数はオーバーロードされ、今やケースクラスの`apply`関数を直接渡す事が出来る。

<!-- In 1.0 the `<>` method for bidirectional mappings was overloaded for -->
<!-- different arities so you could directly pass a case class's `apply` -->
<!-- method to it: -->

```scala
// --------------------- Slick 1.0 code -- does not compile in 2.0 ---------------------
def * = id ~ name ~ street <> (Supplier _, Supplier.unapply)
```

上記のような記述はもはや2.0ではサポートされていない。その理由の1つとして、このようなオーバーロードはエラーメッセージを複雑にしすぎるためである。現在では適切なタプル型を用いて関数を定義する事が出来る。もしケースクラスをマッピングしたいのならば、コンパニオンオブジェクトの`.tupled`を単純に用いれば良いのである。

<!-- This is no longer supported in 2.0. One of the reasons is that the -->
<!-- overloading lead to complicated error messages. You now have to use a -->
<!-- function with an appropriate tuple type. If you map to a case class you -->
<!-- can simply use `.tupled` on its companion object: -->

```scala
def * = (id, name, street) <> (Supplier.tupled, Supplier.unapply)
```

Pre-compiled updates
--------------------

Slickはselect文において用いられるのと同じ方法で、update文における事前コンパイルもサポートしている。これについては、[Compliled-Queries](http://slick.typesafe.com/doc/2.0.0/queries.html#compiled-queries)のセクションを見て欲しい。

<!-- Slick now supports pre-compilation of updates in the same manner like -->
<!-- selects, see compiled-queries. -->

Database and Session Handling
-----------------------------

Slick 1.0では`Database`のファクトリオブジェクトとして標準的なJDBCベースな`Database`と`Session`といった型が`scala.slick.session`パッケージにある。Slick 2.0からはJDBCベースなデータベースに制限せず、このパッケージは(*backend*としても知られる)[`DatabaseComponent`](http://slick.typesafe.com/doc/2.0.0/api/#scala.slick.backend.DatabaseComponent)階層
によって置き換えられている。もし[`JdbcProfile`](http://slick.typesafe.com/doc/2.0.0/api/#scala.slick.driver.JdbcProfile)抽象レベルで動かしたいのならば、以前に`scala.slick.session`にあったものをインポートし、常に[`JdbcBackend`](http://slick.typesafe.com/doc/2.0.0/api/#scala.slick.jdbc.JdbcBackend)を用いれば良い。ただし、`simple._`といったインポートを行うと自動的にスコープ内にこれらの型が持ち込まれてしまうので注意して欲しい。

<!-- In Slick 1.0, the common JDBC-based `Database` and `Session` types, as -->
<!-- well as the `Database` factory object, could be found in the package -->
<!-- `scala.slick.session`. Since Slick 2.0 is no longer restricted to -->
<!-- JDBC-based databases, this package has been replaced by the new -->
<!-- scala.slick.backend.DatabaseComponent (a.k.a. *backend*) hierarchy. If -->
<!-- you work at the scala.slick.driver.JdbcProfile abstraction level, you -->
<!-- will always use a scala.slick.jdbc.JdbcBackend from which you can import -->
<!-- the types that were previously found in `scala.slick.session`. Note that -->
<!-- importing `simple._` from a driver will automatically bring these types -->
<!-- into scope. -->

Dynamically and Statically Scoped Sessions
------------------------------------------

Slick 2.0では依然としてスレッドローカルな動的セッションと静的スコープセッションを提供している。しかしシンタックスが変わっており、静的スコープセッションを用いる際にはより簡潔な記述が推奨される。以前の`threadLocalSession`は`dynamicSession`という名前に変わっており、関連する`withSession`や`withTransaction`といった関数も`withDynSession`と`withDynTransaction`という名前にそれぞれ変わっている。Slick 1.0で記述されていた以下のようなシンタックスは、

<!-- Slick 2.0 still supports both, thread-local dynamic sessions and -->
<!-- statically scoped sessions, but the syntax has changed to make the -->
<!-- recommended way of using statically scoped sessions more concise. The -->
<!-- old `threadLocalSession` is now called `dynamicSession` and the -->
<!-- overloads of the associated session handling methods `withSession` and -->
<!-- `withTransaction` have been renamed to `withDynSession` and -->
<!-- `withDynTransaction` respectively. If you used this pattern in Slick -->
<!-- 1.0: -->

```scala
// --------------------- Slick 1.0 code -- does not compile in 2.0 ---------------------
import scala.slick.session.Database.threadLocalSession
...
myDB withSession {
  // use the implicit threadLocalSession here
}
```

Slick 2.0で以下のようなシンタックスへ変わる。

```scala
import scala.slick.jdbc.JdbcBackend.Database.dynamicSession
...
myDB withDynSession {
  // use the implicit dynamicSession here
}
```

一方で、Slick 1.0で必要になっていた静的スコープセッションにおける明示的な型宣言は

<!-- On the other hand, due to the overloaded methods, Slick 1.0 required an -->
<!-- explicit type annotation when using the statically scoped session: -->

```scala
myDB withSession { implicit session: Session =>
  // use the implicit session here
}
```

2.0においてもはや必要なくなる。

<!-- This is no longer necessary in 2.0: -->

```scala
myDB withSession { implicit session =>
  // use the implicit session here
}
```

また、動的セッションを使うことは確かな情報を取得できるか分からない事から推奨されていない。静的セッションを用いる方がより安全である。

<!-- Again, the recommended practice is NOT to use dynamic sessions. If you -->
<!-- are uncertain if you need them the answer is most probably no. Static -->
<!-- sessions are safer. -->

Mapped Column Types
-------------------

Slick 1.0の`MappedTypeMapper`は[`MappedColumnType`](http://slick.typesafe.com/doc/2.0.0/api/#scala.slick.driver.JdbcTypesComponent@MappedColumnType:JdbcDriver.MappedColumnTypeFactory)へと名前が変わった。[`MappedColumnType.base`][1]を用いるような基本的な操作は[`RelationalProfile`](http://slick.typesafe.com/doc/2.0.0/api/#scala.slick.profile.RelationalProfile)レベル(高度な利用法をするのならば依然として[`JdbcProfile`](http://slick.typesafe.com/doc/2.0.0/api/#scala.slick.driver.JdbcProfile)が必要)において現在も利用できる。

<!-- Slick 1.0’s `MappedTypeMapper` has been renamed to MappedColumnType. Its basic form (using MappedColumnType.base) is now available at the RelationalProfile level (with more advanced uses still requiring JdbcProfile). The idiomatic use in Slick 1.0 was: -->

```scala
// --------------------- Slick 1.0 code -- does not compile in 2.0 ---------------------
case class MyID(value: Int)
...
implicit val myIDTypeMapper =
  MappedTypeMapper.base[MyID, Int](_.value, new MyID(_))
```

この記述は、次のように変わる。

<!-- This has changed to: -->

```scala
case class MyID(value: Int)
...
implicit val myIDColumnType =
  MappedColumnType.base[MyID, Int](_.value, new MyID(_))
```

もしこの例のように単純なラッパー型へマッピングするのなら、[`MappedTo`](http://slick.typesafe.com/doc/2.0.0/api/#scala.slick.lifted.MappedTo)を用いてもっと簡単に書くことが出来る。

<!-- If you need to map a simple wrapper type (as shown in this example), you -->
<!-- can now do that in an easier way by extending -->
<!-- scala.slick.lifted.MappedTo: -->

```scala
case class MyID(value: Int) extends MappedTo[Int]
// No extra implicit required any more
```

[1]: http://slick.typesafe.com/doc/2.0.0/api/#scala.slick.profile.RelationalTypesComponent$MappedColumnTypeFactory@base[T,U](T)=>U,(U)=>T)(ClassTag[T],(RelationalTypesComponent.this)#BaseColumnType[U]):(RelationalTypesComponent.this)#BaseColumnType[T])
