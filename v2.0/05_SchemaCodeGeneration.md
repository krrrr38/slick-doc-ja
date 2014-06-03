Slick 2.0.0 documentation - 05 Schema code generation

[Permalink to Schema Code Generation — Slick 2.0.0 documentation](http://slick.typesafe.com/doc/2.0.0/code-generation.html)


Schema code generation
======================

Slickコードジェネレータは既存のデータベーススキーマをそのまま動かす上で便利なツールとなっている。スタンドアローン形式で動かしたり、sbtのbuildに対し統合したり出来る。

<!-- The Slick code generator is a convenient tool for working with an -->
<!-- existing or evolving database schema. It can be run as stand-alone or -->
<!-- integrated into you sbt build for creating all code Slick needs to work -->
<!-- with it. -->

Overview
--------

デフォルトでコードジェネレータは、TableQueryの値に対応するTableクラスを生成する。これらの値は、個々は行の値を包括するケースクラスとなり、全体としてコレクション操作関数が呼び出せるようなものになっている。もしScalaのタプルの限界数である22個より多いカラムが存在していたのなら、自動的にSlickの実験的な実装であるHListを用いた実装を出力する。(ちなみに、25カラムより多い場合には非常にコンパイルに時間がかかる事が分かっており、可能な限り早く修正する予定だ)

<!-- By default the code generator generates Table classes, corresponding -->
<!-- TableQuery values, which can be used in a collection-like manner as well -->
<!-- as case classes for holding complete rows of values. For Tables with -->
<!-- more than 22 columns the generator automatically switches to Slick's -->
<!-- experimental HList implementation for overcoming Scala's tuple size -->
<!-- limit. (Note that compilation times currently get extremely long for -->
<!-- more than 25 columns. We are hoping to fix this as soon as possible). -->

実装は実用的なものになってはいるが、コードジェネレータはSlick 2.0における新しい機能となっており、依然として実験的なものも含んでいる。必要なものを摘出し、必要のない機能を取り除いていく予定だ。将来的なバージョンにおけるコードジェネレータに対する修正は小さくする予定だ。もし必要ならば、Slickの他の部分から独立した実装にしても良い。我々はこの機能を用いた人々の挑戦に対する声に非常に関心がある。

<!-- The implementation is ready for practical use, but since it is new in -->
<!-- Slick 2.0 we consider it experimental and reserve the right to remove -->
<!-- features without a deprecation cycle if we think that it is necessary. -->
<!-- It would be only a small effort to run an old generator against a future -->
<!-- version of Slick though, if necessary, as it's implementation is rather -->
<!-- isolated from the rest of Slick. We are interested in hearing about -->
<!-- people's experiences with using it in practice. -->

ジェネレータについて、[talk at Scala eXchange2013](http://slick.typesafe.com/docs/#20131203_patterns_for_slick_database_applications_at_scala_exchange_2013)で軽く説明も行っている。

<!-- Parts of the generator are also explained in our [talk at Scala eXchange -->
<!-- 2013](http://slick.typesafe.com/docs/#20131203_patterns_for_slick_database_applications_at_scala_exchange_2013). -->

Run from the command line or Java/Scala
---------------------------------------

Slickのコードジェネレータは以下のようにして手軽に動かすことが出来る。

<!-- Slick's code generator comes with a default runner. You can simply -->
<!-- execute -->

```scala
scala.slick.model.codegen.SourceCodeGenerator.main(
  Array(slickDriver, jdbcDriver, url, outputFolder, pkg)
)
```

必要な引数は以下の通りである

<!-- and provide the following values -->

-   **slickDriver** *"scala.slick.driver.H2Driver"* のようなSlickのドライバークラス名
-   **jdbcDriver** *"org.h2.Driver"* のようなjdbcドライバークラス名
-   **url** *"jdbc:postgresql://localhost/test"* のようなjdbcのURL
-   **outputFolder** 出力先フォルダ
-   **pkg** 生成されるコードが属するScalaパッケージ

<!-- -   **slickDriver** Fully qualified name of Slick driver class, e.g. -->
<!--     *"scala.slick.driver.H2Driver"* -->
<!-- -   **jdbcDriver** Fully qualified name of jdbc driver class, e.g. -->
<!--     *"org.h2.Driver"* -->
<!-- -   **url** jdbc url, e.g. *"jdbc:postgresql://localhost/test"* -->
<!-- -   **outputFolder** Place where the package folder structure should be -->
<!--     put -->
<!-- -   **pkg** Scala package the generated code should be places in -->

コードジェネレータは指定されたパッケージ名に一致するサブフォルダを、指定された出力先フォルダの中に作成し、そこの"Tables.scala"というファイルへ結果を出力する。そのファイルには"Tables"オブジェクトが生成される。引数に与えたSlickドライバーと同じものが用いられているかを確認して欲しい。このファイルには同様に"Tables"トレイトがふくまれ、これはCakeパターンに用いられたものになっている。

<!-- The code generator places a file "Tables.scala" in the given folder in a -->
<!-- subfolder corresponding to the package. The file contains an object -->
<!-- "Tables" from which the code can be imported for use right away. Make -->
<!-- sure you use the same Slick driver. The file also contains a trait -->
<!-- "Tables" which can be used in the cake pattern. -->

Integrated into sbt
-------------------

コードジェネレータをコンパイル毎に事前に実行することも出来るし、手動で実行することも出来る。実際に使ってみた例が[こちら](https://github.com/slick/slick-codegen-example/tree/master)にあるので見て欲しい。

<!-- The code generator can be run before every compilation or manually. An -->
<!-- example project showing both can be [found -->
<!-- here](https://github.com/slick/slick-codegen-example/tree/master). -->

Customization
-------------

コードジェネレータはモデルデータに基づきコードを自動生成する関数をオーバーライドする事で、柔軟にカスタマイズ出来る。小さなカスタマイズであっても大きなカスタマイズであっても、このようなモデルドリブンなコードジェネレーションが同じように扱われる。例えば、とあるフレームワークにおけるバインディングや、その他のデータに関連するアプリケーションの繰り返しセクションにおいて用いられる。

<!-- The generator can be flexibly customized by overriding methods to -->
<!-- programmatically generate any code based on the data model. This can be -->
<!-- used for minor customizations as well as heavy, model driven code -->
<!-- generation, e.g. for framework bindings (Play,...), other data-related, -->
<!-- repetetive sections of applications, etc. -->

[この例](https://github.com/slick/slick-codegen-customization-example/tree/master)ではカスタマイズされたコードジェネレータを用いており、メインリソースをコンパイルする前にコードジェネレータを走らせるマルチプロジェクトのsbtビルドに対しどのように設定を行うのかを示している。

<!-- [This example](https://github.com/slick/slick-codegen-customization-example/tree/master) -->
<!-- shows a customized code-generator and how to setup up a multi-project -->
<!-- sbt build, which compiles and runs it before compiling the main sources. -->

コードジェネレータの実装は構造化されており、いくつかの階層化されたサブジェネレータに責務を委譲している。つまり完全なる出力を出す際に、部分化した結果を各ジェネレータにおいて出力している。各サブジェネレータの実装は、対応するファクトリメソッドをオーバーライドすることで、カスタマイズしたものへ変更する事が出来る。`SourceCodeGenerator`はファクトリメソッドである`Table`を持っており、これは各テーブルのためのサブジェネレータを生成するために用いられるものである。サブジェネレータである`Table`は、`Table`クラス、エンティティケースクラス、カラム、キー、インデックス、といった情報のための、別個複数のサブジェネレータを持っている。

<!-- The implementation of the code generator is structured into a small -->
<!-- hierarchy of sub-generators responsible for different fragments of the -->
<!-- complete output. The implementation of each sub-generator can be swapped -->
<!-- out for a customized one by overriding the corresponding factory method. -->
<!-- SourceCodeGenerator contains a factory method Table, which it uses to -->
<!-- generate a sub-generator for each table. The sub-generator Table in turn -->
<!-- contains sub-generators for Table classes, entity case classes, columns, -->
<!-- key, indices, etc. Custom sub-generators can easily be added as well. -->

Slickに部分的に関連するサブジェネレータにおいて、データモデルはコード生成のために用いられる。

<!-- Within the sub-generators the relevant part of the Slick data model can -->
<!-- be accessed to drive the code generation. -->

カスタマイズする際にオーバーライドする関数については、[APIドキュメント](http://slick.typesafe.com/doc/2.0.0/api/#scala.slick.model.codegen.SourceCodeGenerator)を是非見てもらいたい。

<!-- Please see the -->
<!-- api documentation \<scala.slick.model.codegen.SourceCodeGenerator\> for -->
<!-- info on all of the methods that can be overridden for customization. -->

コードジェネレータをカスタマイズする例として、以下のようなものがある。

<!-- Here is an example for customizing the generator: -->

```scala
import scala.slick.jdbc.meta.createModel
import scala.slick.model.codegen.SourceCodeGenerator
// fetch data model
val model = db.withSession{ implicit session =>
  createModel(H2Driver.getTables.list,H2Driver) // you can filter specific tables here
}
// customize code generator
val codegen = new SourceCodeGenerator(model){
  // override mapped table and class name
  override def entityName =
    dbTableName => dbTableName.dropRight(1).toLowerCase.toCamelCase
  override def tableName =
    dbTableName => dbTableName.toLowerCase.toCamelCase
  // add some custom import
  override def code = "import foo.{MyCustomType,MyCustomTypeMapper}" + "\n" + super.code
  // override table generator
  override def Table = new Table(_){
    // disable entity class generation and mapping
    override def EntityType = new EntityType{
      override def classEnabled = false
    }
    // override contained column generator
    override def Column = new Column(_){
      // use the data model member of this column to change the Scala type, e.g. to a custom enum or anything else
      override def rawType =
        if(model.name == "SOME_SPECIAL_COLUMN_NAME") "MyCustomType" else super.rawType
    }
  }
}
codegen.writeToFile(
  "scala.slick.driver.H2Driver","some/folder/","some.packag","Tables","Tables.scala"
)
```
