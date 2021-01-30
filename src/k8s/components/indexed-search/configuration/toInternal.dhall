let Kubernetes/SecurityContext =
      ../../../../deps/k8s/schemas/io.k8s.api.core.v1.SecurityContext.dhall

let Kubernetes/VolumeMount =
      ../../../../deps/k8s/schemas/io.k8s.api.core.v1.VolumeMount.dhall

let Configuration/global = ../../../configuration/global.dhall

let Configuration/internal = ./internal.dhall

let Configuration/internal/statefulset = ./internal/statefulset.dhall

let Configuration/internal/service/indexed-search = ./internal/service/indexed-search.dhall

let Configuration/internal/service/indexed-search-indexer = ./internal/service/indexed-search-indexer.dhall

let Configuration/internal/Environment = ./environment/environment.dhall

let Configuration/internal/Containers/zoekt-indexserver =
      ./internal/container/zoekt-indexserver.dhall

let Configuration/internal/Containers/zoekt-webserver =
      ./internal/container/zoekt-webserver.dhall

let util = ../../../../util/package.dhall

let environment/toList = ./environment/toList.dhall

let Simple/IndexedSearch = ../../../../simple/indexed-search/package.dhall

let Image/manipulate = util.Image/manipulate

let Fixtures = ../../../util/test-fixtures/package.dhall

let Configuration/ResourceRequirements/toK8s =
      ../../../util/container-resources/toK8s.dhall

let nonRootSecurityContext =
      Kubernetes/SecurityContext::{
      , runAsUser = Some 100
      , runAsGroup = Some 101
      , allowPrivilegeEscalation = Some False
      }

let getSecurityContext
    : ∀(cg : Configuration/global.Type) →
        Optional Kubernetes/SecurityContext.Type
    = λ(cg : Configuration/global.Type) →
        if    cg.Global.nonRoot
        then  Some nonRootSecurityContext
        else  None Kubernetes/SecurityContext.Type

let Container/Zoekt-Indexserver/toInternal
    : ∀(cg : Configuration/global.Type) →
        Configuration/internal/Containers/zoekt-indexserver
    = λ(cg : Configuration/global.Type) →
        let opts = cg.indexed-search.StatefulSet.Containers.zoekt-indexserver

        let image = Image/manipulate cg.Global.ImageManipulations opts.image

        let resources = Configuration/ResourceRequirements/toK8s opts.resources

        let securityContext = getSecurityContext cg

        let envVars = environment/toList opts.environment

        let envVars = Some (envVars # opts.additionalEnvVars)

        let simple/indexserver = Simple/IndexedSearch.Containers.indexserver

        let dataVolumeMount =
              Kubernetes/VolumeMount::{
              , mountPath = simple/indexserver.volumes.data
              , name = "data"
              }

        let volumeMounts = [ dataVolumeMount ] # opts.additionalVolumeMounts

        in  { image
            , resources
            , securityContext
            , envVars
            , volumeMounts = Some volumeMounts
            }

let Container/Zoekt-Webserver/toInternal
    : ∀(cg : Configuration/global.Type) →
        Configuration/internal/Containers/zoekt-webserver
    = λ(cg : Configuration/global.Type) →
        let opts = cg.indexed-search.StatefulSet.Containers.zoekt-webserver

        let image = Image/manipulate cg.Global.ImageManipulations opts.image

        let resources = Configuration/ResourceRequirements/toK8s opts.resources

        let securityContext = getSecurityContext cg

        let envVars = environment/toList opts.environment

        let envVars = Some (envVars # opts.additionalEnvVars)

        let simple/webserver = Simple/IndexedSearch.Containers.webserver

        let dataVolumeMount =
              Kubernetes/VolumeMount::{
              , mountPath = simple/webserver.volumes.data
              , name = "data"
              }

        let volumeMounts = [ dataVolumeMount ] # opts.additionalVolumeMounts

        in  { image
            , resources
            , securityContext
            , envVars
            , volumeMounts = Some volumeMounts
            }

let Test/Container/Zoekt-Indexserver/Image =
        assert
      :   ( Container/Zoekt-Indexserver/toInternal
              ( Fixtures.Config.Default
                with   indexed-search
                     . StatefulSet
                     . Containers
                     . zoekt-indexserver
                     . image
                     = Fixtures.Image.Base
                with Global.ImageManipulations
                     = Fixtures.Image.ManipulateOptions
              )
          ).image
        ≡ Fixtures.Image.Manipulated

let Test/Container/Zoekt-Indexserver/Resources/none =
        assert
      :   ( Container/Zoekt-Indexserver/toInternal
              ( Fixtures.Config.Default
                with   indexed-search
                     . StatefulSet
                     . Containers
                     . zoekt-indexserver
                     . resources
                     = Fixtures.Resources.EmptyInput
              )
          ).resources
        ≡ Fixtures.Resources.EmptyExpected

let Test/Container/Zoekt-Indexserver/Resources/some =
        assert
      :   ( Container/Zoekt-Indexserver/toInternal
              ( Fixtures.Config.Default
                with   indexed-search
                     . StatefulSet
                     . Containers
                     . zoekt-indexserver
                     . resources
                     = Fixtures.Resources.Input
              )
          ).resources
        ≡ Fixtures.Resources.Expected

let Test/Container/Zoekt-Indexserver/SecurityContext/none =
        assert
      :   ( Container/Zoekt-Indexserver/toInternal
              (Fixtures.Config.Default with Global.nonRoot = False)
          ).securityContext
        ≡ None Kubernetes/SecurityContext.Type

let Test/Container/Zoekt-Indexserver/SecurityContext/some =
        assert
      :   ( Container/Zoekt-Indexserver/toInternal
              (Fixtures.Config.Default with Global.nonRoot = True)
          ).securityContext
        ≡ Some
            Kubernetes/SecurityContext::{
            , runAsUser = Some 100
            , runAsGroup = Some 101
            , allowPrivilegeEscalation = Some False
            }

let Test/Container/Zoekt-Webserver/Image =
        assert
      :   ( Container/Zoekt-Webserver/toInternal
              ( Fixtures.Config.Default
                with indexed-search.StatefulSet.Containers.zoekt-webserver.image
                     = Fixtures.Image.Base
                with Global.ImageManipulations
                     = Fixtures.Image.ManipulateOptions
              )
          ).image
        ≡ Fixtures.Image.Manipulated

let Test/Container/Zoekt-Webserver/Resources/none =
        assert
      :   ( Container/Zoekt-Webserver/toInternal
              ( Fixtures.Config.Default
                with   indexed-search
                     . StatefulSet
                     . Containers
                     . zoekt-webserver
                     . resources
                     = Fixtures.Resources.EmptyInput
              )
          ).resources
        ≡ Fixtures.Resources.EmptyExpected

let Test/Container/Zoekt-Webserver/Resources/some =
        assert
      :   ( Container/Zoekt-Webserver/toInternal
              ( Fixtures.Config.Default
                with   indexed-search
                     . StatefulSet
                     . Containers
                     . zoekt-webserver
                     . resources
                     = Fixtures.Resources.Input
              )
          ).resources
        ≡ Fixtures.Resources.Expected

let Test/Container/Zoekt-Webserver/SecurityContext/none =
        assert
      :   ( Container/Zoekt-Webserver/toInternal
              (Fixtures.Config.Default with Global.nonRoot = False)
          ).securityContext
        ≡ None Kubernetes/SecurityContext.Type

let Test/Container/Zoekt-Webserver/SecurityContext/some =
        assert
      :   ( Container/Zoekt-Webserver/toInternal
              (Fixtures.Config.Default with Global.nonRoot = True)
          ).securityContext
        ≡ Some
            Kubernetes/SecurityContext::{
            , runAsUser = Some 100
            , runAsGroup = Some 101
            , allowPrivilegeEscalation = Some False
            }

let StatefulSet/toInternal
    : ∀(cg : Configuration/global.Type) → Configuration/internal/statefulset
    = λ(cg : Configuration/global.Type) →
        let namespace = cg.Global.namespace

        let opts = cg.indexed-search.StatefulSet

        let replicas = opts.replicas

        in  { namespace
            , replicas
            , Containers =
              { zoekt-indexserver = Container/Zoekt-Indexserver/toInternal cg
              , zoekt-webserver = Container/Zoekt-Webserver/toInternal cg
              }
            , sideCars = opts.additionalSideCars
            }

let Test/StatefulSet/Namespace/none =
        assert
      :   ( StatefulSet/toInternal
              (Fixtures.Config.Default with Global.namespace = None Text)
          ).namespace
        ≡ None Text

let Test/StatefulSet/Namespace/Some =
        assert
      :   ( StatefulSet/toInternal
              ( Fixtures.Config.Default
                with Global.namespace = Some Fixtures.Namespace
              )
          ).namespace
        ≡ Some Fixtures.Namespace

let Test/StatefulSet/Replicas =
        assert
      :   ( StatefulSet/toInternal
              ( Fixtures.Config.Default
                with indexed-search.StatefulSet.replicas = Fixtures.Replicas
              )
          ).replicas
        ≡ Fixtures.Replicas

let Service/IndexedSearch/toInternal
    : ∀(cg : Configuration/global.Type) → Configuration/internal/service/indexed-search
    = λ(cg : Configuration/global.Type) → { namespace = cg.Global.namespace }

let Test/Service/IndexedSearch/Namespace/none =
        assert
      :   ( Service/IndexedSearch/toInternal
              (Fixtures.Config.Default with Global.namespace = None Text)
          ).namespace
        ≡ None Text

let Test/Service/IndexedSearch/Namespace/Some =
        assert
      :   ( Service/IndexedSearch/toInternal
              ( Fixtures.Config.Default
                with Global.namespace = Some Fixtures.Namespace
              )
          ).namespace
        ≡ Some Fixtures.Namespace

let Service/IndexedSearchIndexer/toInternal
    : ∀(cg : Configuration/global.Type) → Configuration/internal/service/indexed-search-indexer
    = λ(cg : Configuration/global.Type) → { namespace = cg.Global.namespace }

let Test/Service/IndexedSearchIndexer/Namespace/none =
        assert
      :   ( Service/IndexedSearchIndexer/toInternal
              (Fixtures.Config.Default with Global.namespace = None Text)
          ).namespace
        ≡ None Text

let Test/Service/IndexedSearchIndexer/Namespace/Some =
        assert
      :   ( Service/IndexedSearchIndexer/toInternal
              ( Fixtures.Config.Default
                with Global.namespace = Some Fixtures.Namespace
              )
          ).namespace
        ≡ Some Fixtures.Namespace

let PersistentVolumes/Internal = ./internal/persistentvolumes.dhall

let PersistentVolumes/toInternal
    : ∀(cg : Configuration/global.Type) → PersistentVolumes/Internal
    = λ(cg : Configuration/global.Type) →
        { namespace = cg.Global.namespace
        , replicas = cg.indexed-search.StatefulSet.replicas
        , pvg = cg.indexed-search.PersistentVolumeGenerator
        }

let Test/PersistentVolumes/replicas =
        assert
      :   ( PersistentVolumes/toInternal
              ( Fixtures.Config.Default
                with indexed-search.StatefulSet.replicas = Fixtures.Replicas
              )
          ).replicas
        ≡ Fixtures.Replicas

let toInternal
    : ∀(cg : Configuration/global.Type) → Configuration/internal
    = λ(cg : Configuration/global.Type) →
        { StatefulSet.indexed-search = StatefulSet/toInternal cg
        , Service.indexed-search = Service/IndexedSearch/toInternal cg
        , Service.indexed-search-indexer
          = Service/IndexedSearchIndexer/toInternal cg
        , persistentvolumes = PersistentVolumes/toInternal cg
        }

in  toInternal
