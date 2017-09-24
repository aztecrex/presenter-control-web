# Easy Presenter - Control

Part of the demo for "Functional and Serverless on AWS"

## Continuous Delivery

The application is continually delivered using AWS CodePipeline and CodeBuild.

`buildspec.yml` contains the build specification for AWS CodeBuild.

The most recent deployment is available on the [live site](https://present.banjocreek.io).

## Build and Publish

Build is based on Node and NPM. Local versions of the Purescript compiler, build tooling (Pulp), and dependency manager (Bower) are installed as part of prep.

- install node and npm
- `npm run prep` prepare node and purescript environment
- `npm test` to run unit tests
- `./rum.sh` to run webpack dev server
- `./build.sh` to build static site; results in `./build/`
- `./publish.sh` to publish static site to origin bucket (see provisioning)

## Provisioning

The site is deployed to AWS S3 and delivered from that origin through AWS CloudFront. Provisioning templatesa are provided. Provisioning tooling is WIP

the runtime  and build facilities for the application are currently
provisioned
in the webui project. all provisioning should be moved to a separate
project eventually

