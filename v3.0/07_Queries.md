Slick 3.0.0 documentation - 07 Queries

[Permalink to Queries — Slick 3.0.0 documentation](http://slick.typesafe.com/doc/3.0.0/queries.html)

クエリ
=======

本章ではselect, insert, update, deleteといった処理を、SlickのクエリAPIで、どのようにして型安全なクエリを記述するのかを説明する。
<!-- This chapter describes how to write type-safe queries for selecting, inserting, updating and deleting data with Slick's Scala-based query API.  -->

このAPIは *Lifted Embedding* と呼ばれる。これは、実際にはScalaの基本的な型を操作するのではなく、[Rep](http://slick.typesafe.com/doc/3.0.0/api/index.html#slick.lifted.Rep)の型コンストラクタへと *持ち上げられた型* を用いてる事に由来する。以下のように、Scalaのコレクション操作で扱う型と比較すると分かりやすい。

<!-- It is also called the *Lifted Embedding*, due to the fact that you are not working with standard Scala types but with types that are *lifted* into a slick.lifted.Rep type constructor. This becomes clearer when you compare the types of a simple Scala collections example  -->

```scala
case class Coffee(name: String, price: Double)
val coffees: List[Coffee] = //...
...
val l = coffees.filter(_.price > 8.0).map(_.name)
//                       ^       ^          ^
//                       Double  Double     String
```

Slickにおいて似たような記述を行うと、以下のようになる。
<!-- ... with the types of similar code in Slick: -->

```scala
class Coffees(tag: Tag) extends Table[(String, Double)](tag, "COFFEES") {
def name = column[String]("COF_NAME")
def price = column[Double]("PRICE")
def * = (name, price)
}
val coffees = TableQuery[Coffees]
...
val q = coffees.filter(_.price > 8.0).map(_.name)
//                       ^       ^          ^
//               Rep[Double]  Rep[Double]  Rep[String]
```

全ての基本的な型は`Rep`へと持ち上げられる。`Coffees`の列を表す型も`Rep[(String, Double)]`として扱われるのと等価になる。`8.0`というリテラルも、暗黙的変換により、`Rep[Double]`となる。これは`>`オペレータが`Rep[Double]`を要求するためである。この持ち上げ操作は、クエリを生成する際のシンタックスツリーを作成するのに必要になる。Scalaの基本的な関数や値はSQLへ変換するのに十分な情報を含んではいない。
<!-- All plain types are lifted into `Rep`. The same is true for the table row type `Coffees` which is a subtype of `Rep[(String, Double)]`. Even the literal `8.0` is automatically lifted to a `Rep[Double]` by an implicit conversion because that is what the `>` operator on `Rep[Double]` expects for the right-hand side. This lifting is necessary because the lifted types allow us to generate a syntax tree that captures the query computations. Getting plain Scala functions and values would not give us enough information for translating those computations to SQL.  -->

Expressions
-----------

レコードでもコレクションでも無い単純なスカラー値は、暗黙的な`TypedType[T]`が存在し、`Rep[T]`により表現される。
<!-- Scalar (non-record, non-collection) values are represented by type `Rep[T]` for which an implicit `TypedType[T]` exists.  -->

クエリ内で一般的に用いられるオペレータやメソッドは、`ExtensionMethodConversions`で定義された暗黙的な変換を通して利用される。実際のメソッドは`AnyExtensionMethods`、`ColumnExtensionMethods`、`NumericColumnExtensionMethods`、`BooleanColumnExtensionMethods`、`StringColumnExtensionMethods`に存在する。（cf. [ExtensionMethods](https://github.com/slick/slick/blob/3.0.0/src/main/scala/slick/lifted/ExtensionMethods.scala)）
<!-- The operators and other methods which are commonly used in queries are added through implicit conversions defined in `ExtensionMethodConversions`. The actual methods can be found in the classes `AnyExtensionMethods`, `ColumnExtensionMethods`, `NumericColumnExtensionMethods`, `BooleanColumnExtensionMethods` and `StringColumnExtensionMethods` (cf. ExtensionMethods \<src/main/scala/slick/lifted/ExtensionMethods.scala\>).  -->

> **Warning**
>
> Scalaの基本的な比較演算子は、凡そ同じように動作するものの、`==`と`!=`に関しては、`===`と`=!=`を代わりに用いなくてはならない。これはこれらのメソッドが`Any`に定義されていることから拡張する事が出来ないためである。
<!-- **warning** -->
<!-- Most operators mimic the plain Scala equivalents, but you have to use `===` instead of `==` for comparing two values for equality and `=!=` instead of `!=` for inequality. This is necessary because these operators are already defined (with unsuitable types and semantics) on the base type `Any`, so they cannot be replaced by extension methods.  -->

コレクションは`Query`クラスにより`Rep[Seq[T]]`のように表現される。ここには`flatMap`、`filter`、`take`、`groupBy`のような基本的なコレクションメソッドが含まれている。2つの異なる複合型を表すために（持ち上げられたものと、持ち上げられる前のもの e.g. `Query[(Rep[Int], Rep[String]), (Int, String), Seq]`）、これらのシグネチャはとても複雑なものになっている。ただ意味的には基本的にScalaのコレクションと同じようなものになっていることは確認して欲しい。
<!-- Collection values are represented by the `Query` class (a `Rep[Seq[T]]`) which contains many standard collection methods like `flatMap`, `filter`, `take` and `groupBy`. Due to the two different component types of a `Query` (lifted and plain, e.g. `Query[(Rep[Int), Rep[String]), (Int, String), Seq]`), the signatures for these methods are very complex but the semantics are essentially the same as for Scala collections.  -->

`SingleColumnQueryExtensionMethods`への暗黙的変換により、クエリやスカラー値のためのメソッドが数多く用意されている。
<!-- Additional methods for queries of scalar values are added via an implicit conversion to `SingleColumnQueryExtensionMethods`.  -->

Sorting and Filtering
---------------------

並び替えやフィルタリングを行うための様々なメソッドが存在する。これらは、`Query`から新しい`Query`を生成して返す。
<!-- There are various methods with sorting/filtering semantics (i.e. they take a `Query` and return a new `Query` of the same type), for example:  -->

```scala
val q1 = coffees.filter(_.supID === 101)
// compiles to SQL (simplified):
//   select "COF_NAME", "SUP_ID", "PRICE", "SALES", "TOTAL"
//     from "COFFEES"
//     where "SUP_ID" = 101
...
val q2 = coffees.drop(10).take(5)
// compiles to SQL (simplified):
//   select "COF_NAME", "SUP_ID", "PRICE", "SALES", "TOTAL"
//     from "COFFEES"
//     limit 5 offset 10
...
val q3 = coffees.sortBy(_.name.desc.nullsFirst)
// compiles to SQL (simplified):
//   select "COF_NAME", "SUP_ID", "PRICE", "SALES", "TOTAL"
//     from "COFFEES"
//     order by "COF_NAME" desc nulls first
...
// building criteria using a "dynamic filter" e.g. from a webform.
val criteriaColombian = Option("Colombian")
val criteriaEspresso = Option("Espresso")
val criteriaRoast:Option[String] = None
...
val q4 = coffees.filter { coffee =>
  List(
    criteriaColombian.map(coffee.name === _),
    criteriaEspresso.map(coffee.name === _),
    criteriaRoast.map(coffee.name === _) // not a condition as `criteriaRoast` evaluates to `None`
  ).collect({case Some(criteria)  => criteria}).reduceLeftOption(_ || _).getOrElse(true: Column[Boolean])
}
// compiles to SQL (simplified):
//   select "COF_NAME", "SUP_ID", "PRICE", "SALES", "TOTAL"
//     from "COFFEES"
//     where ("COF_NAME" = 'Colombian' or "COF_NAME" = 'Espresso')
```

Joining and Zipping
-------------------

joinは2つの異なるテーブルやクエリに対して、1つのクエリを適用するのに用いられる。*Applicative*と*Monadic*の2種類のjoinの書き方が存在する。
<!-- Joins are used to combine two different tables or queries into a single query. There are two different ways of writing joins: *Applicative* and *monadic*.  -->

### Applicative joins

*Applicative*なjoinはそれぞれの結果を取得するクエリに対し、2つのクエリを結合するメソッドを呼ぶ事で実行出来る。SQLにおけるjoinと同様の制約がかかり、右側の式は左側の式に依存しなかったりする。これはScalaのスコープにおけるルールを通して自然に強制される。
<!-- *Applicative* joins are performed by calling a method that joins two queries into a single query of a tuple of the individual results. They have the same restrictions as joins in SQL, i.e. the right-hand side may not depend on the left-hand side. This is enforced naturally through Scala's scoping rules.  -->

```scala
val crossJoin = for {
  (c, s) <- coffees join suppliers
} yield (c.name, s.name)
// compiles to SQL (simplified):
//   select x2."COF_NAME", x3."SUP_NAME" from "COFFEES" x2
//     inner join "SUPPLIERS" x3
...
val innerJoin = for {
  (c, s) <- coffees join suppliers on (_.supID === _.id)
} yield (c.name, s.name)
// compiles to SQL (simplified):
//   select x2."COF_NAME", x3."SUP_NAME" from "COFFEES" x2
//     inner join "SUPPLIERS" x3
//     on x2."SUP_ID" = x3."SUP_ID"
...
val leftOuterJoin = for {
  (c, s) <- coffees joinLeft suppliers on (_.supID === _.id)
} yield (c.name, s.map(_.name))
// compiles to SQL (simplified):
//   select x2."COF_NAME", x3."SUP_NAME" from "COFFEES" x2
//     left outer join "SUPPLIERS" x3
//     on x2."SUP_ID" = x3."SUP_ID"
...
val rightOuterJoin = for {
  (c, s) <- coffees joinRight suppliers on (_.supID === _.id)
} yield (c.map(_.name), s.name)
// compiles to SQL (simplified):
//   select x2."COF_NAME", x3."SUP_NAME" from "COFFEES" x2
//     right outer join "SUPPLIERS" x3
//     on x2."SUP_ID" = x3."SUP_ID"
...
val fullOuterJoin = for {
  (c, s) <- coffees joinFull suppliers on (_.supID === _.id)
} yield (c.map(_.name), s.map(_.name))
// compiles to SQL (simplified):
//   select x2."COF_NAME", x3."SUP_NAME" from "COFFEES" x2
//     full outer join "SUPPLIERS" x3
//     on x2."SUP_ID" = x3."SUP_ID"
```

outer joinの節では、`yield`の中で`map`している。これらのjoinにおいては追加でNULLになるようなカラムが生じ、結果のカラム型が`Option`に包まって返却されるためである（`None`になるのは、対応する列がなかった時など）。
<!-- Note the use of `map` in the `yield` clauses of the outer joins. Since these joins can introduce additional NULL values (on the right-hand side for a left outer join, on the left-hand sides for a right outer join, and on both sides for a full outer join), the respective sides of the join are wrapped in an `Option` (with `None` representing a row that was not matched).  -->

### Monadic joins

*Monadic*なjoinは`flatMap`を利用する事で自動的に生成される。右辺が左辺に依存するため、理論上*Monadic*なjoinは*Applicative*なjoinより強力なものとなる。一方で、これは通常のSQLに適したものとはならない。そのため、Slickは*Monadic*なjoinを*Applicative*なjoinへと変換している。もし*Monadic*なjoinを適切な形に変換出来なければ、実行時に失敗する事になるだろう。
<!-- *Monadic* joins are created with `flatMap`. They are theoretically more powerful than applicative joins because the right-hand side may depend on the left-hand side. However, this is not possible in standard SQL, so Slick has to compile them down to applicative joins, which is possible in many useful cases but not in all of them (and there are cases where it is possible in theory but Slick cannot perform the required transformation yet). If a monadic join cannot be properly translated, it will fail at runtime.  -->

*cross-join*は`Query`の`flatMap`により作成される。1つ以上のジェネレータを用いる際には、for式が役立つ。
<!-- A *cross-join* is created with a `flatMap` operation on a `Query` (i.e. by introducing more than one generator in a for-comprehension):  -->

```scala
val monadicCrossJoin = for {
  c <- coffees
  s <- suppliers
} yield (c.name, s.name)
// compiles to SQL:
//   select x2."COF_NAME", x3."SUP_NAME"
//     from "COFFEES" x2, "SUPPLIERS" x3
```

もし何かしらのフィルタリングを行うのなら、それは*inner join*となる。
<!-- If you add a filter expression, it becomes an *inner join*:  -->

```scala
val monadicInnerJoin = for {
  c <- coffees
  s <- suppliers if c.supID === s.id
} yield (c.name, s.name)
// compiles to SQL:
//   select x2."COF_NAME", x3."SUP_NAME"
//     from "COFFEES" x2, "SUPPLIERS" x3
//     where x2."SUP_ID" = x3."SUP_ID"
```

この*Monadic*なjoinはScalaコレクションの`flatMap`を利用した時と同じ意味を持つ。
<!-- The semantics of these monadic joins are the same as when you are using `flatMap` on Scala collections.  -->

> **Note**
>
> Slickは*Monadic*なjoinに対し暗黙的なjoin（`select ... from a, b where ...`）を、*Applicative*なjoinに対し明示的なjoin（`select ... from a join b on ...`）を生成する。これについては、将来のバージョンで変更があるかもしれない。
<!-- **note** Slick currently generates *implicit* joins in SQL (`select ... from a, b where ...`) for monadic joins, and *explicit* joins (`select ... from a join b on ...`) for applicative joins. This is subject to change in future versions.  -->

### Zip joins

関係でデータベースによってサポートされている一般的な*Applicative* joinに加えて、Slickは2つのクエリのペアを作成する*zip join*を提供している。これは`zip`や`zipWith`メソッドを用いれば利用でき、Scalaコレクションで利用するものと同じような挙動をするものである。
<!-- In addition to the usual applicative join operators supported by relational databases (which are based off a cross join or outer join), Slick also has *zip joins* which create a pairwise join of two queries. The semantics are again the same as for Scala collections, using the `zip` and `zipWith` methods:  -->

```scala
val zipJoinQuery = for {
  (c, s) <- coffees zip suppliers
} yield (c.name, s.name)
...
val zipWithJoin = for {
  res <- coffees.zipWith(suppliers, (c: Coffees, s: Suppliers) => (c.name, s.name))
} yield res
```

また別のzip joinとして、`zipWithIndex`というものも存在する。これは0から始まる無限数列をクエリ結果と結合してくれるものである。この数列はSQLデータベースによって提供されたものではなく、Slickがサポートしているものでもない。ただの数字を吐く関数とSQLの結果を統合したものとして、`zipWithIndex`がプリミティブなオペレータとして提供されているのである。
<!-- A particular kind of zip join is provided by `zipWithIndex`. It zips a query result with an infinite sequence starting at 0. Such a sequence cannot be represented by an SQL database and Slick does not currently support it, either. The resulting zipped query, however, can be represented in SQL with the use of a *row number* function, so `zipWithIndex` is supported as a primitive operator:  -->

```scala
val zipWithIndexJoin = for {
  (c, idx) <- coffees.zipWithIndex
} yield (c.name, idx)
```

Unions
------

互換のある2つのクエリは`++`（もしくは`unionAll`）や`union`で結合することが出来る。
<!-- Two queries can be concatenated with the `++` (or `unionAll`) and `union` operators if they have compatible types:  -->

```scala
val q1 = coffees.filter(_.price < 8.0)
val q2 = coffees.filter(_.price > 9.0)
...
val unionQuery = q1 union q2
// compiles to SQL (simplified):
//   select x8."COF_NAME", x8."SUP_ID", x8."PRICE", x8."SALES", x8."TOTAL"
//     from "COFFEES" x8
//     where x8."PRICE" < 8.0
//   union select x9."COF_NAME", x9."SUP_ID", x9."PRICE", x9."SALES", x9."TOTAL"
//     from "COFFEES" x9
//     where x9."PRICE" > 9.0
...
val unionAllQuery = q1 ++ q2
// compiles to SQL (simplified):
//   select x8."COF_NAME", x8."SUP_ID", x8."PRICE", x8."SALES", x8."TOTAL"
//     from "COFFEES" x8
//     where x8."PRICE" < 8.0
//   union all select x9."COF_NAME", x9."SUP_ID", x9."PRICE", x9."SALES", x9."TOTAL"
//     from "COFFEES" x9
//     where x9."PRICE" > 9.0
```

`union`は重複する値については省いてしまうのに対し、`++`は個々のクエリ結果を単純に、より効率的に繋げるものとなっている。
<!-- Unlike `union` which filters out duplicate values, `++` simply concatenates the results of the individual queries, which is usually more efficient.  -->

Aggregation
-----------

集約関数はQueryから単一の値、主に計算された数値を返すものである。
<!-- The simplest form of aggregation consists of computing a primitive value from a Query that returns a single column, usually with a numeric type, e.g.:  -->

```scala
val q = coffees.map(_.price)
...
val q1 = q.min
// compiles to SQL (simplified):
...
val q2 = q.max
// compiles to SQL (simplified):
//   select max(x4."PRICE") from "COFFEES" x4
...
val q3 = q.sum
// compiles to SQL (simplified):
//   select sum(x4."PRICE") from "COFFEES" x4
...
val q4 = q.avg
// compiles to SQL (simplified):
//   select avg(x4."PRICE") from "COFFEES" x4
```

集約クエリはコレクションではなく、スカラー値を返却する。いくつかの集約関数は以下のような恣意的なクエリで定義されている。
<!-- Note that these aggregate queries return a scalar result, not a collection. Some aggregation functions are defined for arbitrary queries (of more than one column):  -->

```scala
val q1 = coffees.length
// compiles to SQL (simplified):
//   select count(1) from "COFFEES"
...
val q2 = coffees.exists
// compiles to SQL (simplified):
//   select exists(select * from "COFFEES")
```

グループ化は`groupBy`メソッドにより処理出来る。これはScalaのコレクションでの操作と同じような意味を持つ。
<!-- Grouping is done with the `groupBy` method. It has the same semantics as for Scala collections:  -->

```scala
val q = (for {
  c <- coffees
  s <- c.supplier
} yield (c, s)).groupBy(_._1.supID)
val q2 = q.map { case (supID, css) =>
  (supID, css.length, css.map(_._1.price).avg)
}
// compiles to SQL:
//   select x2."SUP_ID", count(1), avg(x2."PRICE")
//     from "COFFEES" x2, "SUPPLIERS" x3
//     where x3."SUP_ID" = x2."SUP_ID"
//     group by x2."SUP_ID"
```

中間クエリである`q`はネストされた`Query`の値を持っている。クエリを実行した際に、ネストしたコレクションが返却される。それゆえ`q2`においては、集約関数を用いてネストを解消している。
<!-- The intermediate query `q` contains nested values of type `Query`. These would turn into nested collections when executing the query, which is not supported at the moment. Therefore it is necessary to flatten the nested queries immediately by aggregating their values (or individual columns) as done in `q2`.  -->

Querying
--------

クエリによる選択は`result`メソッドを呼ぶことで[Action](http://slick.typesafe.com/doc/3.0.0/api/index.html#slick.dbio.DBIOAction)へ変換される。Actionはストリームか個々に分割された方法、もしくは他のアクションを混在したものとして直接[実行される](http://slick.typesafe.com/doc/3.0.0/dbio.html#executing-actions)。
<!-- A Query can be converted into an Action \<slick.dbio.DBIOAction\> by calling its `result` method. The Action can then be executed \<executing-actions\> directly in a streaming or fully materialized way, or composed further with other Actions:  -->

```scala
val q = coffees.map(_.price)
val action = q.result
val result: Future[Seq[Double]] = db.run(action)
val sql = action.statements.head
```

もし結果を1つだけ受け取りたいのなら、`head`か`headOption`を用いれば良い。
<!-- If you only want a single result value, you can call `head` or `headOption` on the `result` Action.  -->

Deleting
--------

削除はクエリの場合と同じように動作する。はじめに削除したい行をクエリで選択した上で、`delete`メソッドを呼ぶことで削除を行うActionが得られる。
<!-- Deleting works very similarly to querying. You write a query which selects the rows to delete and then get an Action by calling the `delete` method on it:  -->

```scala
val q = coffees.filter(_.supID === 15)
val action = q.delete
val affectedRowsCount: Future[Int] = db.run(action)
val sql = action.statements.head
```

削除を行うクエリは、1つのテーブルのみを指定しなくてはならない。どんな射影も無視され、行はまるまる削除される。
<!-- A query for deleting must only select from a single table. Any projection is ignored (it always deletes full rows).  -->

Inserting
---------

挿入は1つのテーブルから特定のカラムを射影したものに対して実行する。テーブルを直接用いた場合には、挿入は`*`射影に対して実行される。挿入時にいくつかのカラムを省略した場合には、テーブル定義にあるデフォルト値が用いられるか、明示的なデフォルト値が無い場合には型に応じたデフォルト値が挿入される。挿入Actionに関する全てのメソッドは、[CountingInsertActionComposer](http://slick.typesafe.com/doc/3.0.0/api/index.html#slick.driver.JdbcActionComponent@CountingInsertActionComposer[U]:JdbcDriver.CountingInsertActionComposer[U])か[ReturningInsertActionComposer](http://slick.typesafe.com/doc/3.0.0/api/index.html#slick.driver.JdbcActionComponent@ReturningInsertActionComposer[U,RU]:JdbcDriver.ReturningInsertActionComposer[U,RU])に定義されている。
<!-- Inserts are done based on a projection of columns from a single table. When you use the table directly, the insert is performed against its `*` projection. Omitting some of a table's columns when inserting causes the database to use the default values specified in the table definition, or a type-specific default in case no explicit default was given. All methods for building insert Actions are defined in CountingInsertActionComposer \<slick.driver.JdbcActionComponent@CountingInsertActionComposer[U]:JdbcDriver.CountingInsertActionComposer[U]\> and ReturningInsertActionComposer \<slick.driver.JdbcActionComponent@ReturningInsertActionComposer[U,RU]:JdbcDriver.ReturningInsertActionComposer[U,RU]\>.  -->

```scala
val insertActions = DBIO.seq(
  coffees += ("Colombian", 101, 7.99, 0, 0),
  coffees ++= Seq(
    ("French_Roast", 49, 8.99, 0, 0),
    ("Espresso",    150, 9.99, 0, 0)
  ),
  // "sales" と "total" にはデフォルト値として0が入る
  coffees.map(c => (c.name, c.supID, c.price)) += ("Colombian_Decaf", 101, 8.99)
)
// insertを行うsqlのステートメントを取得
val sql = coffees.insertStatement
// compiles to SQL:
//   INSERT INTO "COFFEES" ("COF_NAME","SUP_ID","PRICE","SALES","TOTAL") VALUES (?,?,?,?,?)
```

`AutoInc`がついたカラムが挿入された際には、そのカラムに対する挿入値は無視され、データベースが生成した適切な値が挿入される。大抵の場合、自動で生成された主キーの値などを返り値として取得したいと考えるだろう。デフォルトでは`+=`は影響を与えた行の数を返却する（普通は成功時に1が返る）。`++=`は`Option`に包まれた結果数を返す。`None`になるのはデータベースシステムが影響を与えた数を返さない時である。これらの返り値は`returning`メソッドを用いることで、好きな値が返るように変更出来る。この場合、`+=`に対して単一の値やタプルを返すように設定すると、`++=`にはその値の`Seq`が返却されることになる。以下の様な記述で、`AutoInc`で生成された主キーを返すことが出来る。
<!-- When you include an `AutoInc` column in an insert operation, it is silently ignored, so that the database can generate the proper value. In this case you usually want to get back the auto-generated primary key column. By default, `+=` gives you a count of the number of affected rows (which will usually be 1) and `++=` gives you an accumulated count in an `Option` (which can be `None` if the database system does not provide counts for all rows). This can be changed with the `returning` method where you specify the columns to be returned (as a single value or tuple from `+=` and a `Seq` of such values from `++=`):  -->

```scala
val userId =
  (users returning users.map(_.id)) += User(None, "Stefan", "Zeiger")
```
> **Note**
>
> 多くのデータベースでは、1つのテーブルのAutoIncrementな主キーのみを返却することを許可している。もし他のカラムについても同様の事をしようとしたならば、データベースがサポートしていない時には`SlickException`が投げられる。
<!-- **note** Many database systems only allow a single column to be returned which must be the table's auto-incrementing primary key. If you ask for other columns a `SlickException` is thrown at runtime (unless the database actually supports it).  -->

`returning`に`into`を続けて用いると、挿入された値と自動生成された値をもとに返り値を変更する事ができる。得られた`id`を用いて更新されたオブジェクトを返却する例は以下の通りとなる。
<!-- You can follow the `returning` method with the `into` method to map the inserted values and the generated keys (specified in returning) to a desired value. Here is an example of using this feature to return an object with an updated id:  -->

```scala
val userWithId =
  (users returning users.map(_.id)
         into ((user,id) => user.copy(id=Some(id)))
  ) += User(None, "Stefan", "Zeiger")
```

クライアント側でデータを挿入する以外にも、データベースサーバ側で実行されるスカラー表現や`Query`を作る事でデータを挿入することも出来る。
<!-- Instead of inserting data from the client side you can also insert data created by a `Query` or a scalar expression that is executed in the database server:  -->

```scala
class Users2(tag: Tag) extends Table[(Int, String)](tag, "users2") {
  def id = column[Int]("id", O.PrimaryKey)
  def name = column[String]("name")
  def * = (id, name)
}
val users2 = TableQuery[Users2]
val actions = DBIO.seq(
  users2.schema.create,
  users2 forceInsertQuery (users.map { u => (u.id, u.first ++ " " ++ u.last) }),
  users2 forceInsertExpr (users.length + 1, "admin")
)
```

この場合、`AutoInc`なカラムは _無視されない_ 。
<!-- In these cases, `AutoInc` columns are *not* ignored.  -->

Updating
--------
更新は更新を行いたいデータを選択してから、新しいデータで置き換える事で実行される。更新時の返り値は計算された値ではなく、1つのテーブルから取得された生のカラムをそのまま返却しなくてはならない。更新に関連するメソッドは、[UpdateExtensionMethods](http://slick.typesafe.com/doc/3.0.0/api/index.html#slick.driver.JdbcActionComponent@UpdateActionExtensionMethodsImpl[T]:JdbcDriver.UpdateActionExtensionMethodsImpl[T])で定義されている。
<!-- Updates are performed by writing a query that selects the data to update and then replacing it with new data. The query must only return raw columns (no computed values) selected from a single table. The relevant methods for updating are defined in UpdateExtensionMethods \<slick.driver.JdbcActionComponent@UpdateActionExtensionMethodsImpl[T]:JdbcDriver.UpdateActionExtensionMethodsImpl[T]\>.  -->

```scala
val q = for { c <- coffees if c.name === "Espresso" } yield c.price
val updateAction = q.update(10.49)
// 値を更新することなくステートメントを取得する
val sql = q.updateStatement
// compiles to SQL:
//   update "COFFEES" set "PRICE" = ? where "COFFEES"."COF_NAME" = 'Espresso'
```

現時点では、データベースに用意された更新用の変換関数等を利用したりすることは出来ない。
<!-- There is currently no way to use scalar expressions or transformations of the existing data in the database for updates.  -->

Compiled Queries
----------------

通常、データベースクエリはいくつかのパラメータに依存している（IDは一致する列を取得するために用いられるなど）。パラメータ化された`Query`オブジェクトを実行の度に作ることも出来るが、これはSlickが毎度クエリをコンパイルするコストが高くついてしまう（パラメータに値を代入しない場合など特に）。パラメータ化されたクエリ関数を事前にSlick側でコンパイルする、より効率的な方法が存在する。
<!-- Database queries typically depend on some parameters, e.g. an ID for which you want to retrieve a matching database row. You can write a regular Scala function to create a parameterized `Query` object each time you need to execute that query but this will incur the cost of recompiling the query in Slick (and possibly also on the database if you don't use bind variables for all parameters). It is more efficient to pre-compile such parameterized query functions:  -->

```scala
def userNameByIDRange(min: Rep[Int], max: Rep[Int]) =
for {
  u <- users if u.id >= min && u.id < max
} yield u.first
val userNameByIDRangeCompiled = Compiled(userNameByIDRange _)
// このクエリは1度しかコンパイルされない
val namesAction1 = userNameByIDRangeCompiled(2, 5).result
val namesAction2 = userNameByIDRangeCompiled(1, 3).result
// .insert にも .update にも .delete にも使える
```

これは個々のカラムやカラムの[records](http://slick.typesafe.com/doc/3.0.0/userdefined.html#record-types)をパラメータに取る全てのメソッドに対し上手く機能し、`Query`オブジェクトなどを返却する。[Compiled](http://slick.typesafe.com/doc/3.0.0/api/index.html#slick.lifted.Compiled)のAPIドキュメントを見て、そのサブクラスなど、コンパイルされたクエリの詳細について学んで欲しい。
<!-- This works for all functions that take parameters consisting only of individual columns or or records \<record-types\> of columns and return a `Query` object or a scalar query. See the API documentation for slick.lifted.Compiled and its subclasses for details on composing compiled queries.  -->

`ConstColumn[Long]`をパラメータに取る`take`や`drop`を使う場合には気をつけて欲しい。クエリによって計算された他の値に取って代わられる`Rep[Long]`と異なり、`ConstColumn`はリテラル値かコンパイルされたクエリのパラメータのみを要求する。これは、Slickによって実行される前までに、クエリが実際の値を知っておかなくてはならないためである。
<!-- Be aware that `take` and `drop` take `ConstColumn[Long]` parameters. Unlike `Rep[Long]]`, which could be substituted by another value computed by a query, a ConstColumn can only be literal value or a parameter of a compiled query. This is necessary because the actual value has to be known by the time the query is prepared for execution by Slick.  -->

```scala
val userPaged = Compiled((d: ConstColumn[Long], t: ConstColumn[Long]) => users.drop(d).take(t))
...
val usersAction1 = userPaged(2, 1).result
val usersAction2 = userPaged(1, 3).result
```

データの選択、挿入、更新、削除において、コンパイルされたクエリを用いる事ができる。Slick 1.0への後方互換用に、[Parameters](http://slick.typesafe.com/doc/3.0.0/api/index.html#slick.lifted.Parameters)オブジェクトに`flatMap`を呼ぶ事で、コンパイルされたクエリを作成する事も可能である。大抵の場合、これはコンパイルされたクエリを1つのfor式で書くのに役立つだろう。
<!-- You can use a compiled query for querying, inserting, updating and deleting data. For backwards-compatibility with Slick 1.0 you can still create a compiled query by calling `flatMap` on a slick.lifted.Parameters object. In many cases this enables you to write a single *for comprehension* for a compiled query:  -->

```scala
val userNameByID = for {
  id <- Parameters[Int]
  u <- users if u.id === id
} yield u.first
...
val nameAction = userNameByID(2).result.head
...
val userNameByIDRange = for {
  (min, max) <- Parameters[(Int, Int)]
  u <- users if u.id >= min && u.id < max
} yield u.first
val namesAction = userNameByIDRange(2, 5).result
```
