
This repository holds kubernetes configuration to host a libra network and some example move modules. 

Docker images for kubernetes were created using https://github.com/pariweshsubedi/libra-bbchain-port and example of Libra modules for document verification can be found under : https://github.com/pariweshsubedi/libra-bbchain-port/tree/master/testsuite/bbchain-test/src/modules/move

# Starting a kubernetes network

Configuration defined for kubernetes network uses docker images from [docker repository](https://hub.docker.com/r/pariwesh/thesis/tags). Here, different libra components are present under the same docker repository but tagged such that it represents different components for the libra network. These images are used as a part of kubernetes configuration. All the configuration and scripts relating to starting your own kubernetes network resides under `kube/libra/` directory. Among them two important ones are:

- `start.sh` - starts core validator node and monitoring nodes(prometheis, grafana) in a kubernetes network with libra validators. Validator templates are defined in [kube/libra/template/validator.tmpl.yaml](https://github.com/pariweshsubedi/libra-kubernetes-document-verification/blob/master/kube/libra/template/validator.tmpl.yaml) and can be used to configure network variables such as validator seeds, docker images for validators/safetyrules/initialization container, container ports, etc.
- `stop.sh` - stops all nodes started by the `start.sh` script


# Other Development scripts
`transport.sh` - libra module testing applies to `*.mvir` modules and requires them to be moved to `libra/language/functional_tests/tests/testsuite/modules`. It works by moving modules and scripts to `language/functional_tests/tests/testsuite/modules/custom_modules` and triggering move test.

# Note:
- the default network doesn't host a faucet server but the seed values from validators can be used with clients to mint Libra coins into Libra accounts.
- libra has to be setup according to [libra's documentation](https://github.com/pariweshsubedi/libra-bbchain-port). Current version requires it to be setup inside `~/libra` directory
