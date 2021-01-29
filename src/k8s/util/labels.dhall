let deploySourcegraph = { deploy = "sourcegraph" }

let noClusterAdmin = { sourcegraph-resource-requires = "no-cluster-admin" }

in  { deploySourcegraph, noClusterAdmin }
