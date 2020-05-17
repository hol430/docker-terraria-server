#!/bin/bash
LAT_V="${GAME_VERSION//.}"
CUR_V="$(find $DATA_DIR -name terraria-* | cut -d '-' -f 2,3)"
if [ "$LAT_V" -lt "1402" ]; then
	DL_LINK="http://terraria.org/server/"
else
	if [ "$LAT_V" == "1402" ]; then
		DL_LINK="https://terraria.org/system/dedicated_servers/archives/000/000/036/original/"
		DL_TOP="?1589675482"
fi

if [ -f ${SERVER_DIR}/terraria-server-$LAT_V.zip ]; then
	if [ ${DATA_DIR}/terraria-$CUR_V ]; then
    	rm ${DATA_DIR}/terraria-$CUR_V
	fi
    cd ${SERVER_DIR}
	echo "---Found Terraria v${GAME_VERSION} locally, installing---"
	unzip -q ${SERVER_DIR}/terraria-server-$LAT_V.zip
    mv ${SERVER_DIR}/$LAT_V/Linux/* ${SERVER_DIR}
    rm -R ${SERVER_DIR}/$LAT_V
    rm -R ${SERVER_DIR}/terraria-server-$LAT_V.zip
    touch ${DATA_DIR}/terraria-$LAT_V
else
	echo "---Version Check---"
	if [ ! -d "${SERVER_DIR}/lib" ]; then
    	echo "---Terraria not found, downloading!---"
    	cd ${SERVER_DIR}
    	if wget -q -nc --show-progress --progress=bar:force:noscroll -O terraria-server-$LAT_V.zip "$DL_LINK"terraria-server-$LAT_V.zip"$DL_TOP" ; then
			echo "---Successfully downloaded Terraria v${GAME_VERSION}---"
		else
			echo "------------------------------------------------------------------------------"
			echo "---Can't download Terraria v${GAME_VERSION}, putting server into sleep mode---"
			echo "------You can also place the Terraria Server zip in the main directory to-----"
			echo "---install it manually, don't forget to set it to the right version in your---"
			echo "----------Docker configuration, otherwise it won't find the zip file!---------"
			echo "------------------------------------------------------------------------------"
		fi
	    unzip -q ${SERVER_DIR}/terraria-server-$LAT_V.zip
	    mv ${SERVER_DIR}/$LAT_V/Linux/* ${SERVER_DIR}
	    rm -R ${SERVER_DIR}/$LAT_V
	    rm -R ${SERVER_DIR}/terraria-server-$LAT_V.zip
	    touch ${DATA_DIR}/terraria-$LAT_V
	elif [ "$LAT_V" != "$CUR_V" ]; then
	    echo "---Newer version found, installing!---"
	    rm ${DATA_DIR}/terraria-$CUR_V
	    cd ${SERVER_DIR}
	    if wget -q -nc --show-progress --progress=bar:force:noscroll -O terraria-server-$LAT_V.zip "$DL_LINK"terraria-server-$LAT_V.zip"$DL_TOP" ; then
			echo "---Successfully downloaded Terraria v${GAME_VERSION}---"
		else
			echo "------------------------------------------------------------------------------"
			echo "---Can't download Terraria v${GAME_VERSION}, putting server into sleep mode---"
			echo "------You can also place the Terraria Server zip in the main directory to-----"
			echo "---install it manually, don't forget to set it to the right version in your---"
			echo "----------Docker configuration, otherwise it won't find the zip file!---------"
			echo "------------------------------------------------------------------------------"
		fi
	    unzip -q ${SERVER_DIR}/terraria-server-$LAT_V.zip
	    mv ${SERVER_DIR}/$LAT_V/Linux/* ${SERVER_DIR}
	    rm -R ${SERVER_DIR}/$LAT_V
	    rm -R ${SERVER_DIR}/terraria-server-$LAT_V.zip
	    touch ${DATA_DIR}/terraria-$LAT_V
	elif [ "$LAT_V" == "$CUR_V" ]; then
	    echo "---Terraria Version up-to-date---"
	else
  	echo "---Something went wrong, putting server in sleep mode---"
  	sleep infinity
	fi
fi

echo "---Prepare Server---"
if [ ! -f "${SERVER_DIR}/serverconfig.txt" ]; then
  echo "---No serverconfig.txt found, downloading...---"
  cd ${SERVER_DIR}
  wget -qi serverconfig.txt "https://raw.githubusercontent.com/ich777/docker-terraria-server/master/config/serverconfig.txt"
fi
echo "---Server ready---"
chmod -R ${DATA_PERM} ${DATA_DIR}
echo "---Checking for old logs---"
find ${SERVER_DIR} -name "masterLog.*" -exec rm -f {} \;

echo "---Start Server---"
cd ${SERVER_DIR}
screen -S Terraria -L -Logfile ${SERVER_DIR}/masterLog.0 -d -m ${SERVER_DIR}/TerrariaServer.bin.x86_64 ${GAME_PARAMS}
sleep 2
tail -f ${SERVER_DIR}/masterLog.0