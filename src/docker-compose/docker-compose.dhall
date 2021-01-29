{ networks.sourcegraph = None <>
, services =
  { caddy =
    { container_name = "caddy"
    , cpus = 4
    , environment =
      [ "XDG_DATA_HOME=/caddy-storage/data"
      , "XDG_CONFIG_HOME=/caddy-storage/config"
      , "SRC_FRONTEND_ADDRESSES=sourcegraph-frontend-0:3080"
      ]
    , image =
        "index.docker.io/caddy/caddy:alpine@sha256:ef2f47730caa12cb7d0ba944c048b8e48f029d5e0ff861840fa2b8f1868e1966"
    , mem_limit = "4g"
    , networks = [ "sourcegraph" ]
    , ports = [ "0.0.0.0:80:80", "0.0.0.0:443:443" ]
    , restart = "always"
    , volumes =
      [ "caddy:/caddy-storage"
      , "../caddy/builtins/http.Caddyfile:/etc/caddy/Caddyfile"
      ]
    }
  , cadvisor =
    { command = [ "--port=8080" ]
    , container_name = "cadvisor"
    , cpus = 1
    , image =
        "index.docker.io/sourcegraph/cadvisor:3.19.2@sha256:76276b4b464154d0329c7d960fdfcb2c627784a0e809243cc53d3e5dea6f19c8"
    , mem_limit = "1g"
    , networks = [ "sourcegraph" ]
    , restart = "always"
    , volumes =
      [ "/:/rootfs:ro"
      , "/var/run:/var/run:ro"
      , "/sys:/sys:ro"
      , "/var/lib/docker/:/var/lib/docker:ro"
      , "/dev/disk/:/dev/disk:ro"
      ]
    }
  , github-proxy =
    { container_name = "github-proxy"
    , cpus = 1
    , environment =
      [ "GOMAXPROCS=1"
      , "SRC_FRONTEND_INTERNAL=sourcegraph-frontend-internal:3090"
      , "JAEGER_AGENT_HOST=jaeger"
      ]
    , image =
        "index.docker.io/sourcegraph/github-proxy:3.19.2@sha256:bf435dd750c46840e2b45696577e0d94aac7a0afedf43428c2073a85c429843c"
    , mem_limit = "1g"
    , networks = [ "sourcegraph" ]
    , restart = "always"
    }
  , gitserver-0 =
    { container_name = "gitserver-0"
    , cpus = 4
    , environment =
      [ "GOMAXPROCS=4"
      , "SRC_FRONTEND_INTERNAL=sourcegraph-frontend-internal:3090"
      , "JAEGER_AGENT_HOST=jaeger"
      ]
    , image =
        "index.docker.io/sourcegraph/gitserver:3.19.2@sha256:51b827ff2bf3f9df740cd8538840ef7fd7cb245c7b93063ef829f67ca71ea23e"
    , mem_limit = "8g"
    , networks = [ "sourcegraph" ]
    , restart = "always"
    , volumes = [ "gitserver-0:/data/repos" ]
    }
  , grafana =
    { container_name = "grafana"
    , cpus = 1
    , image =
        "index.docker.io/sourcegraph/grafana:3.19.2@sha256:0f363ceecf8d206b16afa16716365949c882016a040c3b04a0041252ff8dbb11"
    , mem_limit = "1g"
    , networks = [ "sourcegraph" ]
    , ports = [ "0.0.0.0:3370:3370" ]
    , restart = "always"
    , volumes =
      [ "grafana:/var/lib/grafana"
      , "../grafana/datasources:/sg_config_grafana/provisioning/datasources"
      , "../grafana/dashboards:/sg_grafana_additional_dashboards"
      ]
    }
  , jaeger =
    { command = [ "--memory.max-traces=20000" ]
    , container_name = "jaeger"
    , cpus = 0.5
    , image =
        "index.docker.io/sourcegraph/jaeger-all-in-one:3.19.2@sha256:fe04ae824252cb7bfb7047242d5f5da3a8491681b4007213c5d989d761f226ca"
    , mem_limit = "512m"
    , networks = [ "sourcegraph" ]
    , ports =
      [ "0.0.0.0:16686:16686"
      , "0.0.0.0:14250:14250"
      , "0.0.0.0:5778:5778"
      , "0.0.0.0:6831:6831"
      , "0.0.0.0:6832:6832"
      ]
    , restart = "always"
    }
  , pgsql =
    { container_name = "pgsql"
    , cpus = 4
    , healthcheck =
      { interval = "10s"
      , retries = 3
      , start_period = "15s"
      , test = "/liveness.sh"
      , timeout = "1s"
      }
    , image =
        "index.docker.io/sourcegraph/postgres-11.4:3.19.2@sha256:63090799b34b3115a387d96fe2227a37999d432b774a1d9b7966b8c5d81b56ad"
    , mem_limit = "2g"
    , networks = [ "sourcegraph" ]
    , restart = "always"
    , volumes = [ "pgsql:/data/" ]
    }
  , precise-code-intel-bundle-manager =
    { container_name = "precise-code-intel-bundle-manager"
    , cpus = 2
    , environment =
      [ "SRC_FRONTEND_INTERNAL=sourcegraph-frontend-internal:3090" ]
    , healthcheck =
      { interval = "5s"
      , retries = 3
      , start_period = "60s"
      , test = "wget -q 'http://127.0.0.1:3187/healthz' -O /dev/null || exit 1"
      , timeout = "5s"
      }
    , image =
        "index.docker.io/sourcegraph/precise-code-intel-bundle-manager:3.19.2@sha256:104b10b85cd508e31cc71271a7a5153d7248d2ef28a8f08756875d863492e363"
    , mem_limit = "2g"
    , networks = [ "sourcegraph" ]
    , restart = "always"
    , volumes = [ "precise-code-intel-bundle-manager:/lsif-storage" ]
    }
  , precise-code-intel-worker =
    { container_name = "precise-code-intel-worker"
    , cpus = 2
    , environment =
      [ "PRECISE_CODE_INTEL_BUNDLE_MANAGER_URL=http://precise-code-intel-bundle-manager:3187"
      , "SRC_FRONTEND_INTERNAL=sourcegraph-frontend-internal:3090"
      ]
    , healthcheck =
      { interval = "5s"
      , retries = 3
      , start_period = "60s"
      , test = "wget -q 'http://127.0.0.1:3188/healthz' -O /dev/null || exit 1"
      , timeout = "5s"
      }
    , image =
        "index.docker.io/sourcegraph/precise-code-intel-worker:3.19.2@sha256:a1f5e4589cf09995d67cca1156749a371d24d8af9f1171808df1d39d6b6f1df6"
    , mem_limit = "4g"
    , networks = [ "sourcegraph" ]
    , restart = "always"
    }
  , prometheus =
    { container_name = "prometheus"
    , cpus = 4
    , environment =
      [ "SRC_FRONTEND_INTERNAL=sourcegraph-frontend-internal:3090" ]
    , image =
        "index.docker.io/sourcegraph/prometheus:3.19.2@sha256:be6b68a89bdf4b4b60ed61a1545179b20f91db8ba11e60869aaa00720b7c0e7b"
    , mem_limit = "8g"
    , networks = [ "sourcegraph" ]
    , ports = [ "0.0.0.0:9090:9090" ]
    , restart = "always"
    , volumes =
      [ "prometheus-v2:/prometheus", "../prometheus:/sg_prometheus_add_ons" ]
    }
  , query-runner =
    { container_name = "query-runner"
    , cpus = 1
    , environment =
      [ "GOMAXPROCS=1"
      , "SRC_FRONTEND_INTERNAL=sourcegraph-frontend-internal:3090"
      , "JAEGER_AGENT_HOST=jaeger"
      ]
    , image =
        "index.docker.io/sourcegraph/query-runner:3.19.2@sha256:bdf87a86c751774dc7940ed3f4bd0a508e24e06630b1b8874d1dc43b1263969f"
    , mem_limit = "1g"
    , networks = [ "sourcegraph" ]
    , restart = "always"
    }
  , redis-cache =
    { container_name = "redis-cache"
    , cpus = 1
    , image =
        "index.docker.io/sourcegraph/redis-cache:3.19.2@sha256:7820219195ab3e8fdae5875cd690fed1b2a01fd1063bd94210c0e9d529c38e56"
    , mem_limit = "6g"
    , networks = [ "sourcegraph" ]
    , restart = "always"
    , volumes = [ "redis-cache:/redis-data" ]
    }
  , redis-store =
    { container_name = "redis-store"
    , cpus = 1
    , image =
        "index.docker.io/sourcegraph/redis-store:3.19.2@sha256:e8467a8279832207559bdfbc4a89b68916ecd5b44ab5cf7620c995461c005168"
    , mem_limit = "6g"
    , networks = [ "sourcegraph" ]
    , restart = "always"
    , volumes = [ "redis-store:/redis-data" ]
    }
  , repo-updater =
    { container_name = "repo-updater"
    , cpus = 4
    , environment =
      [ "GOMAXPROCS=1"
      , "SRC_FRONTEND_INTERNAL=sourcegraph-frontend-internal:3090"
      , "JAEGER_AGENT_HOST=jaeger"
      , "GITHUB_BASE_URL=http://github-proxy:3180"
      ]
    , image =
        "index.docker.io/sourcegraph/repo-updater:3.19.2@sha256:c135cd1efd3731c3cc0cc03f205147917110240650888e538fdbe325a552caff"
    , mem_limit = "4g"
    , networks = [ "sourcegraph" ]
    , restart = "always"
    , volumes = [ "repo-updater:/mnt/cache" ]
    }
  , searcher-0 =
    { container_name = "searcher-0"
    , cpus = 2
    , environment =
      [ "GOMAXPROCS=2"
      , "SRC_FRONTEND_INTERNAL=sourcegraph-frontend-internal:3090"
      , "JAEGER_AGENT_HOST=jaeger"
      ]
    , healthcheck =
      { interval = "5s"
      , retries = 3
      , test = "wget -q 'http://127.0.0.1:3181/healthz' -O /dev/null || exit 1"
      , timeout = "10s"
      }
    , image =
        "index.docker.io/sourcegraph/searcher:3.19.2@sha256:96c83aa499031c3811cac30f2c0637f00873125b465708495e018d7e2cca680a"
    , mem_limit = "2g"
    , networks = [ "sourcegraph" ]
    , restart = "always"
    , volumes = [ "searcher-0:/mnt/cache" ]
    }
  , sourcegraph-frontend-0 =
    { container_name = "sourcegraph-frontend-0"
    , cpus = 4
    , environment =
      [ "DEPLOY_TYPE=docker-compose"
      , "GOMAXPROCS=12"
      , "JAEGER_AGENT_HOST=jaeger"
      , "PGHOST=pgsql"
      , "SRC_GIT_SERVERS=gitserver-0:3178"
      , "SRC_SYNTECT_SERVER=http://syntect-server:9238"
      , "SEARCHER_URL=http://searcher-0:3181"
      , "SYMBOLS_URL=http://symbols-0:3184"
      , "INDEXED_SEARCH_SERVERS=zoekt-webserver-0:6070"
      , "SRC_FRONTEND_INTERNAL=sourcegraph-frontend-internal:3090"
      , "REPO_UPDATER_URL=http://repo-updater:3182"
      , "PRECISE_CODE_INTEL_BUNDLE_MANAGER_URL=http://precise-code-intel-bundle-manager:3187"
      , "GRAFANA_SERVER_URL=http://grafana:3370"
      , "JAEGER_SERVER_URL=http://jaeger:16686"
      , "GITHUB_BASE_URL=http://github-proxy:3180"
      , "PROMETHEUS_URL=http://prometheus:9090"
      ]
    , healthcheck =
      { interval = "5s"
      , retries = 3
      , start_period = "300s"
      , test = "wget -q 'http://127.0.0.1:3080/healthz' -O /dev/null || exit 1"
      , timeout = "10s"
      }
    , image =
        "index.docker.io/sourcegraph/frontend:3.19.2@sha256:776606b680d7ce4a5d37451831ef2414ab10414b5e945ed5f50fe768f898d23f"
    , mem_limit = "8g"
    , networks = [ "sourcegraph" ]
    , restart = "always"
    , volumes = [ "sourcegraph-frontend-0:/mnt/cache" ]
    }
  , sourcegraph-frontend-internal =
    { container_name = "sourcegraph-frontend-internal"
    , cpus = 4
    , environment =
      [ "DEPLOY_TYPE=docker-compose"
      , "GOMAXPROCS=4"
      , "PGHOST=pgsql"
      , "SRC_GIT_SERVERS=gitserver-0:3178"
      , "SRC_SYNTECT_SERVER=http://syntect-server:9238"
      , "SEARCHER_URL=http://searcher-0:3181"
      , "SYMBOLS_URL=http://symbols-0:3184"
      , "INDEXED_SEARCH_SERVERS=zoekt-webserver-0:6070"
      , "SRC_FRONTEND_INTERNAL=sourcegraph-frontend-internal:3090"
      , "REPO_UPDATER_URL=http://repo-updater:3182"
      , "PRECISE_CODE_INTEL_BUNDLE_MANAGER_URL=http://precise-code-intel-bundle-manager:3187"
      , "GRAFANA_SERVER_URL=http://grafana:3000"
      , "JAEGER_SERVER_URL=http://jaeger:16686"
      , "GITHUB_BASE_URL=http://github-proxy:3180"
      , "PROMETHEUS_URL=http://prometheus:9090"
      ]
    , image =
        "index.docker.io/sourcegraph/frontend:3.19.2@sha256:776606b680d7ce4a5d37451831ef2414ab10414b5e945ed5f50fe768f898d23f"
    , mem_limit = "8g"
    , networks = [ "sourcegraph" ]
    , restart = "always"
    , volumes = [ "sourcegraph-frontend-internal-0:/mnt/cache" ]
    }
  , symbols-0 =
    { container_name = "symbols-0"
    , cpus = 2
    , environment =
      [ "GOMAXPROCS=2"
      , "SRC_FRONTEND_INTERNAL=sourcegraph-frontend-internal:3090"
      , "JAEGER_AGENT_HOST=jaeger"
      ]
    , healthcheck =
      { interval = "5s"
      , retries = 3
      , start_period = "60s"
      , test = "wget -q 'http://127.0.0.1:3184/healthz' -O /dev/null || exit 1"
      , timeout = "5s"
      }
    , image =
        "index.docker.io/sourcegraph/symbols:3.19.2@sha256:4254ec07804e84ab8b9b63fca906122c8501e3678978b818fe20dc3ec0344efd"
    , mem_limit = "4g"
    , networks = [ "sourcegraph" ]
    , restart = "always"
    , volumes = [ "symbols-0:/mnt/cache" ]
    }
  , syntect-server =
    { container_name = "syntect-server"
    , cpus = 4
    , healthcheck =
      { interval = "5s"
      , retries = 3
      , start_period = "5s"
      , test = "wget -q 'http://127.0.0.1:9238/health' -O /dev/null || exit 1"
      , timeout = "5s"
      }
    , image =
        "index.docker.io/sourcegraph/syntax-highlighter:3.19.2@sha256:625c556f5cf456144e51e3fe55e6312398b7714994165b4f605711e6f7d862a0"
    , mem_limit = "6g"
    , networks = [ "sourcegraph" ]
    , restart = "always"
    }
  , zoekt-indexserver-0 =
    { container_name = "zoekt-indexserver-0"
    , environment =
      [ "GOMAXPROCS=8"
      , "HOSTNAME=zoekt-webserver-0:6070"
      , "SRC_FRONTEND_INTERNAL=http://sourcegraph-frontend-internal:3090"
      ]
    , hostname = "zoekt-indexserver-0"
    , image =
        "index.docker.io/sourcegraph/search-indexer:3.19.2@sha256:7ddeb4d06a89e086506f08d9a114186260c7fa6c242e59be8c28b505d506047a"
    , mem_limit = "16g"
    , networks = [ "sourcegraph" ]
    , restart = "always"
    , volumes = [ "zoekt-0-shared:/data/index" ]
    }
  , zoekt-webserver-0 =
    { container_name = "zoekt-webserver-0"
    , cpus = 8
    , environment = [ "GOMAXPROCS=8", "HOSTNAME=zoekt-webserver-0:6070" ]
    , healthcheck =
      { interval = "5s"
      , retries = 3
      , test = "wget -q 'http://127.0.0.1:6070/healthz' -O /dev/null || exit 1"
      , timeout = "10s"
      }
    , hostname = "zoekt-webserver-0"
    , image =
        "index.docker.io/sourcegraph/indexed-searcher:3.19.2@sha256:d2e87635cf48c4c5d744962540751022013359bc00a9fb8e1ec2464cc6a0a2b8"
    , mem_limit = "50g"
    , networks = [ "sourcegraph" ]
    , restart = "always"
    , volumes = [ "zoekt-0-shared:/data/index" ]
    }
  }
, version = "2.4"
, volumes =
  { caddy = None <>
  , gitserver-0 = None <>
  , grafana = None <>
  , pgsql = None <>
  , precise-code-intel-bundle-manager = None <>
  , prometheus-v2 = None <>
  , redis-cache = None <>
  , redis-store = None <>
  , repo-updater = None <>
  , searcher-0 = None <>
  , sourcegraph-frontend-0 = None <>
  , sourcegraph-frontend-internal-0 = None <>
  , symbols-0 = None <>
  , zoekt-0-shared = None <>
  }
}
