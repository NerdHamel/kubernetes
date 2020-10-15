#!/bin/bash
read -p "Enter HOST: " host
read -p "Enter pager duty integration api key:" apikey
read -p "Enter all the IP which you want to use as Node-exporter target. The input format will be like 'IP-1:31000', 'IP-2:31000',..,'IP-n:31000':" IP
read -p "Enter the endpoint url: " endpoint
read -p "Enter the api url: " api
host=$host
apikey=$apikey
IP=$IP
endpoint=$endpoint
api=$api


sed -i "s/<Host>/$host/g" prometheus/configmaps/alertrule.yaml
sed -i "s/<node-exporter-ip>/$IP/g" prometheus/configmaps/config-map.yaml
sed -i "s/<Host>/$host/g" alert-manager/configmap.yaml
sed -i "s/<api-key>/$apikey/g" alert-manager/configmap.yaml
sed -i "s/<endpoint-url>/$endpoint/g" grafana/configmaps/dashboard.yaml
sed -i "s/<api-url>/$api/g" grafana/configmaps/dashboard.yaml

# cp alertrule.yaml configmaps/alertrule.yaml
if [ "$host" == "localhost" ]
then 
  perl -0 -i -pe "s/<RUN_NLP_DE>((\W|\w)*?)<\/RUN_NLP_DE>//g" prometheus/configmaps/alertrule.yaml
  perl -0 -i -pe "s/<RUN_NLP_EN>((\W|\w)*?)<\/RUN_NLP_EN>//g" prometheus/configmaps/alertrule.yaml
  perl -0 -i -pe "s/<RUN_NLP_GE>((\W|\w)*?)<\/RUN_NLP_GE>//g" prometheus/configmaps/alertrule.yaml
  perl -0 -i -pe "s/<RUN_NLP_ES>((\W|\w)*?)<\/RUN_NLP_ES>//g" prometheus/configmaps/alertrule.yaml
  perl -0 -i -pe "s/<RUN_NLP_NL>((\W|\w)*?)<\/RUN_NLP_NL>//g" prometheus/configmaps/alertrule.yaml
  perl -0 -i -pe "s/<RUN_NLP_FR>((\W|\w)*?)<\/RUN_NLP_FR>//g" prometheus/configmaps/alertrule.yaml
  perl -0 -i -pe "s/<RUN_NLP_JA>((\W|\w)*?)<\/RUN_NLP_JA>//g" prometheus/configmaps/alertrule.yaml
  perl -0 -i -pe "s/<RUN_NLP_ZH>((\W|\w)*?)<\/RUN_NLP_ZH>//g" prometheus/configmaps/alertrule.yaml
  perl -0 -i -pe "s/<RUN_NLP_KO>((\W|\w)*?)<\/RUN_NLP_KO>//g" prometheus/configmaps/alertrule.yaml
  perl -0 -i -pe "s/<RUN_NLP_AR>((\W|\w)*?)<\/RUN_NLP_AR>//g" prometheus/configmaps/alertrule.yaml
  perl -0 -i -pe "s/<RUN_NLP_FI>((\W|\w)*?)<\/RUN_NLP_FI>//g" prometheus/configmaps/alertrule.yaml
  perl -0 -i -pe "s/<RUN_NLP_SV>((\W|\w)*?)<\/RUN_NLP_SV>//g" prometheus/configmaps/alertrule.yaml
fi

if [ "$host" == "app.cognigy.cloud" ] || [ "$host" == "lhg.cognigy.cloud" ]
then 
  perl -0 -i -pe "s/<RUN_NLP_GE>((\W|\w)*?)<\/RUN_NLP_GE>//g" prometheus/configmaps/alertrule.yaml
  perl -0 -i -pe "s/<RUN_NLP_ES>((\W|\w)*?)<\/RUN_NLP_ES>//g" prometheus/configmaps/alertrule.yaml
  perl -0 -i -pe "s/<RUN_NLP_NL>((\W|\w)*?)<\/RUN_NLP_NL>//g" prometheus/configmaps/alertrule.yaml
  perl -0 -i -pe "s/<RUN_NLP_FR>((\W|\w)*?)<\/RUN_NLP_FR>//g" prometheus/configmaps/alertrule.yaml
  perl -0 -i -pe "s/<RUN_NLP_JA>((\W|\w)*?)<\/RUN_NLP_JA>//g" prometheus/configmaps/alertrule.yaml
  perl -0 -i -pe "s/<RUN_NLP_ZH>((\W|\w)*?)<\/RUN_NLP_ZH>//g" prometheus/configmaps/alertrule.yaml
  perl -0 -i -pe "s/<RUN_NLP_KO>((\W|\w)*?)<\/RUN_NLP_KO>//g" prometheus/configmaps/alertrule.yaml
  perl -0 -i -pe "s/<RUN_NLP_AR>((\W|\w)*?)<\/RUN_NLP_AR>//g" prometheus/configmaps/alertrule.yaml
  perl -0 -i -pe "s/<RUN_NLP_FI>((\W|\w)*?)<\/RUN_NLP_FI>//g" prometheus/configmaps/alertrule.yaml
  perl -0 -i -pe "s/<RUN_NLP_SV>((\W|\w)*?)<\/RUN_NLP_SV>//g" prometheus/configmaps/alertrule.yaml
fi

if [ "$host" == "dev.cognigy.ai" ]
then
  perl -0 -i -pe "s/<RUN_NLP_ZH>((\W|\w)*?)<\/RUN_NLP_ZH>//g" prometheus/configmaps/alertrule.yaml
  perl -0 -i -pe "s/<RUN_NLP_FI>((\W|\w)*?)<\/RUN_NLP_FI>//g" prometheus/configmaps/alertrule.yaml
  perl -0 -i -pe "s/<RUN_NLP_SV>((\W|\w)*?)<\/RUN_NLP_SV>//g" prometheus/configmaps/alertrule.yaml
  perl -0 -i -pe "s/<RUN_NLP_JA>((\W|\w)*?)<\/RUN_NLP_JA>//g" prometheus/configmaps/alertrule.yaml
fi

if [ "$host" == "internal.cognigy.ai" ]
then
  perl -0 -i -pe "s/<RUN_NLP_ZH>((\W|\w)*?)<\/RUN_NLP_ZH>//g" prometheus/configmaps/alertrule.yaml
  perl -0 -i -pe "s/<RUN_NLP_FI>((\W|\w)*?)<\/RUN_NLP_FI>//g" prometheus/configmaps/alertrule.yaml
  perl -0 -i -pe "s/<RUN_NLP_SV>((\W|\w)*?)<\/RUN_NLP_SV>//g" prometheus/configmaps/alertrule.yaml
fi

if [ "$host" == "au-01.cognigy.ai" ]
then
  perl -0 -i -pe "s/<RUN_NLP_DE>((\W|\w)*?)<\/RUN_NLP_DE>//g" prometheus/configmaps/alertrule.yaml
  perl -0 -i -pe "s/<RUN_NLP_GE>((\W|\w)*?)<\/RUN_NLP_GE>//g" prometheus/configmaps/alertrule.yaml
  perl -0 -i -pe "s/<RUN_NLP_ES>((\W|\w)*?)<\/RUN_NLP_ES>//g" prometheus/configmaps/alertrule.yaml
  perl -0 -i -pe "s/<RUN_NLP_NL>((\W|\w)*?)<\/RUN_NLP_NL>//g" prometheus/configmaps/alertrule.yaml
  perl -0 -i -pe "s/<RUN_NLP_JA>((\W|\w)*?)<\/RUN_NLP_JA>//g" prometheus/configmaps/alertrule.yaml
  perl -0 -i -pe "s/<RUN_NLP_ZH>((\W|\w)*?)<\/RUN_NLP_ZH>//g" prometheus/configmaps/alertrule.yaml
  perl -0 -i -pe "s/<RUN_NLP_KO>((\W|\w)*?)<\/RUN_NLP_KO>//g" prometheus/configmaps/alertrule.yaml
  perl -0 -i -pe "s/<RUN_NLP_AR>((\W|\w)*?)<\/RUN_NLP_AR>//g" prometheus/configmaps/alertrule.yaml
  perl -0 -i -pe "s/<RUN_NLP_FI>((\W|\w)*?)<\/RUN_NLP_FI>//g" prometheus/configmaps/alertrule.yaml
  perl -0 -i -pe "s/<RUN_NLP_FR>((\W|\w)*?)<\/RUN_NLP_FR>//g" prometheus/configmaps/alertrule.yaml
  perl -0 -i -pe "s/<RUN_NLP_SV>((\W|\w)*?)<\/RUN_NLP_SV>//g" prometheus/configmaps/alertrule.yaml
fi

sed -i "s/<RUN_NLP_DE>//g" prometheus/configmaps/alertrule.yaml
sed -i "s/<\/RUN_NLP_DE>//g" prometheus/configmaps/alertrule.yaml
sed -i "s/<RUN_NLP_EN>//g" prometheus/configmaps/alertrule.yaml
sed -i "s/<\/RUN_NLP_EN>//g" prometheus/configmaps/alertrule.yaml
sed -i "s/<RUN_NLP_GE>//g" prometheus/configmaps/alertrule.yaml
sed -i "s/<\/RUN_NLP_GE>//g" prometheus/configmaps/alertrule.yaml
sed -i "s/<RUN_NLP_ES>//g" prometheus/configmaps/alertrule.yaml
sed -i "s/<\/RUN_NLP_ES>//g" prometheus/configmaps/alertrule.yaml
sed -i "s/<RUN_NLP_NL>//g" prometheus/configmaps/alertrule.yaml
sed -i "s/<\/RUN_NLP_NL>//g" prometheus/configmaps/alertrule.yaml
sed -i "s/<RUN_NLP_FR>//g" prometheus/configmaps/alertrule.yaml
sed -i "s/<\/RUN_NLP_FR>//g" prometheus/configmaps/alertrule.yaml
sed -i "s/<RUN_NLP_JA>//g" prometheus/configmaps/alertrule.yaml
sed -i "s/<\/RUN_NLP_JA>//g" prometheus/configmaps/alertrule.yaml
sed -i "s/<RUN_NLP_ZH>//g" prometheus/configmaps/alertrule.yaml
sed -i "s/<\/RUN_NLP_ZH>//g" prometheus/configmaps/alertrule.yaml
sed -i "s/<RUN_NLP_KO>//g" prometheus/configmaps/alertrule.yaml
sed -i "s/<\/RUN_NLP_KO>//g" prometheus/configmaps/alertrule.yaml
sed -i "s/<RUN_NLP_AR>//g" prometheus/configmaps/alertrule.yaml
sed -i "s/<\/RUN_NLP_AR>//g" prometheus/configmaps/alertrule.yaml
sed -i "s/<RUN_NLP_FI>//g" prometheus/configmaps/alertrule.yaml
sed -i "s/<\/RUN_NLP_FI>//g" prometheus/configmaps/alertrule.yaml
sed -i "s/<RUN_NLP_SV>//g" prometheus/configmaps/alertrule.yaml
sed -i "s/<\/RUN_NLP_SV>//g" prometheus/configmaps/alertrule.yaml