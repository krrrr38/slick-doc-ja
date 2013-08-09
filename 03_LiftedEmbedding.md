Slick 1.0.0 documentation - 03 Lifted Embedding
<!--Lifted Embedding — Slick 1.0.0 documentation-->

[Permalink to Lifted Embedding — Slick 1.0.0 documentation](http://slick.typesafe.com/doc/1.0.0/lifted-embedding.html)

# Lifted Embedding

*lifted embedding* はSlickにおいて型安全なクエリ操作が行える基本的なAPIである．導入には[*始めよう*][1]を読んで欲しい．この章ではSlick及び *lifted embedding* の特徴と詳細について説明する．

<!-- The *lifted embedding* is the standard API for type-safe queries and updates in Slick. Please see [*Getting Started*][1] for an introduction. This chapter describes the available features in more detail.-->

*Lifted Embedding* という名前はScalaの基本的な型を用いる[*direct embedding*][2]と異なり，scala.slick.lifted.Repの型コンストラクタへと変化するような型を用いている事に基づいている．これはScalaのシンプルなコレクションと， *lifted embedding* を用いたコードを比べると明らかである．

<!-- The name *Lifted Embedding* refers to the fact that you are not working with standard Scala types (as in the [*direct embedding*][2]) but with types that are *lifted* into a the scala.slick.lifted.Rep type constructor. This becomes clear when you compare the types of a simple Scala collections example -->

こちらがScalaのコレクションの操作，

```scala
case class Coffee(name: String, price: Double)
val l: List[Coffee] = //...
val l2 = l.filter(_.price > 8.0).map(_.name)
//                  ^       ^          ^
//                Double  Double     String
```

そしてこちらが *Lifted Embedding* を用いた操作である．

<!-- ... with the types of similar code using the lifted embedding: -->

```scala
object Coffees extends Table[(String, Int, Double, Int, Int)]("COFFEES") {
  def name = column[String]("COF_NAME", O.PrimaryKey)
  def price = column[Double]("PRICE")
  //...
}
val q = Query(Coffees)
val q2 = q.filter(_.price > 8.0).map(_.name)
//                  ^       ^          ^
//          Rep[Double]  Rep[Double]  Rep[String]
```

シンプルな型はRepへと変換させられる．レコードの型であるCoffeesは，Rep[(String, Int, Double, Int, Int)]のサブタイプへ，8.0といった数値リテラルも，自動的なimplicit conversionにより，Rep[Double]へと変化する．というのも，Rep[Double]における**>**オペレータの右辺にその型が必要になるためである．

<!-- All plain types are lifted into Rep. The same is true for the record type Coffees which is a subtype of Rep[(String, Int, Double, Int, Int)]. Even the literal 8.0 is automatically lifted to a Rep[Double] by an implicit conversion because that is what the > operator on Rep[Double] expects for the right-hand side.-->

## テーブル

lifted embeddingを用いるためには，データベースのテーブル毎に，テーブルオブジェクトを定義する必要がある．

<!-- In order to use the lifted embedding, you need to define Table objects for your database tables: -->

```scala
object Coffees extends Table[(String, Int, Double, Int, Int)]("COFFEES") {
  def name = column[String]("COF_NAME", O.PrimaryKey)
  def supID = column[Int]("SUP_ID")
  def price = column[Double]("PRICE")
  def sales = column[Int]("SALES")
  def total = column[Int]("TOTAL")
  def * = name ~ supID ~ price ~ sales ~ total
}
```

Slickはテーブルオブジェクトを複製してテーブルを作成するため，不要な状態等を付与すべきではない（操作するための関数に関しては問題無い）．Tableを継承するオブジェクトは *静的な位置* （トップレベルや他のオブジェクトの中でのみネストされた場所）で定義されることは無い．これはscalacによって行われる最適化で，不要な責務まで持ってしまうという問題を防止するためである．匿名の構造型を用いたり区別されたクラス定義を用いることで，テーブル内でvalを用いる事は推奨している．

<!-- Note that Slick clones your table objects under the covers, so you should not add any extra state to them (extra methods are fine though). Also make sure that an actual object for a table is not defined in a *static* location (i.e. at the top level or nested only inside other objects) because this can cause problems in certain situations due to an overeager optimization performed by scalac. Using a val for your table (with an anonymous structural type or a separate class definition) is fine everywhere.-->


全てのカラムはカラムメソッドを通して定義される．カラムはvalではなくdefを用いて定義しなくてはならない．これはカラムは複製する必要があるためである．各々のカラムはScalaの型とデータベースにおけるカラム名（一般的には大文字）を持っている．以下のプリミティブ型については，各データベースドライバーによって課せられた特定の制限を持ちつつも，基本的にはそのまま用いる事が出来る．

<!-- All columns are defined through the column method. Note that they need to be defined with def and not val due to the cloning. Each column has a Scala type and a column name for the database (usually in upper-case). The following primitive types are supported out of the box (with certain limitations imposed by the individual database drivers): -->

*   *数値型*: Byte, Short, Int, Long, BigDecimal, Float, Double
*   *LOB型*: java.sql.Blob, java.sql.Clob, Array[Byte]
*   *Date型*: java.sql.Date, java.sql.Time, java.sql.Timestamp
*   Boolean
*   String
*   Unit
*   java.util.UUID

nullを許可するカラムについては，Tがプリミティブ型である際には，Option[T]を用いて表す事が出来る．ただし，Optionの全ての操作に関して，現在ではScalaのOptionセマンティクスとは少し異なったデータベースのnullプロパゲーションセマンティクスを用いている．（例として，None === None はfalseを返す）．このような挙動は将来的に改善される予定だ．

<!-- Nullable columns are represented by Option[T] where T is one of the supported primitive types. Note that all operations on Option values are currently using the database’s null propagation semantics which may differ from Scala’s Option semantics. In particular, None === None evaluates to false. This behaviour may change in a future major release of Slick.-->

カラム名の後には，カラムの定義に関するオプションを追記することができる．それらのオプションはテーブルのOオブジェクトを通して利用する事が出来る．例として，以下のようなオプションを用いることが出来る．

<!-- After the column name, you can add optional column options to a column definition. The applicable options are available through the table’s O object. The following ones are defined for BasicProfile:-->

**NotNull**, **Nullable**

nullを許可する，nullを許可しないといったことを，DDLの作成時に明示するもの．nullに出来るかどうかといったことは，OptionかOptionで無いかといったように，型からも決定させることが出来る．

<!-- Explicitly mark the column a nullable or non-nullable when creating the DDL statements for the table. Nullability is otherwise determined from the type (Option or non-Option).-->

**PrimaryKey**

DDLを作成する際に，主キーとしてカラムを宣言する．

<!-- Mark the column as a (non-compound) primary key when creating the DDL statements.-->

**Default\[T\](defaultValue: T)**

データをテーブルに挿入する際に用いるデフォルト値を指定する．この情報はDDLを作成する時にのみ用いられる．

<!-- Specify a default value for inserting data the table without this column. This information is only used for creating DDL statements so that the database can fill in the missing information. -->

**DBType(dbType: String)**

DDLに特定のデータベースの型を用いる際に利用する．例えばStringのカラムに対してVARCHAR(20)を指定する際には，DBType("VARCHAR(20)")と明示する．

<!-- Use a non-standard database-specific type for the DDL statements (e.g. DBType("VARCHAR(20)") for a String column).-->

**AutoInc**

DDLを作成する際に，カラムに対して自動インクリメントなキーとして指定させる．他のカラムのオプションとは異なり，このオプションはDDLを作成する時以外に意味を持つ．多くのデータベースではデータを挿入する際に，自動インクリメントでないカラムを返す事を許可していない．そこでSlickでは返されるカラムが自動インクリメントとなっているかどうかを必要に応じてチェックする．

<!-- Mark the column as an auto-incrementing key when creating the DDL statements. Unlike the other column options, this one also has a meaning outside of DDL creation: Many databases do not allow non-AutoInc columns to be returned when inserting data (often silently ignoring other columns), so Slick will check if the return column is properly marked as AutoInc where needed. -->

全てのテーブルではデフォルトの射影となる\*関数を必要とする．これはクエリから行を返すときどのような形で値を返すかを指定するものである．Slickの\*射影はデータベースから通常得られる射影と全く同じにする必要は無い．何らかの計算を行った新しいカラムを作成してもいいし．いくつかのカラムを省略してしまっても良い，\*射影で得られる型と同じ型パラメータをテーブルへ指定する．おおよそこれは単一のカラム型か，カラム型のタプルになるだろう．

<!-- Every table requires a * method contatining a default projection. This describes what you get back when you return rows (in the form of a table object) from a query. Slick’s * projection does not have to match the one in the database. You can add new columns (e.g. with computed values) or omit some columns as you like. The non-lifted type corresponding to the * projection is given as a type parameter to Table. For simple, non-mapped tables, this will be a single column type or a tuple of column types. -->

## 拡張テーブル

自分で定義したクラスに対し，テーブルをマッピングする事も出来る．オペレータを用いる事で，双方向マッピングにより*射影がその型に対応するようになる．

<!-- It is possible to define a mapped table that uses a custom type for its * projection by adding a bi-directional mapping with the  operator:-->

```scala
case class User(id: Option[Int], first: String, last: String)

object Users extends Table[User]("users") {
  def id = column[Int]("id", O.PrimaryKey, O.AutoInc)
  def first = column[String]("first")
  def last = column[String]("last")
  def * = id.? ~ first ~ last <> (User, User.unapply _)
}
```

Optionで結果をラップしたシンプルなapplyメソッドとunapplyメソッドを持つcase Classへと最適化されるが，マッピングされた型を直接操作するオーバーロードも存在している．

<!-- It is optimized for case classes (with a simple apply method and an unapply method that wraps its result in an Option) but there is also an overload that operates directly on the mapped types. -->

## 制約

外部キー制約はテーブルのforeignKeyメソッドによって定義される．制約，カラム（または行），リンクされるテーブル，そしてテーブルから一致する行への関数として，特定の名前を与える必要がある．DDLを作成する際に，外部キーはその名前を用いて追加される．

<!-- A foreign key constraint can be defined with a table’s foreignKey method. It takes a name for the constraint, the local column (or projection, so you can define compound foreign keys), the linked table, and a function from that table to the corresponding column(s). When creating the DDL statements for the table, the foreign key definition is added to it.-->

```scala
object Suppliers extends Table[(Int, String, String, String, String, String)]("SUPPLIERS") {
  def id = column[Int]("SUP_ID", O.PrimaryKey)
  //...
}

object Coffees extends Table[(String, Int, Double, Int, Int)]("COFFEES") {
  def supID = column[Int]("SUP_ID")
  //...
  def supplier = foreignKey("SUP_FK", supID, Suppliers)(_.id)
}
```    

データベースにおける実際の制約とは独立に， *join* を用いてデータを結合する際に，外部キーは利用される．この時，joinされたデータを探すための自分で定義した便利な関数のように動作させる事が出来る．

<!-- Independent of the actual constraint defined in the database, such a foreign key can be used to navigate to the linked data with a *join*. For this purpose, it behaves the same as a manually defined utility method for finding the joined data:-->

```scala
def supplier = foreignKey("SUP_FK", supID, Suppliers)(_.id)
def supplier2 = Suppliers.where(_.id === supID)
```

主キー制約はprimaryKey関数を追加する事で，同様に定義することが出来る．これは複合主キーを定義する際に役立つ．複合主キーを用いる際は，カラムのオプションにO.PrimaryKeyをつける事は出来ない．

<!-- A primary key constraint can be defined in a similar fashion by adding a method that calls primaryKey. This is useful for defining compound primary keys (which cannot be done with the O.PrimaryKey column option):-->

```scala
object A extends Table[(Int, Int)]("a") {
  def k1 = column[Int]("k1")
  def k2 = column[Int]("k2")
  def * = k1 ~ k2
  def pk = primaryKey("pk_a", (k1, k2))
}
```

他のindexについてはindex関数を用いて同様に定義することが可能だ．uniqueパラメータを設定しなければ，デフォルトでは各indexはuniqueでは無い状態になっている．

<!-- Other indexes are defined in a similar way with the index method. They are non-unique by default unless you set the unique parameter:-->

```scala
object A extends Table[(Int, Int)]("a") {
  def k1 = column[Int]("k1")
  def k2 = column[Int]("k2")
  def * = k1 ~ k2
  def idx = index("idx_a", (k1, k2), unique = true)
}
```

全ての制約はテーブルで定義された適切な返り値を持つ関数を探す際に，反射的に適応される．これはtableConstraints関数をオーバーライドすることにより自由にカスタマイズする事が出来る．

<!-- All constraints are discovered reflectively by searching for methods with the appropriate return types which are defined in the table. This behavior can be customized by overriding the tableConstraints method.-->

## Data Definition Language

DDLステートメントはddl関数を用いて作成される．複数のDDLオブジェクトは++を用いて正しい順番にcreateとdropが行われるように連結される．これはテーブルの依存関係が循環している場合にも上手く機能する．ステートメントはcreate関数やdrop関数を用いて実行される．

<!-- DDL statements for a table can be created with its ddl method. Multiple DDL objects can be concatenated with ++ to get a compound DDL object which can create and drop all entities in the correct order, even in the presence of cyclic dependencies between tables. The statements are executed with the create and drop methods:-->

```scala
val ddl = Coffees.ddl ++ Suppliers.ddl
db withSession {
  ddl.create
  //...
  ddl.drop
}
```

SQLのコードを取得するには，createStatementsやdropStatements関数を用いると良い．

<!-- You can use the createStatements and dropStatements methods to get the SQL code:-->

```scala
ddl.createStatements.foreach(println)
ddl.dropStatements.foreach(println)
``` 

## Expressions

プリミティブ値（not 複合型，not コレクション）は，TypeMapper[T]が存在していれば，Rep[T]のサブタイプであるColumn[T]という型によって表される．内部的に用いられるいくつかの特別な関数と，nullを許可するかnullを許可しないカラム間の変換を行う関数のみ，Columnクラスで定義がなされている．

<!--Primitive (non-compound, non-collection) values are representend by type Column[T] (a sub-type of Rep[T]) where a TypeMapper[T] must exist. Only some special methods for internal use and those that deal with conversions between nullable and non-nullable columns are defined directly in the Column class.-->

lifted embeddingにおいて一般的に用いられているオペレータや他の関数については，ExtensionMethodConversionsで定義された暗黙的な変換を通して追加される．実際の関数は，AnyExtensionMethods，ColumnExtensionMethods，NumericColumnExtensionMethods，BooleanColumnExtensionMethods，StringColumnExtensionMethodsといったクラスの中にある．

<!-- The operators and other methods which are commonly used in the lifted embedding are added through implicit conversions defined in ExtensionMethodConversions. The actual methods can be found in the classes AnyExtensionMethods, ColumnExtensionMethods, NumericColumnExtensionMethods, BooleanColumnExtensionMethods and StringColumnExtensionMethods.-->

コレクションはflatMap，filter，take，groupByといったコレクションに本来用意されている基本的な関数を持った，Queryクラス（Rep[Seq[T]]）によって表されている．変換された型とシンプルな型といったようなQueryの異なる2つの複合型により，先のような関数はとても複雑なものになる．しかし，意味的にはScalaのコレクションと本質は同じになる．

<!--Collection values are represented by the Query class (a Rep[Seq[T]]) which contains many standard collection methods like flatMap, filter, take and groupBy. Due to the two different component types of a Query (lifted and plain), the signatures for these methods are very complex but the semantics are essentially the same as for Scala collections.-->

それ以外にも，複合でない値のクエリのための関数がSingleColumnQueryExtensionMethodsへ暗黙的な変換を通して追加されている．

<!--Additional methods for queries of non-compound values are added via an implicit conversion to SingleColumnQueryExtensionMethods.-->

## ソートとフィルタリング（Sorting, Filtering）

様々な種類のソートやフィルタリングが存在している．例えばQueryを引数に，同じ型である新しいQueryを返すものなどがある．

<!--There are various methods with sorting/filtering semantics (i.e. they take a Query and return a new Query of the same type), for example:-->

```scala
val q = Query(Coffees)
val q1 = q.filter(_.supID === 101)
val q2 = q.drop(10).take(5)
val q3 = q.sortBy(_.name.desc.nullsFirst)
``` 

## 結合（Join, Zipping）

joinは1つのクエリで異なる2つの異なったテーブルやクエリを結合させるために用いられる．

<!--Joins are used to combine two different tables or queries into a single query.-->

joinを記述するには2つの方法がある． *明示的な* joinは2つのクエリを，個々の結果であるタプルの単一クエリへと結合させる関数を呼び出すことによって行う． *暗黙的な* joinは特別な関数を呼び出すこと無く，クエリを特定の形へと変形させる．

<!-- There are two different ways of writing joins: *Explicit* joins are performed by calling a method that joins two queries into a single query of a tuple of the individual results. *Implicit* joins arise from a specific shape of a query without calling a special method.-->

*暗黙的な交差結合（cross-join）* はQueryにおいてflatMapを用いることで実装出来る．for式を用いることでより簡単に表現することが可能だ．

<!--An *implicit cross-join* is created with a flatMap operation on a Query (i.e. by introducing more than one generator in a for-comprehension):-->

```scala
val implicitCrossJoin = for {
  c <- Coffees
  s <- Suppliers
} yield (c.name, s.name)
```

もしfilterのような操作を行った場合には，それは暗黙的な内部結合（inner-join）となる．

<!--If you add a filter expression, it becomes an implicit inner join:-->

```scala
val implicitInnerJoin = for {
  c <- Coffees
  s <- Suppliers if c.supID === s.id
} yield (c.name, s.name)
```

これらの暗黙的な結合はScalaコレクションにおけるflatMapを用いた時と全く同じような意味を持つ．

<!--The semantics of these implicit joins are the same as when you are using flatMap on Scala collections.-->

明示的な結合はjoin関数を呼び出す事で作成出来る．

<!--Explicit joins are created by calling one of the available join methods:-->

```scala
val explicitCrossJoin = for {
  (c, s) <- Coffees innerJoin Suppliers
} yield (c.name, s.name)

val explicitInnerJoin = for {
  (c, s) <- Coffees innerJoin Suppliers on (_.supID === _.id)
} yield (c.name, s.name)

val explicitLeftOuterJoin = for {
  (c, s) <- Coffees leftJoin Suppliers on (_.supID === _.id)
} yield (c.name, s.name.?)

val explicitRightOuterJoin = for {
  (c, s) <- Coffees rightJoin Suppliers on (_.supID === _.id)
} yield (c.name.?, s.name)

val explicitFullOuterJoin = for {
  (c, s) <- Coffees outerJoin Suppliers on (_.supID === _.id)
} yield (c.name.?, s.name.?)
```

交差結合や内部結合の明示的なversionsは，暗黙的なversions（大抵はSQLにおける暗黙的な結合）として生成されるSQLのコードへと帰着する．外部結合における.?の利用には注意して欲しい．これらの結合は付随的なNULL（左外部結合における右辺，右外部結合における左辺，完全外部結合における両辺）を生み出すが，そこからOption値を取得する事が出来る．

<!-- The explicit versions of the cross join and inner join will result in the same SQL code being generated as for the implicit versions (usually an implicit join in SQL). Note the use of .? in the outer joins. Since these joins can introduce additional NULL values (on the right-hand side for a left outer join, on the left-hand sides for a right outer join, and on both sides for a full outer join), you have to make sure to retrieve Option values from them.-->

交差結合や外部結合によらない関係データベースによってサポートされる一般的なjoinオペレータに加えて，Slickでは2つのクエリのペアワイズ結合を生成するzip joinを用意している．またそれは，ScalaのコレクションにおけるzipやzipWith関数を用いた時と全く同じような意味を持つ．

<!--In addition to the usual join operators supported by relational databases (which are based off a cross join or outer join), Slick also has zip joins which create a pairwise join of two queries. The semantics are again the same as for Scala collections, using the zip and zipWith methods:-->

```scala
val zipJoinQuery = for {
  (c, s) <- Coffees zip Suppliers
} yield (c.name, s.name)

val zipWithJoin = for {
  res <- Coffees.zipWith(Suppliers, (c: Coffees.type, s: Suppliers.type) => (c.name, s.name))
} yield res
```

zip joinにはzipWithIndexのような特有な結合がある．これは0から始まる無限長の数列をクエリの結果と結合させる．SQLデータベースではそのような数列を表すことが出来ないし，Slickも現在ではそれについてサポートしていない（今後変更するかもしれない）．しかし，zipされたクエリ結果というのは行番号関数を用いる事でSQLにおいても表現する事が出来る．つまりzipWithIndexはプリミティブなオペレータとしてサポートされているのである．

<!-- A particular kind of zip join is provided by zipWithIndex. It zips a query result with an infinite sequence starting at 0. Such a sequence cannot be represented by an SQL database and Slick does not currently support it, either (but this is expected to change in the future). The resulting zipped query, however, can be represented in SQL with the use of a row number function, so zipWithIndex is supported as a primitive operator:-->

```scala
val zipWithIndexJoin = for {
  (c, idx) <- Coffees.zipWithIndex
} yield (c.name, idx)
```

## 連結（Unions）

適応可能な型については，unionやunionAllというオペレータを用いて2つのクエリを連結させる事が出来る．

<!-- Two queries can be concatenated with the union and unionAll operators if they have compatible types:-->

```scala
val q1 = Query(Coffees).filter(_.price < 8.0)
val q2 = Query(Coffees).filter(_.price > 9.0)
val unionQuery = q1 union q2
val unionAllQuery = q1 unionAll q2
```

複製された値をフィルタリングするような結合と異なり，unionAllではシンプルに，時折より効率的に，複数のクエリを結合させる．

<!--Unlike union which filters out duplicate values, unionAll simply concatenates the queries, which is usually more efficient.-->

## 集約（Aggregation）

集約の簡単な例として，単一のカラムを返すクエリからプリミティブ値を計算する事を考える．単一のカラムというのは基本的に数値型となる．

<!--The simplest form of aggregation consists of computing a primitive value from a Query that returns a single column, usually with a numeric type, e.g.:-->

```scala
val q = Coffees.map(_.price)
val q1 = q.min
val q2 = q.max
val q3 = q.sum
val q4 = q.avg
```

以下のような集約関数は任意のクエリにおいて実行する事が出来る．

<!--Some aggregation functions are defined for arbitrary queries:-->

```scala
val q = Query(Coffees)
val q1 = q.length
val q2 = q.exists
```

グループ化はgroupByメソッドによって実装されている．これもScalaのコレクション操作と同じ様に機能する．

<!--Grouping is done with the groupBy method. It has the same semantics as for Scala collections:-->

```scala
val q = (for {
  c <- Coffees
  s <- c.supplier
} yield (c, s)).groupBy(_._1.supID)

val q2 = q.map { case (supID, css) =>
  (supID, css.length, css.map(_._1.price).avg)
}
```

<!--TODO よくわからない...-->

Note that the intermediate query q contains nested values of type Query. These would turn into nested collections when executing the query, which is not supported at the moment. Therefore it is necessary to flatten the nested queries by aggregating their values (or individual columns) as done in q2.

## クエリの実行（Querying）

Queryは[Invoker][3]トレイト（パラメータが無い場合には[UnitInvoker][4] ）において定義されたメソッドを用いて実行される．Queryからの暗黙的な変換が存在しているため，全てのQueryを直接的に実行する事が出来る．もっとも一般的な使用方法は，listといった特定の関数や，様々な種類のコレクションを生成する関数（to[Vector]など）を用いてコレクションへと結果を変換させる事である．

<!--Queries are executed using methods defined in the [Invoker][3] trait (or [UnitInvoker][4] for the parameterless versions). There is an implicit conversion from Query, so you can execute any Query directly. The most common usage scenario is reading a complete result set into a strict collection with a specialized method such as list or the generic method to which can build any kind of collection:-->

```scala
val l = q.list
val v = q.to[Vector]
val invoker = q.invoker
val statement = q.selectStatement
```

この例では，明示的に暗黙的な変換メソッドを呼び出す事無しに，invokerへの参照をどのようにして取得するのかを表している．

<!--This snippet also shows how you can get a reference to the invoker without having to call the implicit conversion method manually.-->

クエリを実行する全てのメソッドは暗黙的にSessionの値を保持している．もちろん，明示的にsessionを通しても構わない．

<!-- All methods that execute a query take an implicit Session value. Of course, you can also pass a session explicitly if you prefer:-->

```scala
val l = q.list(session)
```

もし返り値として一つだけの値を返したいなら，firstやfirstOptionといったメソッドを使う事が出来る．foreach, foldLeft, elementsといったメソッドは全てのデータをScalaのコレクションへとコピーする事なしに，得られた結果をイテレートさせて利用する事が出来る．

<!-- If you only want a single result value, you can use first or firstOption. The methods foreach, foldLeft and elements can be used to iterate over the result set without first copying all data into a Scala collection.-->

## 削除（Deleting）

データの削除は先のQueryingと同じように機能する．何かデータを削除する時には，適当な行をselectした後にdeleteを呼び出すだろう．Queryからdelete関数や自己参照するdeleteInvokerを持った[DeleteInvoker][5]への暗黙的な変換が存在している．

<!--Deleting works very similarly to querying. You write a query which selects the rows to delete and then call the delete method on it. There is again an implicit conversion from Query to the special [DeleteInvoker][5] which provides the delete method and a self-reference deleteInvoker:-->

```scala
val affectedRowsCount = q.delete
val invoker = q.deleteInvoker
val statement = q.deleteStatement
```

削除を行うクエリは単一のテーブルのみを指定する．どんな射影も無視される．

<!--A query for deleting must only select from a single table. Any projection is ignored (it always deletes full rows).-->

## 挿入（Inserting）

データの挿入は単一のテーブルに対し，カラムの射影を用いて行われる．テーブルを直接的に利用する場合，挿入は\*射影を用いずに実行される．挿入時にテーブルのカラムを一部省くと，データベース作成時に定義されたデフォルト値か，もしくは適当に用意した，型に応じた非明示的なデフォルト値をデータベースに挿入する．データ挿入のための全てのメソッドは[InsertInvoker][6]と[FullInsertInvoker][7]において定義されている．

<!--Inserts are done based on a projection of columns from a single table. When you use the table directly, the insert is performed against its * projection. Omitting some of a table’s columns when inserting causes the database to use the default values specified in the table definition, or a type-specific default in case no explicit default was given. All methods for inserting are defined in [InsertInvoker][6] and [FullInsertInvoker][7].-->

```scala
Coffees.insert("Colombian", 101, 7.99, 0, 0)

Coffees.insertAll(
  ("French_Roast", 49, 8.99, 0, 0),
  ("Espresso",    150, 9.99, 0, 0)
)

// "sales"と"total"はデフォルト値である0を用いる
(Coffees.name ~ Coffees.supID ~ Coffees.price).insert("Colombian_Decaf", 101, 8.99)

val statement = Coffees.insertStatement
val invoker = Coffees.insertInvoker
```

あるデータベースシステムではAutoIncとなっているカラムへの適切な値の挿入や作成された値を取得するためにNoneという値を挿入することを許可している一方，多くのデータベースではこのような操作を禁じているため，これらのカラムについて省けるかどうかは，データベースシステムについて調べて確認をしなくてはならない．Slickはまだ自動的にこの処理を行うような機能を持ってはいないが，将来的に追加する予定である．現時点では以下の例にあるforInsertのような，AutoIncとなっているカラムを含まない射影を用いるべきである．

<!--While some database systems allow inserting proper values into AutoInc columns or inserting None to get a created value, most databases forbid this behaviour, so you have to make sure to omit these columns. Slick does not yet have a feature to do this automatically but it is planned for a future release. For now, you have to use a projection which does not include the AutoInc column, like forInsert in the following example:-->

```scala
case class User(id: Option[Int], first: String, last: String)

object Users extends Table[User]("users") {
  def id = column[Int]("id", O.PrimaryKey, O.AutoInc)
  def first = column[String]("first")
  def last = column[String]("last")
  def * = id.? ~ first ~ last <> (User, User.unapply _)
  def forInsert = first ~ last <> ({ t => User(None, t._1, t._2)}, { (u: User) => Some((u.first, u.last))})
}

Users.forInsert insert User(None, "Christopher", "Vogt")
```

このような処理を行う際，AutoIncで自動生成された主キーのカラムを取得したいと考える事があるだろう．デフォルトでは，insert関数は影響を与えた行の数（大抵1になる）を返り値として返すし，insertAll関数はOption（もしデータベースが全ての行のための数え上げ機能を提供していない場合にはNoneとなる）における計算された数を返す．insertから単一の値やタプル，insertAllからSeqのような値として，返されるカラムを指定する場合には，returning関数を用いる事で指定が可能になる．

<!--In these cases you frequently want to get back the auto-generated primary key column. By default, insert gives you a count of the number of affected rows (which will usually be 1) and insertAll gives you an accumulated count in an Option (which can be None if the database system does not provide counts for all rows). This can be changed with the returning method where you specify the columns to be returned (as a single value or tuple from insert and a Seq of such values from insertAll):-->

```scala
val userId =
  Users.forInsert returning Users.id insert User(None, "Stefan", "Zeiger")
```

多くのデータベースでは単一のカラムを返す際に，テーブルのAutoIncな主キーを返す事を許可している．もし他のカラムが叩かれたら，SlickExceptionが実行中に（データベースが実際にそれをサポートしていない限り）投げられてしまう．

<!--Note that many database systems only allow a single column to be returned which must be the table’s auto-incrementing primary key. If you ask for other columns a SlickException is thrown at runtime (unless the database actually supports it).-->

クライアント側からデータを挿入する代わりに，データベースサーバーにおいて実行されるQueryやスカラー表現によって作られたデータを挿入すること事も出来る．

<!--Instead of inserting data from the client side you can also insert data created by a Query or a scalar expression that is executed in the database server:-->

```scala
object Users2 extends Table[(Int, String)]("users2") {
  def id = column[Int]("id", O.PrimaryKey)
  def name = column[String]("name")
  def * = id ~ name
}

Users2.ddl.create

Users2 insert (Users.map { u => (u.id, u.first ++ " " ++ u.last) })

Users2 insertExpr (Query(Users).length + 1, "admin")
```

## 更新（Updating）

データの更新は該当するデータをselectしてから，新たなデータへ更新することになるだろう．そのようなクエリは単一テーブルからselectされた生のカラム（計算された値ではない）のみを返すべきである．更新に関係する関数は[UpdateInvoker][8]において定義されている．

<!--Updates are performed by writing a query that selects the data to update and then replacing it with new data. The query must only return raw columns (no computed values) selected from a single table. The relevant methods for updating are defined in [UpdateInvoker][8].-->

```scala
val q = for { c <- Coffees if c.name === "Espresso" } yield c.price
q.update(10.49)

val statement = q.updateStatement
val invoker = q.updateInvoker
```

現時点では，更新のための，データベース内にあるデータのスカラー表現や変換を利用する方法は無い．

<!--There is currently no way to use scalar expressions or transformations of the existing data in the database for updates.-->

## クエリテンプレート

クエリテンプレートは任意のパラメータが決められたクエリのことである．複数のパラメータを取る関数のようにテンプレートは機能し，より効率的にQueryを返す．通常，クエリを作成するために関数を評価する際，新しいクエリとなるASTをその関数は構築し，そのクエリを実行する際に，たとえ同じSQL文が結果を返したとしても，常にクエリコンパイラによって毎度クエリはコンパイルされる．一方で，クエリテンプレートは単一のSQL文（全てのパラメータが変数へバインドされるが）に制限され，たった一度しかクエリはビルド，コンパイルされない．

<!--Query templates are parameterized queries. A template works like a function that takes some parameters and returns a Query for them except that the template is more efficient. When you evaluate a function to create a query the function constructs a new query AST, and when you execute that query it has to be compiled anew by the query compiler every time even if that always results in the same SQL string. A query template on the other hand is limited to a single SQL string (where all parameters are turned into bind variables) by design but the query is built and compiled only once.-->

クエリテンプレートは[Parameters][9]オブジェクトのflatMapを呼び出すことによって作る事が出来る．大抵の場合，for式を1つ書くことで，テンプレートを作成する事が出来る．

<!--You can create a query template by calling flatMap on a [Parameters][9] object. In many cases this enables you to write a single for comprehension for a template.-->

```scala
val userNameByID = for {
  id <- Parameters[Int]
  u <- Users if u.id is id
} yield u.first

val name = userNameByID(2).first

val userNameByIDRange = for {
  (min, max) <- Parameters[(Int, Int)]
  u <- Users if u.id >= min && u.id < max
} yield u.first

val names = userNameByIDRange(2, 5).list
```

## ユーザ定義関数とユーザ定義型

もしデータベースシステムがSlickにおける関数として利用出来るスカラー関数を用意していたとしたら，それを[SimpleFunction][10]として定義することが出来る．パラメータと返り値を固定した1つ，2つ，もしくは3つの関数を作成するための関数が既に定義されている．

<!--If your database system supports a scalar function that is not available as a method in Slick you can define it as a [SimpleFunction][10]. There are predefined methods for creating unary, binary and ternary functions with fixed parameter and return types.-->

```scala
// H2はタイムスタンプから曜日を抽出する関数であるday_of_week()を持っている
val dayOfWeek = SimpleFunction.unary[Date, Int]("day_of_week")

// 曜日によってグループ化するクエリにおいて，拡張された関数を用いる事が出来る
val q1 = for {
  (dow, q) <- SalesPerDay.map(s => (dayOfWeek(s.day), s.count)).groupBy(_._1)
} yield (dow, q.map(_._2).sum)
```

もし特定の型（varargsや，ポリモーフィックな関数，もしくはある関数におけるOptionや非Option型をサポートするため）を評価する，より柔軟な機能が欲しいのならば，型の決められていないインスタンスを得るためにSimpleFunction.applyを用いる事ができるし，適切な型検査をつけたラッパー関数を自身で書くことも出来る．

<!--If you need more flexibility regarding the types (e.g. for varargs, polymorphic functions, or to support Option and non-Option types in a single function), you can use SimpleFunction.apply to get an untyped instance and write your own wrapper function with the proper type-checking:-->

```scala
def dayOfWeek2(c: Column[Date]) =
  SimpleFunction("day_of_week")(TypeMapper.IntTypeMapper)(Seq(c))
```

[SimpleBinaryOperator][11]と[SimpleLiteral][12]はよく似た機能を持っている．さらにより柔軟な機能（普遍的でないシンタックスを持った関数に近い表現など）のために，[SimpleExpression][13]を用いる事が出来る．

<!--[SimpleBinaryOperator][11] and [SimpleLiteral][12] work in a similar way. For even more flexibility (e.g. function-like expressions with unusual syntax), you can use [SimpleExpression][13].-->

もしカスタムしたカラム型を必要とするのならば，[TypeMapper][14]と[TypeMapperDelegate][15]を実装すれば良い．大抵の場面，アプリケーション特有の型をデータベースに既にサポートされた型へとマッピングする事になる．これは全ての共通事項(boilerplate)を考慮した[MappedTypeMapper][16]を用いることによってより簡単に実装する事が出来る．

<!--If you need a custom column type you can implement [TypeMapper][14] and [TypeMapperDelegate][15]. The most common scenario is mapping an application-specific type to an already supported type in the database. This can be done much simpler by using a [MappedTypeMapper][16] which takes care of all the boilerplate:-->

```scala
// booleanの代数型
sealed trait Bool
case object True extends Bool
case object False extends Bool

// 上記のbooleanを1と0のIntへと変換するTypeMapper
implicit val boolTypeMapper = MappedTypeMapper.base[Bool, Int](
  { b => if(b == True) 1 else 0 },    // map Bool to Int
  { i => if(i == 1) True else False } // map Int to Bool
)
```
Bool型をテーブルやクエリなどにおいて，ビルドインされたカラム型であるかのように扱う事が出来る．
さらにより柔軟な操作にはサブクラスであるMappedTypeMapperを用いる事が出来る．

<!--// You can now use Bool like any built-in column type (in tables, queries, etc.)
You can also subclass MappedTypeMapper for a bit more flexibility.-->

[1]: http://slick.typesafe.com/doc/1.0.0/gettingstarted.html
[2]: http://slick.typesafe.com/doc/1.0.0/direct-embedding.html
[3]: http://slick.typesafe.com/doc/1.0.0/api/#scala.slick.jdbc.Invoker
[4]: http://slick.typesafe.com/doc/1.0.0/api/#scala.slick.jdbc.UnitInvoker
[5]: http://slick.typesafe.com/doc/1.0.0/api/#scala.slick.driver.BasicInvokerComponent$DeleteInvoker
[6]: http://slick.typesafe.com/doc/1.0.0/api/#scala.slick.driver.BasicInvokerComponent$InsertInvoker
[7]: http://slick.typesafe.com/doc/1.0.0/api/#scala.slick.driver.BasicInvokerComponent$FullInsertInvoker
[8]: http://slick.typesafe.com/doc/1.0.0/api/#scala.slick.driver.BasicInvokerComponent$UpdateInvoker
[9]: http://slick.typesafe.com/doc/1.0.0/api/#scala.slick.lifted.Parameters
[10]: http://slick.typesafe.com/doc/1.0.0/api/#scala.slick.lifted.SimpleFunction
[11]: http://slick.typesafe.com/doc/1.0.0/api/#scala.slick.lifted.SimpleBinaryOperator
[12]: http://slick.typesafe.com/doc/1.0.0/api/#scala.slick.lifted.SimpleLiteral
[13]: http://slick.typesafe.com/doc/1.0.0/api/#scala.slick.lifted.SimpleExpression
[14]: http://slick.typesafe.com/doc/1.0.0/api/#scala.slick.lifted.TypeMapper
[15]: http://slick.typesafe.com/doc/1.0.0/api/#scala.slick.lifted.TypeMapperDelegate
[16]: http://slick.typesafe.com/doc/1.0.0/api/#scala.slick.lifted.MappedTypeMapper
