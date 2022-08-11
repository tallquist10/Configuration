# This requires you to use SSH keys, so do that before running this script
REPOS=(
    "QTrade/CustomServices"
    "QTrade/QTradeClassic"
    "QTrade/BestEx.Scripts"
    "QTrade/BestEx.Libraries"
    "QTrade/QTradeClassic.SQLDB"
    "QTrade/Audimate"
    "QTrade/AuditCICD-Orb"
    "QTrade/ExternalMarketDataServices"
    "QTrade/docs"
    "QTrade/IAC"
    "QTrade/LFM"
    "QTrade/ForwarderServices"
    "QTrade/Templates"
    "QTrade/ExternalMarketData.Libraries"
    "QTrade/KafkaTopics"
    "QTrade/KafkaProducer"
    "QTrade/ccloud-kafka-admin-tools"
    "QTrade/BestEx.InRule"
    "QTrade/confluent_scripts"
    "Rocket-Technology-Post-Incident-Process/Incidents"
    "FinancialExecution/StreamConnection"
)

cd ~/Dev

for repo in "${REPOS[@]}"
do
    if [ ! -d "~/Dev/${repo}" ]
    then
        git clone git@git.rockfin.com:QTrade/${repo}.git
    else
        echo "${repo} has already been cloned to '~/Dev'"
    fi     
done

git clone git@git.rockfin.com:sudoers/ssm-instance-connect.git
