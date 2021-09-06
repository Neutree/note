#!/bin/bash

steamcmd_dir="$HOME/steamcmd"
install_dir="$HOME/dontstarvetogether_dedicated_server"
cluster_name="room"
dontstarve_dir="$HOME/.klei/DoNotStarveTogether"

function fail()
{
	echo Error: "$@" >&2
	exit 1
}

function check_for_file()
{
	if [ ! -e "$1" ]; then
		fail "Missing file: $1"
	fi
}

cd "$steamcmd_dir" || fail "Missing $steamcmd_dir directory!"

check_for_file "steamcmd.sh"
check_for_file "$dontstarve_dir/$cluster_name/cluster.ini"
check_for_file "$dontstarve_dir/$cluster_name/cluster_token.txt"
check_for_file "$dontstarve_dir/$cluster_name/Master/server.ini"
check_for_file "$dontstarve_dir/$cluster_name/Caves/server.ini"

echo "== Install DST and check update =="

./steamcmd.sh +force_install_dir "$install_dir" +login anonymous +app_update 343050 validate +quit

echo "== Install DST and check update complete =="

echo "== Override mods settings == "
if [[ -f $dontstarve_dir/$cluster_name/dedicated_server_mods_setup.lua ]]; then
    echo "== copy dedicated_server_mods_setup.lua =="
    cp -f $dontstarve_dir/$cluster_name/dedicated_server_mods_setup.lua $install_dir/mods/
fi
if [[ -f $dontstarve_dir/$cluster_name/modsettings.lua ]]; then
    echo "== copy modsettings.lua =="
    cp -f $dontstarve_dir/$cluster_name/modsettings.lua $install_dir/mods/
fi
echo "== Override mods settings end == "


check_for_file "$install_dir/bin64"

cd "$install_dir/bin64" || fail

run_shared=(./dontstarve_dedicated_server_nullrenderer_x64)
run_shared+=(-console)
run_shared+=(-cluster "$cluster_name")
run_shared+=(-monitor_parent_process $$)

echo "== Run DST dedicated server =="

"${run_shared[@]}" -shard Caves  | sed 's/^/Caves:  /' &
"${run_shared[@]}" -shard Master | sed 's/^/Master: /'
