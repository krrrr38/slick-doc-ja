Slick 3.0.0 documentation - 11 Coming from ORM to Slick

[Permalink to Coming from ORM to Slick — Slick 3.0.0 documentation](http://slick.typesafe.com/doc/3.0.0/orm-to-slick.html)

ORMからSlickを利用する人へ
========================

Introduction
------------
Slickは、Hibernateや他の[JPA](http://en.wikipedia.org/wiki/Java_Persistence_API)ベースのプロダクトのようなORM（object-relational mapper）では無い。SlickはORMのようにデータを永続化させるソリューションの1つであり、いくつかのコンセプトは共有しつつも、大きな違いがいくつかある。本章ではSlickのメリットについての理解を手助けしつつ、ORMとの違いについて順に説明する。object-relationalなものに対して言及される様々な問題（object-relation-impedance mismatch）をSlickは上手く取り扱っていることについても説明したい。
<!-- Slick is not an object-relational mapper (ORM) like Hibernate or other JPA\_-based products. Slick is a data persistence solution like ORMs and naturally shares some concepts, but it also has significant differences. This chapter explains the differences in order to help you get the best out of Slick and avoid confusion for those familiar with ORMs. We explain how Slick manages to avoid many of the problems often referred to as the object-relational impedance mismatch.  -->

SlickはFRM（functional-relational mapper）である、と表現されるのが良い。Slickはイミュータブルなコレクションをもとにして関係データを取り扱っており、より自由なクエリ生成とうまくコントロールされた副作用処理に対し、特に焦点を当てた作りになっている。ORMでは一般的にミュータブルなオブジェクトグラフをむき出しにし、read-・write-cachesのような副作用や、ハードコードサポート（継承を利用したユースケースや関連テーブルを通した関連の取得など）を利用してしまっている事が多い。ORMではオブジェクトグラフの永続化に焦点を当てている一方、Slickは関連データストアにアクセスする最も良い方法に焦点を当てている。

<!-- A good term to describe Slick is functional-relational mapper. Slick allows working with relational data much like with immutable collections and focuses on flexible query composition and strongly controlled side-effects. ORMs usually expose mutable object-graphs, use side-effects like read- and write-caches and hard-code support for anticipated use-cases like inheritance or relationships via association tables. Slick focuses on getting the best out of accessing a relational data store. ORMs focus on persisting an object-graph.  -->

ORMはオブジェクト指向言語からデータベースを利用する際には、自然なアプローチをとっている。ORMではデータがメモリ内に残っていたとしても、オブジェクトグラフを部分的に永続化させようとする。オブジェクトは編集可能、関連も変更が可能であり、オブジェクトグラフは色々と状態が変化する。実のところ、このようなものに対して正確に保存をするのは簡単ではない。それゆえこの問題を object-relation impedance mismatchと呼んでいる。これはORMの実装をを難しくさせている所以であり、ほんの少し難しいケースに対しても複雑化してしまうこともある。一方でSlickはオブジェクトグラフをむき出しにしたりはしていない。SlickはSQLや関連モデルからインスパイアされているし、型安全なScalaの特徴を利用しつつも、大抵の場合コンセプトはだいたい同じものになっている。データベースクエリはScalaの制限されたイミュータブルな、純粋関数のサブセットを用いて表現されている。Scala側からも代わりのものとして[first-class SQL support](http://slick.typesafe.com/doc/3.0.0/sql.html)を提供している。
<!-- ORMs are a natural approach when using databases from object-oriented languages. They try to allow working with persisted object-graphs partly as if they were completely in memory. Objects can be modified, associations can be changed and the object graph can be traversed. In practice this is not exactly easy to achieve due to the so called object-relational impedance mismatch. It makes ORMs hard to implement and often complicated to use for more than simple cases and if performance matters. Slick in contrast does not expose an object-graph. It is inspired by SQL and the relational model and mostly just maps their concepts to the most closely corresponding, type-safe Scala features. Database queries are expressed using a restricted, immutable, purely-functional subset of Scala much like collections. Slick also offer first-class SQL support \<sql\> as an alternative.  -->

実のところ、ORMはそれ自体が挑戦しようと試みている事に対する概念的な課題にしばしば直面する。これはORMが複雑なせいであり、実装上の課題であったり、使用上の課題であったりもする。以下では、ORMについての特徴と、なぜ代わりにSlickを用いる事を推奨するのかについて述べる。初めに、どのようにしてオブジェクトグラフとうまく付き合っていくかについて説明し、それからSlickがどのようにして取り組んでいるかをその特徴とユースケースを主に述べていく。
<!-- In practice, ORMs often suffer from conceptual problems of what they try to achieve, from mere problems of the implementations and from mis-use, because of their complexity. In the following we look at many features of ORMs and what you would use with Slick instead. We'll first look at how to work with the object graph. We then look at a series of particular features and use cases and how to handle them with Slick.  -->

Configuration
-------------

いくつかのORMでは外部の設定ファイルを用いる。Slickは少しのScalaのコードを用いて設定を行う。[データベースに接続する方法](http://slick.typesafe.com/doc/3.0.0/database.html)についての情報をSlickに提供し、Slickにクエリに対する型チェックを行いたいのならば、[database-schema](http://slick.typesafe.com/doc/3.0.0/schemas.html)を手で書くor自動生成させる。外部キーを用いる[関連の定義](http://slick.typesafe.com/doc/3.0.0/orm-to-slick.html#orm-relationships)といったようなものも、再利用可能な抽象メソッドを利用しつつ、基本的なScalaのコードで記述する事が出来る。
<!-- Some ORMs use extensive configuration files. Slick is configured using small amounts of Scala code. You have to provide information about how to connect to the database \<database\> and write or auto-generate a database-schema \<schemas\> description if you want Slick to type-check your queries. Everything else like relationship definitions \<orm-relationships\> beyond foreign keys are ordinary Scala code, which can use familiar abstraction methods for re-use.  -->

Mapping configuration.
----------------------

以下の例では、このようなデータベーススキーマを用いる。
<!-- The later examples use the following database schema -->

![image](http://slick.typesafe.com/doc/3.0.0/_images/from-sql-to-slick.person-address.png)

このスキーマをSlickで利用する際は、以下のようなコードを記述すれば良い。
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

ORMではコンフィグファイルの中でマッピングの仕様について記述を行う。Slickでは、上記の例のようにScalaの型として仕様を提供してあげる事ができ、型安全なSlickのクエリを用いる事ができる。違いとして、Slickのマッピングは概念上非常にシンプルだ。単にテーブルの情報を記述するだけでよく、列に対するマッピングを行うケースクラスやその他のファクトリや抽出子はオプショナルにすぎない。外部キーの情報は持たせる事が出来るものの、[関連](http://slick.typesafe.com/doc/3.0.0/orm-to-slick.html#orm-relationships)やその類の情報については保持しない。その代わりに再利用可能な部分的なクエリを用いたマッピングなども行える。
<!-- In ORMs you often provide your mapping specification in a configuration file. In Slick you provide it as Scala types like above, which are used to type-check Slick queries. A difference is that the Slick mapping is conceptually very simple. It only describes database tables and optionally maps rows to case classes or something else using arbitrary factories and extractors. It does contain information about foreign keys, but nothing else about relationships \<orm-relationships\> or other patterns. These are mapped using re-usable queries fragments instead.  -->

Navigating the object graph
---------------------------

### Using plain old method calls

本章では、厳格vs遅延、もしくは義務的or宣言的について考えていきたい。一般的なORMの特徴の一つとして、オブジェクトグラフが、まるでメモリ上に存在しているかのように扱える、ということがある。関連メンバのような関連するオブジェクトについては、必要に応じてアドホックにデータがデータベースから読み込まれる。メモリ上にあるかのように表現するために、ORMは関連メンバに対する呼び出しを途中でフックしたりして、必要なデータを得るために、データベースクエリをその途中で実行したりしている。以下のORMっぽい例を見てみよう。
<!-- This chapter could also be called strict vs. lazy or imperative vs. declarative. One common feature ORMs provide is using a persisted object graph just as if it was in-memory. And since it is not, artifacts like members or related objects are usually loaded ad-hoc only when they are needed. To make this happen, ORMs implement or intercept method calls, which look like they happen in-memory, but instead execute database queries as needed to return the desired results. Let's look at an example using a hypothetical ORM:  -->

```scala
val people: Seq[Person] = PeopleFinder.getByIds(Seq(2,99,17,234))
val addresses: Seq[Address] = people.map(_.address)
```

データを取得するのに何回データベースとやり取りをする必要があるのだろうか？実際ORMのコレクション風APIを学ぶ際には、この質問に何度も直面することになるだろう。普通に考えると、このORMは`getByIds`の際にデータベースと一度やり取りを行い、`Person`に関する結果を返す。それからScalaのListのメソッドである`map`を使い、各`Person`から`address`を取得するために`.map(_.address)`を呼ぶ。ORMはこの`map`のループの前に`address`が何度も呼ばれる事を通常知らない。その結果、各`Person`の`address`を取得するために何度もデータベースとやり取りをしなくてはならなくなるし、データベースのやり取りのコストを考えると、非常に非効率である（n+1問題）。この問題を解決するためには、以下の例のように、ORMに将来的にデータが必要になる旨を事前に伝えてあげることで、複数回のデータベース呼び出しを集約により効率化させる事ができる。
<!-- How many database round trips does this require? In fact reasoning about this question for different code is one of the things you need to devote the most time to when learning the collections-like API of an ORM. What usually happens is, that the ORM would do an immediate database round trip for `getByIds` and return the resulting people. Then `map` would be a Scala List method and `.map(_.address)` accesses the `address` of each person. An ORM would witness the `address` accesses one-by-one not knowing upfront that they happen in a loop. This often leads to an additional database round trip for each person, which is not ideal (n+1 problem), because database round trips are expensive. To solve the problem, ORMs often provide means to work around this, by basically telling them about the future, so they can aggregate multiple upcoming round trips into fewer more efficient ones.  -->

```scala
// 関連する`address`をロードしておくことをORMに事前に伝える
val people: Seq[Person] = PeopleFinder.getByIds(Seq(2,99,17,234)).prefetch(_.address)
val addresses: Seq[Address] = people.map(_.address)
```

ここでは仮のORMの中で`prefetch`メソッドにより各`Person`の`address`を予めロードしている。結果、データベースとのやり取りは1度か2度に収まる。`address`の情報はORMの管理下にキャッシュされる。続く`.map(_.address)`では、キャッシュされたメモリ上の値からデータを得る事ができる。もちろんこれは2度も`address`へのマッピングを教えてあげる必要があるため無駄があるし、もし`prefetch`を忘れた場合には、非効率な処理になってしまうだろう。ORMにもよるが、`prefetch`の方法として外部の設定を用いるか、上記の例のようにインラインで記述する方法がある。
<!-- Here the prefetch method instructs the hypothetical ORM to load all addresses immediately with the people, often in only one or two database round trips. The addresses are then stored in a cache many ORMs maintain. The later `.map(_.address)` call could then be fully served from the cache. Of course this is redundant as you basically need to provide the mapping to addresses twice and if you forget to prefetch you will have poor performance. How you specify the pre-fetching rules depends on the ORM, often using external configuration or inline like here.  -->

Slickは関連するデータを取得するのに異なる方法をとっている。同じような処理には、以下のような記述を行う。型アノテーションは必要無いが、分かりやすさのためにここでは記述している。
<!-- Slick works differently. To do the same in Slick you would write the following. The type annotations are optional but shown here for clarity.  -->

```scala
val peopleQuery: Query[People,Person,Seq] = people.filter(_.id inSet(Set(2,99,17,234)))
val addressesQuery: Query[Addresses,Address,Seq] = peopleQuery.flatMap(_.address)
```

見ての通り、この例はまさにScalaのコレクション操作と同じであり、違いは返り値が`Query`型になるだけだ。この時点ではSlickは、データを取得する上で必要になるSQLを作るために必要な計画を練っているだけで、データベースに対しアクセスは行わない。上記の例は、まだ一度もデータベースにはアクセスしていない。実際にデータを取得するには、`.result`を用いて[database Action](http://slick.typesafe.com/doc/3.0.0/database.html)にクエリをコンパイルさせ、`Database`オブジェクトに`run`してもらう。
<!-- As we can see it looks very much like collection operations but the values we get are of type `Query`. They do not store results, only a plan of the operations that are needed to create a SQL query that produces the results when needed. No database round trips happen at all in our example. To actually fetch results, we can have to compile the query to a database Action \<database\> with `.result` and then `run` it on the Database.   -->

```scala
val addressesAction: DBIO[Seq[Address]] = addressesQuery.result
val addresses: Future[Seq[Address]] = db.run(addressesAction)
```

結果の取得には、たった1つのクエリのみが実行される。これはデータベースへのアクセスを行う箇所を明らかにしているし、非常に理に適っている。
<!-- A single query is executed and the results returned. This makes database round trips very explicit and easy to reason about. Achieving few database round trips is easy.  -->

Slickの例を見ての通り、Slickではオブジェクトグラフ（i.e. results）を直接操作したりはしない。その代わりにSlickは、データベースアクセス無しに効率的なクエリを発行出来るよう事前にクエリを組み立て、オブジェクトグラフを操作している。Slickでは実際に必要になるまでクエリの組立を遅延させ、`Database.run`の呼び出しによりクエリを発行させるのである。
<!-- As you can see with Slick we do not navigate the object graph (i.e. results) directly. We navigate it by composing queries instead, which are just place-holder values for potential database round trip yet to happen. We can lazily compose queries until they describe exactly what we need and then use a single `Database.run` call for execution.  -->

ORMにおいてオブジェクトグラフを直接操作することは、あまりに早い状態でクエリを発行してしまうため問題になりやすい。そのためSlickではこのような機能を外した。ORMはこの問題に取り組むにあたり、しばしば宣言的なクエリ言語を用いて問題を解決しようとしている。これはSlickの動作とよく似たものになっている。
<!-- Navigating the object graph directly in an ORM is problematic as explained earlier. Slick gets away without that feature. ORMs often solve the problem by offering a declarative query language as an alternative, which is similar to how you work with Slick. -->

### Query languages

ORMはしばしばJPAのSQLやCriteria APIのような宣言的なクエリ言語を用いている。SQLやSlickのように、これらのクエリ言語は実行すること無しにクエリを表現する事が可能であり、クエリを実行するには明示的な処理を必要とする。
<!-- ORMs often come with declarative query languages like JPA's JQL or Criteria API. Similar to SQL or Slick, they allow expressing queries yet to happen and make execution explicit.  -->

#### String based embeddings

ここではHQLの例を出すが、一般的にこのようなクエリ言語では、SQLは文字列としてプログラムに埋め込まれている。HQLの例を見てみよう。
<!-- Quite commonly, these languages, for example HQL, but also SQL are embedded into programs as Strings. Here is an example for HQL.  -->

```Scala
val hql: String = "FROM Person p WHERE p.id in (:ids)"
val q: Query = session.createQuery(hql)
q.setParameterList("ids", Array(2,99,17,234))
```

大抵の言語において、コンパイラを変更せずに任意の言語を埋め込むのには文字列を使うのが最も簡単である。シンプルである一方、この種の埋め込みには大きな制限がかかる。
<!-- Strings are a very simple way to embed an arbitrary language and in many programming languages the only way without changing the compiler, for example in Java. While simple, this kind of embedding has significant limitations.  -->

1つの大きな問題としては、このようなツールには埋め込まれた言語や、任意の文字列としてクエリを扱う事に対する知識を持たせる事が出来ない。ホストされた言語のコンパイラやインタプリタは記述の間違いを発見したりは出来ないし、もしクエリが期待する型とは異なる型を返しても間違いを検出出来ない。1つの解決法としては、IDEによりシンタックスハイライトやコード補完、インラインのエラーなどを表示させる、といった方法があげられる。
<!-- One issue is that tools often have no knowledge about the embedded language and treat queries as ordinary Strings. The compilers or interpreters of the host languages do not detect syntactical mistakes upfront or if the query produces a different type of result than expected. Also IDEs often do not provide syntax highlighting, code completion, inline error hints, etc.  -->

また、大きな問題として、この種の言語では再利用が難しい。クエリの一部分を再利用するために文字列を結合したいと考えるかもしれない。上記のHQLの例で、idによるフィルタリングの機能を再利用可能なものとして扱いたいとする。`Person`テーブル以外にも`Address`テーブルでその機能を使いたくても、これは非常に扱うのが難しいものになってしまう。
<!-- More importantly, re-use is very hard. You would need to compose Strings in order to re-use certain parts of queries. As an exercise, try to make the id filtering part of our above HQL example re-useable, so we can use it for table person as well as address. It is really cumbersome.  -->

Javaはその他多くの言語において、文字列は正確なクエリ言語を埋め込む唯一の方法になっている。次のセクションを見て、Scalaがいかに柔軟かを確認して欲しい。
<!-- In Java and many other languages, strings are the only way to embed a concise query language. As we will see in the next sections, Scala is more flexible.  -->

#### Method based APIs

埋め込み言語にとって柔軟性を得るものとして、その他のアプローチとして、ホストされた言語の拡張機能を用いて同様の機能を利用する方法があげられる。JavaやScalaのようなオブジェクト指向言語はオブジェクトやメソッドのAPI定義を通した拡張を許可している。JPAのCriteria APIはこの概念を利用しており、Slickも同様に利用している。これは埋め込まれた言語を部分的に理解するために、ホストされた言語の機能を利用している。Criteria Queriesを用いた例を見てみよう。
<!-- Instead of getting the ultimate flexibility for the embedded language, an alternative approach is to go with the extensibility features of the host language and use those. Object-oriented languages like Java and Scala allow extensibility through the definition of APIs consisting of objects and methods. JPA's Criteria API use this concept and so does Slick. This allows the host language tools to partially understand the embedded language and provide better support for the features mentioned earlier. Here is an example using Criteria Queries.  -->

```scala
val id = Property.forName("id")
val q = session.createCriteria(classOf[Person])
               .add( id in Array(2,99,17,234) )
```

埋め込みを利用するメソッドはクエリを部分的に利用可能なものへと変化させる。idによるフィルタリングのみの機能を生成するのも容易い。
<!-- A method based embedding makes queries compositional. Factoring out filtering by ids becomes easy:  -->

```scala
def byIds(c: Criteria, ids: Array[Int]) = c.add( id in ids )
...
val c = byIds(
  session.createCriteria(classOf[Person]),
  Array(2,99,17,234)
)
```

もちろん上の例は取るに足らない例ではあるが、より複雑なクエリを合成する上で、このメソッドは既に役立つものになっている。
<!-- Of course ids are a trivial example, but this becomes very useful for more complex queries.  -->

JPAのCriteria APIのようなJava APIは、Scalaのようにオペレータの機能をオーバーロードしたりは出来ない。これはクエリを表現する際のよく似たコードを減らす。例として、5歳より若いか65歳より歳のいった人を取得するクエリを考えてみよう。
<!-- Java APIs like JPA's Criteria API do not use Scala's operator overloading capabilities. This can lead to more cumbersome and less familiar code when expressing queries. Let's query for all people younger 5 or older than 65 for example.  -->

```scala
val age = Property.forName("age")
val q = session.createCriteria(classOf[Person])
               .add(
                 Restrictions.disjunction
                   .add(age lt 5)
                   .add(age gt 65)
               )
```

Scalaはオペレータをオーバーロード出来るため、Slickでは以下のような記述が可能になり、クエリはより簡潔なものになる。
<!-- With Scala's operator overloading we can do better and that's what Slick uses. Queries are very concise. The same query in Slick would look like this:  -->

```scala
val q = people.filter(p => p.age < 5 || p.age > 65)
```

Scalaのオーバーロードには、Slickにも影響を与えるものとして、いくつか制限があった。Slickでは、クエリの中で`==`は`===`に、`!=`は`=!=`と記述しなくてはならない。また、文字列結合にも`+`の代わりに`++`を用いなくてはならない。さらに、`if`という予約後をオーバーロードする事も出来ない。Slickでは代わりのものとして、[DSL for SQL case expressions](http://slick.typesafe.com/doc/3.0.0/sql-to-slick.html#case)を提供している。
<!-- There are some limitations to Scala's overloading capabilities that affect Slick. In queries, one has to use `===` instead of `==`, `=!=` instead of `!=` and `++` for string concatenation instead of `+`. Also it is not possible to overload `if` expressions in Scala. Instead Slick comes with a small DSL for SQL case expressions \<case\>.  -->

前述した通り、Slickでは、クエリを実行しないクエリを記述するためだけのものとして、プレースホルダ構文も扱える。以下の例では分かりやすさのために型アノテーションを書いているが、実際には書く必要はない。
<!-- As already mentioned, we are working with placeholder values, merely describing the query, not executing it. Here's the same expression again with added type annotations to allow us looking behind the scenes a bit:  -->

```scala
val q = (people: Query[People, Person, Seq]).filter(
  (p: People) =>
    (
      ((p.age: Rep[Int]) < 5 || p.age > 65)
      : Rep[Boolean]
  )
)
```

`Query`はコレクション風のクエリ表現を指定する。`People`は`Person`のテーブルのために定義されたSlickの`Table`のサブクラスである。値が列を表すプロトタイプとして用いられることに混乱してしまうかもしれない。個々のカラムを表す`Rep`のメンバーもある。`filter`をするために、いくつかの`Rep[Int]`を用いて`Rep[Boolean]`を得ている。内部的にSlickは、オペレーション内容を表すSQLコードを生成するのに用いられるツリーを作成している。Slickはしばしばこのような表現木（持ち上げられた表現として、プレースホルダーの値を含んだもの）の生成プロセスを呼び出す。これ故にSlickのクエリインターフェスの1つを _lifted embedding_ と呼んでいる。
<!-- `Query` marks collection-like query expressions, e.g. a whole table. `People` is the Slick Table subclass defined for table person. In this context it may be confusing that the value is used rather as a prototype for a row here. It has members of type `Rep` representing the individual columns. Expressions based on these columns result in other expressions of type `Rep`. Here we are using several `Rep[Int]` to compute a `Rep[Boolean]`, which we are using as the filter expression. Internally, Slick builds a tree from this, which represents the operations and is used to produce the corresponding SQL code. We often call this process of building up expression trees encapsulated in place-holder values as lifting expressions, which is why we also call this query interface the *lifted embedding* in Slick.  -->

Scalaが型安全であるのは非常に重要な事である。例として、Slickは`Rep[String]`のために`.substring`というメソッドをサポートしている（`Rep[Int]`には使えない）。これはJavaやCriteria QueriesのようなJava APIにおいては利用不可能なものである。Scalaでは暗黙的な表現を通したメソッド拡張に基づく型パラメータを利用する事で、サポートが可能となった。ScalaコンパイラのようなツールやIDEが、コードを正確に理解したりチェックやサポートを行ってくれるのを手助けしてくれる。
<!-- It is important to note that Scala allows to be very type-safe here. E.g. Slick supports a method `.substring` for `Rep[String]` but not for `Rep[Int]`. This is impossible in Java and Java APIs like Criteria Queries, but possible in Scala using type-parameter based method extensions via implicits. This allows tools like the Scala compiler and IDEs to understand the code much more precisely and offer better checking and support.  -->

Slickのようなクエリ言語において、Scalaのコレクション操作のシンタックスシュガーであるfor式が非常に役立つ。上の例は、for式を使う事で、以下のように書き換える事が出来る。
<!-- A nice property of a Slick-like query language is, that it can be used with Scala's comprehension syntax, which is just Scala-builtin syntactic sugar for collections operations. The above example can alternatively be written as  -->

```scala
for( p <- people if p.age < 5 || p.age > 65 ) yield p
```

Scalaのfor式は、SQLやORMのクエリ言語によく似たものになる。一方で、ソートやグルーピングのような幾つかの操作のためのシンタックスサポートが欠けている。
<!-- Scala's comprehension syntax looks much like SQL or ORM query languages. It however lacks syntactic support for some constructs like sorting and grouping, for which one has to use the method-based api, e.g.  -->

```scala
( for( p <- people if p.age < 5 || p.age > 65 ) yield p ).sortBy(_.name)
```

シンタックスの制限があるにも関わらず、for式は複数のinner joinを利用する時などに非常に便利なものとなる。
<!-- Despite the syntactic limitations, the comprehension syntax is convenient when dealing with multiple inner joins.  -->

先に記述したような、Criteria QueriesのようなメソッドベースなクエリAPIの問題は、ORMのクエリ言語にある概念上の制限とは異なる事を胸に留めといて欲しい。ScalaのORMはSlickのようなクエリ言語にオファーしても良いし、そうすべきであると考えている。快適にクエリを合成出来る事は、コードの再利用性に大きなメリットをもたらす。これは多くの開発者にとってSlickのお気に入りの機能になるのではないだろうか。
<!-- It is important to note that the problems of method-based query apis like Criteria Queries described above are not a conceptual limitation of ORM query languages but merely an artifact of many ORMs being Java frameworks. In principle, a Scala ORMs could offer a query language just like Slick's and they should. Comfortably compositional queries allow for a high degree of code re-use. They seem to be Slick's favorite feature for many developers.  -->

#### Macro-based embeddings

Scalaのマクロは埋め込みクエリのためのもう一つのアプローチとなる。文字列として埋め込まれたクエリをコンパイル時にチェックすることが可能になる。`Query`や`Rep`に関わるSQLへのプレースホルダを使う事無しにScalaのコードを変換する事が可能になる。双方のアプローチはSlickで利用する事が出来るが、まだ万全の準備ができているわけではない。クエリ言語のためにマクロを用いているデータベースライブラリは他にも存在している。
<!-- Scala macros allow other approaches for embedding queries. They can be used to check queries embedded as Strings at compile time. They can also be used to translate Scala code written without Query and Rep place holder types to SQL. Both approaches are being prototyped and evaluated for Slick but are not ready for prime-time yet. There are other database libraries out there that already use macros for their query language.  -->

Query granularity
-----------------

ORMを用いると、データをロードする際にオブジェクトを取り扱ったり、最も小さい粒度として列を補完したりすることは凡そ亡くなる。これはフレームワークによって制限されているわけではないが、慣例としてそのように扱われている。Slickを用いると実際に欲しいデータのみを取得する事が簡単になる。Slickでは列をクラスに対してマッピング出来るが、そのような機能を使わないことでより効率的なクエリを実行出来る。その時その時に必要なデータのみを取り出すようなクエリを扱える。もし`person`の名前と年齢のみが必要なら、以下のようにする事でタプルを返すことができる。
<!-- With ORMs it is not uncommon to treat objects or complete rows as the smallest granularity when loading data. This is not necessarily a limitation of the frameworks, but a habit of using them. With Slick it is very much encouraged to only fetch the data you actually need. While you can map rows to classes with Slick, it is often more efficient to not use that feature, but to restrict your query to the data you actually need in that moment. If you only need a person's name and age, just map to those and return them as a tuple.  -->

```scala
people.map(p => (p.name, p.age))
```

このような記述により、正確に欲しいデータのみを取得することが可能になる。
<!-- This allows you to be very precise about what data is actually transferred.  -->

Read caching
------------

Slickはクエリの結果をキャッシュしない。Slickを扱うのは生のJDBCを扱う事と等しいようなもんだ。多くのORMではキャッシュの読み書きを行う。キャッシュは一種の副作用である。これらは、時に理解を難しくさせる。キャッシュにより保存されたデータとそのライフタイムを扱う事は難しい。
<!-- Slick doesn't cache query results. Working with Slick is like working with JDBC in this regard. Many ORMs come with read and write caches. Caches are side-effects. They can be hard to reason about. It can be tricky to manage cache consistency and lifetime.  -->

```scala
PeopleFinder.getById(5)
```

ORMの例においては、ここではデータベースもしくはキャッシュから値を取り出している。どのような処理が生じたのかが明らかになっていない。Slickではデータベースとのやり取りは、クエリを実行させる処理を呼び出す必要があるので、非常に明確だ。Slickはオブジェクトへのアクセスに干渉したりもしない。
<!-- This call may be served from the database or from a cache. It is not clear at the call site what the performance is. With Slick it is very clear that executing a query leads to a database round trip and that Slick doesn't interfere with member accesses on objects.  -->

```scala
db.run(people.filter(_.id === 5).result)
```

Slickは毎度データベースのデータに対して、矛盾のないイミュータブルなスナップショットを返す。もし複数クエリに対する永続性を保証したいのなら、トランザクションを用いれば良い。
<!-- Slick returns a consistent, immutable snapshot of a fraction of the database at that point in time. If you need consistency over multiple queries, use transactions.  -->

Writes (and caching)
--------------------

多くのORMでは書き込み操作はパフォーマンスのためにキャッシュを経由する。
<!-- Writes in many ORMs require write caching to be performant. -->

```scala
val person = PeopleFinder.getById(5)
person.name = "C. Vogt"
person.age = 12345
session.save
```

上の仮ORMのレコードは、オブジェクトを変更し、`.save`メソッドを呼ぶことでデータベースとのやり取りを1度だけ行いデータを同期させている。Slickでは以下のような記述が可能だ。
<!-- Here our hypothetical ORM records changes to the object and the `.save` method syncs back changes into the database in a single round trip rather than one per member. In Slick you would do the following instead:  -->

```scala
val personQuery = people.filter(_.id === 5)
personQuery.map(p => (p.name,p.age)).update("C. Vogt", 12345)
```

Slickは宣言的な変換を内包してしまっている。オブジェクトの個々の値を順に変更するのではなく、全ての変更を同時に行い、キャッシュを通さずにデータベースとのやり取りを1度だけ行う。Slickの新規ユーザにとって、このシンタックスは混乱を招くかもしれない。しかし実際にはこれはよく整理されたシンタックスになっている。Slickはクエリの選択、挿入、更新、削除に対するシンタックスを一体化している。上記`personQuery`はデータを取得するために単なる選択用クエリに過ぎない。実際には、クエリにより特定されたカラムの更新を行うためにこの選択用クエリは用いられる。`personQuery`は列の削除にもそのまま使える。
<!-- Slick embraces declarative transformations. Rather than modifying individual members of objects one after the other, you state all modifications at once and Slick creates a single database round trip from it without using a cache. New Slick users seem to be often confused by this syntax, but it is actually very neat. Slick unifies the syntax for queries, inserts, updates and deletes. Here `personQuery` is just a query. We could use it to fetch data. But instead, we can also use it to update the columns specified by the query. Or we can use it do delete the rows.  -->

```scala
personQuery.delete // deletes person with id 5
```

データを挿入するには、代入するカラムを選択した後に、個々のカラムに対する値を挿入してあげたら良い。
<!-- For inserts, we insert into the query, that resembles the whole table and can select individual columns in the same way.  -->

```scala
people.map(p => (p.name,p.age)) += ("S. Zeiger", 54321)
```

Relationships
-------------

ORMは一対多関連、多対多関連に対しハードコードされたサポートを提供している。関連に関しては設定の中でセットアップが行われる。一方、SQLでは各クエリに対しjoinを用いる事で関連を取得する。joinを用いることで柔軟な記述が可能になる。Slickでは両方の記述方法をより良い形で提供している。SlickのクエリはSQLと同じぐらい柔軟であるのに加えて、組み合わせ可能なものになっている。join条件に関わる部分的なクエリを定義する事もできるため、言語レベルの抽象化が可能になる。Slickがこの種のユースケースのためにハードコードサポートする必要は全く無い。あなたは、一対多、多対多関連や複数テーブルを跨ぐ関連の取得に対しても、任意のユースケースに対して簡単に実装が行える。
<!-- ORMs usually provide built-in, hard-coded support for 1-to-many and many-to-many relationships. They can be set up centrally in the configuration. In SQL on the other hand you would specify them using joins in every single query. You have a lot of flexibility what you join and how. With Slick you get the best of both worlds. Slick queries are as flexible as SQL, but also compositional. You can store fragements like join conditions in central places and use language-level abstraction. Relationships of any sort are just one thing you can naturally abstract over like in any Scala code. There is no need for Slick to hard-code support for certain use cases. You can easily implement arbitrary use cases yourself, e.g. the common 1-n or n-n relationships or even relationships spanning over multiple tables, relationships with additional discriminators, polymorphic relationships, etc.  -->

`Person`と`Address`に対する例は以下のようになる。
<!-- Here is an example for person and addresses. -->

```scala
implicit class PersonExtensions[C[_]](q: Query[People, Person, C]) {
  // 住所に対する関連のマッピング
  def withAddress = q.join(addresses).on(_.addressId === _.id)
}
...
val chrisQuery = people.filter(_.id === 2)
val stefanQuery = people.filter(_.id === 3)
...
val chrisWithAddress: Future[(Person, Address)] =
db.run(chrisQuery.withAddress.result.head)
val stefanWithAddress: Future[(Person, Address)] =
db.run(stefanQuery.withAddress.result.head)
```

Slickを初めて使うユーザがよくする質問として、どのようにして関連の結果を利用するのか、といったことがあげられる。ORMではおそらくこんな感じで書けるのだろう。
<!-- A common question for new Slick users is how they can follow a relationships on a result. In an ORM you could do something like this:  -->

```scala
val chris: Person = PeopleFinder.getById(2)
val address: Address = chris.address
```

以前に説明したように、Slickはデータがメモリ上にあるかのようにオブジェクトグラフを操作出来るようにはしていない。関連を直接操作するのではなく、データベースにアクセスする前に、関連データを取得するような別のクエリを記述して欲しい。
<!-- As explained earlier, Slick does not allow navigating the object-graph as if data was in memory, because of the problem that comes with it. Instead of navigating relationships on results you write new queries instead.  -->

```scala
val chrisQuery: Query[People,Person,Seq] = people.filter(_.id === 2)
val addressQuery: Query[Addresses,Address,Seq] = chrisQuery.withAddress.map(_._2)
val address = db.run(addressQuery.result.head)
```

上の例では型アノテーションを記述しているが、これは普段の記述には必要無く、取り除くことで見通しの良いコードになるだろう。そしてデータベースへのアクセスがどこで発生するのかについて非常に分かりやすいものになっている。
<!-- If you leave out the optional type annotation and some intermediate vals it is very clean. And it is very clear where database round trips happen.  -->

他のSlick初心者の中には、どのようにしたらSlickで以下のような記述が出来るのか、といった疑問を考える人もいるかもしれない。
<!-- A variant of this question Slick new comers often ask is how they can do something like this in Slick:  -->

```scala
case class Address( … )
case class Person( …, address: Address )
```

ここには`Person`が`Address`を必要とすることがハードコードされてしまうという問題がある。そのような情報無しにデータが読み込まれてはならない。もしそのような挙動を許してしまったなら、正確にデータを読み込ませる事を上手くユーザの管理下に置かせるという、Slickの哲学に反するものになってしまう。1つのテーブルからタプルやケースクラスへのマッピングを定義しているが、関連オブジェクトへのリファレンスをオブジェクトに持たせる事はSlickでは行っていない。その代わりに、2つのテーブルを結合させ、それらの結果をタプルもしくは結果の合わさったケースクラスのインスタンスとして返すメソッドを記述することができる。これは関連を明示するだけものであり、クラスの1つに強く紐付いたものにはなっていない。
<!-- The problem is that this hard-codes that a Person requires an Address. It can not be loaded without it. This does't fit to Slick's philosophy of giving you fine-grained control over what you load exactly. With Slick it is advised to map one table to a tuple or case class without them having object references to related objects. Instead you can write a function that joins two tables and returns them as a tuple or association case class instance, providing an association externally, not strongly tied one of the classes.  -->

```scala
val tupledJoin: Query[(People,Addresses),(Person,Address), Seq]
      = people join addresses on (_.addressId === _.id)
...
case class PersonWithAddress(person: Person, address: Address)
val caseClassJoinResults = db.run(tupledJoin.result).map(_.map(PersonWithAddress.tupled))
```

それ以外のアプローチとして、関連オブジェクトへの参照を表すOption型のメンバ変数をクラスに定義させることも出来る。Noneは関連オブジェクトがまだ読み込まれていない事を表す。しかしこれはタプルやケースクラスを用いても型安全性に欠けるものになっている。なぜなら、関連オブジェクトが読み込まれたとしても厳格なチェックが出来ないためである。
<!-- An alternative approach is giving your classes Option-typed members referring to related objects, where None means that the related objects have not been loaded yet. However this is less type-safe then using a tuple or case class, because it cannot be statically checked, if the related object is loaded.  -->

### Modifying relationships

ORMを用いて関連を操作する際に、関連オブジェクトのミュータブルなコレクションを用いて挿入や削除を行うといったことがしばしば見受けられる。変更は即座にデータベースへ書き込まれる、もしくはキャッシュに記録された後にまとめて書き込まれる。ステートフルなキャッシュやミュータブルなオブジェクトを扱うのを避けるために、SlickはSQLのように外部キーを用いた関連操作を提供している。関連の変更は、単に普通のフィールドを変更するかのように、外部キーのフィールドを新しいidへ更新する事で行う。良いことに、これはメモリにロードされていないオブジェクトの関連を、作成したり取り除いたりも出来るようになっている。単にidを扱うだけで十分なのである。
<!-- When manipulating relationships with ORMs you usually work on mutable collections of associated objects and inserts or remove related objects. Changes are written to the database immediately or recorded in a write cache and commited later. To avoid stateful caches and mutability, Slick handles relationship manipulations just like SQL - using foreign keys. Changing relationships means updating foreign key fields to new ids, just like updating any other field. As a bonus this allows establishing and removing associations with objects that have not been loaded into memory. Having their ids is sufficient.  -->

Inheritance
-----------

Slickは任意のオブジェクトグラフを押し付けたりはしない。Scalaに統合されたナイスな関連データモデルを提供しているだけである。関連スキーマは継承を含んでたりはしない。一般的に継承は、ルールに沿うような関連に簡単に取って代わられる。fooはbarであるというのは、barという役割を持つfooを考えるのと同じである。Slickはクエリ合成やクエリの抽象化を許可しており、継承風のクエリスニペットを実装するのは容易いし、再利用のための関数にも用いやすい。Slickは枠外の機能を提供していないが、その柔軟さゆえにあなた自身のコードの中で問題に合うような記述法等を自由に記述しても良い。
<!-- Slick does not persist arbitrary object-graphs. It rather exposes the relational data model nicely integrated into Scala. As the relational schema doesn't contain inheritance so doesn't Slick. This can be unfamiliar at first. Usually inheritance can be simply replaced by relationalships thinking along the lines of roles. Instead of foo is a bar think foo has role bar. As Slick allows query composition and abstraction, inheritance-like query-snippets can be easily implemented and put into functions for re-use. Slick doesn't provide any out of the box but allows you to flexibly come up with the ones that match your problem and use them in your queries.  -->

Code-generation
---------------

上記のようなコンセプトの多くは、Scalaのコードを用いてコードの重複を避けるような抽象化が行われる。しかし、もしかするとあなたはScalaの型システムの抽象能力の限界に達してしまうかもしれない。コード生成はこの課題に対する解決法の1つとして提供されている。Slickは非常に柔軟で様々なカスタマイズも行える[code generator](http://slick.typesafe.com/doc/3.0.0/code-generation.html)を提供している。コード生成機能はデータベースのメタデータを用いて動作する。Slickの型、関連情報を生成するのに必要な独自のメタデータを組み合わせる事も出来る。詳しくは[Scala Days 2014のトーク](http://slick.typesafe.com/docs/)を見て欲しい。
<!-- Many of the concepts described above can be abstracted over using Scala code to avoid repetition. There cases however, where you reach the limits of Scala's type system's abstraction capabilities. Code generation offers a solution to this. Slick comes with a very flexible and fully customizable code generator \<code-generation\>, which can be used to avoid repetition in these cases. The code generator operates on the meta data of the database. Combine it with your own extra meta data if needed and use it to generate Slick types, relationship accessors, association classes, etc. For more info see our Scala Days 2014 talk at <http://slick.typesafe.com/docs/> .  -->
