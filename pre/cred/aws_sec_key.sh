#!/bin/sh


AWS_KEY_ID=`echo $AWS_ACCESS_KEY_ID`
AWS_SECRET=`echo $AWS_SECRET_ACCESS_KEY`

cat << EOF
    <org.jenkinsci.plugins.plaincredentials.impl.StringCredentialsImpl plugin="plain-credentials@1.4">
      <scope>GLOBAL</scope>
      <id>jenkins_aws_secret_key</id>
      <description></description>
      <secret>$AWS_SECRET</secret>
    </org.jenkinsci.plugins.plaincredentials.impl.StringCredentialsImpl>
EOF