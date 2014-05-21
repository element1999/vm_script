export PATH=$cwd/provided/DXutils/bin:$PATH
export PATH=/local/scratch/ESSIM/essim/bin:$PATH
export ESSIM_LIB=/local/scratch/ESSIM_LIB
export ESSIM_WORKSPACE=/local/scratch/cbaExDir/essimws
export PATH=/opt/VirtualBox/bin:$PATH
export DX_SYSROOT_X86_64=$cwd/provided/LINUX_API
export DX_CUSTOM_RPATH=$cwd/provided/coremw_sdk/lib64/opensaf
export INCLIBPATH=$cwd/provided/coremw_sdk
export PATH=$cwd/provided/dxcpp/compilers/bin:$PATH
export CLEARCASE_HOME=/opt/ibm/RationalSDLC/clearcase/linux_x86/
export PATH=$PATH:$CLEARCASE_HOME/bin

export ANT_HOME=/usr/local/ant
export PATH=$PATH:$ANT_HOME/bin

export JAVA_HOME=/usr/java/jdk1.7.0_25
#export JAVA_HOME=/usr/java/jdk1.6.45/jdk1.6.0_45
export PATH=$JAVA_HOME/bin:$PATH
export PATH=/root/tool/db:$PATH
export JRE_HOME=$JAVA_HOME/jre

export CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar:/vobs/oss/CCC/dev/modules/nsm/lib/*.jar:./nsm/lib/*.jar:$JRE_HOME/lib/
export https_proxy=https://cnbjip.mgmt.ericsson.se:8080
export http_proxy=http://cnbjip.mgmt.ericsson.se:8080 
alias grep='/usr/bin/grep -n -i --color=auto'
export PATH=/root/util:$PATH
alias ws='source ws2'
alias ct='cleartool'
export p=/root/tool/load/uninstall
export log=/opt/ericsson/iptnms/jboss-as-7.1.0.Final/standalone/log
export load=/var/tmp/IPT-NMS14.2/14A_LSV1438
export esahome=/opt/ericsson/iptnms/packet/dmi
export JBOSS_HOME=/opt/ericsson/iptnms/jboss-as-7.1.0.Final
export PACKET_HOME=/opt/ericsson/iptnms/packet
export packet=$PACKET_HOME
export SSH_ASKPASS=/usr/lib64/ssh/ssh-askpass

export boss="$JBOSS"
export proj=/mnt/git_repo/iptnms-p/dev/modules
export LANG='en_US.UTF-8'
export ANT_OPTS="-XX:-UseSplitVerifier \-Dfile.encoding=UTF8 -Dskip.signjar=true"
alias ant1="ant -Djboss.home=$JBOSS_HOME -Desa.home=$esahome"
alias antesa="ant -Djboss.home=$JBOSS_HOME -Desa.home=$esahome deploy-esa-jar"
alias antnsm="ant -Djboss.home=$JBOSS_HOME -Desa.home=$esahome bind explode"
alias initenv='source ~/.bashrc'
alias bosshome="cd $JBOSS_HOME"
alias deploynsm="/root/tool/buildanddeploy/deploynsm.sh"
alias restorensm="/root/tool/buildanddeploy/restorensmear.sh"
alias bakupnsm="/root/tool/buildanddeploy/bakupnsm.sh"
alias deployesa="/root/tool/buildanddeploy/deployesa.sh"
alias packet="cd /opt/ericsson/iptnms/packet"
alias dmilog="cd /opt/ericsson/iptnms/packet/log/dmi"
export deploydir="/opt/ericsson/iptnms/jboss-as-7.1.0.Final/standalone/deployments"
alias sublime='/root/software/"Sublime Text 2"/sublime_text'
alias p='mypath'
alias setid='/root/tool/load/bin/setid.sh -t 6700 -l 6700 -a 6700 -p 6700'
alias killall="jps | awk '{print $1}' |xargs kill -9"
alias buildanddeploy='ant build;deploynsm;deployesa'
alias cd2='cd ../..'
alias cd1='cd ..'
alias cd3='cd ../../..'
export PATH='/proj/nms/git/bin':$PATH
export LESS="-erX"
PID=`pgrep -n -u $USER gnome-session`
#if [[ $- =~ "i" ]];then
#	if [ -n "$PID" ]; then
#	    export DISPLAY=`awk 'BEGIN{FS="="; RS="\0"}  $1=="DISPLAY" {print $2; }' /proc/$PID/environ`
#	    echo "DISPLAY set to $DISPLAY"
#	else
#	    echo "Could not set DISPLAY"
#	fi
#	unset PID
#fi
export tool='/root/tool/load/bin'
alias codereview='git push origin HEAD:refs/for/rel_LSV_14A'
alias dbrestore='/mnt/tool/dbrestore'
export PATH=/usr/local/rvm/bin/:$PATH
export PATH=/opt/kdiff3-0.9.96:/opt/git1.8.5/bin:/opt/apache-ant-1.8.2/bin:$PATH
export IDEA_JDK=/opt/jdk1.7.0_25/
export PATH=/mnt/ibuild:/root/tool/buildanddeploy:$PATH
export mv36data='/opt/ericsson/mv36sim/mv36sim-0.0.0.0/mv36sim_data/EM1/persistent_store'
alias mvs='/opt/ericsson/mv36sim/mv36sim-0.0.0.0/scripts/mv36sim'
alias mvsd='cd /opt/ericsson/mv36sim/mv36sim-0.0.0.0/mv36sim_data/'
export BTRACE_HOME=/mnt/tool/btrace
export PATH=$BTRACE_HOME/bin:$PATH
alias utdc="python /mnt/tool/UTDC/UTDC/UTDC.py"
