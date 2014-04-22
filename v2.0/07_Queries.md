Slick 2.0.0 documentation - 07 Queries

[Permalink to Queries — Slick 2.0.0 documentation](http://slick.typesafe.com/doc/2.0.0/queries.html)

Queries
=======

ここでは、[Lifted Embedding](http://slick.typesafe.com/doc/2.0.0/introduction.html#lifted-embedding) APIを用いたデータの選択、挿入、更新、削除について、どのようにして型安全なクエリを書くか、ということについて説明を行う

<!-- This chapter describes how to write type-safe queries for selecting, -->
<!-- inserting, updating and deleting data with the -->
<!-- Lifted Embedding \<lifted-embedding\> API. -->

Expressions
-----------

(レコードでもコレクションでもない)スカラー値は、`TypedType[T]`が必ず存在しているという条件の元、(`Rep[T]`のサブタイプである)`Column[T]`によって表される。内部的な利用のために、`Column`クラスにおいて、いくつかの特別な関数が直接定義されている。

<!-- Scalar (non-record, non-collection) values are representend by type -->
<!-- `Column[T]` (a sub-type of `Rep[T]`) where a `TypedType[T]` must exist. -->
<!-- Only some special methods for internal use are defined directly in the -->
<!-- `Column` class. -->

それらのオペレータやlifted embeddingにおいて一般的に用いられる他の関数は、`ExtensionMethodConversions`において定義された暗黙的な変換を通して追加されている。実際に用いる関数については`AnyExtensionMethods`、`ColumnExtensionMethods`、`NumericColumnExtensionMethods`、`BooleanColumnExtensionMethods`、`StringColumnExtensionMethods`といったクラスにおいて定義がなされている(参照: [ExtensionMethods](https://github.com/slick/slick/blob/2.0.0/src/main/scala/scala/slick/lifted/ExtensionMethods.scala))。

<!-- The operators and other methods which are commonly used in the lifted -->
<!-- embedding are added through implicit conversions defined in -->
<!-- `ExtensionMethodConversions`. The actual methods can be found in the -->
<!-- classes `AnyExtensionMethods`, `ColumnExtensionMethods`, -->
<!-- `NumericColumnExtensionMethods`, `BooleanColumnExtensionMethods` and -->
<!-- `StringColumnExtensionMethods` (cf. -->
<!-- ExtensionMethods \<src/main/scala/scala/slick/lifted/ExtensionMethods.scala\>). -->

コレクション値は`Query`(`Rep[Seq[T]]`)クラスによって表される。これは、`flatMap`、`filter`、`take`、`groupBy`のような多くの標準的なコレクション関数を持っている。2つの異なる`Query`の複合型により、これらの関数のシグネチャは非常に複雑なものになっているが、本質的にはScalaのコレクションと同様の意味合いを持つ。

<!-- Collection values are represented by the `Query` class (a `Rep[Seq[T]]`) -->
<!-- which contains many standard collection methods like `flatMap`, -->
<!-- `filter`, `take` and `groupBy`. Due to the two different component types -->
<!-- of a `Query` (lifted and plain), the signatures for these methods are -->
<!-- very complex but the semantics are essentially the same as for Scala -->
<!-- collections. -->

他にも、スカラー値のクエリに対しいくつかの関数が`SingleColumnQueryExtensionMethods`への暗黙的な変換を通して存在する。

<!-- Additional methods for queries of scalar values are added via an -->
<!-- implicit conversion to `SingleColumnQueryExtensionMethods`. -->

Sorting and Filtering
---------------------

ソートやフィルタリングのための関数がいくつか用意されている(`Query`を取り、新しい同じ型の`Query`を返す)。例として、以下のようなものがある。

<!-- There are various methods with sorting/filtering semantics (i.e. they -->
<!-- take a `Query` and return a new `Query` of the same type), for example: -->

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
```

Joining and Zipping
-------------------

結合(join)は2つの異なるテーブルを結合し、何らかのクエリ処理を1つのクエリで実行するために用いられる。

<!-- Joins are used to combine two different tables or queries into a single -->
<!-- query. -->

結合を行うには2つの方法がある。*明示的な結合*では、2つのクエリを1つのクエリへと結合させる関数(`innerJoin`など)を呼び出すことにより処理を実行させる。*暗黙的な結合*では、そのような関数を呼び出す事はせず、特有の記述を行うことで結合を行わさせる。

<!-- There are two different ways of writing joins: *Explicit* joins are -->
<!-- performed by calling a method that joins two queries into a single query -->
<!-- of a tuple of the individual results. *Implicit* joins arise from a -->
<!-- specific shape of a query without calling a special method. -->

*暗黙的な交差結合(cross join)*は`Query`に対し`flatMap`操作を行うことで実行させる事が出来る(すなわち、for式を用いる事で同様の記述が行える)。

<!-- An *implicit cross-join* is created with a `flatMap` operation on a -->
<!-- `Query` (i.e. by introducing more than one generator in a -->
<!-- for-comprehension): -->

```scala
val implicitCrossJoin = for {
  c <- coffees
  s <- suppliers
} yield (c.name, s.name)
// compiles to SQL:
//   select x2."COF_NAME", x3."SUP_NAME"
//     from "COFFEES" x2, "SUPPLIERS" x3
```

もし結合の際にフィルタリングを行ったのなら、これは*暗黙的な内部結合(inner join)*となる。

<!-- If you add a filter expression, it becomes an *implicit inner join*: -->

```scala
val implicitInnerJoin = for {
  c <- coffees
  s <- suppliers if c.supID === s.id
} yield (c.name, s.name)
// compiles to SQL:
//   select x2."COF_NAME", x3."SUP_NAME"
//     from "COFFEES" x2, "SUPPLIERS" x3
//     where x2."SUP_ID" = x3."SUP_ID"
```

このような暗黙的結合は、Scalaコレクションの`flatMap`を扱うのと同様の意味合いを持つ。

<!-- The semantics of these implicit joins are the same as when you are using -->
<!-- `flatMap` on Scala collections. -->

明示的結合は適切なjoin関数を呼び出す事で実行出来る。

<!-- Explicit joins are created by calling one of the available join methods: -->

```scala
val explicitCrossJoin = for {
  (c, s) <- coffees innerJoin suppliers
} yield (c.name, s.name)
// compiles to SQL (simplified):
//   select x2."COF_NAME", x3."SUP_NAME" from "COFFEES" x2
//     inner join "SUPPLIERS" x3
...
val explicitInnerJoin = for {
  (c, s) <- coffees innerJoin suppliers on (_.supID === _.id)
} yield (c.name, s.name)
// compiles to SQL (simplified):
//   select x2."COF_NAME", x3."SUP_NAME" from "COFFEES" x2
//     inner join "SUPPLIERS" x3
//     on x2."SUP_ID" = x3."SUP_ID"
...
val explicitLeftOuterJoin = for {
  (c, s) <- coffees leftJoin suppliers on (_.supID === _.id)
} yield (c.name, s.name.?)
// compiles to SQL (simplified):
//   select x2."COF_NAME", x3."SUP_NAME" from "COFFEES" x2
//     left outer join "SUPPLIERS" x3
//     on x2."SUP_ID" = x3."SUP_ID"
...
val explicitRightOuterJoin = for {
  (c, s) <- coffees rightJoin suppliers on (_.supID === _.id)
} yield (c.name.?, s.name)
// compiles to SQL (simplified):
//   select x2."COF_NAME", x3."SUP_NAME" from "COFFEES" x2
//     right outer join "SUPPLIERS" x3
//     on x2."SUP_ID" = x3."SUP_ID"
...
val explicitFullOuterJoin = for {
  (c, s) <- coffees outerJoin suppliers on (_.supID === _.id)
} yield (c.name.?, s.name.?)
// compiles to SQL (simplified):
//   select x2."COF_NAME", x3."SUP_NAME" from "COFFEES" x2
//     full outer join "SUPPLIERS" x3
//     on x2."SUP_ID" = x3."SUP_ID"
```

ここでは外部結合において`.?`といったものを用いている。これは、このような結合ではnull値が新たに追加されてしまうため、そのような値に対し`Option`値が取得される事を保証するためである。(左外部結合、右外部結合においても同様である)

<!-- Note the use of `.?` in the outer joins. Since these joins can introduce -->
<!-- additional NULL values (on the right-hand side for a left outer join, on -->
<!-- the left-hand sides for a right outer join, and on both sides for a full -->
<!-- outer join), you have to make sure to retrieve `Option` values from -->
<!-- them. -->

リレーショナルデータベースによってサポートされた一般的な結合処理に加えて、Slickでは2つのクエリのペアワイズ結合を作成する*zip結合*というものを提供している。これはScalaコレクションにおいて`zip`や`zipWith`関数を用いた処理と同様の意味合いを持つものである。

<!-- In addition to the usual join operators supported by relational -->
<!-- databases (which are based off a cross join or outer join), Slick also -->
<!-- has *zip joins* which create a pairwise join of two queries. The -->
<!-- semantics are again the same as for Scala collections, using the `zip` -->
<!-- and `zipWith` methods: -->

```scala
val zipJoinQuery = for {
  (c, s) <- coffees zip suppliers
  } yield (c.name, s.name)
...
val zipWithJoin = for {
  res <- coffees.zipWith(suppliers, (c: Coffees, s: Suppliers) => (c.name, s.name))
} yield res
```

ある種のzip結合は`zipWithIndex`により提供される。これはクエリの結果を0から始まる無限数列とzipしたものとなる。そのような数列についてはSQLデータベースでは表す事が出来ず、Slickでも現在ではサポートしていない。しかし、行番号(*row number*)関数を利用する事でSQLにおいてzipクエリの結果については表す事が出来る。ゆえに`zipWithIndex`は原子的なオペレータとしてサポートされているのである。

<!-- A particular kind of zip join is provided by `zipWithIndex`. It zips a -->
<!-- query result with an infinite sequence starting at 0. Such a sequence -->
<!-- cannot be represented by an SQL database and Slick does not currently -->
<!-- support it, either. The resulting zipped query, however, can be -->
<!-- represented in SQL with the use of a *row number* function, so -->
<!-- `zipWithIndex` is supported as a primitive operator: -->

```scala
val zipWithIndexJoin = for {
  (c, idx) <- coffees.zipWithIndex
} yield (c.name, idx)
```

Unions
------

両立可能な2つのクエリは、`++`(もしくは`unionAll`)や`union`オペレータを用いる事で連結する事が出来る。

<!-- Two queries can be concatenated with the `++` (or `unionAll`) and -->
<!-- `union` operators if they have compatible types: -->

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

重複した値を弾く`union`と違って、`++`は、より効率的な個々のクエリの結果を、単純に連結させる。

<!-- Unlike `union` which filters out duplicate values, `++` simply -->
<!-- concatenates the results of the individual queries, which is usually -->
<!-- more efficient. -->

Aggregation
-----------

最も単純な集合操作は、単一カラムを返却する`Query`からプリミティブな値(大抵は数値型)を計算させる事で取得を行う。

<!-- The simplest form of aggregation consists of computing a primitive value -->
<!-- from a Query that returns a single column, usually with a numeric type, -->
<!-- e.g.: -->

```scala
val q = coffees.map(_.price)
...
val q1 = q.min
// compiles to SQL (simplified):
//   select min(x4."PRICE") from "COFFEES" x4
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

これらの集合クエリはコレクションではなく、スカラー値を返却する事に注意して欲しい。いくつかの集合関数は恣意的なクエリにより定義がなされている。

<!-- Note that these aggregate queries return a scalar result, not a -->
<!-- collection. Some aggregation functions are defined for arbitrary queries -->
<!-- (of more than one column): -->

```scala
val q1 = coffees.length
// compiles to SQL (simplified):
//   select count(1) from "COFFEES"
...
val q2 = coffees.exists
// compiles to SQL (simplified):
//   select exists(select * from "COFFEES")
```

`groupBy`関数によりグルーピングは行なわれる。これはScalaコレクションに対する操作と同じ意味を持つ。

<!-- Grouping is done with the `groupBy` method. It has the same semantics as -->
<!-- for Scala collections: -->

```scala
val q = (for {
  c <- coffees
  s <- c.supplier
} yield (c, s)).groupBy(_._1.supID)
...
val q2 = q.map { case (supID, css) =>
  (supID, css.length, css.map(_._1.price).avg)
}
// compiles to SQL:
//   select x2."SUP_ID", count(1), avg(x2."PRICE")
//     from "COFFEES" x2, "SUPPLIERS" x3
//     where x3."SUP_ID" = x2."SUP_ID"
//     group by x2."SUP_ID"
```

ここで、中間クエリである`q`はネストされた型`Query`の値を保持している。つまり、クエリを実行する際にはネストされたコレクションが現れる。これは現在サポートがされていない。それゆえ、`q2`において行なわれるようにそれらの値(もしくは個々のカラム)をまとめることで、ネストされたクエリを即座に平滑化する必要がある。

<!-- Note that the intermediate query `q` contains nested values of type -->
<!-- `Query`. These would turn into nested collections when executing the -->
<!-- query, which is not supported at the moment. Therefore it is necessary -->
<!-- to flatten the nested queries immediately by aggregating their values -->
<!-- (or individual columns) as done in `q2`. -->

Querying
--------

クエリは[Invoker](http://slick.typesafe.com/doc/2.0.0/api/#scala.slick.jdbc.Invoker)トレイト(もしくはパラメータが無い場合には[UnitInvoker](http://slick.typesafe.com/doc/2.0.0/api/#scala.slick.jdbc.UnitInvoker))において定義された関数を用いて実行される。`Query`に対する暗黙的な変換が存在しているため、直接的に`Query`を実行できるのである。最も一般的な利用法として、`list`や`to`のような特定の関数を用いて、適切にコレクションの値を結果として読み込み事がある。

<!-- Queries are executed using methods defined in the -->
<!-- scala.slick.jdbc.Invoker trait (or scala.slick.jdbc.UnitInvoker for the -->
<!-- parameterless versions). There is an implicit conversion from `Query`, -->
<!-- so you can execute any `Query` directly. The most common usage scenario -->
<!-- is reading a complete result set into a strict collection with a -->
<!-- specialized method such as `list` or the generic method `to` which can -->
<!-- build any kind of collection: -->

```scala
val l = q.list
val v = q.buildColl[Vector]
val invoker = q.invoker
val statement = q.selectStatement
```

このスニペットは暗黙的な変換関数を呼び出す事無しに、どのようにして手動でinvokerに対する参照を取得するのかを示している。

<!-- This snippet also shows how you can get a reference to the invoker -->
<!-- without having to call the implicit conversion method manually. -->

クエリを実行する全ての関数は暗黙的な`Session`を必要とする。もちろん明示的に`Session`を渡してあげてもよい。

<!-- All methods that execute a query take an implicit `Session` value. Of -->
<!-- course, you can also pass a session explicitly if you prefer: -->

```scala
val l = q.list()(session)
```

もし単一の結果値が欲しいのなら、`first`や`firstOption`といった関数を用いる事が出来る。`foreach`、`foldLeft`、`elements`といった関数はScalaコレクションに全てのデータをコピーしたりせずに、結果をイテレートさせる事が出来る。

<!-- If you only want a single result value, you can use `first` or -->
<!-- `firstOption`. The methods `foreach`, `foldLeft` and `elements` can be -->
<!-- used to iterate over the result set without first copying all data into -->
<!-- a Scala collection. -->

Deleting
--------

データの削除はクエリの実行と同じように処理させる。削除したいデータを取得するクエリを書いた後に、`delete`関数を呼び出せば良い。`Query`から`delete`関数と自己参照用の`deleteInvoker`を提供する[DeleteInvoker](http://slick.typesafe.com/doc/2.0.0/api/#scala.slick.driver.JdbcInvokerComponent@DeleteInvoker:JdbcDriver.DeleteInvoker)への暗黙的な変換が存在している。

<!-- Deleting works very similarly to querying. You write a query which -->
<!-- selects the rows to delete and then call the `delete` method on it. -->
<!-- There is again an implicit conversion from `Query` to the special -->
<!-- DeleteInvoker \<scala.slick.driver.JdbcInvokerComponent@DeleteInvoker:JdbcDriver.DeleteInvoker\> -->
<!-- which provides the `delete` method and a self-reference `deleteInvoker`: -->

```scala
val affectedRowsCount = q.delete
val invoker = q.deleteInvoker
val statement = q.deleteStatement
```

削除のためのクエリは単一のテーブルからデータを取得すべきだ。どんな射影も無視されるだろう(常に行を丸々削除する)。

<!-- A query for deleting must only select from a single table. Any -->
<!-- projection is ignored (it always deletes full rows). -->

Inserting
---------

データの挿入は単一のテーブルに対し、カラムの射影に基づいて実行される。テーブルを直接用いる際には、挿入はテーブルの`*`射影関数を用いて実行する。挿入時にテーブルのカラムをいくつか省くと、データベースはテーブル定義に基づき、デフォルト値を利用する。明示的なデフォルト値が無い場合には、型特有なデフォルト値を用いる。挿入に対する全ての関数は[InsertInvoker](http://slick.typesafe.com/doc/2.0.0/api/#scala.slick.driver.JdbcInvokerComponent@InsertInvoker[T]:JdbcDriver.InsertInvoker[T])と[FullInsertInvoker](http://slick.typesafe.com/doc/2.0.0/api/#scala.slick.driver.JdbcInvokerComponent@FullInsertInvoker[U]:JdbcDriver.FullInsertInvoker[U])において定義がなされている。

<!-- Inserts are done based on a projection of columns from a single table. -->
<!-- When you use the table directly, the insert is performed against its `*` -->
<!-- projection. Omitting some of a table's columns when inserting causes the -->
<!-- database to use the default values specified in the table definition, or -->
<!-- a type-specific default in case no explicit default was given. All -->
<!-- methods for inserting are defined in -->
<!-- InsertInvoker \<scala.slick.driver.JdbcInvokerComponent@InsertInvoker[T]:JdbcDriver.InsertInvoker[T]\> -->
<!-- and -->
<!-- FullInsertInvoker \<scala.slick.driver.JdbcInvokerComponent@FullInsertInvoker[U]:JdbcDriver.FullInsertInvoker[U]\>. -->

```scala
coffees += ("Colombian", 101, 7.99, 0, 0)
coffees ++= Seq(
  ("French_Roast", 49, 8.99, 0, 0),
  ("Espresso",    150, 9.99, 0, 0)
)
...
// "sales" and "total" will use the default value 0:
coffees.map(c => (c.name, c.supID, c.price)) += ("Colombian_Decaf", 101, 8.99)
val statement = coffees.insertStatement
val invoker = coffees.insertInvoker
// compiles to SQL:
//   INSERT INTO "COFFEES" ("COF_NAME","SUP_ID","PRICE","SALES","TOTAL") VALUES (?,?,?,?,?)
```

もし`AutoInc`なカラムが挿入操作において含まれていたなら、暗黙的に無視され、データベースは適切な値を生成しようとする。このような場合において、自動生成された主キーのカラムを返却して欲しいと思うだろう。デフォルトでは、`+=`関数は変更の合った行数(通常は1)を返却し、`++=`関数は蓄積したOptionの数を返却する(もしデータベースシステムがカウントを提供しなければ、Noneになるため)。もし特定のカラムを返却させたいのなら、`returning`関数を用いて変更する事が出来る。`+=`からは単一値もしくはタプルを、`+==`からはそれらの値の`Seq`を返す事が出来る。

<!-- When you include an `AutoInc` column in an insert operation, it is -->
<!-- silently ignored, so that the database can generate the proper value. In -->
<!-- this case you usually want to get back the auto-generated primary key -->
<!-- column. By default, `+=` gives you a count of the number of affected -->
<!-- rows (which will usually be 1) and `++=` gives you an accumulated count -->
<!-- in an `Option` (which can be `None` if the database system does not -->
<!-- provide counts for all rows). This can be changed with the `returning` -->
<!-- method where you specify the columns to be returned (as a single value -->
<!-- or tuple from `+=` and a `Seq` of such values from `++=`): -->

```scala
val userId =
  (users returning users.map(_.id)) += User(None, "Stefan", "Zeiger")
```

ちなみに、多くのデータベースシステムではテーブルの自動インクリメントされる主キーを返却する事を許可している。もし他のカラムを返却しようとしたなら、(データベースがサポートしていない場合にも)`SlickException`が実行時(at runtime)に投げられる。

<!-- Note that many database systems only allow a single column to be -->
<!-- returned which must be the table's auto-incrementing primary key. If you -->
<!-- ask for other columns a `SlickException` is thrown at runtime (unless -->
<!-- the database actually supports it). -->

クライアント側から挿入されるデータの代わりに、`Query`によって作成されたデータもしくはデータベースサーバにおいて実行されたスカラー表現を挿入する事もできる。

<!-- Instead of inserting data from the client side you can also insert data -->
<!-- created by a `Query` or a scalar expression that is executed in the -->
<!-- database server: -->

```scala
class Users2(tag: Tag) extends Table[(Int, String)](tag, "users2") {
  def id = column[Int]("id", O.PrimaryKey)
  def name = column[String]("name")
  def * = (id, name)
}
val users2 = TableQuery[Users2]
users2.ddl.create
users2 insert (users.map { u => (u.id, u.first ++ " " ++ u.last) })
users2 insertExpr (users.length + 1, "admin")
```

このような場合では、`AutoInc`カラムは無視されない。

<!-- In these cases, `AutoInc` columns are *not* ignored. -->

Updating
--------

データの更新は、更新するデータを取得し、新たなデータに差し替えるクエリを記述する事で行える。クエリは単一のテーブルから選択された(計算のされていない)カラムが返却されるべきである。更新に関連する関数は[UpdateInvoker](http://slick.typesafe.com/doc/2.0.0/api/#scala.slick.driver.JdbcInvokerComponent@UpdateInvoker[T]:JdbcDriver.UpdateInvoker[T])において定義がなされている。

<!-- Updates are performed by writing a query that selects the data to update -->
<!-- and then replacing it with new data. The query must only return raw -->
<!-- columns (no computed values) selected from a single table. The relevant -->
<!-- methods for updating are defined in -->
<!-- UpdateInvoker \<scala.slick.driver.JdbcInvokerComponent@UpdateInvoker[T]:JdbcDriver.UpdateInvoker[T]\>. -->

```scala
val q = for { c <- coffees if c.name === "Espresso" } yield c.price
q.update(10.49)
...
val statement = q.updateStatement
val invoker = q.updateInvoker
...
// compiles to SQL:
//   update "COFFEES" set "PRICE" = ? where "COFFEES"."COF_NAME" = 'Espresso'
```

今現在、スカラー表現やデータベースに存在するデータを変換して用いる更新処理を行う方法は無い。

<!-- There is currently no way to use scalar expressions or transformations -->
<!-- of the existing data in the database for updates. -->

Compiled Queries
----------------

データベースに対する処理は基本的にいくつかのパラメータに依存している(これはデータベースから探索を行いたいデータのIDの事などである)。クエリを実行するたびに、パラメータを入れた`Query`オブジェクトを作成するような関数をしばしば記述する。しかし、これはSlickにおいてクエリをコンパイルしなおすコストを増長させる。そこで、このようなパラメータが固定されたクエリについて、事前コンパイルを行うことでより効率化する事が出来る。

<!-- Database queries typically depend on some parameters, e.g. an ID for -->
<!-- which you want to retrieve a matching database row. You can write a -->
<!-- regular Scala function to create a parameterized `Query` object each -->
<!-- time you need to execute that query but this will incur the cost of -->
<!-- recompiling the query in Slick (and possibly also on the database if you -->
<!-- don't use bind variables for all parameters). It is more efficient to -->
<!-- pre-compile such parameterized query functions: -->

```scala
def userNameByIDRange(min: Column[Int], max: Column[Int]) =
  for {
    u <- users if u.id >= min && u.id < max
  } yield u.first

val userNameByIDRangeCompiled = Compiled(userNameByIDRange _)
...
// The query will be compiled only once:
val names1 = userNameByIDRangeCompiled(2, 5).run
val names2 = userNameByIDRangeCompiled(1, 3).run
// Also works for .update and .delete
```

これは`Column`パラメータ(もしくはカラムの[レコード](http://slick.typesafe.com/doc/2.0.0/userdefined.html#record-types))を取ったり、`Query`オブジェクトやクエリを返却する全ての関数において上手く機能する。[Compiled](http://slick.typesafe.com/doc/2.0.0/api/#scala.slick.lifted.Compiled)やそのサブクラスのAPIドキュメントを見ると、コンパイルされたクエリの構成についての詳細を知ることが出来る。

<!-- This works for all functions that take `Column` parameters (or -->
<!-- records \<record-types\> of Columns) and return a `Query` object or a -->
<!-- scalar query. See the API documentation for scala.slick.lifted.Compiled -->
<!-- and its subclasses for details on composing compiled queries. -->

コンパイルされたクエリをクエリ処理、更新、削除といった処理に対して用いる事ができる。

<!-- You can use a compiled query for querying, updating and deleting data. -->

Slick 1.0の後方互換のために、`Parameters`オブジェクトの`flatMap`を呼ぶことで依然コンパイルされたクエリを作る事が出来る。多くの場合において、単一のfor式を書くことでコンパイルされたクエリを作る事が出来るだろう。

<!-- For backwards-compatibility with Slick 1.0 you can still create a -->
<!-- compiled query by calling `flatMap` on a scala.slick.lifted.Parameters -->
<!-- object. In many cases this enables you to write a single *for -->
<!-- comprehension* for a compiled query: -->

```scala
val userNameByID = for {
  id <- Parameters[Int]
  u <- users if u.id is id
} yield u.first
...
val name = userNameByID(2).first
...
val userNameByIDRange = for {
  (min, max) <- Parameters[(Int, Int)]
  u <- users if u.id >= min && u.id < max
} yield u.first
...
val names = userNameByIDRange(2, 5).list
```
