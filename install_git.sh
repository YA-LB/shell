#!/bin/bash
# auth:kaliarch
# version:v1.0
# func:git 2.0.0/2.10.0/2.18.0 ��װ

# ���尲װĿ¼������־��Ϣ
. /etc/init.d/functions
[ $(id -u) != "0" ] && echo "Error: You must be root to run this script" && exit 1
export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
download_path=/tmp/tmpdir/
install_log_name=install_git.log
env_file=/etc/profile.d/git.sh
install_log_path=/var/log/appinstall/
install_path=/usr/local/
#software_config_file=${install_path}

clear
echo "##########################################"
echo "#                                        #"
echo "#   ��װ git 2.0.0/2.10.0/2.18.0         #"
echo "#                                        #"
echo "##########################################"
echo "1: Install git 2.0.0"
echo "2: Install git 2.10.0"
echo "3: Install git 2.18.0"
echo "4: EXIT"
# ѡ��װ����汾
read -p "Please input your choice:" softversion
if [ "${softversion}" == "1" ];then
        URL="https://anchnet-script.oss-cn-shanghai.aliyuncs.com/git/git-2.0.0.tar.gz"
elif [ "${softversion}" == "2" ];then
        URL="https://anchnet-script.oss-cn-shanghai.aliyuncs.com/git/git-2.10.0.tar.gz"
elif [ "${softversion}" == "3" ];then
        URL="https://anchnet-script.oss-cn-shanghai.aliyuncs.com/git/git-2.18.0.tar.gz"
elif [ "${softversion}" == "4" ];then
        echo "you choce channel!"
        exit 1;
else
        echo "input Error! Place input{1|2|3|4}"
        exit 0;
fi

# ��������,��ʽ���������,���Դ���������,�ÿո����
output_msg() {
    for msg in $*;do
        action $msg /bin/true
    done
}


# �ж������Ƿ����,��һ������ $1 Ϊ�жϵ�����,�ڶ�������Ϊ�ṩ�������yum ���������
check_yum_command() {
        output_msg "������:$1"
        hash $1 >/dev/null 2>&1
        if [ $? -eq 0 ];then
            echo "`date +%F' '%H:%M:%S` check command $1 ">>${install_log_path}${install_log_name} && return 0
        else
            yum -y install $2 >/dev/null 2>&1
        #    hash $Command || { echo "`date +%F' '%H:%M:%S` $2 is installed fail">>${install_log_path}${install_log_name} ; exit 1 }
        fi
}

# yum ��װ��������ɴ����������,�ÿո����
yum_install_software() {
	output_msg "yum ��װ���"
        yum -y install $* >/dev/null 2>${install_log_path}${install_log_name}
        if [ $? -eq 0 ];then
            echo "`date +%F' '%H:%M:%S`yum install $* ���" >>${install_log_path}${install_log_name}
        else
	    exit 1
        fi
}


# �ж�Ŀ¼�Ƿ����,����Ŀ¼����·��,���Դ�����Ŀ¼
check_dir() {
    output_msg "Ŀ¼���"
    for dirname in $*;do
        [ -d $dirname ] || mkdir -p $dirname >/dev/null 2>&1
        echo "`date +%F' '%H:%M:%S` $dirname check success!" >> ${install_log_path}${install_log_name}
    done
}

# �����ļ�����ѹ����װĿ¼,����url���ӵ�ַ
download_file() {
    output_msg "����Դ���"
    mkdir -p $download_path 
    for file in $*;do
        wget $file -c -P $download_path &> /dev/null
        if [ $? -eq 0 ];then
           echo "`date +%F' '%H:%M:%S` $file download success!">>${install_log_path}${install_log_name}
        else
           echo "`date +%F' '%H:%M:%s` $file download fail!">>${install_log_path}${install_log_name} && exit 1
        fi
    done
}


# ��ѹ�ļ�,���Դ�����ѹ���ļ�����·��,�ÿո����,��ѹ����װĿ¼
extract_file() {
   output_msg "��ѹԴ��"
   for file in $*;do
       if [ "${file##*.}" == "gz" ];then
           tar -zxf $file -C $install_path && echo "`date +%F' '%H:%M:%S` $file extrac success!,path is $install_path">>${install_log_path}${install_log_name}
       elif [ "${file##*.}" == "zip" ];then
           unzip -q $file -d $install_path && echo "`date +%F' '%H:%M:%S` $file extrac success!,path is $install_path">>${install_log_path}${install_log_name}
       else
           echo "`date +%F' '%H:%M:%S` $file type error, extrac fail!">>${install_log_path}${install_log_name} && exit 1
       fi
    done
}

# ���밲װgit,����$1 Ϊ��ѹ�������������
source_install_git() {
    output_msg "���밲װgit"
    mv ${install_path}${1} ${install_path}tmp${1}
    cd ${install_path}tmp${1} && make prefix=${install_path}git all >/dev/null 2>&1
    if [ $? -eq 0 ];then
        make prefix=${install_path}git install >/dev/null 2>&1 echo "`date +%F' '%H:%M:%S` git source install success ">>${install_log_path}${install_log_name}
    else 
       echo "`date +%F' '%H:%M:%S` git source install fail!">>${install_log_path}${install_log_name} && exit 1
    fi
}


# ���û�������,��һ������Ϊ��ӻ��������ľ���·��
config_env() {
    output_msg "������������"
    echo "export PATH=\$PATH:$1" >${env_file}
    source ${env_file} && echo "`date +%F' '%H:%M:%S` �����װ���!">> ${install_log_path}${install_log_name}

}


main() {
check_dir $install_log_path $install_path
check_yum_command wget wget
check_yum_command make make
yum_install_software curl-devel expat-devel gettext-devel openssl-devel zlib-devel gcc perl-ExtUtils-MakeMaker
download_file $URL

software_name=$(echo $URL|awk -F'/' '{print $NF}'|awk -F'.tar.gz' '{print $1}')
for filename in `ls $download_path`;do
    extract_file ${download_path}$filename
done

source_install_git ${software_name}
mv /usr/bin/git /usr/bin/git.bak

rm -fr ${download_path}
config_env ${install_path}git/bin
}

main