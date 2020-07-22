
This repository holds kubernetes configuration to host a libra network and some example move modules. 

Docker images for kubernetes were created using https://github.com/pariweshsubedi/libra-bbchain-port and example of Libra modules for document verification can be found under : https://github.com/pariweshsubedi/libra-bbchain-port/tree/master/testsuite/bbchain-test/src/modules/move

# Starting a Libra network using kubernetes

Configuration defined for kubernetes network uses docker images from [docker repository](https://hub.docker.com/r/pariwesh/thesis/tags). Here, different libra components are present under the same docker repository but tagged such that it represents different components for the libra network. These images are used as a part of kubernetes configuration. 

All the configuration and scripts relating to starting your own kubernetes network resides under `kube/libra/` directory. Among them two important ones are:

- `start.sh` - starts core validator node and monitoring nodes(prometheis, grafana) in a kubernetes network with libra validators. Validator templates are defined in [kube/libra/template/validator.tmpl.yaml](https://github.com/pariweshsubedi/libra-kubernetes-document-verification/blob/master/kube/libra/template/validator.tmpl.yaml) and can be used to configure network variables such as validator seeds, docker images for validators/safetyrules/initialization container, container ports, etc.
- `stop.sh` - stops all nodes started by the `start.sh` script

### Docker images and their organization
Libra components used here exists under same docker repository but under different tags:
- **validator** : pariwesh/thesis:libra_validator_dynamic-2.0.1
- **container initialization** : pariwesh/thesis:libra_init-2.0.0
- **safety rules** : pariwesh/thesis:libra_safety_rules-2.0.0

These can be replaced by any other docker images by modifying images in validator configuration template file. https://github.com/pariweshsubedi/libra-kubernetes-document-verification/blob/master/kube/libra/template/validator.tmpl.yaml.


# Other Development scripts
* `transport.sh` - Move intermediate language(`*.mvir`) defined modules and requires them to be moved to `libra/language/functional_tests/tests/testsuite/modules`. It works by moving modules and scripts to `language/functional_tests/tests/testsuite/modules/custom_modules` and triggering move test.
* `test_move.sh` - Move programs(`*.move`) also needs to be in a defined directory for the tests to work. This script moves any files in `modules/move/` directory to `<libra-installation-dir>/language//move-lang/tests/functional/custom_modules` where move verifier can test the files from.

# Note:
- the default network doesn't host a faucet server but the seed values from validators can be used with clients to mint Libra coins into Libra accounts.
- libra has to be setup according to [libra's documentation](https://github.com/pariweshsubedi/libra-bbchain-port). Current version requires it to be setup inside `~/libra` directory
