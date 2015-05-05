Slick 3.0.0 documentation - 14 Slick Extensions

[Permalink to Slick Extensions — Slick 3.0.0 documentation](http://slick.typesafe.com/doc/3.0.0/extensions.html)

Slick Extensionsについて
================

Typesafeにより提供された商用サポートを伴うクローズドなソースパッケージであるSlick Extensionsは、以下のデータベースのためのSlickドライバを含んでいる。
<!-- Slick Extensions, a closed-source package with commercial support provided by Typesafe, Inc contains Slick drivers for:  -->

-   Oracle (`com.typesafe.slick.driver.oracle.OracleDriver`)
-   IBM DB2 (`com.typesafe.slick.driver.db2.DB2Driver`)
-   Microsoft SQL Server (`com.typesafe.slick.driver.ms.SQLServerDriver`)

> **Note**
>
> 開発とテストを目的とした利用の際には、[Typesafe Subscription Agreement](http://typesafe.com/public/legal/TypesafeSubscriptionAgreement.pdf) (PDF) を読んだ上で利用して欲しい。プロダクション環境での利用をするには、[Typesafe Subscription](http://typesafe.com/subscription)を見て欲しい。
<!-- **note** You may use it for development and testing purposes under the terms and conditions of the Typesafe Subscription Agreement\_ (PDF). Production use requires a Typesafe Subscription\_.  -->

もし[sbt](http://www.scala-sbt.org/)を利用しているのなら、Typesafeリポジトリにある _slick-extensions_ を依存に加える事で利用出来る。
<!-- If you are using sbt\_, you can add *slick-extensions* and the Typesafe repository (which contains the required artifacts) to your build definition like this:  -->

```scala
libraryDependencies += "com.typesafe.slick" %% "slick-extensions" % "3.0.0"
resolvers += "Typesafe Releases" at "<http://repo.typesafe.com/typesafe/maven-releases/>"
```
