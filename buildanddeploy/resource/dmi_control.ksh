#!/bin/ksh
# Copyright (c) 2011-2012 Ericsson AB.
# All rights reserved.

# ===========================================================
#                       dmi_control.ksh
# ===========================================================
# Description:
#   Provide access to basic DMI server
#   administrative operations


CheckNonEmptyValue "PACKET_HOME environment variable not set" "$PACKET_HOME"
CheckPathIsDirectory "$PACKET_HOME" "$APPLICATION_NAME installation directory"

DMI_PID_FILE="`GetDMILogDirectory`/dmi.pid"
PROCMAN_STATUS_FILE="$SCRIPT_HOME/dmi/data/procman_status.properties"
NSM_STATUS="NSMStarted"


# UpdateProcmanStatus
#
# Description:
#   Update keyword's value in procman_status.properties
# Arguments:
#   1) Keyword
#	2) Value	
# Return value:
#   <none>
UpdateProcmanStatus ()
{
  typeset +x propertyName=$1
  typeset +x propertyValue=$2

  if [ ! -f "$PROCMAN_STATUS_FILE" ]
  then
    touch "$PROCMAN_STATUS_FILE"
  fi

  typeset +x propertyHeader="$propertyName="
  typeset +x alreadyInFile=`fgrep $propertyHeader $PROCMAN_STATUS_FILE`
  if [ -z "$alreadyInFile" ]
  then
    echo "$propertyHeader" >> $PROCMAN_STATUS_FILE
  fi

  ReplacePropertyInFile "$propertyHeader" "$PROCMAN_STATUS_FILE" "$propertyValue"
  chmod 600 $PROCMAN_STATUS_FILE

}

# GetDMIServerProcessID
#
# Description:
#   Retrieve the DMI server's UNIX process ID
# Arguments:
#   <none>
# Return value:
#   - UNIX process ID of the DMI server (JVM)
#     if the DMI server is running
#   - <none>
#     otherwise
GetDMIServerProcessID ()
{
  typeset +x dmiProcess=""
  if [ -f "$DMI_PID_FILE" ] && [ -r "$DMI_PID_FILE" ] && \
     [ -s "$DMI_PID_FILE" ]
  then
    dmiProcess=`head -n 1 $DMI_PID_FILE`
  fi
  echo "$dmiProcess"
}

# IsDMIServerRunning
#
# Description:
#   Check if the DMI server is currently running
# Arguments:
#   <none>
# Return value:
#   - "true"
#      if the DMI server is running
#   - "false"
#      if the DMI server is not running
IsDMIServerRunning ()
{
  typeset +x dmiProcess=`GetDMIServerProcessID`
  typeset +x dmiStillRunning="$FALSE"
  if [ -n "$dmiProcess" ]
  then
    dmiStillRunning=`IsProcessStillRunning $dmiProcess`
  fi

  echo "$dmiStillRunning"
}

# TODO: Move to DMI server Operations script
# IsDMIServerFullyStarted
#
# Description:
#   Determine if the DMI server is fully started.
# Arguments:
#   1) Epoch time of when the DMI server was initially started
# Return value:
#   - "true"
#      if the DMI server is fully started
#   - "false"
#      if the DMI server is not fully started
IsDMIServerFullyStarted ()
{
  # We assume that the application server is running
  typeset +x dmiServerStartEpochTime=$1
  CheckNonEmptyValue "Invalid application server start epoch time" \
                     "$dmiServerStartEpochTime"

  typeset +x dmiServerProcessID=`GetDMIServerProcessID`
  if [ -n "$dmiServerProcessID" ]
  then
    typeset +x dmiServerLogFile="`GetDMILogDirectory`/soesa_server_0.log"
    if [ -f "$dmiServerLogFile" ] && [ -r "$dmiServerLogFile" ] && \
       [ -s "$dmiServerLogFile" ]
    then
      typeset +x serverStartedTimeStamp=`grep "Server\.ApplicationMain - Server Ready\!" $dmiServerLogFile 2>/dev/null`
      if [ -n "$serverStartedTimeStamp" ]
      then
        serverStartedTimeStamp=`echo $serverStartedTimeStamp | awk '{print $1 FS $2}'`
        # Convert to epoch time
        serverStartedTimeStamp=`date -d "$serverStartedTimeStamp" +%s`
        if [ $serverStartedTimeStamp -gt $dmiServerStartEpochTime ]
        then
          # Timestamp of server started message is later than the time when
          # the DMI server start command was run; thus, the application
          # server is fully started
          echo "$TRUE"
        else
          # Timestamp of server started message was from a previous run
          # (so it is stale); this means that the DMI server processes are still
          # not fully started.
          echo "$FALSE"
        fi
      else
        # No server started message in the log file
        # so the DMI server processes are not fully started
        echo "$FALSE"
      fi
    else
      # DMI log file is empty; so the DMI server processes are not fully started
      echo "$FALSE"
    fi
  else
    # DMI server is not running
    echo "$FALSE"
  fi
}

# StopDMIServer
#
# Description:
#   Stop the DMI server by killing all Java processes in the same process group
#   as the main DMI server process
# Arguments:
#   <none>
# Return value:
#   <none>
StopDMIServer ()
{
  typeset +x dmiServerRunning=`IsDMIServerRunning`
  if [ "$dmiServerRunning" = "$TRUE" ]
  then
    typeset +x dmiProcess=`GetDMIServerProcessID`
    typeset +x dmiProcessGroup=`ps -j -u $AUTHORIZED_USER | awk '$1=="'"$dmiProcess"'" {print $2}'`
    kill -s TERM $dmiProcess >/dev/null 2>&1
    echo "Stopping $APPLICATION_NAME DMI server \c"

    # TODO: Should replace the generation of the procman.log filepath
    # TODO: with a function from a new DMI operations script
    typeset +x currentLogFile="`GetDMILogDirectory`/procman.log"

    trap 'echo "Check $currentLogFile for DMI server log details."; exit 1' \
         HUP INT QUIT TERM

    dmiServerRunning=`IsDMIServerRunning`
    # Timeout value is 2 minutes
    typeset +x timeoutValue="120"
    # Display a busy cursor while the Packet DMI server shuts down
    until [ "$dmiServerRunning" = "$FALSE" ] || [ $timeoutValue -le 0 ]
    do
      typeset +x loopStartTime=`date +%s`
      dmiServerRunning=`IsDMIServerRunning`
      ShowWaitCursor 0.6
      typeset +x loopEndTime=`date +%s`
      typeset +x loopDuration=`expr $loopEndTime - $loopStartTime`
      timeoutValue=`expr $timeoutValue - $loopDuration`
    done
    echo ""
    trap '' HUP INT QUIT TERM
    if [ "$dmiServerRunning" = "$TRUE" ] && [ $timeoutValue -le 0 ]
    then
      echo "$APPLICATION_NAME DMI server is taking too long to stop"
    else
      echo "$APPLICATION_NAME DMI server stopped"
    fi
    typeset +x remainingProcesses=`pgrep -g $dmiProcessGroup java`
    # TODO: Refactor this into smaller functions and create a common trap function
    if [ -n "$remainingProcesses" ]
    then
      echo "Cleaning up extraneous $APPLICATION_NAME DMI server processes \c"
      # Kill all the Java processes in the same process group as the
      # DMI process manager process
      pkill -TERM -g $dmiProcessGroup java >/dev/null 2>&1
      timeoutValue="60"
      until [ -z "$remainingProcesses" ] || [ $timeoutValue -le 0 ]
      do
        typeset +x loopStartTime=`date +%s`
        trap 'kill -s KILL $remainingProcesses; echo "Check $currentLogFile for DMI server log details."; exit 1' \
             HUP INT QUIT TERM
        ShowWaitCursor 0.6
        remainingProcesses=`pgrep -g $dmiProcessGroup java`
        typeset +x loopEndTime=`date +%s`
        typeset +x loopDuration=`expr $loopEndTime - $loopStartTime`
        timeoutValue=`expr $timeoutValue - $loopDuration`
      done
      echo ""
      trap '' HUP INT QUIT TERM
      # Do a hard-kill of all remaining DMI java processes
      if [ -n "$remainingProcesses" ] && [ $timeoutValue -le 0 ]
      then
        kill -s KILL $remainingProcesses >/dev/null 2>&1
      fi
    fi
    rm -f $DMI_PID_FILE
    rm -f `GetDMILogDirectory`/soesa_initialRestart.log
    if [ -n "$currentLogFile" ]
    then
      echo "Check $currentLogFile for DMI server log details."
    fi
  fi

  # TODO: Add mv36 simulator data logic from ESA server script
}

# StartDMIServer
#
# Description:
#   Start the DMI server
# Arguments:
#   <none>
# Return value:
#   <none>
StartDMIServer ()
{
  typeset +x dmiServerRunning=`IsDMIServerRunning`
  if [ "$dmiServerRunning" = "$TRUE" ]
  then
    echo "$APPLICATION_NAME DMI server is already running."
    return
  fi
  

  # reset Process Manager Status before start it
  UpdateProcmanStatus "$NSM_STATUS" "$FALSE"

  typeset +x corbaNameServicePort="9000"
  typeset +x dmiHome=`GetDMIHome`
  typeset +x dmiLogDir=`GetDMILogDirectory`
  typeset +x thisHost=`hostname -f`

  set -A dmiClasspathJars "$dmiHome/ext/log4j-1.2.16.jar" \
                          "$dmiHome/ext/jacorb.jar" \
                          "$dmiHome/ext/idl.jar" \
                          "$dmiHome/ext/logkit-1.2.jar" \
                          "$dmiHome/ext/avalon-framework-4.1.5.jar" \
                          "$dmiHome/ext/antlr-2.7.2.jar" \
                          "$dmiHome/ext/postgresql.jar" \
                          "$dmiHome/lib/procman.jar" \
                          "$dmiHome/lib/common.jar" \
                          "$dmiHome/lib/alarmRmi.jar" \
                          "$dmiHome/lib/pdmRmi.jar" \
                          "$dmiHome/lib/neaccessRmi.jar" \
                          "$dmiHome/lib/mplstpRmi.jar" \
                          "$dmiHome/lib/pdm.jar" \
                          "$dmiHome/lib/cccserver.jar" \
                          "$dmiHome/lib/nlstext.jar" \
                          "$dmiHome/lib/schemamapping.jar"
  CheckClasspathJars "$APPLICATION_NAME Java binary file" ${dmiClasspathJars[@]}
  typeset +x dmiClasspath=`GenerateClasspath ${dmiClasspathJars[@]}`
  unset dmiClasspathJars
  CheckNonEmptyValue "$APPLICATION_NAME DMI server classpath" "$dmiClasspath"

  typeset +x loggingPropertiesFile="$dmiHome/data/procman_jacorb.properties"
  CheckFileIsReadable "$loggingPropertiesFile" \
                      "Process manager logging properties file"

  if [ ! -d "$dmiLogDir" ]
  then
    mkdir -p $dmiLogDir
  fi
  typeset +x dmiServerStartTime=`date +%s`
  nohup ${JAVA_HOME}/bin/java \
        -client -Xmx256m \
        -Dproc.name=procman \
        -Dccc.home=$dmiHome -Dccc.install=$dmiHome -Dccc.log.dir=$dmiLogDir \
        -Dlog.file=$dmiLogDir/procman.log -cp $dmiClasspath \
        -Dorg.omg.CORBA.ORBClass=org.jacorb.orb.ORB \
        -Dorg.omg.CORBA.ORBSingletonClass=org.jacorb.orb.ORBSingleton \
        -DORBInitRef.NameService=corbaloc:iiop:${thisHost}:${corbaNameServicePort}/NameService \
        -Dcustom.props=$loggingPropertiesFile \
        -Dns.addr=$thisHost \
        -Dns.port=$corbaNameServicePort \
        -Ddb.addr=$thisHost \
        -Ddb.port=${DB_PORT} \
        -Dserver.instances.minimum=1 \
        -Ddbserver=${thisHost}:${DB_PORT} \
-Djvmargs.debug.arg1=-Xdebug \
    -Djvmargs.debug.arg2=-Xnoagent \
    -Djvmargs.debug.arg3=-Djava.compiler=NONE \
    -Djvmargs.debug.neaccess="-Xrunjdwp:transport=dt_socket,address=8001,server=y,suspend=n" \
    -Djvmargs.debug.q38="-Xrunjdwp:transport=dt_socket,address=8002,server=y,suspend=n" \
    -Djvmargs.debug.nameservice="-Xrunjdwp:transport=dt_socket,address=8003,server=y,suspend=n" \
    -Djvmargs.debug.broker="-Xrunjdwp:transport=dt_socket,address=8004,server=y,suspend=n" \
    -Djvmargs.debug.alarm="-Xrunjdwp:transport=dt_socket,address=8005,server=y,suspend=n" \
    -Djvmargs.debug.server="-Xrunjdwp:transport=dt_socket,address=8006,server=y,suspend=n" \
    -Djvmargs.debug.pdm="-Xrunjdwp:transport=dt_socket,address=8007,server=y,suspend=n" \
        com.marconi.CCC.ProcessManager.Main \
        1>> $dmiLogDir/soesa_initialRestart.log \
        2>> $dmiLogDir/soesa_initialRestart.log &
  typeset +x dmiProcManPid=$!
  echo "$dmiProcManPid" > $DMI_PID_FILE

  typeset +x dmiServerLogFile="$dmiLogDir/procman.log"
  echo "Starting $APPLICATION_NAME DMI server \c"

  trap 'echo "Check $dmiServerLogFile for DMI server log details."; exit 1' \
       HUP INT QUIT TERM
  typeset +x dmiServerFullyStarted="$FALSE"
  typeset +x nameServicePortOpen=""
  # Timeout value is 5 minutes
  typeset +x timeoutValue="300"
  # Display a busy cursor while the Packet DMI server starts up
  until [ $timeoutValue -le 0 ] || \
        [ "$dmiServerFullyStarted" = "$TRUE" -a "$nameServicePortOpen" = "$TRUE" ]
  do
    typeset +x loopStartTime=`date +%s`
    dmiServerFullyStarted=`IsDMIServerFullyStarted $dmiServerStartTime`
    nameServicePortOpen=`IsLocalPortOpen $corbaNameServicePort`
    ShowWaitCursor 0.6
    typeset +x loopEndTime=`date +%s`
    typeset +x loopDuration=`expr $loopEndTime - $loopStartTime`
    timeoutValue=`expr $timeoutValue - $loopDuration`
  done
  echo ""
  if [ "$dmiServerFullyStarted" = "$FALSE" -o "$nameServicePortOpen" = "$FALSE" ] && \
     [ $timeoutValue -le 0 ]
  then
    ExitWithError 1 "$APPLICATION_NAME DMI server is taking too long to start"
  else
    echo "$APPLICATION_NAME DMI server started"
  fi
  trap '' HUP INT QUIT TERM
  echo "Check $dmiServerLogFile for DMI server log details."

  # TODO: Add mv36 simulator data logic from ESA server script
}

# GetDMIServerStatus
#
# Description:
#   Displays run-time status information of the DMI server
# Arguments:
#   <none>
# Return value:
#   Run-time status information of the DMI server
GetDMIServerStatus ()
{
  typeset +x dmiProcess=`GetDMIServerProcessID`
  if [ -n "$dmiProcess" ]
  then
    typeset +x dmiStillRunning=`IsProcessStillRunning $dmiProcess`
    if [ "$dmiStillRunning" = "$TRUE" ]
    then
      echo "$APPLICATION_NAME DMI server is running with process ID: $dmiProcess"
    else
      echo "$APPLICATION_NAME DMI server is not running"
    fi
  else
    echo "$APPLICATION_NAME DMI server is not running"
  fi
  echo ""
}

