#!/usr/bin/env bash

echo "####################################################################################################"
echo "##### Installing guardian sw..."
echo "####################################################################################################"

ros_version=${1:-"$(rosversion -d)"}
default_branch_name=${2:-"hydro-devel"}
default_arm_branch_name=${3:-"hydro_dev"}
catkin_folder=${4:-"$HOME/catkin_ws"}

source /opt/ros/${ros_version}/setup.bash

cd "${catkin_folder}/src"
if [ $? -ne 0 ]; then
	mkdir -p "${catkin_folder}/src"
	cd "${catkin_folder}/src"
	catkin_init_workspace
fi

wstool init

function clone_git_repository() {
	repository_host=${1:?'Must specify repository host'}
	repository_name=${2:?'Must specify repository name'}
	branch=${3:?'Must specify repository branch'}
	ls "${repository_name}" &> /dev/null
	if [ $? -ne 0 ]; then
		echo -e "\n"
		echo "-------------------------------------------"
		echo "==> Cloning ${repository_name} (branch: ${branch})"
		git clone -b ${branch} "${repository_host}/${repository_name}.git"
		wstool set ${repository_name} "${repository_host}/${repository_name}.git" --git -y
	else
		echo -e "\n"
		echo "-------------------------------------------"
		echo "==> Updating ${repository_name}"
		cd ${repository_name}
		git pull
		cd ..
	fi
}


echo -e "\n\n"
echo "===================================================================="
echo "=== Cloning RobotnikAutomation packages"
clone_git_repository "https://github.com/RobotnikAutomation" "rly_08" "${default_branch_name}"


echo -e "\n\n"
echo "===================================================================="
echo "=== Cloning inesc-tec-robotics packages"
clone_git_repository "https://github.com/inesc-tec-robotics" "crob_gazebo_models" "master"
clone_git_repository "https://github.com/inesc-tec-robotics" "gazebo_projection_mapping" "${default_branch_name}"
clone_git_repository "https://github.com/inesc-tec-robotics" "guardian_config" "${default_branch_name}"
clone_git_repository "https://github.com/inesc-tec-robotics" "guardian_ros_pkg" "${default_branch_name}"
clone_git_repository "https://github.com/inesc-tec-robotics" "robotnik_tilt_laser" "${default_branch_name}"
clone_git_repository "https://github.com/inesc-tec-robotics" "um7" "indigo-devel"


ls "${catkin_folder}/src/robotnik_tilt_laser/external/dxl_sdk_2.0_for_linux/build" &> /dev/null
if [ $? -ne 0 ]; then
	echo -e "\n\n"
	echo "===================================================================="
	echo "=== Building dxl sdk"
	cd robotnik_tilt_laser/external/dxl_sdk_2.0_for_linux/src
	make
	sudo make install
	cd ${catkin_folder}/src
fi


echo -e "\n\n"
echo "===================================================================="
echo "=== Cloning localization packages"
clone_git_repository "https://github.com/inesc-tec-robotics" "robot_localization_tools" "${default_branch_name}"
clone_git_repository "https://github.com/inesc-tec-robotics" "dynamic_robot_localization" "${default_branch_name}"
${catkin_folder}/src/dynamic_robot_localization/install/install.bash


echo -e "\n\n"
echo "===================================================================="
echo "=== Cloning mission control packages"
clone_git_repository "https://github.com/inesc-tec-robotics" "carlos_mission_control" "master"
hg clone https://bitbucket.org/ragroup/common/src


echo -e "\n\n"
echo "===================================================================="
echo "=== Cloning navigation packages"
clone_git_repository "https://github.com/inesc-tec-robotics" "carlos_motion" "master"
clone_git_repository "https://github.com/inesc-tec-robotics" "carlos_initial_goals" "master"

echo -e "\n\n"
echo "===================================================================="
echo "=== Cloning schunk arm packages"
clone_git_repository "https://github.com/ipa320/ipa_canopen" "ipa_canopen" "${default_arm_branch_name}"
clone_git_repository "https://github.com/ipa320/schunk_modular_robotics" "schunk_modular_robotics" "${default_arm_branch_name}"
clone_git_repository "https://github.com/ipa320/schunk_robots" "schunk_robots" "${default_arm_branch_name}"


echo -e "\n\n"
echo "===================================================================="
echo "=== Downloading remaining schunk arm drivers / packages"

#wget http://mozco.fe.up.pt/redmine/attachments/download/2055/lwa4p_moveit_config_141111.tar.bz2
#wget http://mozco.fe.up.pt/redmine/attachments/download/2056/moveit_ik_plugin_lwa4p_141111.tar.bz2
#tar xvjf lwa4p_moveit_config_141111.tar.bz2
#tar xvjf moveit_ik_plugin_lwa4p_141111.tar.bz2
#rm lwa4p_moveit_config_141111.tar.bz2
#rm moveit_ik_plugin_lwa4p_141111.tar.bz2


cd ~
mkdir drivers
cd drivers
wget http://www.peak-system.com/fileadmin/media/linux/files/peak-linux-driver-7.9.tar.gz
tar zxvf peak-linux-driver-7.9.tar.gz
cd peak-linux-driver-7.9/driver
make NET=NO_NETDEV_SUPPORT
sudo make install

cd ~
rm -rf drivers

cd "${catkin_folder}/src"


echo -e "\n\n"
echo "----------------------------------------------------------------------------------------------------"
echo ">>>>> Cloning git repositories finished"
echo ">>>>> For updating each git repository use: git pull"
echo ">>>>> For updating all repositories use:"
echo ">>>>> cd ${catkin_folder}/src"
echo ">>>>> wstool status"
echo ">>>>> Commit or stash modified files"
echo ">>>>> wstool update"
echo "----------------------------------------------------------------------------------------------------"


echo -e "\n\n"
echo "===================================================================="
echo "=== Installing packages dependencies"
echo -e "\n"

cd ${catkin_folder}
rosdep update
rosdep check --from-paths src --ignore-src --rosdistro=${ros_version}
rosdep install --from-paths src --ignore-src --rosdistro=${ros_version} -y

echo -e "\n\n"
echo "===================================================================="
echo "=== Remaining dependencies that must be manually checked"
rosdep check --from-paths src --ignore-src --rosdistro=${ros_version}


echo -e "\n\n"
echo "===================================================================="
echo "=== Building catkin workspace"
cd "${catkin_folder}"

find ./src -name "*.bash" -exec chmod +x {} \;
find ./src -name "*.cfg" -exec chmod +x {} \;
find ./src -name "*.sh" -exec chmod +x {} \;


catkin_make


echo -e "\n\n"
echo "####################################################################################################"
echo "##### Finished"
echo "####################################################################################################"
