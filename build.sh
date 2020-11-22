#！/bin/bash
set -ex
#获取jinkins的$buildNumber，获取时间戳，获取build随机数
if [ -z ${buildNumber} ];then
    if [ -e /proc/sys/kernel/random/uuid ] && [ -r /proc/sys/kernel/random/uuid ];then
        build=`cat /proc/sys/kernel/random/uuid| cksum | cut -f1 -d" "`
    else
        build=${RANDOM}
    fi
    datetime=`date +%Y%m%d%H%M%S`
    buildNumber="${datetime}.${build}"
else
    buildNumber="${buildNumber}"
fi
#微服务名称
SERVICE_NAME=""
#包所在的项目路径
PACKAGE_PATH=""
#包名称
PACKAGE_NAME=""

#判断当前构建是否为版本构建，以及定义构建变量(包版本,包服务名称,包编译存放路径,包类型,包编译名称,包打包名称)
if [ "${isRelease}"x = "false"x ];then
    SERVICE_VERSION='1.0.0-SNAPSHOT'
	#版本号+时间戳+build随机数写入buildInfo.properties
	echo "buildVersion=${SERVICE_VERSION}.$buildNumber">buildInfo.properties
	#sed -i 's/VERSION/'${SERVICE_VERSION}.${buildNumber}'/g' appspec.yml
	#压缩包名称
	PACKAGE_TAR_PATH="${SERVICE_NAME}_${SERVICE_VERSION}.${buildNumber}"
	#执行工程编译
	workdir=$(cd $(dirname $0); pwd)
	cd $workdir
	echo "workdir is ${workdir} profile is ${profile}"	
	pwd
	#maven打包命令
	mvn clean package -Dmaven.test.skip=true -U -P${profile} -s settings.xml

elif [ "${isRelease}"x = "true"x ];then
    SERVICE_VERSION=${releaseVersion}
	#版本号+时间戳+build随机数写入buildInfo.properties
	echo "buildVersion=${SERVICE_VERSION}">buildInfo.properties
	#sed -i 's/VERSION/'${SERVICE_VERSION}'/g' appspec.yml
	#压缩包名称
	PACKAGE_TAR_PATH="${SERVICE_NAME}_${SERVICE_VERSION}"
	#执行工程编译
	workdir=$(cd $(dirname $0); pwd)
	cd $workdir
	echo "workdir is ${workdir} profile is ${profile}"
	pwd
	#Maven打包命令
    mvn clean package -Dmaven.test.skip=true -P${profile} -s settings.xml #以上为案例，请产品团队自行修改

fi


