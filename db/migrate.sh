#!/bin/bash -xe

# As node-flywaydb is installed on this local computer it creates a hard-coded path to the flyway-bin
# eg. /Users/teemu/git_projects/munjutut/example-kubernetes-stack/my-node-bootstrap/node_modules/node-flywaydb/jlib/flyway-4.0.3/jre/bin/java
# which might be possible to rewrite without re-installing everything but this is the easiest way
npm uninstall node-flywaydb
npm install node-flywaydb
npm run db:migrate
