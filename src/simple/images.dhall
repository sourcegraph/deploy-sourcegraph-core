let images =
      { sourcegraph/cadvisor =
        { registry = Some "index.docker.io"
        , name = "sourcegraph/cadvisor"
        , tag = "insiders"
        , digest = Some
            "da8fa91d4e06bdcd430ceb5e719f63339a5ff233471850bf16c7290cbb3630fd"
        }
      , sourcegraph/alpine =
        { registry = None Text
        , name = "sourcegraph/alpine"
        , tag = "3.10"
        , digest = Some
            "4d05cd5669726fc38823e92320659a6d1ef7879e62268adec5df658a0bacf65c"
        }
      , sourcegraph/codeintel-db =
        { registry = Some "index.docker.io"
        , name = "sourcegraph/codeintel-db"
        , tag = "insiders"
        , digest = Some
            "a55fea6638d478c2368c227d06a1a2b7a2056b693967628427d41c92d9209e97"
        }
      , wrouesnel/postgres_exporter =
        { registry = None Text
        , name = "wrouesnel/postgres_exporter"
        , tag = "v0.7.0"
        , digest = Some
            "785c919627c06f540d515aac88b7966f352403f73e931e70dc2cbf783146a98b"
        }
      , sourcegraph/frontend =
        { registry = Some "index.docker.io"
        , name = "sourcegraph/frontend"
        , tag = "insiders"
        , digest = Some
            "6634dedb1f7e80b8f7b781ae169a98f578ac9d42cdf7b21597ee295ebd53a3e8"
        }
      , sourcegraph/jaeger-agent =
        { registry = Some "index.docker.io"
        , name = "sourcegraph/jaeger-agent"
        , tag = "insiders"
        , digest = Some
            "626831a08a1cfbd4d66c84c0c57b995df6a36a80c37a0f419df73ec86088e908"
        }
      , sourcegraph/github-proxy =
        { registry = Some "index.docker.io"
        , name = "sourcegraph/github-proxy"
        , tag = "insiders"
        , digest = Some
            "c2942b35049793a0f52fc123d5287f56d3a59082ad579e1e697bed2c05a06572"
        }
      , sourcegraph/gitserver =
        { registry = Some "index.docker.io"
        , name = "sourcegraph/gitserver"
        , tag = "insiders"
        , digest = Some
            "0a5b2b0171c426442e7138d0c0e2d4a9bcf007a14066c6573fcf371ec1e3283d"
        }
      , sourcegraph/grafana =
        { registry = Some "index.docker.io"
        , name = "sourcegraph/grafana"
        , tag = "insiders"
        , digest = Some
            "a176f43202b0be8ee891452ee454515da93baee7d173ede4c9a8a5bc18d91a3d"
        }
      , sourcegraph/indexed-searcher =
        { registry = Some "index.docker.io"
        , name = "sourcegraph/indexed-searcher"
        , tag = "insiders"
        , digest = Some
            "76d7e8a7453caed03412064d2f8e40dd49b9df958edd846e5a91c514b840803e"
        }
      , sourcegraph/search-indexer =
        { registry = Some "index.docker.io"
        , name = "sourcegraph/search-indexer"
        , tag = "insiders"
        , digest = Some
            "89fa7d5eac6f9f3e8893a482650dffcea4d22be993328427679af7e3ddd08e10"
        }
      , sourcegraph/jaeger-all-in-one =
        { registry = Some "index.docker.io"
        , name = "sourcegraph/jaeger-all-in-one"
        , tag = "insiders"
        , digest = Some
            "4d7b14f09400931017aa1ab2565b9a5210613291f74d0fcaabf5446cbb727739"
        }
      , sourcegraph/minio =
        { registry = Some "index.docker.io"
        , name = "sourcegraph/minio"
        , tag = "insiders"
        , digest = Some
            "3d7a0147396ea799284ba707765d477797518425682c9aa65faa5883a63fac4f"
        }
      , `sourcegraph/postgres-11.4` =
        { registry = Some "index.docker.io"
        , name = "sourcegraph/postgres-11.4"
        , tag = "insiders"
        , digest = Some
            "a55fea6638d478c2368c227d06a1a2b7a2056b693967628427d41c92d9209e97"
        }
      , sourcegraph/postgres_exporter =
        { registry = None Text
        , name = "sourcegraph/postgres_exporter"
        , tag = "insiders"
        , digest = Some
            "ac8ef017099276edef5df78fba63d633e68bd881fa56882074f4710e09ebe1ed"
        }
      , sourcegraph/precise-code-intel-worker =
        { registry = Some "index.docker.io"
        , name = "sourcegraph/precise-code-intel-worker"
        , tag = "insiders"
        , digest = Some
            "fffa377c6576e6dba8a0b3160391a04999d103ca054fd8ef48558547badcbe5c"
        }
      , sourcegraph/prometheus =
        { registry = Some "index.docker.io"
        , name = "sourcegraph/prometheus"
        , tag = "insiders"
        , digest = Some
            "d2e77c4a178c15139e76c29f9708792fdfd39e561e5d0be584c67dfbe6a496eb"
        }
      , sourcegraph/query-runner =
        { registry = Some "index.docker.io"
        , name = "sourcegraph/query-runner"
        , tag = "insiders"
        , digest = Some
            "6f8b007b54f9641d4048db2af0a50522bd306b4263880b1ed4095b2064e04ab8"
        }
      , sourcegraph/redis-cache =
        { registry = Some "index.docker.io"
        , name = "sourcegraph/redis-cache"
        , tag = "insiders"
        , digest = Some
            "7820219195ab3e8fdae5875cd690fed1b2a01fd1063bd94210c0e9d529c38e56"
        }
      , sourcegraph/redis_exporter =
        { registry = Some "index.docker.io"
        , name = "sourcegraph/redis_exporter"
        , tag = "84464_2021-01-15_c2e4c28"
        , digest = Some
            "f3f51453e4261734f08579fe9c812c66ee443626690091401674be4fb724da70"
        }
      , sourcegraph/redis-store =
        { registry = Some "index.docker.io"
        , name = "sourcegraph/redis-store"
        , tag = "insiders"
        , digest = Some
            "e8467a8279832207559bdfbc4a89b68916ecd5b44ab5cf7620c995461c005168"
        }
      , sourcegraph/repo-updater =
        { registry = Some "index.docker.io"
        , name = "sourcegraph/repo-updater"
        , tag = "insiders"
        , digest = Some
            "811b345d8b06cc411c4138519652b33dbf1be3d6db2e0ed5d7a31e4d8c0ae266"
        }
      , sourcegraph/searcher =
        { registry = Some "index.docker.io"
        , name = "sourcegraph/searcher"
        , tag = "insiders"
        , digest = Some
            "1270809512e5f61eb0867e82c08f0f98fa58b4d282ffbbdf23c5ace095132831"
        }
      , sourcegraph/symbols =
        { registry = Some "index.docker.io"
        , name = "sourcegraph/symbols"
        , tag = "insiders"
        , digest = Some
            "0bd03b9faec72499a595f08dcd65b28944eaeccdc1adc5d768edfba2a71f657b"
        }
      , sourcegraph/syntax-highlighter =
        { registry = Some "index.docker.io"
        , name = "sourcegraph/syntax-highlighter"
        , tag = "insiders"
        , digest = Some
            "83ff65809e6647b466bd400de4c438a32feeabe8e791b12e15c67c84529ad2de"
        }
      }

in  images
