Slick 3.0.0 documentation - 08 Schema Code Generation

[Permalink to Schema Code Generation — Slick 3.0.0 documentation](http://slick.typesafe.com/doc/3.0.0/code-generation.html)

Schema Code Generation
======================

SLickのコードジェネレータはデータベーススキーマが既に存在している場合に、非常に便利なツールとなる。これはジェネレータ単独で利用する事もできるし、sbtのbuildと組わわせて全ての必要なSlickのコードを生成する事が出来る。
<!-- The Slick code generator is a convenient tool for working with an existing or evolving database schema. It can be run stand-alone or integrated into you sbt build for creating all code Slick needs to work.  -->

Overview
--------

デフォルトでは、コードジェネレータは全てのテーブルに対する`Table`クラスと、対応する`TableQuery`の値を生成する。列に対応するものは、各カラムを引数に取るケースクラスとして生成される。22より多くのカラムを持つテーブルについては、コードジェネレータは自動的にSlickの実験的な機能である`HList`を用いた実装に変更する。これはScalaのタプルサイズ問題を解決する1つの方法である。（Scalaのバージョンが2.10.3以下である場合、コンパイル時間に対する問題を解決するために`HCons`が`::`の代わりに用いられるが、これはScala2.10.4以上では解決されている話だ）
<!-- By default, the code generator generates `Table` classes, corresponding `TableQuery` values, which can be used in a collection-like manner, as well as case classes for holding complete rows of values. For tables with more than 22 columns the generator automatically switches to Slick's experimental `HList` implementation for overcoming Scala's tuple size limit. (In Scala \<= 2.10.3 use `HCons` instead of `::` as a type contructor due to performance issues during compilation, which are fixed in 2.10.4 and later.)  -->

ジェネレータについては、[talk at Scala eXchange 2013](http://slick.typesafe.com/docs/#20131203_patterns_for_slick_database_applications_at_scala_exchange_2013)にも説明があるから、是非見て欲しい。
<!-- Parts of the generator are also explained in our [talk at Scala eXchange 2013](http://slick.typesafe.com/docs/#20131203_patterns_for_slick_database_applications_at_scala_exchange_2013).  -->

Standalone use
--------------

SlickのコードジェネレータはそのライブラリがSlick本体とは独立して公開されている。sbtプロジェクトにおいては、以下のような記述をビルド定義（`build.sbt`や`project/Build.scala`など）に加える事で利用可能となる。
<!-- To include Slick's code generator use the published library. For sbt projects add following to your build definition -`build.sbt` or `project/Build.scala`:  -->

```scala
libraryDependencies += "com.typesafe.slick" %% "slick-codegen" % "3.0.0"
```

Mavenプロジェクトには、以下のような`<dependency>`を加えて欲しい。
<!-- For Maven projects add the following to your `<dependencies>`: -->

```xml
<dependency>
  <groupId>com.typesafe.slick</groupId>
  <artifactId>slick-codegen_2.10</artifactId>
  <version>3.0.0</version>
</dependency>
```

Slickのコードジェネレータはコマンドラインから、もしくはJavaやScalaからAPIを利用して使う事が出来る。単純な例だと、以下のように実行すれば良い。
<!-- Slick's code generator comes with a default runner that can be used from the command line or from Java/Scala. You can simply execute  -->

```
slick.codegen.SourceCodeGenerator.main(
  Array(slickDriver, jdbcDriver, url, outputFolder, pkg)
)
```

もしくは、こんな感じに。
<!-- or -->

```scala
slick.codegen.SourceCodeGenerator.main(
  Array(slickDriver, jdbcDriver, url, outputFolder, pkg, user, password)
)
```

引数は、以下のようなものを取る。
<!-- and provide the following values -->

-   **slickDriver** Slick driver class, e.g. *"slick.driver.H2Driver"*
-   **jdbcDriver** jdbc driver class, e.g. *"org.h2.Driver"*
-   **url** jdbc url, e.g. *"jdbc:postgresql://localhost/test"*
-   **outputFolder** 生成されたコードを出力するためのフォルダ
-   **pkg** 生成されたコードが置かれるべきScalaのパッケージ名
-   **user** データベースに接続するユーザ名
-   **password** データベースにユーザが接続する際に利用するパスワード

<!-- -   **slickDriver** Fully qualified name of Slick driver class, e.g. *"slick.driver.H2Driver"* -->
<!-- -   **jdbcDriver** Fully qualified name of jdbc driver class, e.g. *"org.h2.Driver"* -->
<!-- -   **url** jdbc url, e.g. *"jdbc:postgresql://localhost/test"* -->
<!-- -   **outputFolder** Place where the package folder structure should be put -->
<!-- -   **pkg** Scala package the generated code should be places in -->
<!-- -   **user** database connection user name -->
<!-- -   **password** database connection password -->

Integrated into sbt
-------------------

コードジェネレータは[sbt](http://www.scala-sbt.org/)で手で実行したり、コンパイル前に毎度実行したりも出来る。[slick-codegen-example](https://github.com/slick/slick-codegen-example)に例があるから参考にして欲しい。
<!-- The code generator can be run before every compilation or manually in sbt\_. An example project showing both can be [found here](https://github.com/slick/slick-codegen-example).  -->
（訳注: [tototoshi/sbt-slick-codegen](https://github.com/tototoshi/sbt-slick-codegen)も参考までに）

Generated Code
--------------

デフォルトでは、生成されたコードは指定されたフォルダー以下に`Tables.scala`という名前のファイルで保存される。このファイルは、良い感じにインポート出来るコードを持つ`object Tables`を含んでいる。Slickドライバーが適切なものになっているのかも確認出来る。このファイルには`trait Tables`も含まれていて、Cakeパターンを用いたい場合にはこちらを利用すると良い。
<!-- By default, the code generator places a file `Tables.scala` in the given folder in a subfolder corresponding to the package. The file contains an `object Tables` from which the code can be imported for use right away. Make sure you use the same Slick driver. The file also contains a `trait Tables` which can be used in the cake pattern.  -->

> **Warning**
>
> 生成されたコードを用いる際には、異なるデータベースドライバを誤って混ぜてしまわないように注意して欲しい。デフォルトの`object Tables`はコード生成の際にドライバを用いる。異なるドライバを一緒に使ってしまうと、ランタイムエラーを引き起こす。生成された`trait Tables`は異なるドライバーにより用いられるが、これは現在テストされておらず非公式な使い方となっている。あなたの環境では上手く動かないかもしれない。将来的にこれらについては公式でサポートする予定だ。

<!-- **warning** When using the generated code, be careful **not** to mix different database drivers accidentally. The default `object Tables` uses the driver used during code generation. Using it together with a different driver for queries will lead to runtime errors. The generated `trait Tables` can be used with a different driver, but be aware, that this is currently untested and not officially supported. It may or may not work in your case. We will officially support this at some point in the future.  -->

Customization
-------------

ジェネレータはデータモデルに対しどんなコードも生成出来るように様々なメソッドをオーバライドして自由にカスタマイズすることが出来る。簡単なカスタマイズから非常に大きなカスタマイズまで、様々なカスタマイズに対応出来ます。[Play](https://playframework.com/)に対応するフレームワークバインディングを行うだとか、そのような例があります。
<!-- The generator can be flexibly customized by overriding methods to programmatically generate any code based on the data model. This can be used for minor customizations as well as heavy, model driven code generation, e.g. for framework bindings in Play\_, other data-related, repetitive sections of applications, etc.  -->

[This example](https://github.com/slick/slick-codegen-customization-example)では、どのようにしてコードジェネレータをカスタマイズするのか、sbtのmulti-projectに対しどのようにセットアップするのか、メインとなるソースに対して、コンパイル前に毎度コードジェネレータをどのようにして実行させるのかを見ることが出来ます。
<!-- [This example](https://github.com/slick/slick-codegen-customization-example) shows a customized code-generator and how to setup up a multi-project sbt build, which compiles and runs it before compiling the main sources.  -->

コードジェネレータ、異なるフラグメントに対して最適化された小さなサブジェネレータの階層を構造化して実装されています。サブジェネレータの実装は、個々のファクトリメソッドをオーバーライドすることで、カスタマイズしたものに取り替える事ができる。[SourceCodeGenerator](http://slick.typesafe.com/doc/3.0.0/codegen-api/index.html#slick.codegen.SourceCodeGenerator)は各々のテーブルのためのサブジェネレータを生成するファクトリメソッドを含んでいる。サブジェネレータはTableクラス自体、エンティティとなるケースクラス、カラム、キー、インデックスなど、様々なものを生成するサブジェネレータを含んでいる。カスタマイズされたサブジェネレータも簡単に同様に扱う事ができる。
<!-- The implementation of the code generator is structured into a small hierarchy of sub-generators responsible for different fragments of the complete output. The implementation of each sub-generator can be swapped out for a customized one by overriding the corresponding factory method. SourceCodeGenerator \<slick.codegen.SourceCodeGenerator\> contains a factory method Table, which it uses to generate a sub-generator for each table. The sub-generator Table in turn contains sub-generators for Table classes, entity case classes, columns, key, indices, etc. Custom sub-generators can easily be added as well.  -->

様々なサブジェネレータにおいて、Slickのデータモデルに関連する部分はコード生成を実行させる際にアクセスされる。
<!-- Within the sub-generators the relevant part of the Slick data model can be accessed to drive the code generation.  -->

カスタマイズ可能なオーバーライド出来るメソッド一覧については、[api documentation](http://slick.typesafe.com/doc/3.0.0/codegen-api/index.html#slick.codegen.SourceCodeGenerator)を見て欲しい。
<!-- Please see the api documentation \<slick.codegen.SourceCodeGenerator\> for info on all of the methods that can be overridden for customization.  -->

以下にジェネレータをカスタマイズするサンプルを載せる。
<!-- Here is an example for customizing the generator: -->

```scala
import slick.codegen.SourceCodeGenerator
// データモデルを取得する
val modelAction = H2Driver.createModel(Some(H2Driver.defaultTables)) // テーブルのフィルタリングはここで行う
val modelFuture = db.run(modelAction)
// コードジェネレータをカスタマイズする
val codegenFuture = modelFuture.map(model => new SourceCodeGenerator(model) {
  // マッピングするテーブルとクラス名をオーバーライド
  override def entityName =
    dbTableName => dbTableName.dropRight(1).toLowerCase.toCamelCase
  override def tableName =
    dbTableName => dbTableName.toLowerCase.toCamelCase
  // いくつか追加のimportを加える
  override def code = "import foo.{MyCustomType,MyCustomTypeMapper}" + "\n" + super.code
  // テーブルジェネレータをカスタマイズ
  override def Table = new Table(_){
    // エンティティクラスの生成を抑制する
    override def EntityType = new EntityType{
      override def classEnabled = false
    }
    // カラムジェネレータをカスタマイズ
    override def Column = new Column(_){
      // 特定のカラムに対して、Scalaの型を変更するようカスタマイズ
      // e.g. to a custom enum or anything else
      override def rawType =
        if(model.name == "SOME_SPECIAL_COLUMN_NAME") "MyCustomType" else super.rawType
    }
  }
})
codegenFuture.onSuccess { case codegen =>
  codegen.writeToFile(
    "slick.driver.H2Driver","some/folder/","some.packag","Tables","Tables.scala"
  )
}
```
