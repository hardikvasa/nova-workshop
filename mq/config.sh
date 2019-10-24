#!/bin/bash
cd ~/environment
echo "Installing jq..."
sudo yum install -y jq > /dev/null 2>&1
java_version=`java -version |& awk -F '"' '/version/ {print $2}'`
if [[ "$java_version" =~ .*1\.8.*  ]]; then
    echo "Java is up to date"
else 
    echo "Updating java to 1.8..."
    wget https://d3pxv6yz143wms.cloudfront.net/8.222.10.1/java-1.8.0-amazon-corretto-devel-1.8.0_222.b10-1.x86_64.rpm > /dev/null 2>&1
    sudo yum localinstall -y java-1.8.0-amazon-corretto-devel-1.8.0_222.b10-1.x86_64.rpm > /dev/null 2>&1
fi

echo "export JAVA_HOME=$(dirname $(dirname $(readlink -f $(which javac))))" >> ~/.bashrc
source ~/.bashrc

mvn_version=`mvn -version |& awk '/Apache Maven/ {print $3 }'`
if [[ "$mvn_version" =~ .*3\.6.* ]]; then
    echo "Maven is up to date"
else 
    echo "Updating maven to 3.6..."
    wget http://mirror.cc.columbia.edu/pub/software/apache/maven/maven-3/3.6.1/binaries/apache-maven-3.6.1-bin.tar.gz > /dev/null 2>&1
    tar zxvf apache-maven-3.6.1-bin.tar.gz > /dev/null 2>&1
    echo "export PATH=~/environment/apache-maven-3.6.1/bin:$PATH" >> ~/.bashrc
fi

if [[ -d ~/environment/activemq-perftest ]];
then
    echo "Maven performance tool kit exists"
else 
    echo "Installing maven performance plugin..."
    svn checkout http://svn.apache.org/repos/asf/activemq/sandbox/activemq-perftest/ activemq-perftest > /dev/null 2>&1
    sed -i 's/5.8-SNAPSHOT/5.15.9/g' ~/environment/activemq-perftest/pom.xml 
    mkdir ~/environment/activemq-perftest/reports
fi
echo "Getting broker urls..."
brokerId=`aws mq list-brokers | jq '.BrokerSummaries[] | select(.BrokerName=="WorkshopBroker") | {id:.BrokerId}' | grep "id" | cut -d '"' -f4`
url=`aws mq describe-broker --broker-id=$brokerId | jq '.BrokerInstances[].Endpoints[0]' | xargs -n 2 | awk '{ print "failover:("$1","$2")" }'`
echo "Saving broker urls..."

echo "perfurl=\"$url\"" >> ~/.bashrc; 
echo "url=\"$url\"" >> ~/.bashrc; 

echo "Accessing parameter store..."
brokerUser='brokerUser'
brokerPassword='brokerPassword123'

echo "brokerUser=\"$brokerUser\"" >> ~/.bashrc; 
echo "brokerPassword=\"$brokerPassword\"" >> ~/.bashrc; 

source ~/.bashrc

if [[ ! -z $perfurl ]]; 
then
printf "\nfactory.brokerURL=$perfurl\n" >> ~/environment/workshop/mq/openwire-producer.properties
printf "factory.userName=$brokerUser\n" >> ~/environment/workshop/mq/openwire-producer.properties
printf "factory.password=$brokerPassword\n" >> ~/environment/workshop/mq/openwire-producer.properties
printf "\nfactory.brokerURL=$perfurl\n" >> ~/environment/workshop/mq/openwire-consumer.properties
printf "factory.userName=$brokerUser\n" >> ~/environment/workshop/mq/openwire-consumer.properties
printf "factory.password=$brokerPassword\n" >> ~/environment/workshop/mq/openwire-consumer.properties
fi
echo "Done."