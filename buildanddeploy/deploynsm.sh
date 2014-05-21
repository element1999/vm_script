#!/bin/bash
cd /opt/ericsson/iptnms/jboss-as-7.1.0.Final/standalone/deployments
rm -rf *
cd $proj
cd nsm
antnsm
#cp $proj/nsm/dist/nsm.ear /opt/ericsson/iptnms/jboss-as-7.1.0.Final/standalone/deployments/
#cp $proj/nsm/dist/nsm-faultcorrelation-server.ear /opt/ericsson/iptnms/jboss-as-7.1.0.Final/standalone/deployments/
