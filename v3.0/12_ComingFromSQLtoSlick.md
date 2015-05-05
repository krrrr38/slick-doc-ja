Slick 3.0.0 documentation - 12 Coming from SQL to Slick

[Permalink to Coming from SQL to Slick — Slick 3.0.0 documentation](http://slick.typesafe.com/doc/3.0.0/sql-to-slick.html)

SQLからSlickを利用する人へ
========================

JDBC/SQLを利用していて、Slickに移ってきた場合には躓くことなく学ぶ事が出来るだろう。Slickはコネクションハンドリング、結果の取得、クエリ言語の利用という事についてより良いAPIを備えている。さらに文字列クエリを書くよりも、Scalaを通してより良い記述が行えるようなものを統合している。SQLを知っていてSlickを学ぼうと考えている開発者にとっての主な障壁は、SQLとScalaのコレクションの間にある、よく似た操作に対するセマンティックの違いのみであろう。本章ではこれらの違いについての概要をみていく。概念的な違いを考えた後に、[SQL操作とSlickの操作](http://slick.typesafe.com/doc/3.0.0/sql-to-slick.html#sql-to-slick-operators)の比較を例を通して説明していく。SlickのAPIに関する詳細な説明については、[クエリについての章](http://slick.typesafe.com/doc/3.0.0/queries.html)や[the Scala collections API](http://www.scala-lang.org/api/2.10.0/#scala.collection.immutable.Seq)にあるメソッドを見て欲しい。
<!-- Coming from JDBC/SQL to Slick is pretty straight forward in many ways. Slick can be considered as a drop-in replacement with a nicer API for handling connections, fetching results and using a query language, which is integrated more nicely into Scala than writing queries as Strings. The main obstacle for developers coming from SQL to Slick seems to be the semantic differences of seemingly similar operations between SQL and Scala's collections API which Slick's API imitates. The following sections give a quick overview over the differences. They start with conceptual differences and then list examples of many SQL operators and their Slick equivalents \<sql-to-slick-operators\>. For a more detailed explanations of Slick's API please refer to chapter queries \<queries\> and the equivalent methods in the the Scala collections API \<scala.collection.immutable.Seq\>.  -->

Schema
------

本章ではこのようなデータベーススキーマを例に説明を行う。
<!-- The later examples use the following database schema -->

![image](http://slick.typesafe.com/doc/3.0.0/_images/from-sql-to-slick.person-address.png)

Slickで上記スキーマを記述した際には、以下のように定義出来る。
<!-- mapped to Slick using the following code: -->

```scala
type Person = (Int,String,Int,Int)
class People(tag: Tag) extends Table[Person](tag, "PERSON") {
  def id = column[Int]("ID", O.PrimaryKey, O.AutoInc)
  def name = column[String]("NAME")
  def age = column[Int]("AGE")
  def addressId = column[Int]("ADDRESS_ID")
  def * = (id,name,age,addressId)
  def address = foreignKey("ADDRESS",addressId,addresses)(_.id)
}
lazy val people = TableQuery[People]
...
type Address = (Int,String,String)
class Addresses(tag: Tag) extends Table[Address](tag, "ADDRESS") {
  def id = column[Int]("ID", O.PrimaryKey, O.AutoInc)
  def street = column[String]("STREET")
  def city = column[String]("CITY")
  def * = (id,street,city)
}
lazy val addresses = TableQuery[Addresses]
```

テーブルはケースクラスにマッピングされる。このコードは[自動生成](http://slick.typesafe.com/doc/3.0.0/code-generation.html)しても[手で書いても](http://slick.typesafe.com/doc/3.0.0/schemas.html)良い。
<!-- Tables can alternatively be mapped to case classes. Similar code can be auto-generated \<code-generation\> or hand-written \<schemas\>.  -->

Queries in comparison
---------------------

### JDBC Query

エラーハンドリングを伴うJDBCのクエリはこのように書ける。
<!-- A JDBC query with error handling could look like this: -->

```scala
import java.sql._
Class.forName("org.h2.Driver")
val conn = DriverManager.getConnection("jdbc:h2:mem:test1")
val people = new scala.collection.mutable.MutableList[(Int,String,Int)]()
try{
  val stmt = conn.createStatement()
  try{
    val rs = stmt.executeQuery("select ID, NAME, AGE from PERSON")
    try{
      while(rs.next()){
        people += ((rs.getInt(1), rs.getString(2), rs.getInt(3)))
      }
    }finally{
      rs.close()
    }
  }finally{
    stmt.close()
  }
}finally{
  conn.close()
}
```

Slickはクエリを記述するのに2つの方法を提供してくれている。1つはJDBCのようにSQL文字列をそのまま書くこと、もう1つの方法は型安全で合成可能なクエリを記述する事である。
<!-- Slick gives us two choices how to write queries. One is SQL strings just like JDBC. The other are type-safe, composable queries.  -->

### Slick Plain SQL queries

もしSQLを用いてクエリを書き続けたい、もしくはSlickにまだサポートされていない機能が必要なら、SlickのPlain SQLクエリが役立つ。SlickのPlain SQLを用いて上記の例と同様のクエリを記述すると、以下のようになる。この中にはエラーハンドリングや、非同期実行のために最適化されたリソース管理機能などが含まれている。
<!-- This is useful if you either want to continue writing queries in SQL or if you need a feature not (yet) supported by Slick otherwise. Executing the same query using Slick Plain SQL, which has built-in error-handling and resource management optimized for asynchronous execution, looks like this:  -->

```scala
import slick.driver.H2Driver.api._
...
val db = Database.forConfig("h2mem1")
...
val action = sql"select ID, NAME, AGE from PERSON".as[(Int,String,Int)]
db.run(action)
```

`.list`は結果のリストを返し、`.head`は結果を1つだけ貸す。`.foreach`は全ての結果を1度だけイテレートさせて取り扱うのに用いられる。
<!-- `.list` returns a list of results. `.first` a single result. `.foreach` can be used to iterate over the results without ever materializing all results at once.  -->

### Slick type-safe, composable queries

Slickの重要な機能の1つとして、型安全で合成可能なクエリがある。SlickはScalaからSQLへ変換するためののコンパイラを持っている。基本的なライブラリのサブセットやいくつかの拡張についても利用可能である。Scala開発者はSQLについて知らなくても少しの基本的学習と特定の方言について覚えるだけで、関連データベースに対する多くのクエリを即座に記述する事が出来るようになる。Slickのクエリは合成可能である。これはSQL文字列を結合するかのような、joinに関する条件式であるとか、そのような繰り返し利用されるコードの重複を避けるための再利用可能な部分クエリを記述出来る事を表す。そのようなクエリは型安全であり、コンパイル時に間違いを発見出来るのみならず、SQLインジェクションのリスクをなくす事が出来る。
<!-- Slick's key feature are type-safe, composable queries. Slick comes with a Scala-to-SQL compiler, which allows a (purely functional) sub-set of the Scala language to be compiled to SQL queries. Also available are a subset of the standard library and some extensions, e.g. for joins. The familiarity allows Scala developers to instantly write many queries against all supported relational databases with little learning required and without knowing SQL or remembering the particular dialect. Such Slick queries are composable, which means that you can write and re-use fragments and functions to avoid repetitive code like join conditions in a much more practical way than concatenating SQL strings. The fact that such queries are type-safe not only catches many mistakes early at compile time, but also eliminates the risk of SQL injection vulnerabilities.  -->

型安全なSlickによるクエリは、上記JDBCの例と同じサンプルに対して、以下のように記述出来る。
<!-- The same query written as a type-safe Slick query looks like this: -->

```scala
import slick.driver.H2Driver.api._
...
val db = Database.forConfig("h2mem1")
...
val query = people.map(p => (p.id,p.name,p.age))
db.run(query.result)
```

`.run`は自動的にコレクション風のクエリにはSeqを、スカラ値に対するクエリには単一の結果を返す。`.list`、`.head`、`.foreach`も同様に利用できる。
<!-- `.run` automatically returns a Seq for collection-like queries and a single value for scalar queries. `.list`, `.first` and `.foreach` are also available.  -->

SQL文字列利用する場合と比較して、メソッド呼び出しによりクエリを簡単に組み立てる事が出来る。例として、`query.filter(_.age > 18)`は結果を絞り込むようなクエリを返す。これにより、メンテナンスしやすい、再利用可能なクエリを作成する事ができる。joinに対する条件や、ページング、絞り込みなど、様々な抽象化が行える。
<!-- A key benefit compared to SQL strings is, that you can easily transform the query by calling more methods on it. E.g. `query.filter(_.age > 18)` returns transformed query which further restricts the results. This allows to build libraries of queries, which re-use each other become much more maintainable. You can abstract over join conditions, pagination, filters, etc. -->

Slickはクエリの型チェックを行うための型情報を必要とすることに注意して欲しい。このような型情報は、データベーススキーマと強く紐付いていなくてはならず、上の方で記述したように、TableのサブクラスとTableQueryの値を定義してあげる必要がある。
<!-- It is important to note that Slick needs the type-information to type-check these queries. This type information closely corresponds to the database schema and is provided to Slick in the form of Table sub classes and TableQuery values shown above.  -->

Main obstacle: Semantic API differences
---------------------------------------

ScalaのコレクションのメソッドがSQLに備わっているものと少し異なる事がある。新しくSQLの知識を基にSlickを学ぼうと考えている人にとっては、少し障壁となってしまう可能性がある。特に[groupBy](http://slick.typesafe.com/doc/3.0.0/sql-to-slick.html#groupby)はトリッキーなものに思えるだろう。
<!-- Some methods of the Scala collections work a bit differently than their SQL counter parts. This seems to be one of the main causes of confusion for people newly coming from SQL to Slick. Especially groupBy\_ seems to be tricky.  -->

Slickの型安全なAPIを利用したクエリを記述するための最適なアプローチとして、Scalaのコレクションについて考えてみるのが良い。もしSlickのTableQueryオブジェクトの代わりに、タプルやケースクラスのSeqを扱う場合には、コードはどのようなものになっているだろうか。恐らく同じようなコードを記述する事になるだろう。もしScalaのライブラリの特徴がSlickによってサポートされていなかったり、少し異なるものになっている場合には、別途一時的に対応する必要がある。いくつかの操作に関しては、Scalaの場合よりSlickの場合の方が強い型情報を持つ事がある。違いの1つとして、算術演算には`.asColumnOf[T]`を用いた明示的なキャストを必要とする。またSlickはOption操作のために3つの値のロジックを用いている (`Also Slick uses 3-valued logic for Option inference.`)。
<!-- The best approach to write queries using Slick's type-safe api is thinking in terms of Scala collections. What would the code be if you had a Seq of tuples or case classes instead of a Slick TableQuery object. Use that exact code. If needed adapt it with workarounds where a Scala library feature is currently not supported by Slick or if Slick is slightly different. Some operations are more strongly typed in Slick than in Scala for example. Arithmetic operation in different types require explicit casts using `.asColumnOf[T]`. Also Slick uses 3-valued logic for Option inference.  -->

Scala-to-SQL compilation during runtime
---------------------------------------

Slickは型安全なクエリを提供するために、ScalaからSQLへ変換するためのコンパイラを持っている。このコンパイラはScalaのランタイムに実行され、複雑なクエリに対しては少しばかりの時間を必要とする。クエリが定義される度に1度だけコンパイラが実行されるのは、非常に役立つ。実行時に毎度行われる代わりに、アプリ起動時にコンパイルさせるなど。[Compiled queries](http://slick.typesafe.com/doc/3.0.0/queries.html#compiled-queries)を用いると、再利用のために生成されたSQLをキャッシュさせる事が出来る。
<!-- Slick runs a Scala-to-SQL compiler to implement its type-safe query feature. The compiler runs at Scala run-time and it does take its time which can even go up to second or longer for complex queries. It can be very useful to run the compiler only once per defined query and upfront, e.g. at app startup instead of each execution over and over. Compiled queries \<compiled-queries\> allow you to cache the generated SQL for re-use.  -->

Limitations
-----------

Slickを大々的に使っている場合にいくつかのケースで、Slickの型安全なクエリ言語がクエリオペレータやJDBCの機能を一部サポートしていないために、最適化されてないSQLコードを使いたいといった要求があるかもしれない。これに対処する方法がいくつかある。
<!-- When you use Slick extensively you will run into cases, where Slick's type-safe query language does not support a query operator or JDBC feature you may desire to use or produces non-optimal SQL code. There are several ways to deal with that.  -->

### Missing query operators

Slickに対して、存在していないオペレータを追加してあげる事が出来る。
<!-- Slick is extensible to some degree, which means you can add some kinds of missing operators yourself.  -->

#### Definition in terms of others

Slickに既に存在するオペレータを用いて、何かしらの拡張を行いたい場合には、単にScalaのメソッドを書くか、存在するオペレータに対してメソッドを生やすような暗黙的クラスを書くと良い。以下の例では、`squared`というメソッドを追加している。
<!-- If the operator you desire is expressible using existing Slick operations you can simply write a Scala function or implicit class that implements the operator as a method in terms of existing operators. Here we implement `squared` using multiplication.  -->

```scala
implicit class MyStringColumnExtensions(i: Rep[Int]){
  def squared = i * i
}
...
// usage:
people.map(p => p.age.squared)
```

#### Definition using a database function

もしスカラ値を操作するような基本的オペレータが必要なら、それも実装して拡張してあげたら良い。例えばSlickには`power`というメソッドが無いが、データベースの関数にある`POWER`を呼び出すには、以下のようなマッピングを定義する。
<!-- If you need a fundamental operator, which is not supported out-of-the-box you can add it yourself if it operates on scalar values. For example Slick currently does not have a `power` method out of the box. Here we are mapping it to a database function.  -->

```scala
val power = SimpleFunction.binary[Int,Int,Int]("POWER")
...
// usage:
people.map(p => power(p.age,2))
```

この部分に関する詳細な情報が欲しければ、[Scalar database functions](http://slick.typesafe.com/doc/3.0.0/userdefined.html#scalar-db-functions)を参考にして欲しい。
<!-- More information can be found in the chapter about Scalar database functions \<scalar-db-functions\>.  -->

データベースの関数を利用するクエリを操作するオペレータを追加することは出来ない。これは、SlickのScalaからSQLへ変換するコンパイラが最もシンプルなSQLクエリへコンパイルしようとする際、クエリの構造についての知識を必要とするためである。ゆえに、今現在ではカスタムクエリオペレータを取り扱う事は出来ない（この制限をどうにかしようとするアイデアはいくつかあるが、もう少し調査が必要である）。そのようなオペレータの例として、MySQLのindexヒントなどがある。これはSlickの型安全なAPIではサポートすることができず、ユーザによって追加することも出来ない。もしそのようなオペレータを操作する必要がある場合には、SlickのPlain SQLを使ってクエリを書いて欲しい。もしそのオペレータの返り値が変わらないものである場合には、次章で説明する一時的な解決法を利用することが出来るかもしれない。
<!-- You can however not add operators operating on queries using database functions. The Slick Scala-to-SQL compiler requires knowledge about the structure of the query in order to compile it to the most simple SQL query it can produce. It currently couldn't handle custom query operators in that context. (There are some ideas how this restriction can be somewhat lifted in the future, but it needs more investigation). An example for such operator is a MySQL index hint, which is not supported by Slick's type-safe api and it cannot be added by users. If you require such an operator you have to write your whole query using Plain SQL. If the operator does not change the return type of the query you could alternatively use the workaround described in the following section.  -->

### Non-optimal SQL code

SlickはSQLを生成する際、出来る限りシンプルなクエリを作成しようとする。このアルゴリズムは完璧なものにはなっておらず、目下良いものにしようと開発中である。生成されたクエリが、手で記述したものよりもより複雑なものになってしまうケースもある。オプティマイザやDBMSを通してもこのようなクエリは悪いパフォーマンスとなる場合もある。例えばSlickは時折不必要なサブクエリを生成する。MySQLの5.5以下の場合において、不必要なテーブルスキャンと利用されないインデックスを用いることがある。Slickの開発チームはクエリオプティマイザが最適化出来るようなより良いコードを生成できるように取り組んでいる。このような場合の対処法としては、最適なSQLコードを手で書いてしまうしかない。手で書いたものはSlickのPlain SQLを通して実行できるし、[このようなハック](https://gist.github.com/cvogt/d9049c63fc395654c4b4)を利用するのも良い。この例では、型安全なクエリの対してSQLのコードを取って替えてしまっている。
<!-- Slick generates SQL code and tries to make it as simple as possible. The algorithm doing that is not perfect and under continuous improvement. There are cases where the generated queries are more complicated than someone would write them by hand. This can lead to bad performance for certain queries with some optimizers and DBMS. For example, Slick occasionally generates unnecessary sub-queries. In MySQL \<= 5.5 this easily leads to unnecessary table scans or indices not being used. The Slick team is working towards generating code better factored to what the query optimizers can currently optimize, but that doesn't help you now. To work around it you have to write the more optimal SQL code by hand. You can either run it as a Slick Plain SQL query or you can [use a hack](https://gist.github.com/cvogt/d9049c63fc395654c4b4), which allows you to simply swap out the SQL code Slick uses for a type-safe query.  -->

```scala
people.map(p => (p.id,p.name,p.age))
      .result
      // 手で書いたSQLを注入している (https://gist.github.com/cvogt/d9049c63fc395654c4b4)
      .overrideSql("SELECT id, name, age FROM Person")
```

SQL vs. Slick examples
----------------------

本節では、利用頻度の多いSQLクエリと同じ意味をなすSlickの型安全なクエリとを比較して順に見ていく。
<!-- This section shows an overview over the most important types of SQL queries and a corresponding type-safe Slick query.  -->

### SELECT \*

#### SQL

```scala
sql"select * from PERSON".as[Person]
```

#### Slick

Slickで`SELECT *`という記述は、TableQueryの`result`を指す。
<!-- The Slick equivalent of `SELECT *` is the `result` of the plain TableQuery:  -->

```scala
people.result
```

### SELECT

#### SQL

```scala
sql"""
  select AGE, concat(concat(concat(NAME,' ('),ID),')')
  from PERSON
""".as[(Int,String)]
```

#### Slick

`SELECT`による射影は、Scalaの`map`に相当する。カラムは同様のものを指せば良いし、カラムに対する関数操作はScalaにおける同様のオペレータを基本的にはそのまま用いる事ができる（ただし、文字列の結合には`+`ではなく`++`を用いる）。
<!-- Scala's equivalent for `SELECT` is `map`. Columns can be referenced similarly and functions operating on columns can be accessed using their Scala eqivalents (but allowing only `++` for String concatenation, not `+`).  -->

```scala
people.map(p => (p.age, p.name ++ " (" ++ p.id.asColumnOf[String] ++ ")")).result
```

### WHERE

#### SQL

```scala
sql"select * from PERSON where AGE >= 18 AND NAME = 'C. Vogt'".as[Person]
```

#### Slick

`WHERE`条件は、Scalaの`filter`を用いれば良い。`==`は利用できず、`===`を代わりに用いなければならない。
<!-- Scala's equivalent for `WHERE` is `filter`. Make sure to use `===` instead of `==` for comparison.  -->

```scala
people.filter(p => p.age >= 18 && p.name === "C. Vogt").result
```

### ORDER BY

#### SQL

```scala
sql"select * from PERSON order by AGE asc, NAME".as[Person]
```

#### Slick

`ORDER BY`はScalaの`sortBy`を利用する。複数カラムを用いたソートにはタプルを渡してあげる必要がある。Slickの`.asc`と`.desc`メソッドも昇順・降順を選ぶのに利用出来る。複数回`.sortBy`呼び出しを行うのは、複数カラムに対して`ORDER BY`のと同じ挙動にはならない。複数カラムを用いた`ORDER BY`には、`.sortBy`に1度だけタプルを渡して欲しい。
<!-- Scala's equivalent for `ORDER BY` is `sortBy`. Provide a tuple to sort by multiple columns. Slick's `.asc` and `.desc` methods allow to affect the ordering. Be aware that a single `ORDER BY` with multiple columns is not equivalent to multiple `.sortBy` calls but to a single `.sortBy` call passing a tuple.  -->

```scala
people.sortBy(p => (p.age.asc, p.name)).result
```

### Aggregations (max, etc.)

#### SQL

```scala
sql"select max(AGE) from PERSON".as[Option[Int]].head
```

#### Slick

集約関数については、Scalaにもある同じようなコレクションの操作関数を用いる事ができる。SQLではカラムに対して集約関数を呼び出すが、Slickではコレクションに対し集約メソッドを呼び出す。結果は個々に実行され、スカラー値が返却される。`max`のような集約関数は`NULL`が返る事があるため、SlickではOptionが返却される。
<!-- Aggregations are collection methods in Scala. In SQL they are called on a column, but in Slick they are called on a collection-like value e.g. a complete query, which people coming from SQL easily trip over. They return a scalar value, which can be run individually. Aggregation methods such as `max` that can return `NULL` return Options in Slick.  -->

```scala
people.map(_.age).max.result
```

### GROUP BY

SQLを利用していた人にとって理解しにくいものの1つが、Slickの`groupBy`である。なぜなら、これはSQLとSlickで異なるシグニチャになるためである。SQLの`GROUP BY`はグルーピングを行うkeyで、グループ内の全ての要素をもとにした集合を生成する操作を行うような挙動になる。SQLではグルーピングされたコレクションから1つの値を取得するための、`avg`のような集約関数を実行する事が必要になる。
<!-- People coming from SQL often seem to have trouble understanding Scala's and Slick's `groupBy`, because of the different signatures involved. SQL's `GROUP BY` can be seen as an operation that turns all columns that weren't part of the grouping key into collections of all the elements in a group. SQL requires the use of it's aggregation operations like `avg` to compute single values out of these collections.  -->

#### SQL

```scala
sql"""
  select ADDRESS_ID, AVG(AGE)
  from PERSON
  group by ADDRESS_ID
""".as[(Int,Option[Int])]
```

#### Slick

ScalaのgroupByでは、グルーピングを行うkeyをもとに、各グループを列のListを値とするMapを作成する。各々のカラムをコレクションに自動的に変換したりはしない。SQLで集約を行うような操作をするには、得られたグループから必要なカラムへマッピングする操作行うといったように、Scala側で操作を明示的に行わなくてはならない。
<!-- Scala's groupBy returns a Map of grouping keys to Lists of the rows for each group. There is no automatic conversion of individual columns into collections. This has to be done explicitly in Scala, by mapping from the group to the desired column, which then allows SQL-like aggregation.  -->

```scala
people.groupBy(p => p.addressId)
       .map{ case (addressId, group) => (addressId, group.map(_.age).avg) }
       .result
```

SQLではグループ化された値を集約させる必要がある。そのため、Slickでも同じことを明示的に行わなくてはならない。これはつまり、`groupBy`を呼び出した際には、その後に`map`を呼び出すか、もし呼び出さない場合には例外を吐いて失敗してしまう。Slickのグループ化のシンタックスはSQLのものより少しばかり複雑なのだ。
<!-- SQL requires to aggregate grouped values. We require the same in Slick for now. This means a `groupBy` call must be followed by a `map` call or will fail with an Exception. This makes Slick's grouping syntax a bit more complicated than SQL's.  -->

### HAVING

#### SQL

```scala
sql"""
  select ADDRESS_ID
  from PERSON
  group by ADDRESS_ID
  having avg(AGE) > 50
""".as[Int]
```

#### Slick

Slickは`WHERE`と`HAVING`に対して異なるメソッドを持っていない。`HAVING`を実現するためには、ただ`groupBy`の後に`filter`を行えば良い（さらにその後に`map`も必要）。
<!-- Slick does not have different methods for `WHERE` and `HAVING`. For achieving semantics equivalent to `HAVING`, just use `filter` after `groupBy` and the following `map`.  -->

```scala
people.groupBy(p => p.addressId)
       .map{ case (addressId, group) => (addressId, group.map(_.age).avg) }
       .filter{ case (addressId, avgAge) => avgAge > 50 }
       .map(_._1)
       .result
```

### Implicit inner joins

#### SQL

```scala
sql"""
  select P.NAME, A.CITY
  from PERSON P, ADDRESS A
  where P.ADDRESS_ID = a.id
""".as[(String,String)]
```

#### Slick

Slickは`flatMap`と`map`（つまりfor式）によって暗黙的joinを生成する。
<!-- Slick generates SQL using implicit joins for `flatMap` and `map` or the corresponding for-expression syntax.  -->

```scala
people.flatMap(p =>
  addresses.filter(a => p.addressId === a.id)
           .map(a => (p.name, a.city))
).result
...
// for式で同じ記述をすると、以下のようになる
(for(p <- people;
     a <- addresses if p.addressId === a.id
  ) yield (p.name, a.city)
).result
```

### Explicit inner joins

#### SQL

```scala
sql"""
  select P.NAME, A.CITY
  from PERSON P
  join ADDRESS A on P.ADDRESS_ID = a.id
""".as[(String,String)]
```

#### Slick

Slickで明示的joinを生成するには、以下のようなDSLで書ける。
<!-- Slick offers a small DSL for explicit joins. -->

```scala
(people join addresses on (_.addressId === _.id))
  .map{ case (p, a) => (p.name, a.city) }.result
```

### Outer joins (left/right/full)

#### SQL

```scala
sql"""
  select P.NAME,A.CITY
  from ADDRESS A
  left join PERSON P on P.ADDRESS_ID = a.id
""".as[(Option[String],String)]
```

#### Slick
outer joinはSlickの明示的なjoin DSLを使って書ける。注意して欲しいのはouter joinのSQLを用いると、結合時にnullにならないカラムがnullになり得る事だ。これに対しSlickでは、結合時にはそのようなカラムは`Option`を返すようにしている。これに関して、結合時にマッチしなかった列と、元々NULLが含まれていてマッチした列との区別をすることが出来るようになっており、SQL本来の機能より良いものになっている。
<!-- Outer joins are done using Slick's explicit join DSL. Be aware that in case of an outer join SQL changes the type of outer joined, non-nullable columns into nullable columns. In order to represent this in a clean way even in the presence of mapped types, Slick lifts the whole side of the join into an `Option`. This goes a bit further than the SQL semantics because it allows you to distinguish a row which was not matched in the join from a row that was matched but already contained nothign but NULL values.  -->

```scala
(addresses joinLeft people on (_.id === _.addressId))
  .map{ case (a, p) => (p.map(_.name), a.city) }.result
```

### Subquery

#### SQL

```scala
sql"""
  select *
  from PERSON P
  where P.ID in (select ID
                 from ADDRESS
                 where CITY = 'New York City')
""".as[Person]
```

#### Slick

Slickのクエリが合成可能である。サブクエリは単に予め用意されたクエリを用いるだけで済む。
<!-- Slick queries are composable. Subqueries can be simply composed, where the types work out, just like any other Scala code.  -->

```scala
val address_ids = addresses.filter(_.city === "New York City").map(_.id)
people.filter(_.id in address_ids).result // <- run as one query
```

`.in`にはサブクエリを渡す。インメモリのScalaコレクションに対しては`.inSet`を用いる。
<!-- The method `.in` expects a sub query. For an in-memory Scala collection, the method `.inSet` can be used instead.  -->

### Scalar value subquery / custom function

#### SQL

```scala
sql"""
  select * from PERSON P,
                     (select rand() * MAX(ID) as ID from PERSON) RAND_ID
  where P.ID >= RAND_ID.ID
  order by P.ID asc
  limit 1
""".as[Person].head
```

#### Slick

このコードでは[user-defined database function](http://slick.typesafe.com/doc/3.0.0/userdefined.html)で説明した、単一の値を計算して返す関数を用いたサブクエリの使い方を示している。
<!-- This code shows a subquery computing a single value in combination with a user-defined database function \<userdefined\>.  -->

```scala
val rand = SimpleFunction.nullary[Double]("RAND")
...
val rndId = (people.map(_.id).max.asColumnOf[Double] * rand).asColumnOf[Int]
...
people.filter(_.id >= rndId)
      .sortBy(_.id)
      .result.head
```

### insert

#### SQL

```scala
sqlu"""
insert into PERSON (NAME, AGE, ADDRESS_ID) values ('M Odersky', 12345, 1)
"""
```

#### Slick

SQLを学んでいた人から見ると、挿入操作は初めに驚くべきポイントの1つになると思う。なぜなら、SQLと違ってSlickでは挿入すべきカラムを選択したクエリを再利用させる事が出来るからである。基本的には初めに選択用のクエリを書き、挿入を実行するActionとして`+=`を呼び出す。一度に複数の列を挿入する際には、`++=`にSeqを渡す。auto incrementなカラムは自動的に無視される。`forceInsert`を用いると、auto incrementされたカラムへ直接値を挿入することが出来る。
<!-- Inserts can be a bit surprising at first, when coming from SQL, because unlike SQL, Slick re-uses the same syntax that is used for querying to select which columns should be inserted into. So basically, you first write a query and instead of creating an Action that gets the result of this query, you call `+=` on with value to be inserted, which gives you an Action that performs the insert. `++=` allows insertion of a Seq of rows at once. Columns that are auto-incremented are automatically ignored, so inserting into them has no effect. Using `forceInsert` allows actual insertion into auto-incremented columns.  -->

```scala
people.map(p => (p.name, p.age, p.addressId)) += ("M Odersky",12345,1)
```

### update

#### SQL

```scala
sqlu"""
update PERSON set NAME='M. Odersky', AGE=54321 where NAME='M Odersky'
"""
```

#### Slick

挿入時と同じように、更新操作も更新を行いたいデータをfilterなどを用いて選択した後に、`.update`により値を更新させる。
<!-- Just like inserts, updates are based on queries that select and filter what should be updated and instead of running the query and fetching the data `.update` is used to replace it.  -->

```scala
people.filter(_.name === "M Odersky")
      .map(p => (p.name,p.age))
      .update(("M. Odersky",54321))
```

### delete

#### SQL

```scala
sqlu"""
delete PERSON where NAME='M. Odersky'
"""
```

#### Slick

こちらも挿入時と同じように、削除したいデータを選択した後に削除を行う。クエリの結果を得るためではなく、`.delete`は選択された列を削除するActionを得るために用いられる。
<!-- Just like inserts, deletes are based on queries that filter what should be deleted. Instead of getting the query result of the query, `.delete` is used to obtain an Action that deletes the selected rows.  -->

```scala
people.filter(p => p.name === "M. Odersky")
      .delete
```

### CASE

#### SQL

```scala
sql"""
  select
    case
      when ADDRESS_ID = 1 then 'A'
      when ADDRESS_ID = 2 then 'B'
    end
  from PERSON P
""".as[Option[String]]
```

#### Slick

Slickでは`CASE`のための、[小さなDSL](http://slick.typesafe.com/doc/3.0.0/api/index.html#slick.lifted.Case\$)を用意している。
<!-- Slick uses a small DSL \<slick.lifted.Case\$\> to allow `CASE` like case distinctions.  -->

```scala
people.map(p =>
  Case
    If(p.addressId === 1) Then "A"
    If(p.addressId === 2) Then "B"
).result
```
