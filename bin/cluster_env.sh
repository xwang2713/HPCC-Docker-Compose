#!/bin/bash

SCRIPT_HOME=$(dirname $0)
. ${SCRIPT_HOME}/common

function usage()
{
 cat <<EOF
    Push environment.xml from admin node to cluster nodes
    If option -[d|D|s] provided environment.xml will be moved to
    /etc/HPCCSystems/cluster on admin node first before push
    Usage: $(basename $0) <options>  
      <options>:
      -a: app name. The default is hpcc
      -d: a directory contain environment.xml.xml in admin node
      -D: a directory contain environment.xml.xml in local host
      -s: the environment.xml is under /etc/HPCCSystems/source/ 

EOF
   exit 2
}

app_name=hpcc
copy_from_source=false
nodeDir=
hostDir=

# Process command-line parameters
while getopts "*a:d:D:hs" arg
do
   case $arg in
      a) appName=${OPTARG}
         ;;
      d) nodeDir=${OPTARG}
         ;;
      D) comp=${OPTARG}
         ;;
      s) copy_from_source=true
         ;;
      h) usage
         ;;
      ?)
         echo "Unknown option $OPTARG"
         usage
         ;;
   esac
done

cid=$(${SCRIPT_HOME}/query_cluster.sh -q id -g admin)
$DOCKER_SUDO docker exec $cid mkdir -p /etc/HPCCSystems/cluster

if [ "${copy_from_source}" = "true" ]
then
   $DOCKER_SUDO docker exec $cid cp /etc/HPCCSystems/source/environment.xml ../cluster/
   if [ $? -ne 0 ]
   then
       echo "Failed to copy environment.xml from /etc/HPCCSystems/source to ../cluster/"
       exit 1
   fi
elif [ -n "$hostDir" ]
then
   env_file=${hostDir}/environment.xml
   if [ ! -e "${env_file}" ]
   then
      echo "${env_file} doesn't exist"
      exit 1
   fi 
   $DOCKER_SUDO docker cp ${env_file} ${cid}:/etc/HPCCSystems/cluster/
   if [ $? -ne 0 ]
   then
       echo "Failed to copy environment.xml from local $hostDir to /etc/HPCCSystems/cluster/"
       exit 1
   fi
elif [ -n "$nodeDir" ]
then
   env_file=${nodeDir}/environment.xml
   $DOCKER_SUDO docker exec $cid cp $env_file /etc/HPCCSystems/cluster/
   if [ $? -ne 0 ]
   then
       echo "Failed to copy environment.xml from $nodeDir to /etc/HPCCSystems/cluster/"
       exit 1
   fi
fi

$DOCKER_SUDO docker exec $cid /opt/hpcc-tools/push_env.sh
