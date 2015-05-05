Slick 3.0.0 documentation - 10 Plain SQL Queries

[Permalink to Plain SQL Queries — Slick 3.0.0 documentation](http://slick.typesafe.com/doc/3.0.0/sql.html)

Plain SQLクエリ
=================

もしかすると、高レベルに抽象化されてサポートされたオペレーションに対し、SQLコードをそのまま書きたいといった要求があるかもしれない。そのような場合には、低レベルな[JDBC](http://en.wikipedia.org/wiki/Java_Database_Connectivity)のAPIを用いるのではなく、Slickが提供するScalaベースの _Plain SQL_ を利用して欲しい。
<!-- Sometimes you may need to write your own SQL code for an operation which is not well supported at a higher level of abstraction. Instead of falling back to the low level of JDBC\_, you can use Slick's *Plain SQL* queries with a much nicer Scala-based API.  -->

> **Note**
>
> 本章の残りでは、[Slick Plain SQL Queries template](https://typesafe.com/activator/template/slick-plainsql-3.0)をベースに説明を行う。[Activator](https://typesafe.com/activator)からテンプレートを落としてきて、直接編集したり実行しながら読んでみて欲しい。
<!-- **note** The rest of this chapter is based on the Slick Plain SQL Queries template\_. The prefered way of reading this introduction is in Activator\_, where you can edit and run the code directly while reading the tutorial.  -->

Scaffolding
-----------

データベースのコネクションは、[いつもと同じように](http://slick.typesafe.com/doc/3.0.0/gettingstarted.html#gettingstarted-dbconnection)開かれる。全ての _Plain SQL_ [DBIOActions](http://slick.typesafe.com/doc/3.0.0/api/index.html#slick.dbio.DBIOAction)内で実行される。これは複数のアクションを組み合わせたものする事も可能である。
<!-- The database connection is opened in the usual way \<gettingstarted-dbconnection\>. All *Plain SQL* queries result in DBIOActions \<slick.dbio.DBIOAction\> that can be composed and run like any other action.  -->

String Interpolation
--------------------

Slickの _Plain SQL_ は`sql`、`sqlu`、`tsql`という文字列の補間（string interpolation）を通して組み立てることが出来る。これらはSlickドライバから`api._`をインポートする事で利用可能となる。
<!-- *Plain SQL* queries in Slick are built via string interpolation using the `sql`, `sqlu` and `tsql` interpolators. They are available through the standard `api._` import from a Slick driver:  -->

```scala
import slick.driver.H2Driver.api._
```

最も簡単な使用法としては、以下のようなメソッドの中で利用しているように、`sqlu`の中にSQLコードをそのまま書いてしまうことだ。
<!-- You can see the simplest use case in the following methods where the `sqlu` interpolator is used with a literal SQL string:  -->

```scala
def createCoffees: DBIO[Int] =
  sqlu"""create table coffees(
    name varchar not null,
    sup_id int not null,
    price double not null,
    sales int not null,
    total int not null,
    foreign key(sup_id) references suppliers(id))"""
...
def createSuppliers: DBIO[Int] =
  sqlu"""create table suppliers(
    id int not null primary key,
    name varchar not null,
    street varchar not null,
    city varchar not null,
    state varchar not null,
    zip varchar not null)"""
...
def insertSuppliers: DBIO[Unit] = DBIO.seq(
  // Insert some suppliers
  sqlu"insert into suppliers values(101, 'Acme, Inc.', '99 Market Street', 'Groundsville', 'CA', '95199')",
  sqlu"insert into suppliers values(49, 'Superior Coffee', '1 Party Place', 'Mendocino', 'CA', '95460')",
  sqlu"insert into suppliers values(150, 'The High Ground', '100 Coffee Lane', 'Meadows', 'CA', '93966')"
)
```

`sqlu`補間子は、結果の代わりに列の数を返すDMLステートメントとして用いられる。それゆえ、`sqlu`を用いた場合は返り値の型が`DBIO[Int]`となる。
<!-- The `sqlu` interpolator is used for DML statements which produce a row count instead of a result set. Therefore they are of type `DBIO[Int]`.  -->

クエリに注入される変数や表現は、クエリ文字列の中でバインド変数などで表される。クエリ文字列に直接変数を入れることはしない。このような対応は、SQLインジェクションをなくすためにある。以下の例を見て欲しい。
<!-- Any variable or expression injected into a query gets turned into a bind variable in the resulting query string. It is not inserted directly into a query string, so there is no danger of SQL injection attacks. You can see this used in here:  -->

```scala
def insert(c: Coffee): DBIO[Int] =
  sqlu"insert into coffees values (\${c.name}, \${c.supID}, \${c.price}, \${c.sales}, \${c.total})"
```

このメソッドにより生成されるSQLステートメントは、常に同じものになる。
<!-- The SQL statement produced by this method is always the same: -->

```sql
insert into coffees values (?, ?, ?, ?, ?)
```

この種のコードに役立つ便利な[DBIO.sequence][DBIO.sequence]コンビネータは以下のように利用できる。
<!-- Note the use of the DBIO.sequence \<slick.dbio.DBIO\$@sequence[R,M[+\_]\<:TraversableOnce[\_],E\<:Effect](M[DBIOAction[R,NoStream,E]])(CanBuildFrom[M[DBIOAction[R,NoStream,E]],R,M[R]]):DBIOAction[M[R],NoStream,E]\> combinator which is useful for this kind of code:  -->

```scala
val inserts: Seq[DBIO[Int]] = Seq(
  Coffee("Colombian", 101, 7.99, 0, 0),
  Coffee("French_Roast", 49, 8.99, 0, 0),
  Coffee("Espresso", 150, 9.99, 0, 0),
  Coffee("Colombian_Decaf", 101, 8.99, 0, 0),
  Coffee("French_Roast_Decaf", 49, 9.99, 0, 0)
).map(insert)
...
val combined: DBIO[Seq[Int]] = DBIO.sequence(inserts)
combined.map(_.sum)
```

与えられた順序でデータベースのI/Oアクションを直列に実行するシンプルな[DBIO.seq][DBIO.seq]とは異なり、[DBIO.sequence][DBIO.sequence]は個々のアクションの結果を保護するために、`Seq[DBIO[T]]`を`DBIO[Seq[T]]`へ変換する。これは挿入時に影響のあった列の数を数え上げる際などに用いられている。
<!-- Unlike the simpler DBIO.seq \<slick.dbio.DBIO\$@seq[E\<:Effect](DBIOAction[\_,NoStream,E]\*):DBIOAction[Unit,NoStream,E]\> combinator which runs a (varargs) sequence of database I/O actions in the given order and discards the return values, DBIO.sequence \<slick.dbio.DBIO\$@sequence[R,M[+\_]\<:TraversableOnce[\_],E\<:Effect](M[DBIOAction[R,NoStream,E]])(CanBuildFrom[M[DBIOAction[R,NoStream,E]],R,M[R]]):DBIOAction[M[R],NoStream,E]\> turns a `Seq[DBIO[T]]` into a `DBIO[Seq[T]]`, thus preserving the results of all individual actions. It is used here to sum up the affected row counts of all inserts.  -->

Result Sets
-----------

以下のコードでは、ステートメントにより得られた結果を返却する`sql`補間子を利用している。`sql`補間子自身は`DBIO`の値を生成したりはしない。これは、`.as`というメソッドを返り値となる型を組み合わせて呼び出す必要がある。
<!-- The following code uses tbe `sql` interpolator which returns a result set produced by a statement. The interpolator by itself does not produce a `DBIO` value. It needs to be followed by a call to `.as` to define the row type:  -->

```scala
sql"""select c.name, s.name
      from coffees c, suppliers s
      where c.price < \$price and s.id = c.sup_id""".as[(String, String)]
```

この結果の型は、`DBIO[Seq[(String, String)]]`となる。`as`を呼び出す際には、結果から要求する型の値を抽出する[GetResult](http://slick.typesafe.com/doc/3.0.0/api/index.html#slick.jdbc.GetResult)パラメータを暗黙的に必要としている。基本的なJDBCの型やOption、タプルなどに対する`GetResult`は予め定義されている。それ以外の型に対する`GetResult`は、各自で定義して欲しい。
<!-- This results in a `DBIO[Seq[(String, String)]]`. The call to `as` takes an implicit slick.jdbc.GetResult parameter which extracts data of the requested type from a result set. There are predefined `GetResult` implicits for the standard JDBC types, for Options of those (to represent nullable columns) and for tuples of types which have a `GetResult`. For non-standard return types you have to define your own converters:  -->

```scala
// 適当なケースクラス
case class Supplier(id: Int, name: String, street: String, city: String, state: String, zip: String)
case class Coffee(name: String, supID: Int, price: Double, sales: Int, total: Int)
...
// 結果を抽出するためにGetResult
implicit val getSupplierResult = GetResult(r => Supplier(r.nextInt, r.nextString, r.nextString,
  r.nextString, r.nextString, r.nextString))
implicit val getCoffeeResult = GetResult(r => Coffee(r.<<, r.<<, r.<<, r.<<, r.<<))
```

`GetResult[T]`は`PositionedResult => T`という関数の単なるラッパーにすぎない。`Supplier`のための暗黙的な`GetResult`は、列から`Int`か`String`の値を読み出すために、明示的な`PositionedResult`を用いている。2個めの`Coffee`の例では、期待する型を自動的に導出しようと試みる`<<`というショートカットメソッドを利用している（コンストラクタの呼び出しに対して明らかに型が導出出来る場合にのみ利用可能）。
<!-- `GetResult[T]` is simply a wrapper for a function `PositionedResult => T`. The implicit val for `Supplier` uses the explicit `PositionedResult` methods `getInt` and `getString` to read the next `Int` or `String` value in the current row. The second one uses the shortcut method `<<` which returns a value of whatever type is expected at this place. (Of course you can only use it when the type is actually known like in this constructor call.  -->

Splicing Literal Values
-----------------------

パラメータはSQLステートメントに対してバインド変数を用いて挿入されるわけだが、動的に生成されたSQLコードを呼び出す際などでは、もしかすると直接ステートメントの中にリテラルを書く必要が生じるかもしれない。このような場合には以下の例のように、全ての補間子の中で`\$`の代わりに`#\$`を用いて変数をバインドしてあげれば良い。
<!-- While most parameters should be inserted into SQL statements as bind variables, sometimes you need to splice literal values directly into the statement, for example to abstract over table names or to run dynamically generated SQL code. You can use `#\$` instead of `\$` in all interpolators for this purpose, as shown in the following piece of code:  -->

```scala
val table = "coffees"
sql"select * from #\$table where name = \$name".as[Coffee].headOption
```

Type-Checked SQL Statements
---------------------------

今まで見てきた補間子は、SQLステートメントを実行時に構築する。これはステートメントを構築する安全で簡単な方法となっている一方、単なる埋め込み文字列にしかならない。もしステートメントにシンタックスエラーがあったり、データベースとScalaのコードに何かしら型の違いがあったする場合にも、コンパイル時に検出が出来なく、非常に残念である。そのような場合には、`sql`補間子の代わりに`tsql`補間子を使う事を検討してみて欲しい。
<!-- The interpolators you have seen so far only construct a SQL statement at runtime. This provides a safe and easy way of building statements but they are still just embedded strings. If you have a syntax error in a statement or the types don't match up between the database and your Scala code, this cannot be detected at compile-time. You can use the `tsql` interpolator instead of `sql` to get just that:  -->

```scala
def getSuppliers(id: Int): DBIO[Seq[(Int, String, String, String, String, String)]] =
  tsql"select * from suppliers where id > \$id"
```

`tsql`は`.as`を呼び出す必要無しに、直接`DBIOAction`を生成する。
<!-- Note that `tsql` directly produces a `DBIOAction` of the correct type without requiring a call to `.as`.  -->

`tsql`を利用する際は、SQLコンパイラをデータベースにアクセスさせるために、コンパイル時に解決できる設定を提供してあげる必要がある。これは[StaticDatabaseConfig](http://slick.typesafe.com/doc/3.0.0/api/index.html#slick.backend.StaticDatabaseConfig)アノテーションを利用して明示する。
<!-- In order to give the compiler access to the database, you have to provide a configuration that can be resolved at compile-time. This is done with the slick.backend.StaticDatabaseConfig annotation:  -->

```scala
@StaticDatabaseConfig("file:src/main/resources/application.conf#tsql")
```

上の例だと、`application.conf`というファイルにおける、`"tsql"`というパスを指し示しており、ここには`Database`の設定だけではなく、[StaticDatabaseConfig](http://slick.typesafe.com/doc/3.0.0/api/index.html#slick.backend.StaticDatabaseConfig)オブジェクトのための適切な設定を記述しなくてはならない。
<!-- In this case it points to the path "tsql" in a local `application.conf` file, which must contain an appropriate configiration for a slick.backend.StaticDatabaseConfig object, not just a `Database`.  -->

> **Note**
>
> パスを省いたり、URLのフラグメントのみを指定したりすると、クラスパスにある中から`application.conf`を見つけようとする。また、`resource:`というURLスキーマを利用しても良いが、いずれにしても実行時のクラスパスと異なり、コンパイラ時のクラスパスからそれらは見えるようにする必要がある。ビルドツールによっては設定が出来ないかもしれないため、基本的には`file:`のURLスキーマで相対パスを指定するのが良い。

<!-- **note** You can get `application.conf` resolved via the classpath (as usual) by omitting the path and only specifying a fragment in the URL, or you can use a `resource:` URL scheme for referencing an arbitrary classpath resouce, but in both cases, they have to be on the *compiler's* own classpath, not just the source path or the runtime classpath. Depending on the build tool this may not be possible, so it's usually better to use a relative `file:` URL.  -->

実行時に、設定のされた[DatabaseConfig](http://slick.typesafe.com/doc/3.0.0/api/index.html#slick.backend.DatabaseConfig)を取得させても構わない。
<!-- You can also retrieve the statically configured slick.backend.DatabaseConfig at runtime:  -->

```scala
val dc = DatabaseConfig.forAnnotation[JdbcProfile]
import dc.driver.api._
val db = dc.db
```

ここでは、基本的な`api._`というインポートと`Database`を利用している。同じ設定を用いさせることは特に強制しておらず、Slickドライバと`Database`を他の方法で実行時に渡しても良いし、コンパイル時のチェックのみに`StaticDatabaseConfig`を利用するといった方法も1つの選択肢として考えられる。
<!-- This gives you the Slick driver for the standard `api._` import and the `Database`. Note that it is not mandatory to use the same configuration. You can get a Slick driver and `Database` at runtime in any other way you like and only use the `StaticDatabaseConfig` for compile-time checking.  -->

[DBIO.sequence]: http://slick.typesafe.com/doc/3.0.0/api/index.html#slick.dbio.DBIO\$@sequence[R,M[+_]<:TraversableOnce[_],E<:Effect](M[DBIOAction[R,NoStream,E]])(CanBuildFrom[M[DBIOAction[R,NoStream,E]],R,M[R]]):DBIOAction[M[R],NoStream,E])
[DBIO.seq]: http://slick.typesafe.com/doc/3.0.0/api/index.html#slick.dbio.DBIO\$@seq[E<:Effect](DBIOAction[_,NoStream,E]*):DBIOAction[Unit,NoStream,E]
